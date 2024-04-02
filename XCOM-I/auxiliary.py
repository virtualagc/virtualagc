#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   auxiliary.py
Purpose:    This is a module of commonly-used functions for XCOM-I.py.
Requires:   Python 3.6 or later.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-16 RSB  Split off from XCOM-I.py.
'''

import sys
import re
from parseCommandLine import debugSink

# Prints a compiler error message, consisting of the message itself, the
# current line number and line text, and the line number and line text for 
# all the parent contexts.
briefErrors = True
def error(msg, scope):
    if briefErrors:
        print("%s: %s" % (msg, scope["lineText"]), file = sys.stderr)
    else:
        first = True
        print("Error: %s" % msg, file = sys.stderr)
        while scope != None:
            if first:
                first = False
                print("Scope '%s', line %d, %s [ %s ]" % (scope["symbol"],
                                                          scope["lineNumber"], 
                                                          scope["lineText"], 
                                                          scope["lineExpandedText"]), \
                      file = sys.stderr)
            else:
                print("      '%s', line %d, %s" % (scope["symbol"],
                                                          scope["lineNumber"], 
                                                          scope["lineText"]), \
                      file = sys.stderr)
            scope = scope["parent"]

# It is clear that macro expansion in strings within a given scope
# can involve all macros DECLARE'd in the current scope, as well as all
# macros DECLARE'd in ancestor scopes.  Furthermore, it is clear that
# this expansion is recursive, in the sense that once a macro is 
# expanded, the resulting string may contain other macro symbols that
# need to be expanded, and so on.  What is *not* clear is the ordering
# in which these macro expansions are processed.  So I'll just take
# a shot and hope for the best, but it'll be inefficient.  The 
# `expandOneMacroInString` function tries to perform any single 
# substitution (from innermost scope to outermost, but in the order the 
# macros are DECLARE'd within the individual scopes), and if it finds
# one then it returns the modified string.  If none were found, the 
# original string is returned unchanged.
def expandOneMacroInString(scope, string):
    # We have to split the string into quoted portions and non-quoted
    # portions.
    delimiters = ["'", '"']
    inQuote = False
    delimiter = ''
    fields = ['']
    for c in string:
        fields[-1] = fields[-1] + c
        if inQuote and c == delimiter:
            inQuote = False
            fields.append('')
        elif not inQuote and c in delimiters:
            inQuote = True
            delimiter = c
    if fields[-1] == '':
        del fields[-1]
    for i in range(len(fields)):
        s = fields[i]
        if s[:1] in delimiters:
            continue
        # Loop on current scope and all ancestors.
        while True:
            # Loop on all macros DECLARE'd in the scope.
            #if not isinstance(scope, dict):
            #    print(scope)
            for symbol in scope["literals"]:
                attributes = scope["literals"][symbol]
                if "top" not in attributes: # Macro has no parameters!
                    # This is the easy case, since all occurrences of the
                    # symbol can simply be replaced by the same thing.
                    replacement = attributes["LITERALLY"]
                    newString = re.sub('\\b' + symbol + '\\b', replacement, s, \
                                       flags = re.IGNORECASE)
                else:
                    # The macro has parameters.  This is a lot harder case
                    # to deal with.  We have to process with each occurrence of
                    # "symbol(...parameters...) separately, in succession.
                    rFields = re.split('\\b' + symbol + '\\b', s, \
                                       flags = re.IGNORECASE)
                    for ir in range(1, len(rFields)):
                        rField = rFields[ir]
                        ic = 0 # Index of the leading '('.
                        while ic < len(rField) and rField[ic] == ' ':
                            ic += 1
                        # We need to parse the parameters of the symbol.
                        # If there was no list of parameters, then we can't
                        # replace anything.
                        if ic >= len(rField) or rField[ic] != '(':
                            rFields[ir] = symbol + rField
                            continue
                        parameters = [None] # parameters[0] is ignored.
                        parameterDepth = 1
                        inQuote = False
                        ic0 = ic + 1
                        done = -1 # Index following the trailing ')'.
                        for ic in range(ic0, len(rField)):
                            c = rField[ic]
                            if c == "'":
                                inQuote = not inQuote
                            elif inQuote:
                                pass
                            elif c == "," and parameterDepth == 1:
                                parameters.append(rField[ic0 : ic].strip())
                                ic0 = ic + 1
                            elif c == "(":
                                parameterDepth += 1
                            elif c == ")":
                                parameterDepth -= 1
                                if parameterDepth == 0:
                                    parameters.append(rField[ic0 : ic].strip())
                                    done = ic + 1
                                    break
                        # If not `done`, then the parameter list wasn't 
                        # completed, and we can't replace anything.
                        if done < 0:
                            rFields[ir] = symbol + rField
                            continue
                        replacement = attributes["LITERALLY"]
                        for ip in range(1, len(parameters)):
                            replacement = replacement.replace("%%%d%%" % ip, \
                                                              parameters[ip])
                        rFields[ir] = replacement + rField[done:]
                    newString = ''.join(rFields)
                    if False and newString != s:
                        print("A ............. %s" % s)
                        print("B ............. %s" % newString)
                if newString != s:
                    fields[i] = newString
                    return ''.join(fields) # Replaced something!
            if scope["parent"] == None: # No parent?
                return string # No changes to string!
            scope = scope["parent"]

# `expandAllMacrosInString` simply calls `expandOneMacroInString` until
# no more replacements are called.  Note that will enter an infinite
# loop for dumb XPL code like `DECLARE A LITERALLY "A A";`.
def expandAllMacrosInString(scope, string):
    while True:
        newString = expandOneMacroInString(scope, string)
        if newString == string:
            return string
        string = newString

# Recursively walk through a `scope` dictionary, performing some 
# user-defined `function` on each sub-scope in the order encountered.
# The function should return None upon success, and some other 
# user-defined value upon failure.  Whatever the `function`, it should
# always have the required parameter `scope` and the optional parameter
# `extra` (defaulting to None).  `extra` can be of any desired type
# (such as a dictionary), and is ignored by `walkModel` itself.
def walkModel(scope, function, extra = None):
    returnValue = function(scope, extra)
    if returnValue != None:
        return returnValue
    for child in scope["children"]:
        returnValue = walkModel(child, function, extra)
        if returnValue != None:
            return returnValue

# Navigate from the current `scope`, through the ancestors, back to the global
# scope, performing a user-specified `function` at each step.  The normal 
# return value of the `function` and of `navigateToGlobal` itself is `None`,
# but if `function` returns some other value, then that value is returned
# by `navigateToGlobal`.  If additional information needs to be provided, it
# should be by means such as storing it in the `scope`, using global variables,
# and so on.  
def navigateToGlobal(scope, function, arg = None):
    while scope != None:
        returnValue = function(scope, arg)
        if returnValue != None:
            return returnValue
        scope = scope["parent"]
    return None

# Find the attributes for a variable that's in-scope, or None if not found.
def getAttributes(scope, symbol):
    while scope != None:
        if symbol in scope["variables"]:
            return scope["variables"][symbol]
        scope = scope["parent"]
    return None

# The `function` (*a la* walkModel) for user-friendly printing of a
# scope dictionary ... but only when --debug is used.
def printModel(scope, extra = None):
    global indent
    if debugSink == None:
        return
    oneIndent = '\t'
    indent0 = oneIndent * len(scope["ancestors"])
    indent1 = indent0 + oneIndent
    indent2 = indent1 + oneIndent
    symbol = scope["symbol"]
    print(indent0 + "Scope: '%s'" % symbol, file=debugSink)
    print(indent1 + "Prefix: '%s'" % scope["prefix"], file=debugSink)
    if symbol[:1] != '_':
        if len(scope["literals"]) > 0:
            print(indent1 + "Macros:", file=debugSink)
            for macro in scope["literals"]:
                print(indent2 + macro + ": " + str(scope["literals"][macro]), \
                      file=debugSink)
        else:
            #print(indent1 + "Macros: None", file=debugSink)
            pass
        if len(scope["variables"]) > 0:
            print(indent1 + "Identifiers:", file=debugSink)
            for var in scope["variables"]:
                print(indent2 + var + ": " + str(scope["variables"][var]), \
                      file=debugSink)
        else:
            #print(indent1 + "Variables: None", file=debugSink)
            pass
    if len(scope["labels"]) > 0:
        labels = "Labels:"
        for label in scope["labels"]:
            labels = labels + ' ' + label
        print(indent1 + labels, file=debugSink)
    else:
        #print(indent1 + "Labels: None", file=debugSink)
        pass
    if "code" in scope and len(scope["code"]) > 0:
        print(indent1 + "Pseudocode:", file=debugSink)
        for p in scope["code"]:
            print(indent2 + str(p), file=debugSink)
    if False:
        if len(scope["children"]) == 0:
            print(indent1 + "Children: None", file=debugSink)
        else:
            children = "Children:"
            for child in scope["children"]:
                children = children + " " + child["symbol"]
            print(indent1 + children, file=debugSink)
    return None
