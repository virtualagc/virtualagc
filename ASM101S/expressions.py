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
            2026-05-28 RSB  Implemented EBCDIC collation for macro-language
                            string comparisons.
            2026-05-29 RSB  Implemented `ORG` for issue #1333.

There is a stand-alone mode that can be used for testing and certain setups,
but mainly this file is a module to be imported into ASM101S.  

Note that in all cases within this module, an "expression" is a so-called AST
(Abstract Syntax Tree) in the form returned by a TatSu parser.
'''

import sys
import re
from fieldParser import parserASM
from asciiToEbcdic import *

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

#=============================================================================
# Macro arguments and sublists.
#
# A macro argument is a character string, except where the source text wrapped
# it in parentheses, in which case it is a *sublist* whose entries are
# themselves macro arguments, nested to any depth.  The argument is passed
# through verbatim:  for an operand written `(10,(100,200,300),30)`,
# `&SYSLIST(2)` yields that text back, parentheses and all, and further
# subscripts index into it -- `&SYSLIST(2,2)` is `(100,200,300)` and
# `&SYSLIST(2,2,3)` is `300`.  Multilevel sublists are an Assembler H feature,
# described in the Assembler H General Information Manual, GC26-3758-3
# (January 1974), p.13; the same rules survive as Table 49 of the HLASM
# Language Reference, SC26-4940.  They are not an AP-101S invention, which is
# why the Assembler F manual of 1967 has nothing to say about them.
#
# `Sublist` is a tuple subclass, so that a sublist is distinguishable from a
# SETA/SETB/SETC array (a plain Python list) and from the anonymous tuples that
# make up a parse tree.
class Sublist(tuple):
    pass

# Render a macro argument back into the source text it was written as.  A
# sublist is always parenthesised, so the empty sublist `()` -- which is one
# null entry, not zero entries -- renders as `()` rather than as nothing.
def renderMacroArgument(value):
    if isinstance(value, Sublist):
        return "(" + ",".join(map(renderMacroArgument, value)) + ")"
    if value == None:
        return ""
    if isinstance(value, bool):
        return "1" if value else "0"
    if isinstance(value, str):
        return value
    return str(value)

# Apply macro-argument subscripts, 1-based, in order.  An argument that is not
# a sublist behaves as a sublist of one entry, so `&P(1)` is `&P`; a subscript
# past the end yields a null string rather than an error.
def subscriptMacroArgument(value, indices):
    for index in indices:
        if not isinstance(value, Sublist):
            value = Sublist((value,))
        if index < 1 or index > len(value):
            return ""
        value = value[index - 1]
    return value

# N' of a macro argument:  the number of entries in a sublist, and 1 for
# anything else.  An omitted entry still counts, so N' of `(A,,C)` and of
# `(A,B,)` are both 3, and N' of `()` is 1.
def countMacroArgument(value):
    if isinstance(value, Sublist):
        return len(value)
    return 1

# Whether a value can be used as an arithmetic term, and what it is worth if
# so.  GC26-3758-3 p.19:  a character string may be used as an arithmetic term
# when it represents a valid self-defining term, and "a null value is treated
# as zero".  SC26-4940 Table 58 extends that to symbolic parameters and to
# `&SYSLIST(n)`/`&SYSLIST(n,m)`.  That leaves exactly three cases -- null,
# which is zero; a self-defining term, which is its value; and anything else,
# including a whole sublist, which is a program error to diagnose rather than
# something to coerce.  Returns an (ok, value) pair.
def selfDefiningTerm(value):
    if isinstance(value, bool):
        return True, (1 if value else 0)
    if isinstance(value, int):
        return True, value
    if not isinstance(value, str):
        return False, None
    s = value.strip()
    if s == "":
        return True, 0
    try:
        if s[:2] == "X'" and s[-1:] == "'":
            return True, int(s[2:-1], 16)
        if s[:2] == "B'" and s[-1:] == "'":
            return True, int(s[2:-1], 2)
        if s[:2] == "C'" and s[-1:] == "'":
            n = 0
            for c in s[2:-1]:
                n = (n << 8) | asciiToEbcdic[ord(c)]
            return True, n
        if s.isdigit() or (s[:1] in ["+", "-"] and s[1:].isdigit()):
            return True, int(s)
    except:
        return False, None
    return False, None

# Whether `name` is a macro argument -- &SYSLIST, or a symbolic parameter of
# the macro currently being expanded -- as opposed to a SETA/SETB/SETC
# variable.  Only macro arguments can be sublists, and only they may carry
# more than one subscript.  Symbolic parameters are recognised by the metadata
# entry that `readSourceFile` records alongside them.
def isMacroArgument(name, value, svLocals):
    return name == "&SYSLIST" or isinstance(value, Sublist) or \
           ("_" + name) in svLocals

# Evaluate the subscripts of a parsed `&NAME(exp{,exp})`, which the grammar
# hands over as the first expression and the AST of the repetition that
# follows it.  Returns a list of integers, or `None` if any of them cannot be
# evaluated.
def subscriptList(first, rest, svLocals, properties, symtab = {}, star = None, \
                  severity = 255):
    expressions = [first]
    for e in rest:
        if isinstance(e, (list,tuple)) and len(e) == 2 and e[0] == ",":
            expressions.append(e[1])
        else:
            error(properties, "Unrecognized subscript %s" % str(e), severity)
            return None
    indices = []
    for e in expressions:
        n = evalArithmeticExpression(e, svLocals, properties, symtab, star, \
                                     severity)
        if n == None:
            error(properties, "Cannot evaluate subscript %s" % str(e), severity)
            return None
        indices.append(n)
    return indices

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
            indices = []
            for e in ast["exp"]:
                n = evalArithmeticExpression(e, svLocals, properties)
                if n == None:
                    error(properties, "Cannot evaluate index of %s: %s" % \
                          (sv, str(ast["exp"])))
                    break
                indices.append(n)
            if len(indices) != len(ast["exp"]):
                continue
            if isMacroArgument(sv, replacement, svLocals):
                if sv == "&SYSLIST" and indices[0] == 0:
                    # &SYSLIST(0) is the name field of the macro invocation.
                    replacement = subscriptMacroArgument( \
                                        svLocals.get("&SYSLIST0", ""), indices[1:])
                else:
                    replacement = subscriptMacroArgument(replacement, indices)
                end = start + ast.parseinfo.endpos
            elif isinstance(replacement, (list,tuple)):
                # A SETA/SETB/SETC array, which takes exactly one subscript.
                if len(indices) != 1:
                    error(properties, "Too many subscripts for %s" % sv)
                    continue
                n = indices[0] - 1
                if n < 0 or n >= len(replacement):
                    error(properties, "Index of %s(%d) out of range" % (sv, n+1))
                    continue
                replacement = replacement[n]
                end = start + ast.parseinfo.endpos
            else:
                # Not subscriptable at all, so the parentheses are not a
                # subscript:  they belong to whatever the variable is embedded
                # in, as in the address `&D(&X,&B)`.  Replace the bare variable
                # and leave the rest of the text alone.
                pass
        if end < len(text) and text[end] == ".": # Optional "join" character.
            end += 1
        if isinstance(replacement, Sublist):
            # K' is the length of the sublist's text, N' its number of entries.
            if text[start-2:start] == "N'":
                start -= 2
                replacement = str(countMacroArgument(replacement))
            elif text[start-2:start] == "K'":
                start -= 2
                replacement = str(len(renderMacroArgument(replacement)))
            else:
                replacement = renderMacroArgument(replacement)
        elif isinstance(replacement, bool):
            # Before the `int` case:  a Python bool *is* an int.
            replacement = "1" if replacement else "0"
        elif isinstance(replacement, int):
            replacement = str(replacement)
        elif isinstance(replacement, (list,tuple)):
            if text[start-2:start] in ["K'", "N'"]:
                start -= 2
                replacement = str(len(replacement))
            else:
                error(properties, "Cannot use array as a replacement: %s=%s" % \
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

# Render a parsed expression back into something close to the source text it
# came from, for use in diagnostics.  The AST is mostly nested lists of the
# original tokens, so flattening it recovers the text well enough to identify
# which statement is at fault -- which is the whole difficulty with a message
# like "Eval error type 3", that names nothing at all.
def describeExpression(expression, depth=0):
    if depth > 12:
        return "..."
    if isinstance(expression, str):
        return expression
    if isinstance(expression, dict):
        return ''.join(describeExpression(v, depth + 1)
                       for k, v in expression.items() if k != "parseinfo")
    if isinstance(expression, (list, tuple)):
        return ''.join(describeExpression(e, depth + 1) for e in expression)
    if expression == None:
        return ""
    return str(expression)

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
        literal = expression        # kept whole; a Z literal needs A1 and A2
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
            # F and H are FIXED-point types, so an integral value must come
            # back as an int.  Testing with `isdigit` sent every negative one
            # down the float path -- `=F'-5'` became -5.0 -- and a float in an
            # address context is what raises TypeError on a bitwise AND
            # further down.  Only E and D are floating point.
            s = "".join(expression)
            try:
                return int(s)
            except ValueError:
                return float(s)
        elif datatype == "Y":
            # A Y LITERAL HOLDS AN EXPRESSION, evaluated exactly as the
            # generator evaluates the one in `DC Y(...)`.  What stood here
            # looked the operand up as a bare symbol name and then read a
            # "pos1" key that symbol table entries do not have -- they carry
            # "address" -- so it could not have worked for any input.  The
            # value comes back hashed if it is relocatable, which is what the
            # caller wants; see the Y case of `evalLiteralAttributes`.
            return evalArithmeticExpression(expression, svLocals, properties, \
                                            symtab, star, severity)
        elif datatype == "Z":
            # A ZCON literal, `=Z(,address,flags)`.  Its encoding is not
            # documented anywhere; it was derived from the original build,
            # where `DC Z(FCMTRACE,FCMTRCLG,15)` assembles to 00000F00 and
            # `=Z(,FPMXQETB+2,0)` to 00020000.  Those two between them fix all
            # four bytes:
            #
            #     bytes 0-1   the ABSOLUTE part of the address expression,
            #                 the "+2" above; the symbolic part becomes a
            #                 relocation the linker fills in
            #     byte 2      the flags, 15 above
            #     byte 3      reserved, always zero
            #
            # which is the same layout `DC Z(...)` already emitted.
            address = evalArithmeticExpression(literal["A1"], svLocals, \
                                               properties, symtab, star, \
                                               severity)
            flags = evalArithmeticExpression(literal["A2"], svLocals, \
                                             properties, symtab, star, \
                                             severity)
            if address == None or flags == None:
                error(properties, \
                      "Cannot evaluate the operands of a Z-type literal")
                return None
            return ((address & 0xFFFF) << 16) | ((flags & 0xFF) << 8)
        error(properties, "Literals =%s not implemented" % datatype)
        return None
            
    if isinstance(expression, str):
        # A LEADING PLUS COUNTS AS A NUMBER, as a leading minus already did.
        # FIOMCNTL writes `@TI +1`, and the token reached here as the string
        # "+1", failed this test, and was looked up as a symbol of that name.
        if expression.isdigit() or (expression[:1] in ["+", "-"] \
                                    and expression[1:].isdigit()):
            return int(expression)
        sv = None
        if expression in svLocals:
            sv = svLocals
        elif expression in svGlobals:
            sv = svGlobals
        if sv != None:
            sv = sv[expression]
            ok, value = selfDefiningTerm(sv)
            if ok:
                return value
            error(properties, \
                  "Cannot be interpreted as an integer value: '%s' (%s)" % \
                  (renderMacroArgument(sv), expression), severity)
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
        # A bare term that resolved to nothing.  Having got this far it is not
        # a number, not a symbolic variable, not '*', and either absent from
        # the symbol table or present without a value yet -- and those two are
        # worth telling apart, because the second is an ordinary forward
        # reference on an early pass and the first is a real undefined symbol.
        if isinstance(expression, str):
            if expression in symtab:
                error(properties, \
                      "Symbol '%s' has no value yet" % expression, severity)
            else:
                error(properties, "Undefined symbol '%s'" % expression, severity)
        else:
            error(properties, "Not an arithmetic term: %s" % \
                  describeExpression(expression), severity)
        return None
    if len(expression) == 5 and expression[1] == "(" and expression[4] == ")" \
            and isinstance(expression[0], str) and expression[0].startswith("&"):
        arrayName = expression[0]
        if arrayName in svLocals:
            arrayData = svLocals[arrayName]
        elif arrayName in svGlobals:
            arrayData = svGlobals[arrayName]
        else:
            error(properties, "Cannot find %s" % arrayName)
            return None
        indices = subscriptList(expression[2], expression[3], svLocals, \
                                properties, symtab, star, severity)
        if indices == None:
            return None
        if isMacroArgument(arrayName, arrayData, svLocals):
            if arrayName == "&SYSLIST" and indices[0] == 0:
                value = subscriptMacroArgument(svLocals.get("&SYSLIST0", ""), \
                                               indices[1:])
            else:
                value = subscriptMacroArgument(arrayData, indices)
            ok, n = selfDefiningTerm(value)
            if ok:
                return n
            # Not a coercion failure to paper over.  A sublist or a symbol has
            # no arithmetic value, and saying so is the whole point:  comparing
            # it cleanly would turn a loud failure into a wrong assembly.
            error(properties, \
                  "%s is not a self-defining term: '%s'" % \
                  (arrayName, renderMacroArgument(value)), severity)
            return None
        if not isinstance(arrayData, list):
            error(properties, "%s is not an array" % arrayName)
            return None
        if len(indices) != 1:
            error(properties, "Too many subscripts for %s" % arrayName)
            return None
        index = indices[0] - 1
        if index < 0 or index >= len(arrayData):
            error(properties, "Index is out of range (%d > %d)" % \
                  (index+1, len(arrayData)))
            return None
        ok, n = selfDefiningTerm(arrayData[index])
        if ok:
            return n
        error(properties, \
              "Cannot be interpreted as an integer value: '%s' (%s)" % \
              (renderMacroArgument(arrayData[index]), arrayName), severity)
        return None
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
        indices = None
        if isinstance(symvar, (tuple,list)):
            if len(symvar) == 5 and symvar[1] == '(' and symvar[4] == ')':
                pass
            else:
                error(properties, "Unrecognized operand of %s: %s" % \
                      (op, str(symvar)), severity)
                return None
            indices = subscriptList(symvar[2], symvar[3], svLocals, properties, \
                                    symtab, star, severity)
            if indices == None:
                return None
            symvar = symvar[0]
        if symvar in svLocals:
            sv = svLocals
        elif symvar in svGlobals:
            sv = svGlobals
        elif op == "L'" and indices == None:
            # L' OF A PROGRAM SYMBOL, not of a symbolic variable.  This branch
            # existed only for the macro-time attributes, so `L'TIOQSELF` --
            # a symbol defined by a DS in a DSECT -- was diagnosed as a missing
            # symbolic variable, which is what blocks FIOCBLKS.  The attribute
            # is recorded where the symbol is defined; see the comment on
            # `lengthAttribute` in model101.py for the unit and the evidence.
            #
            # A symbol that exists but carries no length attribute is NOT the
            # same as one that does not exist, and the two are reported
            # separately so the next such case says which it was.
            entry = symtab.get(symvar)
            if entry == None:
                error(properties, "Symbol %s not found for L'" % symvar, \
                      severity)
                return None
            if "lengthAttribute" not in entry:
                error(properties, \
                      "Symbol %s has no length attribute" % symvar, severity)
                return None
            return entry["lengthAttribute"]
        else:
            error(properties, "Symbolic variable %s not found" % symvar, severity)
            return None
        var = sv[symvar]
        if indices != None:
            if isMacroArgument(symvar, var, sv):
                if symvar == "&SYSLIST" and indices[0] == 0:
                    var = subscriptMacroArgument(svLocals.get("&SYSLIST0", ""), \
                                                 indices[1:])
                else:
                    var = subscriptMacroArgument(var, indices)
            elif len(indices) != 1:
                error(properties, "Too many subscripts for %s" % symvar, severity)
                return None
            else:
                index = indices[0] - 1 # Change 1-based to 0-based.
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
            return countMacroArgument(var)
        elif op == "K'":
            # The number of characters in the value, which for a sublist is the
            # width of its source text rather than its number of entries.
            return len(renderMacroArgument(var))
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
                            # Assembler division is INTEGER division with the
                            # remainder discarded, and division by zero yields
                            # zero rather than failing (GC28-6514-8 p.28).
                            # Python's `/` is true division, so this produced a
                            # float, which then reached `unhash` and raised
                            # TypeError on a bitwise AND.  Truncation is toward
                            # zero rather than floor, so -7/2 is -3 and not -4,
                            # which is why this is not simply `//`.
                            if right == 0:
                                left = 0
                            else:
                                quotient = abs(left) // abs(right)
                                if (left < 0) != (right < 0):
                                    quotient = -quotient
                                left = int(quotient)
                    else:
                        # The right-hand operand of an arithmetic operator.
                        error(properties, \
                              "Cannot evaluate '%s' in the expression '%s'" % \
                              (describeExpression(entry[1]),
                               describeExpression(expression)), severity)
                        return None
                return left
    # Nothing in the evaluator recognised the shape of this expression.  Show
    # it, because the alternative -- the bare "Eval error type 3" this replaced
    # -- was the commonest diagnostic in the FCOS corpus and identified nothing.
    error(properties, "Cannot evaluate the expression '%s'" % \
          describeExpression(expression), severity)
    return None

# For debugging ...
def printMultiLevelTuple(tin, depth=0):
    def indent(n): return '    '*n
    print(f"{indent(depth)}(")
    for t in tin:
        if not isinstance(t, (tuple, list)):
            print(f"{indent(depth+1)}{t}")
        else:
            printMultiLevelTuple(t, depth+1)
    print(f"{indent(depth)})")
    
# Resolve the operand of a T' or D' attribute -- a bare symbol, a symbolic
# variable, or a subscripted one such as `&SYSLIST(1)` or `&SYSLIST(&I,3)` --
# to the text it stands for.  Returns a (found, text, isArgument) triple, where
# `found` is False when the variable is not defined at all and `isArgument`
# says whether it is a macro argument rather than a SET variable or an
# ordinary symbol.
def attributeOperand(properties, operand, svLocals):
    indices = None
    if isinstance(operand, str):
        if operand[:1] != "&":
            return True, operand, False        # an ordinary symbol
        name = operand
    elif isinstance(operand, (list,tuple)) and len(operand) == 5 and \
            operand[1] == "(" and operand[4] == ")" and \
            isinstance(operand[0], str) and operand[0][:1] == "&":
        name = operand[0]
        indices = subscriptList(operand[2], operand[3], svLocals, properties)
        if indices == None:
            return False, "", False
    else:
        return False, "", False
    if name in svLocals:
        value = svLocals[name]
    elif name in svGlobals:
        value = svGlobals[name]
    else:
        return False, "", False
    isArgument = isMacroArgument(name, value, svLocals)
    if indices != None:
        if isArgument:
            if name == "&SYSLIST" and indices[0] == 0:
                value = subscriptMacroArgument(svLocals.get("&SYSLIST0", ""), \
                                               indices[1:])
            else:
                value = subscriptMacroArgument(value, indices)
        elif len(indices) == 1 and isinstance(value, (list,tuple)):
            i = indices[0] - 1
            value = value[i] if 0 <= i < len(value) else ""
        else:
            return False, "", False
    return True, renderMacroArgument(value), isArgument

# The symbol table of the assembly in progress.  `evalCharacterExpression` and
# the chain beneath it take no symtab argument -- they were written for the
# macro-time expressions, where there is not yet a symbol table to take -- but
# T' of a program symbol has to be answered out of one.  model101.py points
# this at the real table rather than eight signatures being widened, and every
# lookup through it treats an absent symbol exactly as before.
programSymtab = {}
def setProgramSymtab(table):
    global programSymtab
    programSymtab = table

# The type attribute T'.  The AP-101S macro library tests only two of its
# values, and they are the two the manuals define for a macro argument
# (SC26-4940 Table 58):  'O' when the operand was omitted or is null, and 'N'
# when it is a self-defining term.  A macro argument that is neither -- a
# symbol name, a sublist -- is 'U', undefined.
#
# For anything that is not a macro argument the previous answer of 'C' is
# kept.  Distinguishing the storage types of an ordinary symbol would need
# information this function does not have, and inventing an answer would be
# worse than continuing to give the one the rest of the assembler was written
# against.
def typeAttribute(properties, operand, svLocals, symtab=None):
    if symtab == None:
        symtab = programSymtab
    found, text, isArgument = attributeOperand(properties, operand, svLocals)
    if found and text == "":
        # NULL IS 'O' FOR A SET SYMBOL TOO, not only for a macro argument.
        # DCHAR and SCHAR copy their operand into a local SETC and then test
        # `T'&C EQ 'O'` to decide whether it was supplied -- `DCHAR L,` and
        # `DCHAR  ,1` are both ordinary in these sources -- so answering 'C'
        # for the null value let the guard fall through and called CHAR with
        # nothing, which then said OPERAND MISSING.  BILDNEW5 raised that
        # 2679 times and the original build raised it not once.
        return "O"
    if not found:
        # A SYMBOL MAY CARRY ITS OWN TYPE ATTRIBUTE, given outright by the
        # third operand of a three-operand EQU.  That is how the position
        # symbols are typed -- PDEF writes `EQU 1,1,C'#'` -- and the POS macro
        # branches on the answer, so it cannot be the blanket "U" that every
        # unknown operand used to get.
        entry = symtab.get(operand) if isinstance(operand, str) else None
        if entry != None and "typeAttribute" in entry:
            return entry["typeAttribute"]
        return "U"
    if not isArgument:
        entry = symtab.get(text) if isinstance(text, str) else None
        if entry != None and "typeAttribute" in entry:
            return entry["typeAttribute"]
        return "C"
    if text == "":
        return "O"
    ok, value = selfDefiningTerm(text)
    return "N" if ok else "U"

# Evaluate the relations EQ, NE, LT, LE, GT, and GE.
def evaluateRelation(rawLeft, op, rawRight, svLocals, properties):
    left = unroll(rawLeft)
    right = unroll(rawRight)
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
        return False
    # Arithmetical
    if not leftIsString and not rightIsString:
        valLeft = evalArithmeticExpression(left, svLocals, properties)
        if valLeft != None:
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
                  "Cannot evaluate relational expression %s %s %s" \
                  % (str(rawLeft), op, str(rawRight)))
            return False
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
                else:
                    cmp = 0
                    for i in range(len(valLeft)):
                        cLeft = asciiToEbcdic[ord(valLeft[i])]
                        cRight = asciiToEbcdic[ord(valRight[i])]
                        if cLeft < cRight:
                            cmp = -1
                            break
                        elif cLeft > cRight:
                            cmp = 1
                            break
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
          "Cannot evaluate relational expression %s %s %s" \
          % (str(rawLeft), op, str(rawRight)))
    return False

# Evaluate a boolean expression, returning True, False, or None (error).
def evalBooleanExpression(expression, svLocals, properties = { "errors": [] }):
    global svGlobals
    
    expression = unroll(expression)
    
    # A parenthesised sub-expression, which may have blanks inside the
    # parentheses:  ( '(', blanks, expression, blanks, ')' ).
    while isinstance(expression, (tuple,list)) and len(expression) == 5 and \
            expression[0] == '(' and expression[4] == ')':
        expression = unroll(expression[2])
    
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
    if len(expression) == 2 and expression[0] == "D'":
        found, symbol, isArgument = attributeOperand(properties, expression[1], \
                                                     svLocals)
        if not found:
            return False
        return (symbol in definedNormalSymbols)
    # &A(...)
    if len(expression) == 5 and isinstance(expression[0], str) and \
            expression[0][:1] == "&" and \
            expression[1] == '(' and expression[4] == ')':
        sv = expression[0]
        if sv in svLocals:
            scope, what = svLocals, "local"
        elif sv in svGlobals:
            scope, what = svGlobals, "global"
        else:
            error(properties, \
                  "Symbolic variable %s not found in local or global scope" % sv)
            return None
        indices = subscriptList(expression[2], expression[3], svLocals, properties)
        if indices == None:
            return None
        if isMacroArgument(sv, scope[sv], scope):
            if sv == "&SYSLIST" and indices[0] == 0:
                return subscriptMacroArgument(svLocals.get("&SYSLIST0", ""), \
                                              indices[1:])
            return subscriptMacroArgument(scope[sv], indices)
        if not isinstance(scope[sv], list):
            error(properties, \
                  "Access to non-subscripted %s %s" % (what, sv))
            return None
        if len(indices) != 1:
            error(properties, "Too many subscripts for %s" % sv)
            return None
        n = indices[0] - 1  # Convert 1-based to 0-based
        if n < 0 or n >= len(scope[sv]):
            error(properties, \
                  "Subscript out of range for %s %s(%d)" % (what, sv, n+1))
            return None
        return scope[sv][n]
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
        # `booleanExpression = booleanTerm { 'OR' booleanTerm }` gives one
        # repetition per additional term, so a chain of N terms arrives as
        # N-1 of them.  This used to accept ONE and nothing else, testing
        # `len(right) == 4` against a single repetition -- so `A OR B` worked
        # and `A OR B OR C` could not be evaluated at all, nor could any AND
        # chain longer than two.  STKINS tests five alternatives, which is why
        # the IF macro stopped recognising its own condition mnemonics.
        left = unroll(expression[0])
        rest = expression[1]
        single = unroll(rest)
        if isinstance(single, (tuple,list)) and len(single) == 4 and \
                single[1] in ["AND", "OR"]:
            repetitions = [single]
        elif isinstance(rest, (tuple,list)):
            repetitions = list(rest)
        else:
            repetitions = []
        if repetitions and all(isinstance(r, (tuple,list)) and len(r) == 4 \
                               and r[1] in ["AND", "OR"] for r in repetitions):
            value = evalBooleanExpression(left, svLocals, properties)
            if value == None:
                error(properties, \
                      "Cannot evaluate boolean expression '%s'" \
                      % describeExpression(left))
                return None
            # AND binds tighter than OR in the grammar, so every operator at
            # this level is the same one and left-to-right is correct.
            for repetition in repetitions:
                operand = evalBooleanExpression(repetition[3], svLocals, \
                                                properties)
                if operand == None:
                    error(properties, \
                          "Cannot evaluate boolean expression '%s'" \
                          % describeExpression(repetition[3]))
                    return None
                if repetition[1] == "OR":
                    value = value or operand
                else:
                    value = value and operand
            return value
    # Relational expressions:
    if len(expression) == 5 and \
            expression[2] in ["EQ", "NE", "LT", "LE", "GT", "GE"]:
        return evaluateRelation(expression[0], expression[2], expression[4],
                                svLocals, properties)
    error(properties, \
          "Cannot evaluate boolean expression '%s'" \
          % describeExpression(expression))
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
            #
            # A DOUBLED QUOTE INSIDE A QUOTED STRING IS ONE QUOTE CHARACTER, and
            # dropping it silently corrupts the value.  This joined the pieces
            # AROUND each `''` and threw the quote itself away, so
            #     &RESERVE SETC  'H''0'''
            # -- MLIB80/TFPSA.asm:111 -- gave `H0` instead of `H'0'`, and the
            # card it is substituted into, `&X 4&RESERVE`, arrived as `DC 4H0`,
            # which no dcOperands rule can parse.  That is FCMPSA's 128
            # intolerable lines, and FCMNINIT's `DS X0000000` is the same defect
            # through a different SETC.  23 members of MLIB80 carry
            # doubled-quote SETC cards.
            s = expression[1]
            for ss in expression[2]:
                if not isinstance(ss, (list,tuple)) or len(ss) != 2 \
                        or ss[0] != "''":
                    error(properties, \
                          "Cannot evaluate string expression: %s" % \
                          str(expression))
                    return None
                s = s + "'" + ss[1]
        elif len(expression) == 2 and expression[0] == "T'":
            return typeAttribute(properties, expression[1], svLocals)
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

