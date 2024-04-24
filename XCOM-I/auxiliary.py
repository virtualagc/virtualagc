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
from parseCommandLine import debugSink, lines, lineRefs

# `errorRef` and `ref` are indices into the `lines` and `lineRefs` arrays.
errorRef = None
def setErrorRef(ref):
    global errorRef
    errorRef = ref

# Prints a compiler error message, consisting of the message itself, the
# current line number and line text, and the line number and line text for 
# all the parent contexts.
briefErrors = True
def error(msg, scope):
    print("%s: %s" % \
          (lineRefs[errorRef], 
           lines[errorRef].strip()
                          .replace(replacementQuote, "''")
                          .replace(replacementSpace, " ")), file = sys.stderr)
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
        if inQuote and c == delimiter:
            fields[-1] = fields[-1] + c
            inQuote = False
            fields.append('')
        elif not inQuote and c in delimiters:
            fields.append(c)
            inQuote = True
            delimiter = c
        else:
            fields[-1] = fields[-1] + c
    if fields[-1] == '':
        del fields[-1]
    oscope = scope
    for i in range(len(fields)):
        scope = oscope
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
                # In trying to make a regex pattern that can match possible
                # identifiers, the temptation is to use the word-boundary
                # zero-assertion, as in '\\b'+symbol+'\\b'.  The problem is
                # that an identifier can begin or end with one of the symbols
                # $ # @, and any of those will cause the \b test to fail.
                # we must instead construct much more complex zero assertions
                # to cover this case.  (Google for negative lookahead and
                # negative lookbehind.)
                pattern = "(?<![A-Za-z0-9_#@$])" + symbol + "(?![A-Za-z0-9_#@$])"
                if "top" not in attributes: # Macro has no parameters!
                    # This is the easy case, since all occurrences of the
                    # symbol can simply be replaced by the same thing.
                    replacement = attributes["LITERALLY"]
                    newString = re.sub(pattern, replacement, s, \
                                       flags = re.IGNORECASE)
                else:
                    # The macro has parameters.  This is a lot harder case
                    # to deal with.  We have to process with each occurrence of
                    # "symbol(...parameters...) separately, in succession.
                    rFields = re.split(pattern, s, \
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
                break
            scope = scope["parent"]
    return string;

# `expandAllMacrosInString` simply calls `expandOneMacroInString` until
# no more replacements are called.  Note that will enter an infinite
# loop for dumb XPL code like `DECLARE A LITERALLY "A A";`.
def expandAllMacrosInString(scope, string):
    while True:
        if not isinstance(string, str):
            pass
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

# `printList` is a utility called by `printDict`.
def printList(lst):
    isList = isinstance(lst, list)
    if isList:
        print(" [", end="", file=debugSink)
    else:
        print(" (", end="", file=debugSink)
    first = True
    for value in lst:
        if not first:
            print(",", end = "", file=debugSink)
        first = False
        if value == None:
            print(" None", end = "", file=debugSink)
        elif isinstance(value, int):
            print("", value, end="", file=debugSink)
        elif isinstance(value, str):
            print(" '" + value + "'", end="", file=debugSink)
        elif isinstance(value, (list, tuple)):
            printList(value)
        elif isinstance(value, dict):
            printDict(value)
        elif isinstance(value, set):
            print(" " + str(value), end="", file=debugSink)
        else:
            print(" ?", end="", file=debugSink)
    if isList:
        print(" ]", end="", file=debugSink)
    else:
        print(" )", end="", file=debugSink)

# `printDict` is a utility called by `printModel`, used for printing a 
# representation of an identifier's attributes from the variable list.
# The principal difficulty with just printing scope["variables"][identifier]
# is that for any real program, the hierarchy of parent and child scopes
# embedded in this printout make it not only overwhelming in size (multigigabyte
# for ANALYZER.xpl), but useless to look at.  So at the very least, these
# cross references to scopes have to be eliminated.
def printDict(dictionary):
    print(" {", end="", file=debugSink)
    first = True
    for key in sorted(dictionary):
        if key in ["parent", "children", "pseudoStatements", "lineText",
                   "lineExpanded", "lineExpandedText", "lineNumber", "code"]:
            continue
        value = dictionary[key]
        if not first:
            print(",", end = "", file=debugSink)
        first = False
        if isinstance(key, str):
            print(" '" + key + "':", end = "", file=debugSink)
        elif isinstance(key, int):
            print(" " + str(key) + ":", end = "", file=debugSink)
        else:
            continue
        if value == None:
            print(" None", end = "", file=debugSink)
        elif isinstance(value, int):
            print("", value, end="", file=debugSink)
        elif isinstance(value, str):
            print(" '" + value + "'", end="", file=debugSink)
        elif isinstance(value, set):
            print(" " + str(value), end="", file=debugSink)
        elif isinstance(value, (list, tuple)):
            printList(value)
        elif isinstance(value, dict):
            printDict(value)
        else:
            print(" ?", end="", file=debugSink)
    print(" }", end="", file=debugSink)

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
                print(indent2 + var + ":", end="", file=debugSink)
                printDict(scope["variables"][var])
                print("", file=debugSink)
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
            print(indent2, end="", file=debugSink)
            if isinstance(p, dict):
                printDict(p)
            else:
                print(" " + str(p), end="", file=debugSink)
            print("", file=debugSink)
    if False:
        if len(scope["children"]) == 0:
            print(indent1 + "Children: None", file=debugSink)
        else:
            children = "Children:"
            for child in scope["children"]:
                children = children + " " + child["symbol"]
            print(indent1 + children, file=debugSink)
    return None
