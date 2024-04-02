#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   DECLARE.py
Purpose:    This is the module of XCOM-I.py which processes XPL
            DECLARE, ARRAY, or BASED statements.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-07 RSB  Began experimenting with this concept.
'''

import copy
import re
from auxiliary import error, expandAllMacrosInString

# Converts strings that are decimal, 0x hex, or 0b binary to integer.
def integer(s):
    if s.startswith("0x"):
        return int(s[2:], 16)
    elif s.startswith("0b"):
        return int(s[2:], 2)
    elif s.startswith("0q"):
        return int(s[2:], 4)
    elif s.startswith("0o"):
        return int(s[2:], 8)
    else:
        return int(s)

# Returns False on success, True on fatal error.  Parameters:
#    pseudoStatement     The text of the pseudo-statement being 
#                        processed.
#    scope               The dictionary for the scope in which
#                        the `string` was found.
def DECLARE(pseudoStatement, scope, inRecord = False):
    returnValue = False
    
    # We don't normally need any loop here, but if we find a new
    # macro definition, we need to apply it to the remainder of the
    # line in which it was found, and once we've done that we basically
    # need to start over on that line.
    keepGoing = True
    passCount = 0
    while keepGoing:
        keepGoing = False
        passCount += 1
    
        #print("Processing declaration: %s" % pseudoStatement)
        # Let's temporarily replace all spaces inside quoted strings 
        # with the otherwise-unused character '~'.  That'll help us
        # split the pseudo-statement into fields, after which we can 
        # restore those spaces.  Note that the calling code has already 
        # replace all single-quotes inside of quoted strings by the 
        # character '`', so we can split on single-quotes without fear.
        fields = pseudoStatement.split("'")
        for i in range(0, len(fields), 2):
            fields[i] = fields[i].upper()
            fields[i] = fields[i].replace(",", " , ")
            fields[i] = fields[i].replace(";", " ; ")
            fields[i] = fields[i].replace(":", " : ")
            fields[i] = fields[i].replace("(", " ( ")
            fields[i] = fields[i].replace(")", " ) ")
            fields[i] = fields[i].replace("  ", " ")
        for i in range(1, len(fields), 2):
            fields[i] = fields[i].replace(" ", "~")
        pseudoStatement = "'".join(fields)
        fields = pseudoStatement.strip().split()
        if inRecord:
            fields.insert(0, "DECLARE")
        #print(fields)
        
        # At this point, I hope, the entire pseudo-statement should be  
        # nicely split up at spaces, commas, semicolons, and 
        # parentheses not appearing within quoted strings, so every 
        # component of fields[] should be a single meaningful token. 
        isCommon = ( fields[0] == "COMMON" ) # Versus DECLARE
        if isCommon:
            del fields[0]
        isArray = ( fields[0] == "ARRAY" ) # Versus DECLARE or BASED.
        inArray = 0 # State variable for isArray.
        isBased = ( fields[0] == "BASED" )
        inBased = 0 # State variable for isBased.
        seekingName = True
        inInitial = False
        inGroup = False
        nextInGroup = ''
        attributes = []
        group = []
        for n in range(1, len(fields)):
            field = fields[n]
            if inArray == 1:
                if field != "(":
                    arrayTop = 0
                    inArray = 0
                else:
                    inArray = 2
                    continue
            if inBased == 1:
                if field != "RECORD":
                    isBased = False
                    inBased = 0
                else:
                    attributes.append(field)
                    inBased = 2
                    continue
            if field == ":" and inBased == 2:
                inBased = 0
            # *Cannot* be an `elif` below, because the 
            # immediately-preceding cases must fall through and be 
            # processed below.
            if inArray == 2:
                arrayTop = field
                inArray = 3
            elif inArray == 3:
                if field != ")":
                    error("Token not ')': %s" % field, scope)
                    returnValue = True
                inArray = 0
            elif inBased == 2:
                if field == "DYNAMIC":
                    attributes.append(field)
            elif seekingName:
                if inRecord and field == "END":
                    # If this pseudo-statement was a phony "DECLARE" 
                    # designed to continue an initial pseudo-statement 
                    # of the form "BASED ... RECORD ...:", then it will 
                    # be terminated by a "variable" named "END" which 
                    # we should simply ignore.
                    continue
                if field == "(":
                    inGroup = True
                    nextInGroup = ''
                    group = []
                else:
                    if isArray:
                        inArray = 1
                    elif isBased:
                        inBased = 1
                        attributes.append("BASED")
                    group = [field]
                seekingName = False
            elif field == ")" and inGroup:
                group.append(nextInGroup)
                inGroup = False
            elif inGroup:
                if field == ',':
                    group.append(nextInGroup)
                    nextInGroup = ''
                else:
                    nextInGroup = nextInGroup + field
            elif field == "INITIAL":
                inInitial = True
                attributes.append(field)
            elif field == ")" and inInitial:
                inInitial = False
                attributes.append(field)
            elif field in [",", ";", ":"] and not inInitial:
                properties = {}
                if isCommon:
                    properties["common"] = True
                if isArray:
                    properties["arrayTop"] = arrayTop
                # Convert the attributes of the new variable as a
                # list of tokens into a dictionary of properties:
                #    attributes -> properties
                skip = 0
                inFirst = True
                inTop = False
                inLiterally = False
                inBit = False
                inInitial = False
                initial = None
                for token in attributes:
                    if skip > 0:
                        skip -= 1
                    elif inFirst and token == "(":
                        inTop = True
                    elif inTop:
                        try:
                            properties["top"] = integer(token)
                        except:
                            pass
                        inTop = False
                        skip = 1
                    elif inLiterally:
                        # The following line fixes up things like
                        #     LITERALLY '"1234"'
                        # to be
                        #    LITERALLY '0x1234'
                        token = re.sub("^'\"([0-9A-F]+)\"'$", \
                                       "'0x\\1'", token)
                        properties["LITERALLY"] = token[1:-1]
                        inLiterally = False
                    elif inBit:
                        properties["BIT"] = integer(token)
                        inBit = False
                        skip = 1
                    elif inInitial:
                        if token == ",":
                            pass
                        elif token == ")":
                            properties["INITIAL"] = initial
                            inInitial = False
                        else:
                            if "CHARACTER" in properties:
                                token = token[1:-1]\
                                        .replace("~", " ").replace("`", "'")
                            elif "BIT" in properties or \
                                    "FIXED" in properties:
                                try:
                                    token = integer(token)
                                except:
                                    pass
                            else:
                                try:
                                    token = float(token)
                                except:
                                    pass
                            if "top" in properties:
                                if initial == None:
                                    initial = []
                                initial.append(token)
                            else:
                                initial = token
                    elif token == "LITERALLY":
                        inLiterally = True
                        properties["LITERALLY"] = True
                        #properties["numParms"] = TBD
                    elif token == "BIT":
                        inBit = True
                        skip = 1
                    elif token == "INITIAL":
                        inInitial = True
                        skip = 1
                    elif token in ["CHARACTER", "FIXED", "LABEL", 
                                   "BASED", "DYNAMIC"]:
                        properties[token] = True
                    elif token == "RECORD":
                        properties["RECORD"] = {}
                    else:
                        error("Unrecognized token %s" % token, scope)
                        returnValue = True
                    inFirst = False
                
                attributes = []
                for symbol in group:
                    if passCount == 1:
                        if symbol in scope["variables"] or \
                                symbol in scope["literals"]:
                            error("Symbol %s already defined" % symbol, scope)
                            returnValue = True
                            break
                    p = copy.deepcopy(properties)
                    # The default datatype, if not specified explicitly,
                    # is FIXED.
                    if "FIXED" not in p and \
                            "BIT" not in p and \
                            "CHARACTER" not in p and \
                            "LITERALLY" not in p and \
                            "LABEL" not in p:
                        p["FIXED"] = True
                    if "LITERALLY" in properties:
                        if passCount == 1 or \
                                symbol not in scope["literals"] or \
                                scope["literals"][symbol] != p:
                            keepGoing = True
                        scope["literals"][symbol] = p
                        if keepGoing and n + 1 < len(fields):
                            pseudoStatement = ' '.join(fields[:n+1]) + \
                                expandAllMacrosInString(scope, \
                                                        ' '.join(fields[n+1:]))
                        break
                    elif not inRecord:
                        scope["variables"][symbol] = p
                    else:
                        variables = scope["variables"]
                        last = variables[list(variables)[-1]]["RECORD"]
                        last[symbol] = p
                
                if keepGoing:
                    break
                seekingName = True
                if returnValue:
                    break
            else:
                attributes.append(field)
        
        if not keepGoing:
            return returnValue