# Split the operand of a SETx into its comma-separated list of values.
#
# The split is at TOP LEVEL only: a comma inside a quoted string, or inside
# parentheses, belongs to the value it sits in.  Both cases are real -- CHAR
# writes `'LPAREN','RPAREN'` and also `'&CHAR'(1,&N+4)`, and treating either
# comma as a separator ruins it.
#
# It also stops at the first blank outside a quoted string, because everything
# after that is a trailing comment.  CHAR has one -- `&CHARFLD SETA  32
# BLANK CHAR IS DEFAULT FOR OMITTED OPERAND` -- and so does its neighbour
# CMTX6, whose comment field contains a LONE APOSTROPHE.  Stopping at the
# blank is what keeps that stray quote from swallowing the rest of the card.
def splitSetOperands(operand):
    parts = []
    current = ""
    inQuote = False
    depth = 0
    i = 0
    while i < len(operand):
        c = operand[i]
        if inQuote:
            if c == "'":
                if operand[i+1:i+2] == "'":
                    # A doubled apostrophe is one literal apostrophe and does
                    # not end the string.
                    current += "''"
                    i += 2
                    continue
                inQuote = False
            current += c
        elif c == "'":
            inQuote = True
            current += c
        elif c == " ":
            break
        else:
            if c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
            if c == "," and depth == 0:
                parts.append(current)
                current = ""
            else:
                current += c
        i += 1
    parts.append(current)
    return parts

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
    # Note that these stop at the first blank outside a quoted string, so that
    # a trailing comment on the line is ignored rather than making the whole
    # operand unparsable.
    def evaluate(text):
        if operation == "SETA" and isinstance(v, int):
            ast = parserASM(text, "setaOperand")
            if ast == None:
                error(properties, \
                      "Cannot parse arithmetic expression %s" % text)
                return None
            return evalArithmeticExpression(ast["v"], svLocals, properties)
        elif operation == "SETB" and isinstance(v, bool):
            ast = parserASM(text, "setbOperand")
            if ast == None:
                error(properties, "Cannot parse boolean expression %s" % text)
                return None
            return evalBooleanExpression(ast["v"], svLocals, properties)
        elif operation == "SETC" and isinstance(v, str):
            ast = parserASM(text, "setcOperand")
            if ast == None:
                error(properties, "Cannot parse character expression %s" % text)
                return None
            value = evalCharacterExpression(ast["v"], svLocals, properties)
            if value != None:
                # 8 IS ASSEMBLER F'S LIMIT AND THIS LIBRARY IS ASSEMBLER H,
                # where a SETC value may be up to 255 characters.  The old limit
                # did not reject an over-long value, it silently TRUNCATED one,
                # so the card built from it was cut off mid-symbol and the error
                # surfaced as an unparseable operand naming a symbol that does
                # not exist:
                #     DC  Y(FCMTRA              ZCON A
                # every one of them exactly eight characters wide.  TFPSA builds
                # a whole PSW pair in one SETC --
                #     &SRSTPSW SETC 'Y('.'&SR'.'),X''00'.'&BSR'.'&DSR'.'000C0000'''
                # -- which is nowhere near eight.  These are the PSA macro's
                # new-PSW words, the same family as BILDNEW5's uncovered bytes.
                # fieldParser.py already relies on Assembler H sublist
                # subscripting for this library, so H is the right dialect here.
                value = value[:255]
            return value
        error(properties, "Data type doesn't match %s" % sname)
        return None

    if "exp" not in pname:
        value = evaluate(operand)
        if value == None:
            error(properties, "Unable to evaluate data expression %s" % operand)
            return
        sv[sname] = value
        return
    if len(pname["exp"]) != 1:
        # The target of a SETx is a scalar or one element of an array.  Only a
        # macro argument, which cannot be assigned to, has multiple subscripts.
        error(properties, "Too many subscripts in %s" % name)
        return
    index = evalArithmeticExpression(pname["exp"][0], svLocals, properties)
    if index == None:
        error(properties, "Cannot evaluate subscript in %s" % name)
        return
    index -= 1 # Change from 1-based to 0-based.
    # A SUBSCRIPTED target may be given a LIST of values, assigned to
    # consecutive elements starting at that subscript -- so `&CCODE1(1) SETA
    # 48,49,...,57` fills the first ten, and CHAR builds its 51-entry character
    # table and its five code tables that way and no other.  An omitted entry,
    # `43,,45`, leaves that one element as it was.  Only a subscripted target
    # is split, which is why an unsubscripted SETC operand may still contain a
    # comma of its own.
    for offset, text in enumerate(splitSetOperands(operand)):
        text = text.strip()
        if text == "":
            continue
        value = evaluate(text)
        if value == None:
            error(properties, "Unable to evaluate data expression %s" % text)
            return
        i = index + offset
        if i < 0 or i >= len(sv[sname]):
            error(properties, "Index out of range: %s(%d)" % (sname, i + 1))
            return
        sv[sname][i] = value

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
            