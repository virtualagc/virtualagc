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
from fieldParser import parserASM

# Global symbolic variables for the macro language.  Note that we don't need
# to distinguish between `GBLA`, `GBLB`, and `GBLC` in `svGlobals` (nor between
# `LCLA`, `LCLB`, and `LCLC` in `svLocals` elsewhere), because the datatypes of
# the variables do it for us in Python.  Thus, 0, False, and "".
svGlobals = { }  # Use as `global` in every function.
# There can also be "local" variables in the global context.  By the "global
# local" context, I refer to items defined at the top-level scope but not 
# accessible at any lower levels of the scope hierarchy.
svGlobalLocals = { } # Do *not* use as `global` or `nonlocal`.

# Mark an error in the array of source code.
errorCount = 0
def error(line, msg):
    global errorCount
    errorCount += 1
    line["errors"].append(msg)
def getErrorCount():
    return errorCount

# In parsed expressions, remove useless levels of tuple/list embedding, such
# as [([expression])] -> expression.
def unroll(expression):
    while isinstance(expression, (tuple, list)) and \
            len(expression) == 1 or \
            (len(expression) == 2 and expression[1] == []):
        expression = expression [0]
    return expression

# Evaluate an arithmetic expression to an integer and return it, or else `None`
# on failure.  `properties` is for the line of source code.  `expression` is
# the parsed expression, as returned by the parser function.  `svLocals` and
# `svGlobals` provide the defined symbolic variables, with the locals overriding
# the globals in case of overlap
def evalArithmeticExpression(expression, svLocals, properties = { "errors": [] }):
    global svGlobals
    
    expression = unroll(expression)
    
    if isinstance(expression, str):
        if expression.isdigit():
            return int(expression)
        sv = None
        if expression in svLocals:
            sv = svLocals
        elif expression in svGlobals:
            sv = svGlobals
        if sv != None:
            if isinstance(sv[expression], int):
                return(sv[expression])
            error(properties, "Not an integer value: %s" % expression)
            return None
    if isinstance(expression, (list,tuple)) and len(expression) == 3 and \
            expression[0] == '(' and expression[2] == ')':
        return evalArithmeticExpression(expression[1], svLocals, properties)
    if isinstance(expression, (list,tuple)) and len(expression) == 2:
        left = evalArithmeticExpression(expression[0], svLocals, properties)
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
                    right = evalArithmeticExpression(entry[1], svLocals, properties)
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
                        error(properties, "Eval error")
                        return None
                return left
    error(properties, "Eval error")
    return None

# Evaluate a boolean expression, returning True, False, or None (error).
def evalBooleanExpression(expression, svLocals, properties = { "errors": [] }):
    global svGlobals
    
    expression = unroll(expression)
    
    if isinstance(expression, str):
        if expression == '0':
            return False
        if expression == '1':
            return True
        if expression[:1] == "&":
            # I'm not sure if this case can arise in the program flow, because
            # I haven't yet worked out when replacements of symbolic variables
            # is performed, but it should be okay here anyway.
            if expression in svLocals:
                replacement = svLocals[expression]
            elif expression in svGlobals:
                replacement = svGlobals[expression]
            else:
                error(properties, "Not defined: %s" % expression)
                return None
            ast = parserASM(svLocals[expression], "booleanExpression")
            if ast == None:
                error(properties, "Cannot parse %s (%s) as boolean expression" \
                      % (expression, svLocals[expression]))
                return None
            return evalBooleanExpression(properties, ast, svLocals)
        error(properties, "Implementation error:  %s as boolean expression" \
              % expression)
        return None
    # &A(...)
    if len(expression) == 4 and isinstance(expression[0], str) and \
            expression[0][:1] == "&" and \
            expression[1] == '(' and expression[3] == ')':
        sv = expression[0]
        n = evalArithmeticExpression(properties, expression[2], svLocals)
        if n == None:
            return None
        if sv in svLocals:
            if not isinstance(svLocals[sv], list):
                error(properties, "Access to non-subscripted local %s(%d)" % (sv, n))
                return None
            if n < 0 or n >= len(svLocals[sv]):
                error(properties, "Subscript out of range for local %s(%d)" % (sv, n))
            return svLocals[sv][n]
        if sv in svGlobals:
            if not isinstance(svGlobals[sv], list):
                error(properties, "Access to non-subscripted global %s(%d)" % (sv, n))
                return None
            if n < 0 or n >= len(svGlobals[sv]):
                error(properties, "Subscript out of range for global %s(%d)" % (sv, n))
            return svGlobals[sv][n]
        error(properties, "Symbolic variable %s not found in local or global scope" % sv)
        return None
    # NOT
    if len(expression) == 4 and expression[1] == "NOT":
        right = evalBooleanExpression(properties, expression[3], svLocals)
        if right == None:
            return None
        return (not right)
    # AND, OR
    if len(expression) == 2:
        left = unroll(expression[0])
        right = unroll(expressin[1])
        if isinstance(right, (tuple,list)) and \
                len(right) == 4 and \
                right[1] in ["AND", "OR"]:
            op = right[1]
            valLeft = evalBooleanExpression(properties, left, svLocals)
            if valLeft == None:
                return None
            valRight = evalBooleanExpression(properties, right, svLocals)
            if valRight == None:
                return None
            if op == "OR":
                return (left or right)
            else:
                return (left and right)
    # Relational expressions:
    if len(expression) == 5 and \
            expression[2] in ["EQ", "NE", "LT", "LE", "GT", "GE"]:
        left = unroll(expression[0])
        right = unroll(expression[4])
        
        # ***FIXME***
        return None
    error(properties, "Cannot evaluate boolean expression %s", \
          expression, svLocals)
    return None

