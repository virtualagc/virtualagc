#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   expression.py
Purpose:    This parses an expression for XCOM-I.py, given a tokenized form
            of the pseudo-statement containing the expression.
Requires:   Python 3.6 or later.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-22 RSB  Began
'''

import sys
from asciiToEbcdic import asciiToEbcdic

'''
Expressions are treated as Python dictionaries representing a tree structure 
consisting of linked atomic nodes or pointers to dictionaries for the other 
nodes of the tree.  The associated key/value pairs are:

    "token"     The token (from `tokenized`) of an identifier, a constant, or
                and operator for this node.  (Other types of tokens, such as
                parentheses and commas, are syntactical sugar that disappear
                at this point to be replaced by the structure of the tree.)
    "parent"    The link to the dictionary of the parent node, or None at root.
    "children"  A Python list of the child nodes.
    
E.g., if the node is a function or array, then the children will be the 
parameters of the function or the indices of the array.  If the node is an 
operator, then the children will be the operands.  In other words, the atomic
nodes are constants, names of variables or functions without
parameters; non-atomic nodes are operators or functions with parameters.
Note further that there is no need to distinguish between binary and unary
- or + operators, since, the number of children already makes that distinction.
'''

# Function to attach a node as a child to a parent.
def attachChild(parent, child):
    parent["children"].append(child)
    child["parent"] = parent
    if child["end"] > parent["end"]:
        parent["end"] = child["end"]

# Function to create a new node for an expression tree.
def createNode(tokenized, index, parent = None):
    node = {
        "token" : tokenized[index],
        "parent" : None,
        "children" : [],
        # The "end" field is the index of the next token in tokenized[] (or
        # upon reaching the last token, the length of the list) used not only
        # by this node by by all of its sub-nodes.
        "end": index + 1
        }
    if parent != None:
        attachChild(parent, node)
    return node

#-----------------------------------------------------------------------------
'''
I don't really know anything about parsing expressions of the complexity 
needed for XPL, and it's not immediately obvious to me that any existing code
from elsewhere can be immediately used or easily adapted.  So this is a bit
of a brute-force exercise, based on the BNF on pp. 128-129 of McKeeman. 
I don't pretend that it's is going to be efficient.

