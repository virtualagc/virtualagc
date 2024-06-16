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
from auxiliary import error, expandAllMacrosInString, mtokenize, globiterals
from parseCommandLine import ifdefs, replacementSpace, replacementQuote
from xtokenize import xtokenize
from parseExpression import parseExpression

# Tries to evaluate a constant expression, given as a string, at compile-time.  
# Returns tipe,value, where tipe is "FIXED", "CHARACTER".
def evalString(scope, s):
    tokenized = xtokenize(scope, s)
    tree = parseExpression(tokenized, 0)
    if tree == None:
        return None, None
    if "number" in tree["token"]:
        return "FIXED", tree["token"]["number"]
    if "string" in tree["token"]:
        value = tree["token"]["string"] \
            .replace(replacementSpace, " ")\
            .replace(replacementQuote, "'")
        return "CHARACTER", value
    return None, None

# Converts strings like decimal, 0x hex, or 0b binary, or even simple 
# expressions of constants, to integer.
def integer(scope, s):
    try:
        # It turns out that I've sometimes inadvertantly converted the string to 
        # upper case, and I try to catch that here rather than try to undo the 
        # case changes somewhere upstream.
        s = s.lower()
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
    except:
        tipe, value = evalString(scope, s)
        if tipe == "FIXED":
            return value
        elif False:
            tokenized = xtokenize(scope, s)
            tree = parseExpression(tokenized, 0)
            if tree != None and "number" in tree["token"]:
                return tree["token"]["number"]
            else:
                error("Cannot evaluate %s as an integer" % s, scope)
        else:
            error("Cannot evaluate %s as an integer" % s, scope)


