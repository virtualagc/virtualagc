#!/usr/bin/env python3
'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   expressions.py
Purpose:    This is the part of the ASM101S assembler for IBM AP-101 
            assembly language that's largely responsible for computing the
            values of various types of expressions (arithmetic, boolean,
            characters) and maintaining symbolic variables.
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-09-25 RSB  Began.

There is a stand-alone mode that can be used for testing and certain setups,
but mainly this file is a module to be imported into ASM101S.  

Note that in all cases within this module, an "expression" is a so-called AST
(Abstract Syntax Tree) in the form returned by a TatSu parser.
'''

import re
from fieldParser import parserASM

# Already-defined normal program labels (such as `MYSYM`), vs symbolic variables
# for the macro language or sequence symbols.  At the moment this is just for
# the purpose of implementing the `D'` operator, but perhaps other info about
# the labels (such as their addresses) could be collected here later as well.
definedNormalSymbols = {}

'''
Global symbolic variables for the macro language.  Note that we don't need
to distinguish between `GBLA`, `GBLB`, and `GBLC` in `svGlobals` (nor between
`LCLA`, `LCLB`, and `LCLC` in `svLocals` elsewhere), because the datatypes of
the values assigned to the variables do it for us in Python.   (The defaults,
by the way, are 0, False, and '' respectively.)

With that said, the mere datatypes of the variables do not necessarily convey
all of the metainformation about the variables which we may need to track under
all possible circumstances.  For that reason, any symbolic variable such as &A
that appears `svGlobals` (or in the similar `svLocals`) can optionally be
accompanied by a separate key _&A whose value is a dictionary containing 
whatever additional metadata that turns out to be relevant.  