Basically, what I do is have a recognizer function for each BNF non-terminal 
(other than tokens) that can appear in an expression.  Specifically, there's a
separate recognizer function for each of <expression>, <logical factor>, ...,
<subscript head), with the only exception being <relation> (which is so simple
that it doesn't need a recognizer).  

Recognizer functions are applied to a starting index in a list of tokens, 
calling any other relevant recognizer functions they need, and return lists 
of matching trees.  (Which could be empty lists if no matches at all are found.)
In general, none of the recognizer functions are used directly by calling code, 
although in principle any of the recognizers could be called directly.

The parameters of a recognizer function are:

`tokenized`    A list of tokens for a pseudo-statement.

`start`        The index in `tokenized` at which expression analysis begins.
'''

'''
There are several rules of the form:

    <type> ::= <subtype> 
            |  <type> operator <subtype>

The `isType` and `isType0` function are not technically recognizer functions
according to the description above, but can be used to implement any recognizer 
function having rules complying with the template.  

The `operators` parameteter is an iterable of the allowable operators.  These
are just the string representations (such as "+" or "-") rather than the tokens
for those operator types.

If the `recursive` parameter can be set to False, then instead of the rule
template described above, `isType` can instead be used for rule templates of
the form

    <type> ::= <subtype> 
            |  <subtype> operator <subtype>

The difference between `isType0` and `isType` is that the former accepts a
base list of matches (`types`), while the latter generates a base list of 
matches using the `isSubtype` function.  `isType0` needs no `start` parameter,
because the indices into the `tokenized` list are built into the `types`
parameter.
'''
def isType0(tokenized, types, isSubtype, operators, recursive = True):
    if len(types) == 0:
        return []
    # Now look for <type>::=<type>operator<subtype>.  We could end up with a 
    # long chain like <subtype>operator<subtype>operator...operator<subtype>,
    # so we just keep iterating until we stop finding matches.  Note that if
    # we match a <type>operator<subtype>, having previously matched <type> of
    # course, we end up reporting only the former and not the latter.
    changed = True
    obsoletes = [] # Indices if matches marked for removal.
    while changed:
        changed = False
        # Remove obsoletes that have alredy been replaced by lengthened
        # versions.
        for i in reversed(obsoletes):
            del types[i]
        obsoletes = []
        for i in range(len(types)):
            # Unfortunately, `type` is a Python builtin, and so I use the 
            # misspelling `tipe` instead.
            tipe = types[i]
            end = tipe["end"]
            if end >= len(tokenized):
                continue
            operator = tokenized[end]
            if "operator" not in operator or \
                    operator["operator"] not in operators:
                continue
            subtypes = isSubtype(tokenized, end + 1)
            for subtype in subtypes:
                # Combine the parse-trees and update the saved trees.  The
                # `newRoot` being created is a node for the operator, of which
                # the <type> and <subtype> nodes will be children.
                newRoot = createNode(tokenized, end)
                attachChild(newRoot, tipe)
                attachChild(newRoot, subtype)
                types.append(newRoot)
                if i not in obsoletes:
                    obsoletes.append(i)
                if recursive:
                    changed = True
    # Remove obsoletes that have alredy been replaced by lengthened
    # versions.  (Some may still remain in the case recursive==False.)
    for i in reversed(obsoletes):
        del types[i]
    return types

def isType(tokenized, start, isSubtype, operators, recursive = True):
    return isType0(tokenized, isSubtype(tokenized, start), isSubtype, \
                   operators, recursive = True)

'''
    <expression> ::= <logical factor>
                  |  <expression> | <logical factor>
                  
While in principle I allow multiple matches from recognizers, in 
fact the rules mustn't allow multiple matches from `isExpression`, 
since it would be rather pointless to have ambiguity in how to 
compute the values of the expressions.  So `isExpression` is only
going to return 0 or 1 matches if there's no implementation error. 
'''
def isExpression(tokenized, start):
    return isType(tokenized, start, isLogicalFactor, {"|"})

'''
    <logical factor> ::= <logical secondary>
                      |  <logical factor> & <logical secondary>
'''
def isLogicalFactor(tokenized, start):
    return isType(tokenized, start, isLogicalSecondary, {"&"})

'''
    <logical secondary> ::= <logical primary>
                         |  ~ <logical primary>
'''
def isLogicalSecondary(tokenized, start):
    # <logical secondary> ::= <logical primary> 
    #                      |  ~ <logical primary>
    logicalSecondaries = []
    end = start
    if end < len(tokenized) and \
            "operator" in tokenized[end] and \
            tokenized[end]["operator"] == "~":
        end += 1
    numNots = end - start
    logicalPrimaries = isLogicalPrimary(tokenized, end)
    if numNots == 0:
        return logicalPrimaries
    for logicalPrimary in logicalPrimaries:
        root = createNode(tokenized, start)
        newNode = root
        for i in range(1, numNots):
            newNode = createNode(tokenized, start + i, newNode)
        attachChild(newNode, logicalPrimary)
        logicalSecondaries.append(root)
    return logicalSecondaries

# <relation> is so simple we don't need a recognizer for it.
relations = { "=", "<", ">", "~=", "~<", "~>", "<=", ">=" }

'''
    <logical primary> ::= <string expression>
                       |  <string expression> <relation> <string expression>
'''
def isLogicalPrimary(tokenized, start):
    return isType(tokenized, start, isStringExpression, relations, False)

'''
    <string expression> ::= <arithmetic expression>
                         |  <string expression> || <arithmetic expression>
'''
def isStringExpression(tokenized, start):
    return isType(tokenized, start, isArithmeticExpression, {"||"})

'''
    <arithmetic expression> ::= <term>
                             |  <arithmetic expression> + <term>
                             |  <arithmetic expression> - <term>
                             |  + <term>
                             |  - <term>
'''
def isArithmeticExpression(tokenized, start):
    if start >= len(tokenized):
        return []
    # First take care of:
    #    <term>
    #    + <term>
    #    - <term>
    terms = isTerm(tokenized, start)
    if len(terms) == 0 and \
                "operator" in tokenized[start] and \
                tokenized[start]["operator"] in ["+", "-"]:
        terms = isTerm(tokenized, start + 1)
        for i in range(len(terms)):
            newRoot = createNode(tokenized, start)
            attachChild(newRoot, terms[i])
            terms[i] = newRoot
    return isType0(tokenized, terms, isTerm, {"+", "-"})

'''
    <term> ::= <primary>
            |  <term> * <primary>
            |  <term> / <primary>
            |  <term> mod <primary
'''
def isTerm(tokenized, start):
    return isType(tokenized, start, isPrimary, { '*', '/', "mod" })

'''
    <primary> ::= <constant>
               |  <variable>
               |  ( <expression> )
'''
def isPrimary(tokenized, start):
    returnValue = isConstant(tokenized, start)
    if len(returnValue) != 0:
        return returnValue
    returnValue = isVariable(tokenized, start)
    if len(returnValue) != 0:
        return returnValue
    if start >= len(tokenized) or tokenized[start] != "(":
        return []
    start += 1
    expressions = isExpression(tokenized, start)
    remove = []
    for i in range(len(expressions)):
        expression = expressions[i]
        end = expression["end"]
        if end >= len(tokenized) or tokenized[end] != ")":
            remove.append(i)
            continue
        end += 1
        expression["end"] = end
    for i in reversed(remove):
        del expressions[i]
    return expressions

'''
    <constant> ::= <string>
                |  <number>
                
Neither <string> nor <number> have rules; they're just tokens.
'''
def isConstant(tokenized, start):
    if start >= len(tokenized):
        return []
    token = tokenized[start]
    if "string" in token or "number" in token:
        return [createNode(tokenized, start)]
    return []

# The tokenization has separated identifiers that are XPL built-ins and 
# reserved words from the user-defined identifiers, so here's a test (but not
# a recognizer function) that accepts both builtins and user-defined 
# identifiers.  Reserved words are not accepted.
def testIdentifier(tokenized, start):
    if start >= len(tokenized):
        return False
    token = tokenized[start]
    if "identifier" in token:
        return True
    if "builtin" in token:
        return True
    return False

'''
As given in McKeeman, the rule for XPL is:

    <variable> ::= <identifier>
                |  <subscript head> <expression> )

