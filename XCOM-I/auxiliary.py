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
import traceback
import re
from parseCommandLine import debugSink, lines, lineRefs, replacementSpace, \
                             replacementQuote, showBacktrace

scopeDelimiter = 's'

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
        if scope != None:
            print("%s: %s" % (msg, scope["lineText"]), file = sys.stderr)
        else:
            print("%s" % msg, file = sys.stderr)
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
    if showBacktrace:
        print("Backtrace:", file=sys.stderr)
        traceback.print_stack(file=sys.stderr)

# Return the scope of the innermost enclosing PROCEDURE of a scope.
def findParentProcedure(scope):
    while True:
        if "blockType" not in scope:
            return scope
        if scope["parent"] == None:
            return scope
        scope = scope["parent"]
    
# This is a simplified tokenizer used only for macro replacement. Given `string`,
# It returns a list of strings representing the tokens.  The possibilities for
# tokens are:
#    A quoted string (single quotes)
#    An identifier. ([a-zA-Z0-9_#@$]+ but not with a leading digit).
#    A number (i.e., a set of digits, possibly prefixed by "0x", "0q", "0b", "0o".
#    any punctuation.
# The identifiers, possibly followed by "(", ..., ")" are the potential
# macro replacements. The tokens can be rejoined by " ".join(...), possibly 
# with different numbers of spaces outside of quoted strings.
digits = {
    "b": "01",
    "q": "0123",
    "o": "01234567",
    "": "0123456789",
    "x": "0123456789ABCDEFabcdef"
    }
idChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_#@$"
operatorPairs = {"~=", "~<", "~>", "<=", ">=", "||"}
def mtokenize(string):
    tokens = []
    inside = 0 # 0 nothing, 1 quote, 2 identifier, 3 number
    i = 0
    radix = ''
    while i < len(string):
        c = string[i]
        i += 1
        if inside == 1:
            tokens[-1] = tokens[-1] + c
            if c == "'":
                inside = 0
        elif inside == 2:
            if c in idChars:
                tokens[-1] = tokens[-1] + c.upper()
            else:
                inside = 0
                i -= 1
                continue
        elif inside == 3:
            if len(tokens[-1]) == 1 and c in digits:
                radix = c;
                tokens[-1] = tokens[-1] + c
            elif c in digits[radix]:
                tokens[-1] = tokens[-1] + c
            else:
                inside = 0
                i -= 1
                continue
        else: # inside = 0
            pair = string[i-1:i+1]
            if pair in operatorPairs:
                tokens.append(pair)
                i += 1
                continue
            if c == "'":
                inside = 1
            elif c.isdigit():
                radix = ''
                inside = 3
            elif c in idChars:
                inside = 2
                c = c.upper()
            if c != " ":
                tokens.append(c)
    return tokens

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
globiterals = set() # All identifiers used as names of literals.
def expandOneMacroInString(scope, string):
    # We have to split the string into quoted portions and non-quoted
    # portions.
    mtokens = mtokenize(string)
    # Do a quick check to see if there are any names of macros among the tokens.
    # We do a more time-consuming but accurate check only if there are some.
    # (On my computer, this maneuver only cuts compilation time for HAL/S-FC
    # from ~8 seconds down to about ~7 seconds.  But I'll take it, I guess.)
    if 0 == len(globiterals & set(mtokens)):
        return string
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
            # Loop on all macros DECLARE'd within the scope.
            #if not isinstance(scope, dict):
            #    print(scope)
            for symbol in scope["literals"]:
                if symbol not in mtokens:
                    continue
                attributes = scope["literals"][symbol]
                # Found!  Let's determine the parameters:
                found = mtokens.index(symbol)
                end = found + 1
                parameters = []
                parmDepth = 0
                if "top" in attributes:
                    if found + 1 < len(mtokens) and mtokens[found + 1] == "(":
                        parmDepth = 1
                        parameters = [""]
                        for end in range(found + 2, len(mtokens)):
                            mtoken = mtokens[end]
                            if mtoken == "(":
                                parameters[-1] = parameters[-1] + mtoken
                                parmDepth += 1
                            elif mtoken == ")":
                                parmDepth -= 1
                                if parmDepth >= 1:
                                    parameters[-1] = parameters[-1] + mtoken
                                elif parmDepth == 0:
                                    end += 1
                                    break
                            elif mtoken == "," and parmDepth == 1:
                                parameters.append("")
                            else:
                                parameters[-1] = parameters[-1] + mtoken
                        if parameters[-1] == "":
                            parameters.pop()
                # At this point, `parameters` contains the parameters, 
                # and after replacement, the macro will occupy what was 
                # formerly mtokens[found:end], with mtokens outside that range
                # being unaffected.
                replacement = attributes["LITERALLY"]
                for k in range(len(parameters)):
                    replacement = replacement.replace("%" + "%d" % (k+1) + "%", parameters[k])
                newString = " ".join(mtokens[:found] + [replacement] + mtokens[end:])
                return newString
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
    if symbol[:1] != scopeDelimiter:
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

#----------------------------------------------------------------------------
# The stuff below is executed only if this file is run as a program, rather
# rather than if the file is imported as a module.

if __name__ == "__main__":
    for parm in sys.argv[1:]:
        print(parm, "->")
        print(mtokenizer(parm))