I can't specify much of that metadata at the moment.  The example that I know
of, which has prompted this comment in the first place is that the `svLocals`
structure used in macro expansions tracks both macro parameters and local 
"SET symbols`, and that under some circumstances additional data needs to 
accompany macro parameters in order to implement the so-called "number attribute"
operator (N'); specifically, omitted parameters are assigned default values,
but N' needs to know specifically either the parameter has been omitted or not,
rather than merely knowning that it has been assigned a default value.  I'm
sure there are a number of other corner cases of that nature.  

In the specific case just mentioned, the following metadata is added to 
`svLocals` for macro parameters (only):
    "omitted" : boolean
'''
svGlobals = { }  # Use as `global` in every function.
# There can also be "local" variables in the global context.  By the "global
# local" context, I refer to items defined at the top-level scope but not 
# accessible at any lower levels of the scope hierarchy.
svGlobalLocals = { "parent": [None, 0, 0, None] } # For debugging only

# Mark an error in the array of source code.
errorCount = 0
maxSeverity = 0
def error(properties, msg, severity=255):
    global errorCount, maxSeverity
    if severity > maxSeverity:
        maxSeverity = severity
    errorCount += 1
    properties["errors"].append("(Pass %d, Severity %d) %s" % (svGlobals["_passCount"], severity, msg))
def getErrorCount():
    return errorCount, maxSeverity

'''
This function replaces all symbolic variables (e.g., &A) given by 
`svGlobals` and `svLocals` in a string.  `svPattern` is a compiled regular
expression that matches any symbolic variable, whether previously-defined or
not.

Aside from the reverse order of replacements of multiple matches just mentioned,
this sounds trivially straightforward, but it's actually horrible.  Here's the
problem:  The normal case is that the "string" which is being replaced is 
normally a bare symbolic variable such as &A that's an element of an AST, so
what we want to "replace" it with is really itself an AST.
'''
svPattern = re.compile("(?<!&)&[A-Z#$@][A-Z#$@0-9]*(?![#@_$A-Z0-9])")
def svReplace(properties, text, svLocals):
    global svGlobals
    
    if "&" not in text:  # Quick test for absence of symbolic variables.
        return text
    
    # We want to do the replacements in reverse order (i.e., from end of the 
    # string to the beginning of the string), so as to keep the indexes of 
    # matches that haven't yet been replaced from changing.
    matches = []
    for match in svPattern.finditer(text):
        matches.append(match)
    for match in reversed(matches):
        sv = match.group()
        # We have a certain difficulty now, in that while what we've found is
        # most-likely something like &A, it could also be something like 
        # &A(expression).  And the only way we're going to be able to deal with
        # that is via actual parsing.
        start = match.span()[0]
        end = match.span()[1]
        ast = parserASM(text[start:], "nameSet0")
        if ast == None:
            error(properties, "Cannot parse: " + text[start:])
            continue
        sv = ast["sv"][0]
        if sv in svLocals:
            replacement = svLocals[sv]
        elif sv in svGlobals:
            replacement = svGlobals[sv]
        else:
            continue
        if "exp" in ast:
            if not isinstance(replacement, (list,tuple)):
                error(properties, "Not a list: " + str(replacement))
                continue
            n = evalArithmeticExpression(ast["exp"], svLocals, properties)
            if n == None:
                error(properties, "Cannot evaluate index of %s: %s" % \
                      (sv, str(ast["exp"])))
                continue
            n -= 1
            if n < 0 or n >= len(replacement):
                error(properties, "Index of %s(%d) out of range" % (sv, n+1))
                continue
            replacement = replacement[n]
            end = start + ast.parseinfo.endpos
        if end < len(text) and text[end] == ".": # Optional "join" character.
            end += 1
        if isinstance(replacement, int):
            replacement = str(replacement)
        elif replacement == False:
            replacement = "0"
        elif replacement == True:
            replacement = "1"
        elif isinstance(replacement, (list,tuple)):
            if text[start-2:start] in ["K'", "N'"]:
                start -= 2
                replacement = str(len(replacement))
            else:
                if True: ###DEBUG###
                    replacement = str(replacement).replace(",)", ")")
                else:
                    error(properties, "Cannot use list as a replacement: %s=%s" % \
                          (sv, str(replacement)))
                    continue
        try:
            text = text[:start] + replacement + text[end:]
        except:
            pass
            print("***DEBUG***")
    
    return text

# In parsed expressions, remove useless levels of tuple/list embedding, such
# as [([expression])] -> expression.
def unroll(expression):
    while isinstance(expression, (tuple, list)):
        if len(expression) == 1:
            expression = expression[0]
        elif len(expression) > 0 and expression[-1] == []:
            expression = expression[:-1]
        elif len(expression) == 4 and expression[0] == '(' and \
                expression[2] == [] and expression[3] == ')':
            expression = expression[1]
        else:
            break
    return expression

# Rules of the form 
#    X { ',' X }
# create AST that looks like the following:
#    ( AST1, [] }
# or
#    ( AST1, [
#              [ ',', AST2 ],
#              [ ',', AST3 ],
#              ...
#            ] )
# For our processing, it's much more convenient to have
#    [ AST1, AST2, AST3, ... ]
# so that's what the `astFlattenList` function does.
def astFlattenList(ast):
    if ast == []:
        return []
    try:
        flattened = [ ast[0] ]
        for e in ast[1]:
            flattened.append(e[1])
        return flattened
    except:
        print("Implementation error: AST for X{',',X} not appropriate")
        import sys
        sys.exit(1)

# Evaluate an arithmetic expression to an integer and return it, or else `None`
# on failure.  `properties` is for the line of source code.  `expression` is
# the parsed expression, as returned by the parser function.  `svLocals` and
# `svGlobals` provide the defined symbolic variables, with the locals overriding
# the globals in case of overlap
def evalArithmeticExpression(expression, \
                             svLocals, \
                             properties = { "errors": [] }, \
                             symtab = {}, \
                             star = None, \
                             severity = 255
                             ):
    global svGlobals
    
    expression = unroll(expression)
    
    if isinstance(expression, dict) and "T" in expression:
        datatype = expression["T"][0]
        expression = unroll(expression[datatype])
        if datatype == "C":
            error(properties, \
                  "Cannot convert string '%s' to arithmetic expression" % expression)
            return None
        elif datatype == "B":
            return int(expression, 2)
        elif datatype == "X":
            return int(expression, 16)
        elif datatype in ["E", "D"]:
            return float("".join(expression))
        elif datatype in ["F", "H"]:
            s = "".join(expression)
            if s.isdigit():
                return int(s)
            return float(s)
        elif datatype == "Y":
            if expression not in symtab:
                error(properties, "Symbol %s not found" % expression)
                return None
            return symtab[expression]["pos1"] // 2
        elif datatype == "Z":
            error(properties, "Literals =Z(...) not yet implemented")
            return None
        error(properties, "Literals =%s not implemented" % datatype)
        return None
            
    if isinstance(expression, str):
        if expression.isdigit() or (expression.startswith("-") and expression[1:].isdigit()):
            return int(expression)
        sv = None
        if expression in svLocals:
            sv = svLocals
        elif expression in svGlobals:
            sv = svGlobals
        if sv != None:
            sv = sv[expression]
            if isinstance(sv, int):
                return sv
            if isinstance(sv, str) and sv.isdigit():
                return int(sv)
            error(properties, \
                  "Cannot be interpreted as an integer value: '%s' (%s)" % \
                  (sv, expression), severity)
            return None
        if expression == "*" and star != None:
            return star
        if expression in symtab:
            entry = symtab[expression]
            if svGlobals["_passCount"] == 3:
                if "references" not in entry:
                    entry["references"] = []
                entry["references"].append(properties["n"])
            if "value" in entry:
                value = entry["value"]
                try:
                    if svGlobals["_passCount"] > 1 and value != 0 and value != -1 and \
                            (value & 0xFFFFFFF000000000) != 0 and \
                            not entry["dsect"]: ###XPERIMENTAL###
                        value = symtab[symtab["_firstCSECT"]]["value"] + \
                                symtab[entry["section"]]["preliminaryOffset"] + \
                                entry["address"]
                except:
                    pass
                    pass
                return value
    if not isinstance(expression, (list, tuple)):
        error(properties, "Eval error type 1", severity)
        return None
    if len(expression) == 4 and expression[1] == "(" and expression[3] == ")" \
            and isinstance(expression[0], str) and expression[0].startswith("&"):
        arrayName = expression[0]
        if arrayName in svLocals:
            arrayData = svLocals[arrayName]
        elif arrayName in svGlobals:
            arrayData = svGlobals[arrayName]
        else:
            error(properties, "Cannot find %s" % arrayName)
            return None
        if not isinstance(arrayData, list):
            error(properties, "%s is not an array" % arrayName)
            return None
        index = evalArithmeticExpression(expression[2], svLocals, properties, \
                                         symtab, star, severity)
        if index == None:
            error(properties, "Cannot evaluate index")
            return None
        index -= 1
        if index < 0 or index >= len(arrayData):
            error(properties, "Index is out of range (%d > %d)" % \
                  (index+1, len(arrayData)))
            return None
        return arrayData[index]
    if len(expression) == 3 and expression[0] == '(' and expression[2] == ')':
        return evalArithmeticExpression(expression[1], svLocals, properties, \
                                        symtab, star, severity)
    if len(expression) == 3 and expression[0] == "X'" and expression[2] == "'":
        try:
            return int(expression[1], 16)
        except:
            error(properties, "Not hexadecimal: %s" % expression[1], severity)
            return None
    if len(expression) == 3 and expression[0] == "B'" and expression[2] == "'":
        try:
            return int(expression[1], 2)
        except:
            error(properties, "Not binary: %s" % expression[1], severity)
            return None
    if len(expression) == 2 and isinstance(expression[0], str) and \
            expression[0] in ["N'", "K'", "L'", "S'", "I'"]:
        op = expression[0]
        symvar = expression[1]
        index = None
        if isinstance(symvar, (tuple,list)):
            if len(symvar) == 4 and symvar[1] == '(' and symvar[3] == ')':
                pass
            else:
                error(properties, "Unrecognized operand of %s: %s" % \
                      (op, symvar[2]), severity)
                return None
            index = evalArithmeticExpression(symvar[2], svLocals, properties, \
                                             symtab, star, severity)
            if index == None:
                error(properties, "Cannot compute index of %s: %s" %\
                      (symvar[0], str(symvar[2])), severity)
                return None
            symvar = symvar[0]
        if symvar in svLocals:
            sv = svLocals
        elif symvar in svGlobals:
            sv = svGlobals
        else:
            error(properties, "Symbolic variable %s not found" % symvar, severity)
            return None
        var = sv[symvar]
        if index != None:
            if symvar == "&SYSLIST" and index == 0:
                var = svLocals["&SYSLIST0"]
            else:
                index -= 1 # Change 1-based to 0-based.
                if index < 0 or index >= len(var):
                    error(properties, "Index out of range", severity)
                    return None
                var = var[index]
        metavar = "_" + symvar
        if metavar in sv:
            meta = sv[metavar]
        else:
            meta = {}
        if op == "N'":
            if symvar != "&SYSLIST" and "omitted" not in meta:
                error(properties, "Not a macro parameter: %s" % symvar, severity)
                return None
            if symvar != "&SYSLIST" and meta["omitted"]:
                return 0
            if not isinstance(var, (tuple, list)):
                return 1
            return len(var)
        elif op == "K'":
            if isinstance(var, str):
                return len(var)
            error(properties, "Not a string: %s" % str(var), severity)
            return None
        else:
            error(properties, "Not yet implemented: %s" % op, severity)
            return None
        
    if len(expression) == 2:
        left = evalArithmeticExpression(expression[0], svLocals, properties, \
                                        symtab, star, severity)
        if left != None:
            next = expression[1]
            chained = False
            if isinstance(next, (list,tuple)):
                chained = True
                for entry in next:
                    if isinstance(entry, (list,tuple)) and len(entry) == 2 \
                            and entry[0] in ["+", "-", "*", "/"]:
                        continue
                    chained = False
                    break
            if chained:
                for entry in next:
                    op = entry[0]
                    right = evalArithmeticExpression(entry[1], svLocals, \
                                                     properties, symtab, star, \
                                                     severity)
                    if right != None:
                        if op == "+":
                            left += right
                        if op == "-":
                            left -= right
                        if op == "*":
                            left *= right
                        if op == "/":
                            if right == 0:
                                left = 0
                            else:
                                left /= right
                    else:
                        error(properties, "Eval error type 2", severity)
                        return None
                return left
    error(properties, "Eval error type 3", severity)
    return None

# Evaluate a boolean expression, returning True, False, or None (error).
def evalBooleanExpression(expression, svLocals, properties = { "errors": [] }):
    global svGlobals
    
    expression = unroll(expression)
    
    while isinstance(expression, (tuple,list)) and len(expression) == 3 and \
            expression[0] == '(' and expression[2] == ')':
        expression = unroll(expression[1])
    
    if isinstance(expression, str):
        if expression == '0':
            return False
        if expression == '1':
            return True
        if expression[:1] == "&":
            # We shouldn't ever get to here.
            # I'm not sure if this case can arise in the program flow, because
            # I haven't yet worked out when replacements of symbolic variables
            # is performed, but it should be okay here anyway.
            if expression in svLocals:
                return svLocals[expression]
            elif expression in svGlobals:
                return svGlobals[expression]
            else:
                error(properties, "Not defined: %s" % expression)
                return None
        error(properties, "Implementation error:  %s as boolean expression" \
              % expression)
        return None
    if len(expression) == 2 and expression[0] == "D'" and \
            isinstance(expression[1], str):
        symbol = svReplace(properties, expression[1], svLocals)
        return (symbol in definedNormalSymbols)
    # &A(...)
    if len(expression) == 4 and isinstance(expression[0], str) and \
            expression[0][:1] == "&" and \
            expression[1] == '(' and expression[3] == ')':
        sv = expression[0]
        n = evalArithmeticExpression(expression[2], svLocals, properties)
        if n == None:
            return None
        n -= 1  # Convert 1-based to 0-based
        if sv in svLocals:
            if not isinstance(svLocals[sv], list):
                error(properties, \
                      "Access to non-subscripted local %s(%d)" % (sv, n))
                return None
            if n < 0 or n >= len(svLocals[sv]):
                error(properties, \
                      "Subscript out of range for local %s(%d)" % (sv, n))
            return svLocals[sv][n]
        if sv in svGlobals:
            if not isinstance(svGlobals[sv], list):
                error(properties, \
                      "Access to non-subscripted global %s(%d)" % (sv, n))
                return None
            if n < 0 or n >= len(svGlobals[sv]):
                error(properties, \
                      "Subscript out of range for global %s(%d)" % (sv, n))
            return svGlobals[sv][n]
        error(properties, \
              "Symbolic variable %s not found in local or global scope" % sv)
        return None
    # NOT
    if len(expression) == 4 and expression[1] == "NOT":
        right = evalBooleanExpression(expression[3], svLocals, properties)
        if right == None:
            error(properties, \
                  "Cannot evaluate boolean expression %s" \
                  % str(right))
            return None
        return (not right)
    # AND, OR
    if len(expression) == 2:
        left = unroll(expression[0])
        right = unroll(expression[1])
        if isinstance(right, (tuple,list)) and \
                len(right) == 4 and \
                right[1] in ["AND", "OR"]:
            op = right[1]
            valLeft = evalBooleanExpression(left, svLocals, properties)
            if valLeft == None:
                error(properties, \
                      "Cannot evaluate boolean expression %s" \
                      % str(left))
                return None
            valRight = evalBooleanExpression(right[3], svLocals, properties)
            if valRight == None:
                error(properties, \
                      "Cannot evaluate boolean expression %s" \
                      % str(right[3]))
                return None
            if op == "OR":
                return (valLeft or valRight)
            else:
                return (valLeft and valRight)
    # Relational expressions:
    if len(expression) == 5 and \
            expression[2] in ["EQ", "NE", "LT", "LE", "GT", "GE"]:
        op = expression[2]
        left = unroll(expression[0])
        right = unroll(expression[4])
        # Should we do a string comparison or an arithmetical one?  We can
        # recognise string expressions since the first token is always "'".
        def isString(expression):
            e = unroll(expression)
            if isinstance(e, str):
                return e in ["'", "T'"]
            if isinstance(e, (tuple,list)) and len(e) > 0:
                return isString(e[0])
            return False
        leftIsString = isString(left)
        rightIsString = isString(right)
        if leftIsString != rightIsString:
            error(properties, "Cannot determine int vs char for comparison")
            return None
        # Arithmetical
        if not leftIsString and not rightIsString:
            valLeft = evalArithmeticExpression(left, svLocals, properties)
            if valLeft != None:
                if '&ERRNUMS' in right: ###DEBUG###
                    pass
                    pass
                valRight = evalArithmeticExpression(right, svLocals, properties)
                if valRight != None:
                    if op == "EQ":
                        return valLeft == valRight
                    if op == "NE":
                        return valLeft != valRight
                    if op == "LT":
                        return valLeft < valRight
                    if op == "LE":
                        return valLeft <= valRight
                    if op == "GT":
                        return valLeft > valRight
                    if op == "GE":
                        return valLeft >= valRight
                    # Can't get here.
                error(properties, \
                      "Cannot evaluate relational expression %s" \
                      % str(expression))
                return None
        # Character
        if leftIsString and rightIsString:
            valLeft = evalCharacterExpression(left, svLocals, properties)
            if valLeft != None:
                valRight = evalCharacterExpression(right, svLocals, properties)
                if valRight != None:
                    # Recall string comparisons prioritize string length, and
                    # only compare actual character differences when the 
                    # lengths of the strings are identical.
                    if len(valLeft) < len(valRight):
                        cmp = -1
                    elif len(valLeft) > len(valRight):
                        cmp = 1
                    elif valLeft < valRight: # Lengths are the same.
                        cmp = -1
                    elif valLeft > valRight:
                        cmp = 1
                    else:
                        cmp = 0
                    if op == "EQ":
                        return cmp == 0
                    if op == "NE":
                        return cmp != 0
                    if op == "LT":
                        return cmp < 0
                    if op == "LE":
                        return cmp <= 0
                    if op == "GT":
                        return cmp > 0
                    if op == "GE":
                        return cmp >= 0
                    # Can't get here.
        error(properties, \
              "Cannot evaluate relational expression %s" \
              % str(expression))
        return None
    error(properties, \
          "Cannot evaluate boolean expression %s" \
          % str(expression))
    return None

# Evaluate a character expression to string and return it, or else `None`
# on failure.  `properties` is for the line of source code.  `expression` is
# the parsed expression, as returned by the parser function.  `svLocals` and
# `svGlobals` provide the defined symbolic variables, with the locals overriding
# the globals in case of overlap
def evalCharacterExpression(expression, svLocals, properties = { "errors": [] }):
    global svGlobals
    s = None
    
    expression = unroll(expression)
    
    if isinstance(expression, (list,tuple)):
        if len(expression) == 4 and expression[0] == "'" and \
                expression[3] == "'":
            # This case is for 'string1''string2'...'stringN'
            s = expression[1]
            for ss in expression[2]:
                if not isinstance(ss, (list,tuple)) or len(ss) != 2 \
                        or ss[0] != "''":
                    error(properties, \
                          "Cannot evaluate string expression: %s" % \
                          str(expression))
                    return None
                s = s + ss[1]
        elif len(expression) == 2 and expression[0] == "T'" and \
                isinstance(expression[1], str):
            symbol = svReplace(properties, expression[1], svLocals)
            # I only support a tiny percentage of the number of possibilities
            # presented by the assembly-language manual.  At least for right now.
            if isinstance(symbol, str):
                return "C"
            error(properties, "Implementation error in T'")
            return None
        elif len(expression) in [2,3]:
            s = evalCharacterExpression(expression[0], svLocals, properties)
            if s == None:
                error(properties, \
                      "Cannot evaluate string expression: %s" % \
                      str(expression[0]))
                return None
            for index in range(1, len(expression)):
                e = unroll(expression[index])
                if isinstance(e, (list,tuple)) and len(e) == 2 and e[0] == '.':
                    # This case is for exp1.exp2
                    ss = evalCharacterExpression(e[1], svLocals, properties)
                    if ss == None:
                        error(properties, \
                              "Cannot evaluate string expression: %s" % \
                              str(expression[1]))
                        return None
                    s = s + ss
                elif isinstance(e, (list,tuple)) and len(e) == 5 and \
                        e[0] == '(' and e[2] == ',' and e[4] == ')':
                    # This is the case for exp(i1,i2)
                    i = evalArithmeticExpression(e[1], svLocals, properties)
                    if i == None:
                        error(properties, \
                              "Cannot evaluate index %s" % str(e[1]))
                        return None
                    i -= 1
                    n = evalArithmeticExpression(e[3], svLocals, properties)
                    if n == None:
                        error(properties, \
                              "Cannot evaluate length %s" % str(e[3]))
                        return None
                    if i < 0 or n < 0: # If i+n past of string, it's okay.
                        error(properties, "Index or length out of range")
                        return None
                    s = s[i : i + n]
                else:
                    ss = evalCharacterExpression(e, svLocals, properties)
                    if ss == None:
                        error(properties, \
                              "Cannot evaluate string expression: %s" % \
                              str(expression[1]))
                        return None
                    s = s + ss
    if s != None:
        return svReplace(properties, s, svLocals)
    error(properties, "Cannot evaluate string expression: %s" % str(expression))
    return None

# Check of two quantities are of the same type.  Only supported:
# int, boolean, string, list of int, list of boolean, list of string.
# Returns True if different types, False if same type.
def isDifferentType(q0, q1):
    if isinstance(q0, list) and isinstance(q1, list):
        if len(q0) != len(q1):
            return True
        return type(q0[0]) != type(q1[0])
    return type(q0) != type(q1) 

# Declaration of symbolic variables.  The `operation` is a string that's one
# of "GBLA", ..., "LCLC".  The `operand` string is a comma-separated list
# of so-far-undeclared symbolice variables (such as &A,&B,...) or of 
# subscripted symbolic variables (such as &A(&B) or &A(3)), where the total
# lengths (&B or 3 in these examples) are computatble at assembly-time.
def svDeclare(operation, operand, svLocals, properties = { "errors": [] }):
    global svGlobals
    
    fields = operand.split()[0].split(",")
    typ = operation[3]
    if typ == "A":
        value = 0
    elif typ == "B":
        value = False
    else:
        value = ""
    originalValue = value
    if operation.startswith("GBL"):
        sv = svGlobals
    else:
        sv = svLocals
    for field in fields:
        value = originalValue
        if field[:1] != "&":
            error(properties, \
                  "In %s, %s is not a symbolic variable" % \
                  (operation, field))
            continue
        if "(" in field:
            subfields = field.split("(")
            if len(subfields) != 2 or subfields[1][-1:] != ")":
                error(properties, \
                      "In %s, %s is improperly formed" % \
                      (operation, field))
                continue
            length = subfields[1][:-1]
            ast = parserASM(length, "arithmeticExpressionOnly")
            if ast == None:
                error(properties, "Could not parse dimension of %s" % field)
                continue
            n = evalArithmeticExpression(ast, svLocals, properties)
            if n == None:
                error(properties, "Could not compute dimension of %s" % field)
                continue
            if n < 1:
                error(properties, "Dimension of %s out of range (%d)" % \
                      (field, n))
                continue
            field = subfields[0]
            value = [value] * n
        if field in sv:
            if isDifferentType(sv[field], value):
                error(properties, \
                      "Attempt to change type of existing symbolic variable %s" \
                      % field)
            continue
        sv[field] = value

# Set a symbolic variable.  `operation` is one of "SETA", "SETB", "SETC".
# `name` and `operand` are strings.
def svSet(operation, name, operand, svLocals, properties = { "errors": [] }):
    global svGlobals
    
    operand = operand.strip()
    pname = parserASM(name, "nameSet")
    if pname == None:
        error(properties, \
              "Cannot parse name field %s" % name)
        return
    #print("***DEBUG***", pname)
    if "sv" not in pname:
        error(properties, \
              "No symbolic variable for assignment")
        return
    sname = pname["sv"][0]
    if sname in svLocals:
        sv = svLocals
    elif sname in svGlobals:
        sv = svGlobals
    elif "exp" not in pname:
        # The (non-arrayed) SET symbol that's the target of the SETx operation
        # has not been previously declared, which the System/360 assembly-language
        # manual absolutely requires.  However, I believe that in AP-101S
        # assembly language there is likely a convenience feature in which the
        # SET symbol will be automatically declared as local.
        if operation == "SETA":
            dv = 0
        elif operation == "SETB":
            dv = False
        elif operation == "SETC":
            dv = ""
        else:
            error(properties, "Instruction is not SETA, SETB, or SETC")
            return
        sv = svLocals
        svLocals[sname] = dv
    else:
        error(properties, "Symbolic variable %s undeclared" % sname)
        return
    v = sv[sname]
    if isinstance(v, list):
        if "exp" not in pname:
            error(properties, "Is subscripted: %s" % sname)
            return
        # Note that the following is just to get a representative value from 
        # the list for testing the datatype, *not* to get the specific element
        # which is indexed.
        v = v[0]
    elif "exp" in pname:
        error(properties, "Is not subscripted: %s" % sname)
        return
    if operation == "SETA" and isinstance(v, int):
        ast = parserASM(operand, "arithmeticExpressionOnly")
        if ast == None:
            error(properties, "Cannot parse arithmetic expression %s" % operand)
            return
        value = evalArithmeticExpression(ast, svLocals, properties)
    elif operation == "SETB" and isinstance(v, bool):
        ast = parserASM(operand, "booleanExpressionOnly")
        if ast == None:
            error(properties, "Cannot parse boolean expression %s" % operand)
            return
        value = evalBooleanExpression(ast, svLocals, properties)
    elif operation == "SETC" and isinstance(v, str):
        ast = parserASM(operand, "characterExpressionOnly")
        if ast == None:
            error(properties, "Cannot parse character expression %s" % operand)
            return
        value = evalCharacterExpression(ast, svLocals, properties)
        if value != None:
            value = value[:8] # Max length of a SETC symbol is 8 characters.
    else:
        error(properties, "Data type doesn't match %s" % sname)
        return
    if value == None:
        error(properties, "Unable to evaluate data expression %s" % operand)
        return
    if "exp" not in pname:
        sv[sname] = value
        return
    index = evalArithmeticExpression(pname["exp"], svLocals, properties)
    if index == None:
        error(properties, "Cannot evaluate subscript in %s" % name)
        return
    index -= 1 # Change from 1-based to 0-based.
    if index < 0 or index >= len(sv[sname]):
        error(properties, "Index out of range: %s" % name)
        return
    sv[sname][index] = value

#=============================================================================
# Stand-alone test mode (versus the normal usage as an imported module).

if __name__ == "__main__":
    import sys
    
    # Some predefined symbolic variables, for no particular reason.
    svLocals = { 
        "&LAA": 3,
        "&LAB": [4, 5, 6],
        "&LBA": False,
        "&LBB": [True, False, True, True],
        "&LCA": "HELLO",
        "&LCB": ["GOODBYE", "THIS", "IS", "THE", "END"]
        }
    svGlobals["&GAA"] = 2
    svGlobals["&GAB"] = [1, 2, 3, 4]
    svGlobals["&GBA"] = True
    svGlobals["&GBB"] = [False, True, False, False]
    svGlobals["&GCA"] = "SNARFLES"
    svGlobals["&GCB"] = ["THE", "QUALITY", "OF", "MERCY", "IS", "NOT"]
    
    print("""
The input loop accepts any of the following:
    An empty line (exits the program).
    The word LIST (which displays all defined symbolic variables).
    A declaration (of type GBLA, ..., LCLC).
    An assignment (of the form SV SETA OPERAND or SETB or SETC).
    An arithmetic expression.
    A boolean expression.
    A character expression.
Various symbolic variables have been predefined.""")
    while True:
        print()
        print("> ", end="")
        line = input().strip()
        if len(line) == 0:
            break
        if line == "LIST":
            print("Local symbolic variables:")
            for key in sorted(svLocals):
                value = svLocals[key]
                if isinstance(value, str):
                    value = "'" + value + "'"
                print("\t%s:" % key, value)
            print("Global symbolic variables:")
            for key in sorted(svGlobals):
                value = svGlobals[key]
                if isinstance(value, str):
                    value = "'" + value + "'"
                print("\t%s:" % key, value)
            continue
        fields = line.split(None, 1)
        if len(fields) == 2 and \
                fields[0] in { "GBLA", "GBLB", "GBLC", "LCLA", "LCLB", "LCLC"}:
            print("Declaration")
            properties = { "errors": [] }
            svDeclare(fields[0], fields[1], svLocals, properties)
            if len(properties["errors"]) > 0:
                for errorMessage in properties["errors"]:
                    print(errorMessage)
            continue
        fields = line.split(None, 2)
        if len(fields) == 3 and fields[1] in { "SETA", "SETB", "SETC"}:
            print("Assignment")
            properties = { "errors": [] }
            svSet(fields[1], fields[0], fields[2], svLocals, properties)
            if len(properties["errors"]) > 0:
                for errorMessage in properties["errors"]:
                    print(errorMessage)
            continue
        arithmeticExpression = parserASM(line, "arithmeticExpressionOnly")
        if arithmeticExpression != None:
            print("Arithmetic expression")
            properties = { "errors": [] }
            value = evalArithmeticExpression(arithmeticExpression, svLocals, properties)
            if value != None:
                print("\t%d" % value)
            if len(properties["errors"]) > 0:
                for errorMessage in properties["errors"]:
                    print(errorMessage)
        booleanExpression = parserASM(line, "booleanExpressionOnly")
        if booleanExpression != None:
            print("Boolean expression")
            properties = { "errors": [] }
            value = evalBooleanExpression(booleanExpression, svLocals, properties)
            if value != None:
                print("\t" + str(value))
            if len(properties["errors"]) > 0:
                for errorMessage in properties["errors"]:
                    print(errorMessage)
        characterExpression = parserASM(line, "characterExpressionOnly")
        if characterExpression != None:
            print("Character expression")
            properties = { "errors": [] }
            value = evalCharacterExpression(characterExpression, svLocals, properties)
            if value != None:
                print("\t'" + value + "'")
            if len(properties["errors"]) > 0:
                for errorMessage in properties["errors"]:
                    print(errorMessage)
        if arithmeticExpression == None and booleanExpression == None and \
                characterExpression == None:
            print("Cannot interpret this line as a supported type")
            