# Returns False on success, True on fatal error.  Parameters:
#    pseudoStatement     The text of the pseudo-statement being 
#                        processed.
#    scope               The dictionary for the scope in which
#                        the `string` was found.
offsetInRecord = 0
def DECLARE(pseudoStatement, scope, library, inRecord = False):
    global offsetInRecord
    returnValue = False
    
    if not inRecord:
        offsetInRecord = 0
    
    # We don't normally need any loop here, but if we find a new
    # macro definition, we need to apply it to the remainder of the
    # line in which it was found, and once we've done that we basically
    # need to start over on that line.
    keepGoing = True
    passCount = 0
    while keepGoing:
        keepGoing = False
        passCount += 1
        
        fields = mtokenize(pseudoStatement)
        if inRecord:
            fields.insert(0, "DECLARE")
        fields0 = fields[0]
        
        # At this point, I hope, the entire pseudo-statement should be  
        # nicely split up at spaces, commas, semicolons, and 
        # parentheses not appearing within quoted strings, so every 
        # component of fields[] should be a single meaningful token. 
        if fields0 == "COMMON":
            isCommon = True
            if fields[1] in ["ARRAY", "BASED"]:
                del fields[0]
                fields0 = fields[0]
        else:
            isCommon = False
        isArray = ( fields0 == "ARRAY" ) # Versus DECLARE or BASED.
        inArray = 0 # State variable for isArray.
        isBased = ( fields0 == "BASED" )
        inBased = 0 # State variable for isBased.
        seekingName = True
        inInitial = False
        inGroup = False
        nextInGroup = ''
        attributes = []
        if fields0 in ["ARRAY", "BASED"]:
            attributes.append(fields0)
        group = []
        n = 0
        properties = { }
        while n < len(fields) - 1:
            n += 1
            field = fields[n]
            
            if not field[:1].isdigit() and not field[:1] == "'":
                field = field.upper()
            if inArray == 1:
                if field != "(":
                    arrayTop = 0
                    inArray = 0
                else:
                    inArray = 2
                    continue
            if inBased == 1:
                if field != "RECORD":
                    #isBased = False
                    inBased = 0
                else:
                    attributes.append(field)
                    inBased = 2
                    continue
            elif field == "RECORD":
                # This is to cover the case of DECLARE ... RECORD.  It's going
                # to screw up if variables both with and without RECORDs are
                # declared in the same statement, I think.
                attributes.append("BASED")
                fields[0] = "BASED"
                fields0 = fields[0]
                attributes.append(field)
                inBased = 2
                isBased = True
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
                        #attributes.append("BASED")
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
            elif field in ["INITIAL", "CONSTANT"]:
                inInitial = True
                attributes.append(field)
                initialString = ''
                initial = []
                typeInitial = field
                paranCount = 0
            elif field == "(" and inInitial:
                attributes.append(field)
                paranCount += 1
            elif field == ")" and inInitial:
                attributes.append(field)
                paranCount -= 1
                if paranCount == 0:
                    inInitial = False
                    if initialString != '':
                        tipe, value = evalString(scope, initialString)
                        if tipe != None:
                            initial.append(value)
                        else:
                            error("Cannot evaluate INITIAL(%s)" % str(initialString), scope)
                        initialString = ''
                    properties[typeInitial] = initial
            elif field in [",", ";", ":"] and not inInitial:
                properties = {  }
                if isCommon:
                    properties["common"] = True
                if isArray:
                    try:
                        properties["top"] = int(arrayTop)
                    except:
                        # It turns out that there are cases in which an `ARRAY`
                        # declaration is used with no defined subscript, and
                        # the "ARRAY" variable is subsequently used only as a
                        # scalar.  On cannot help but wonder why?  See the 
                        # `DOFORCLBL` variable in PASS2.
                        #error("Unassigned arrayTop", scope)
                        properties["top"] = 0
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
                    elif token == "(": # and inFirst:
                        inTop = True
                        topString = ''
                    elif inTop:
                        if token != ")":
                            topString += " " + token
                        else:
                            properties["top"] = integer(scope, topString)
                            inTop = False
                    elif inLiterally:
                        # The following line fixes up things like
                        #     LITERALLY '"1234"'
                        # to be
                        #    LITERALLY '0x1234'
                        token = re.sub("\"([0-9A-F]+)\"", \
                                       "0x\\1", token)
                        token = token[1:-1]\
                                .replace(replacementSpace, " ")\
                                .replace(replacementQuote, "'")
                        # I've found macros in which the replacement string
                        # contains a comment.  Since all comments *not* in 
                        # quoted strings will have already been removed at this
                        # point, such comments would cause a problem if the
                        # macro expansion suddenly reintroduces them.
                        # Note that the following simplistic fix will fail
                        # in various pathological cases like quoted comments
                        # or multiple comments within the replacement string.
                        token = re.sub('/[*].*[*]/', ' ', token)
                        # There's one final ghastliness to account for, and
                        # that's the use of macros in which the replacement
                        # string contains somewhere within it something like:
                        #    /?c ...text... ?/
                        # where c is A, B, C, or P.  Constructs like the above
                        # but *not* in quotes will already have been either
                        # transparently eliminated or else replaced just by
                        # ...text....  Unfortunately, expanding this macro will
                        # now reinsert garbage like that.  So we need to 
                        # nip it in the bud right here.  
                        while True:
                            match = re.search("/\\?[A-Z].*?\\?/", token)
                            if match == None:
                                break
                            c = match.group()[2]
                            s = match.span()[0]
                            e = match.span()[1]
                            if c in ifdefs:
                                token = token[:s] + token[s+3:e-2] + token[e:]
                            else:
                                token = token[:s] + token[e:]
                        properties["LITERALLY"] = token
                        inLiterally = False
                    elif inBit:
                        bitSize = integer(scope, token)
                        properties["BIT"] = bitSize
                        if not isBased or inRecord:
                            if bitSize <= 8:
                                properties["dirWidth"] = 1
                            elif bitSize <= 16:
                                properties["dirWidth"] = 2
                            else:
                                properties["dirWidth"] = 4
                        inBit = False
                        skip = 1
                    elif inInitial:
                        if token == "(":
                            paranCount += 1
                        if token == ")":
                            paranCount -= 1
                        if token == "," or (token == ")" and paranCount == 0):
                            if initialString != '':
                                tipe, value = evalString(scope, initialString)
                                if tipe != None:
                                    initial.append(value)
                                else:
                                    error("Cannot evaluate INITIAL(%s)" % \
                                          str(initialString), scope)
                                initialString = ''
                            if token == ")":
                                properties[typeInitial] = initial
                                initial = None
                                inInitial = False
                        else:
                            initialString += " " + token
                            if False:
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
                    elif token in ["INITIAL", "CONSTANT"]:
                        inInitial = True
                        initialString = ''
                        initial = []
                        typeInitial = token
                        skip = 1
                        paranCount = 1
                    elif token in ["CHARACTER", "FIXED", "LABEL", "ARRAY",
                                   "BASED", "DYNAMIC"]:
                        properties[token] = True
                        if token == "BASED":
                            properties["dirWidth"] = 28
                        elif "dirWidth" not in properties and \
                                token in ["CHARACTER", "FIXED", "ARRAY"]:
                            properties["dirWidth"] = 4
                    elif token == "RECORD":
                        properties["RECORD_CHAR"] = {}
                        properties["RECORD_NONCHAR"] = {}
                        properties["RECORD"] = {}
                    else:
                        error("Unrecognized token %s (%s)" % \
                                                (str(token), str(attributes)), scope)
                        returnValue = True
                    inFirst = False
                
                if isArray or isBased:
                    attributes = attributes[:1]
                else:
                    attributes = []
                for symbol in group:
                    if passCount == 1 and not inRecord:
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
                            "LABEL" not in p and \
                            "RECORD" not in p:
                        p["FIXED"] = True
                        p["dirWidth"] = 4
                    if "LITERALLY" in properties:
                        globiterals.add(symbol)
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
                        p["library"] = library
                        scope["variables"][symbol] = p
                    else:
                        variables = scope["variables"]
                        basedVar = variables[list(variables)[-1]]
                        last = basedVar["RECORD"]
                        if True:
                            # Sort the fields so that all of the string-
                            # descriptor fields come first, but otherwise 
                            # respecting the ordering as given in the 
                            # declaration.  I believe this is needed for 
                            # SPACELIB's COMPACTIFY to work.
                            last_char = basedVar["RECORD_CHAR"]
                            last_nonchar = basedVar["RECORD_NONCHAR"]
                            if ("BIT" in p and p["BIT"] > 32) or \
                                    "CHARACTER" in p:
                                last_char[symbol] = p
                            else:
                                last_nonchar[symbol] = p
                            newLast = {}
                            basedVar["RECORD"] = newLast
                            for key in last_char:
                                newLast[key] = last_char[key]
                            for key in last_nonchar:
                                newLast[key] = last_nonchar[key]
                            offsetInRecord = 0
                            for key in newLast:
                                q = newLast[key]
                                q["offset"] = offsetInRecord
                                offsetInRecord += q["dirWidth"]
                                if "top" in q:
                                    offsetInRecord += q["dirWidth"] * q["top"]
                        else:
                            # Use the field ordering from the declaration as-is.
                            p["offset"] = offsetInRecord
                            offsetInRecord += p["dirWidth"]
                            if "top" in p:
                                offsetInRecord += p["dirWidth"] * p["top"]
                            last[symbol] = p
                        basedVar["recordSize"] = offsetInRecord
                if keepGoing:
                    break
                seekingName = True
                if returnValue:
                    break
            else:
                attributes.append(field)
        
        if not keepGoing:
            return returnValue