This does not account for structure variables (`BASED ... RECORD`) variables
of XPL/I.  My approach to use McKeeman's rule instead for a terminal I call
<unbased variable>, and to let <variable> instead be either an 
<unbased variable> or else <unbased variable>.<unbased variable>.
'''
def isUnbasedVariable(tokenized, start):
    if not testIdentifier(tokenized, start):
        return []
    subscriptHeads = isSubscriptHead(tokenized, start)
    if len(subscriptHeads) == 0:
        # Just a bare identifier!
        return [createNode(tokenized, start)]
    variables = []
    for subscriptHead in subscriptHeads:
        end = subscriptHead["end"]
        expressions = isExpression(tokenized, end)
        for expression in expressions:
            variable = subscriptHead
            attachChild(variable, expression)
            variable["end"] += 1
            variables.append(variable)
    return variables

def isVariable(tokenized, start):
    return isType(tokenized, start, isUnbasedVariable, {"."}, False)

'''
    <subscript head> ::= <identifier> (
                      |  <subscript head> <expression> ,

<identifier> has no rule; it's either an "identifier" or "builtin" token.
'''
def isSubscriptHead(tokenized, start):
    if not testIdentifier(tokenized, start):
        return []
    if start + 1 >= len(tokenized) or tokenized[start + 1] != "(":
        return []
    newRoot = createNode(tokenized, start)
    newRoot["end"] += 1
    start += 2
    # We've found 
    #    <identifier> (
    # Now add
    #                    <expression> ,
    # to it for as long as we can.
    changed = True
    while changed:
        changed = False
        expressions = isExpression(tokenized, start)
        if len(expressions) != 1:
            break
        expression = expressions[0]
        start = expression["end"]
        if start >= len(tokenized) or tokenized[start] != ",":
            break
        start += 1
        attachChild(newRoot, expression)
        newRoot["end"] = start
        changed = True
    return [newRoot]

# `parseExpression` is the function intended to be directly called by the main 
# software.  It differs from isExpression in that:
#    a) It returns a single parse tree (rather than a list) or else None.
#    b) It prunes the tree by replacing all sub-trees that can actually be 
#       calculated due to consisting entirely of constants and operators.
def parseExpression(tokenized, start):
    expressions = isExpression(tokenized, start)
    if len(expressions) == 0:
        return None        
    root = expressions[0]
    if len(expressions) > 1:
        root["error"] = "Implementation error: Ambiguous expression"
    
    # Compare two strings, using the method described in McKeeman p. 138, 
    # namely a comparison is made first on string lengths and then secondarily
    # on EBCDIC byte codes.  Returns -1, 0, or 1 if <, =, or >.
    def compare(string1, string2):
        if len(string1) < len(string2):
            return -1
        if len(string1) > len(string2):
            return 1
        # Recall that the preprocessing done on quoted strings has replaced
        # ' ' by `replacementSpace` and "''" by `replacementQuote`, but 
        # that "''" is actually a representation of just "'".  We need to do
        # `replacementSpace` -> " " and `replacmentQuoteQuote` -> "'" before 
        # making any further comparison.
        string1 = string1\
                    .replace(replacementSpace, " ")\
                    .replace(replacementQuote, "'")
        string2 = string2\
                    .replace(replacementSpace, " ")\
                    .replace(replacementQuote, "'")
        for i in range(len(string1)):
            # Get EBCDIC byte codes.
            e1 = asciiToEbcdic(ord(string1[i]))
            e2 = asciiToEbcdic(ord(string2[i]))
            if e1 < e2:
                return -1
            if e1 > e2:
                return 1
        return 0
    
    # Compute the value of an expression tree, pruning the tree to a single
    # node where that's possible.
    def computeTree(tree):
        if len(tree["children"]) == 0:
            return
        for child in tree["children"]:
            computeTree(child)
        if not isinstance(tree["token"], dict):
            return
        if "operator" not in tree["token"]:
            return
        values = []
        for child in tree["children"]:
            childToken = child["token"]
            if not isinstance(childToken, dict):
                return
            if "number" in childToken:
                values.append(childToken["number"])
            elif "string" in childToken:
                values.append(childToken["string"])
            else:
                return
        token = tree["token"]
        operator = token["operator"]
        children = tree["children"]
        numChildren = len(children)
        # Having gotten to here, we know that the root of the tree is an 
        # operator, and that all of the children have been reduced to constants
        # of one sort or another.  Therefore, it may be possible to reduce this
        # entire tree to a constant as well.
        if numChildren == 1:
            child = children[0]
            childToken = child["token"]
            value = values[0]
            if not isinstance(value, int):
                return
            if operator == "~":
                tree["token"] = {"number": 0xFFFFFFFF & ~value }
            elif operator == "+":
                tree["token"] = {"number": value }
            elif operator == "-":
                tree["token"] = {"number": -value }
            else:
                return
        elif numChildren == 2:
            value1 = values[0]
            value2 = values[1]
            bothNumbers = isinstance(value1, int) and isinstance(value2, int)
            bothStrings = isinstance(value1, str) and isinstance(value2, str)
            bothSame = bothNumbers or bothStrings
            if operator == "|" and bothNumbers:
                tree["token"] = {"number": (value1 | value2) }
            elif operator == "&" and bothNumbers:
                tree["token"] = {"number": (value1 & value2)}
            elif operator == "=" and bothSame:
                tree["token"] = {"number": int(value1 == value2) }
            elif operator == "<" and bothNumbers:
                tree["token"] = {"number": int(value1 < value2) }
            elif operator == "<" and bothStrings:
                tree["token"] = {"number": int(compare(value1, value2) < 0) }
            elif operator == ">" and bothNumbers:
                tree["token"] = {"number": int(value1 > value2) }
            elif operator == ">" and bothStrings:
                tree["token"] = {"number": int(compare(value1, value2) > 0) }
            elif operator == "~=" and bothSame:
                tree["token"] = {"number": int(value1 != value2) }
            elif operator in ["~<", ">="] and bothNumbers:
                tree["token"] = {"number": int(value1 >= value2) }
            elif operator in ["~<", ">="] and bothStrings:
                tree["token"] = {"number": int(compare(value1, value2) >= 0) }
            elif operator in ["~>", "<="] and bothNumbers:
                tree["token"] = {"number": int(value1 <= value2) }
            elif operator in ["~>", "<="] and bothStrings:
                tree["token"] = {"number": int(compare(value1, value2) <= 0) }
            elif operator == "||" and bothStrings:
                tree["token"] = {"string": value1 + value2 }
            elif operator == "+" and bothNumbers:
                tree["token"] = {"number": value1 + value2 }
            elif operator == "-" and bothNumbers:
                tree["token"] = {"number": value1 - value2 }
            elif operator == "*" and bothNumbers:
                tree["token"] = {"number": value1 * value2 }
            elif operator == "/" and bothNumbers:
                tree["token"] = {"number": value1 // value2 }
            elif operator == "mod" and bothNumbers:
                tree["token"] = {"number": value1 % value2 }
            else:
                return
        else:
            return
        # If we've gotten this far without returning from the functions, then
        # the computation succeeded, and we can prune off the children of the
        # root node.
        tree["children"] = []
        
    computeTree(root)
    return root

def printTree(root, indent = '', file = sys.stdout):
    print(indent + str(root["token"]), file = file)
    for child in root["children"]:
        printTree(child, indent + "\t", file)
    
#----------------------------------------------------------------------------
# The stuff below is executed only if this file is run as a program, and is
# not executed if the file is imported as a module.  I wish I had known about
# this mechanism years ago ....

if __name__ == "__main__":
    from xtokenize import xtokenize

    if False:
        # `terminals` is a list of all the rules we'll check.
        terminals = [] 
        terminals.append((isExpression, "<expression>"))
        if False:
            terminals.append((isLogicalFactor, "<logical factor>"))
            terminals.append((isLogicalSecondary, "<logical secondary>"))
            terminals.append((isLogicalPrimary, "<logical primary>"))
            terminals.append((isStringExpression, "<string expression>"))
            terminals.append((isArithmeticExpression, "<arithmetic expression>"))
            terminals.append((isTerm, "<term>"))
            terminals.append((isPrimary, "<primary>"))
            terminals.append((isConstant, "<constant>"))
            terminals.append((isVariable, "<variable>"))
            terminals.append((isSubscriptHead, "<subscript head>"))
            
        while True:
            expression = input("Input an expression: ")
            tokenized = xtokenize(globalScope, expression)
            for terminal in terminals:
                matches = terminal[0](tokenized, 0)
                for amatch in matches:
                    print("%s (end %d):" % (terminal[1], amatch["end"]))
                    printTree(amatch, "\t")

    else:
        while True:
            expression = input("Input an expression: ")
            tokenized = xtokenize(globalScope, expression)
            print("<identifier>?", testIdentifier(tokenized, 0))
            tree = parseExpression(tokenized, 0)
            if tree == None:
                print("Error:", tree["error"])
            else:
                printTree(tree, "")
                