# Evaluate a character expression to string and return it, or else `None`
# on failure.  `properties` is for the line of source code.  `expression` is
# the parsed expression, as returned by the parser function.  `svLocals` and
# `svGlobals` provide the defined symbolic variables, with the locals overriding
# the globals in case of overlap
def evalCharacterExpression(expression, svLocals, properties = { "errors": [] }):
    global svGlobals
    
    expression = unroll(expression)
    
    error(properties, "Evaluation of character expressions not yet implemented")
    
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
            ast = parserASM(length, "arithmeticExpression")
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
            if isDifferentType(field[sv], value):
                error(properties, \
                      "Attempt to change type of existing symbolic variable %s" \
                      % field)
            continue
        sv[field] = value

# Set a symbolic variable.  `operation` is one of "SETA", "SETB", "SETC".
# `name` and `operand` are strings.
def svSet(operation, name, operand, svLocals, properties = { "errors": [] }):
    global svGlobals

    pname = parserASM(name, "nameSet")
    if pname == None:
        error(properties, \
              "Cannot parse name field %s" % name)
        return
    if isinstance(pname, tuple):
        pname = pname[0]
    if "sv" not in pname:
        error(properties, \
              "No symbolic variable for assignment")
        return
    sname = pname["sv"][0]
    if sname in svLocals:
        sv = svLocals
    elif sname in svGlobals:
        sv = svGlobals
    else:
        error(properties, "Symbolic variable %s undeclared" % sname)
        return
    v = sv[sname]
    if isinstance(v, list):
        if "exp" not in pname:
            error(properties, "Is subscripted: %s" % sname)
            return
        v = v[0]
    elif "exp" in pname:
        error(properties, "Is not subscripted: %s" % sname)
        return
    if operation == "SETA" and isinstance(v, int):
        ast = parserASM(operand, "arithmeticExpression")
        if ast == None:
            error(properties, "Cannot parse arithmetic expression %s" % operand)
            return
        value = evalArithmeticExpression(ast, svLocals, properties)
    elif operation == "SETB" and isinstance(v, bool):
        ast = parserASM(operand, "booleanExpression")
        if ast == None:
            error(properties, "Cannot parse boolean expression %s" % operand)
            return
        value = evalBooleanExpression(ast, svLocals, properties)
    elif operation == "SETC" and isinstance(v, str):
        ast = parserASM(operand, "characterExpression")
        if ast == None:
            error(properties, "Cannot parse character expression %s" % operand)
            return
        value = evalCharacterExpression(ast, svLocals, properties)
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
            print("Declaration ----------------------------------------------")
            properties = { "errors": [] }
            svDeclare(fields[0], fields[1], svLocals, properties)
            if len(properties["errors"]) > 0:
                for errorMessage in properties["errors"]:
                    print(errorMessage)
            continue
        fields = line.split(None, 2)
        if len(fields) == 3 and fields[1] in { "SETA", "SETB", "SETC"}:
            print("Assignment -----------------------------------------------")
            properties = { "errors": [] }
            svSet(fields[1], fields[0], fields[2], svLocals, properties)
            if len(properties["errors"]) > 0:
                for errorMessage in properties["errors"]:
                    print(errorMessage)
            continue
        arithmeticExpression = parserASM(line, "arithmeticExpression")
        if arithmeticExpression != None:
            print("Arithmetic expression ------------------------------------")
            properties = { "errors": [] }
            value = evalArithmeticExpression(arithmeticExpression, svLocals, properties)
            if value != None:
                print("\t%d" % value)
            if len(properties["errors"]) > 0:
                for errorMessage in properties["errors"]:
                    print(errorMessage)
        booleanExpression = parserASM(line, "booleanExpression")
        if booleanExpression != None:
            print("Boolean expression ---------------------------------------")
            properties = { "errors": [] }
            value = evalBooleanExpression(booleanExpression, svLocals, properties)
            if value != None:
                print("\t" + str(value))
            if len(properties["errors"]) > 0:
                for errorMessage in properties["errors"]:
                    print(errorMessage)
        characterExpression = parserASM(line, "characterExpression")
        if characterExpression != None:
            print("Character expression -------------------------------------")
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
            