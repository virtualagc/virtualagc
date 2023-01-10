#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       reorganizer.py
Purpose:        This is part of the preprocessor for the "modern" HAL/S 
                compiler.  Its purpose is to reorganize the source code so 
                that the lines are delimited by the ';' end-of-statement
                characters and the column-1 special characters rather than by 
                the original newlines.
History:        2022-11-29 RSB  Created.
                2022-11-30 RSB  Working, I think.

In addition, the contents of all comments and all single-quoted strings, 
possibly including the delimiting /*, */, or ', and not including any ¬ 
characters, presumed to be encoded in ASCII 7-bit, are translated by toggling 
their 8th bit. The ¬ character is 8-bit ASCII already and so is translated to 
0x80.  The presumption is that upon eventual output by the calling program, 
these character translations will be undone.  The purpose is to insure that 
comments and quotes cannot be affected by REPLACE/BY macros or identifier 
mangling.  The double-quoted strings in the REPLACE/BY macros themselves are 
*not* protected in this manner, nor are full-line comments, because they're not 
themselves subject to macro replacements or mangling.
"""

import sys

# Translate a 7-bit ASCII string to 8-bit (with an exception for ¬, has to 
# be treated differently for the untranslate() function to work properly
# outside of string literals and comments).
Not = "¬"
translatedNot = chr(0xFF)
translatedComma = chr(0x80)
def translate(string):
    #print("T", string)
    translatedString = ""
    isInlineComment = string[:2] == "/*" and string[-2:] == "*/"
    isQuotedString = string[:1] == "'" and string[-1:] == "'"
    if isInlineComment:
        translatedString = "/*"
        string = string[2:-2]
    elif isQuotedString:
        translatedString = "'"
        string = string[1:-1]
    for c in string:
        if c == Not:
            c = translatedNot
        elif c == ",":
            c = translatedComma
        else:
            c = chr(ord(c) + 0x80)
        translatedString += c
    if isInlineComment:
        translatedString += "*/"
    elif isQuotedString:
        translatedString += "'"
    return translatedString
    
# Undo translate().
def untranslate(string):
    #print("U", string)
    translatedString = ""
    for c in string:
        if c == Not:
            pass
        elif c == translatedNot:
            c = Not
        elif c == translatedComma:
            c = ","
        else:
            o = ord(c)
            if o >= 0x80:
                c = chr(ord(c) - 0x80)
        translatedString += c
    return translatedString

# Note that E/M/S multi-line constructs must have been reduced to single 
# lines at this point. 
def reorganizer(halsSource, metadata):

    newHalsSource = []
    newMetadata = []
    outputLine = ""
    outputMeta = {}
    comment = ""
    danglingComment = False
    standAloneComment = False
    parenthesisDepths = [0]
    
    inNormal = 0
    inComment = 1
    inSingleQuote = 2
    inDoubleQuote = 3
    inSingleQuoteEscape = 4
    inDoubleQuoteEscape = 5
    inSlash = 6
    inStar = 7
    inDollar = 8
    status = inNormal
    
    for inputIndex in range(len(halsSource)):
        line = halsSource[inputIndex]
        meta = metadata[inputIndex]
        #print(line, meta, file=sys.stderr)
        
        # Check the first column of the line.  If it's not blank, immediately
        # take care of it, even if we're only partway through accumulating
        # the next source line.
        if line[:1] not in ["", " "]:
            newHalsSource.append(line)
            newMetadata.append(meta)
            continue
        
        line = line.strip()
        for key in meta:
            if key not in outputMeta:
                outputMeta[key] = meta[key]
            elif key == "errors":
                outputMeta[key] += meta[key]
        if status == inNormal and outputLine.strip() != "":
            if outputLine[-1:] != " ":
                outputLine += " "
        elif status == inComment and comment.strip() != "":
            comment += " "
        for c in line:
            backtrack = True
            while backtrack:
                # print(c, parenthesisDepths)
                backtrack = False
                if status == inNormal:
                    if c == " ":
                        if outputLine[-1:] != " ":
                            outputLine += " "
                    elif c == "'":
                        status = inSingleQuote
                        outputLine += c
                    elif c == '"':
                        status = inDoubleQuote
                        outputLine += c
                    elif c == "/":
                        status = inSlash
                    elif c == "$":
                        status = inDollar
                        outputLine += c
                    elif c == "(":
                        parenthesisDepths[-1] += 1
                        outputLine += c
                    elif c == ")":
                        outputLine += c
                        if parenthesisDepths[-1] == 0:
                            if len(parenthesisDepths) == 1:
                                print("Mismatched parentheses, line %d:" \
                                    % (inputIndex + 1), line, file=sys.stderr)
                                return False, [], []
                            else:
                                parenthesisDepths = parenthesisDepths[:-1]
                        else:
                            parenthesisDepths[-1] -= 1
                    else:
                        outputLine += c
                        if c == ";" and len(parenthesisDepths) == 1 and \
                                parenthesisDepths[0] == 0:
                            if comment != "":
                                outputLine += "\t" + translate(comment)
                            newHalsSource.append(" " + outputLine.strip())
                            newMetadata.append(outputMeta)
                            outputLine = ""
                            outputMeta = {}
                            comment = ""
                elif status == inComment:
                    if c == "*":
                        status = inStar
                    else:
                        comment += c
                elif status == inSingleQuote:
                    if c == "\\":
                        status = inSingleQuoteEscape
                    elif c == "'":
                        status = inNormal
                        outputLine += c
                    else:
                        outputLine += translate(c)
                elif status == inDoubleQuote:
                    if c == "\\":
                        status = inDoubleQuoteEscape
                    elif c == '"':
                        status = inNormal
                        outputLine += c
                    else:
                        outputLine += c
                elif status == inSingleQuoteEscape:
                    outputLine += translate("\\" + c)
                    status = inSingleQuote
                elif status == inDoubleQuoteEscape:
                    outputLine += "\\" + c
                    status = inDoubleQuote
                elif status == inSlash:
                    if c == "*":
                        status = inComment
                        comment += "/*"
                        if outputLine.strip() == "":
                            # This is normally a dangling comment that should
                            # be added to the end of the preceding line of 
                            # code.  However, if we're at the top of the file,
                            # or if the preceding line is a full-line comment
                            # or compiler directive, we certainly don't want
                            # to do that.
                            if len(newHalsSource) == 0 or \
                                    newHalsSource[-1][:1] not in ["", " "]:
                                standAloneComment = True
                            else:
                                danglingComment = True
                    else:
                        status = inNormal
                        outputLine += "/"
                        backtrack = True # Reprocess this character inNormal.
                elif status == inStar:
                    if c == "/":
                        status = inNormal
                        comment += "*/"
                        if standAloneComment:
                            newHalsSource.append(" " + translate(comment))
                            newMetadata.append({})
                            comment = ""
                            standAloneComment = False
                        elif danglingComment:
                           newHalsSource[-1] += "\t" + translate(comment)
                           comment = ""
                           danglingComment = False 
                    else:
                        status = inComment
                        comment += "*" + c
                elif status == inDollar:
                    if c == " ":
                        outputLine += c
                    elif c == "(":
                        outputLine += c
                        parenthesisDepths.append(0)
                        status = inNormal
                    else:
                        status = inNormal
                        backtrack = True   
                else:
                    print("Implementation error.", file=sys.stderr)
                    return False, [], []
    
    if outputLine != "":
        if comment != "":
            outputLine += " " + translate(comment)
        newHalsSource.append(" " + outputLine)
        newMetadata.append(meta)
        
    if len(parenthesisDepths) != 1 or parenthesisDepths[0] != 0:
        print("Parentheses mismatch.", file = sys.stderr)
        return False, newHalsSource, newMetadata
        
    return True, newHalsSource, newMetadata

