#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   generateC.py
Purpose:    This is the code generator for XCOM-I.py which targets the 
            language C.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-27 RSB  Began.
'''

import datetime
import os
from auxiliary import *
from parseCommandLine import *
from xtokenize import xtokenize
from parseExpression import parseExpression

debug = False # Standalone interactive test of expression generation.

# Just for engineering
def errxit(msg, expression = None):
    print("Implementation error:", msg, file=sys.stderr)
    #if expression != None:
    #    print(expression, file=sys.stderr)
    sys.exit(1)
    

'''
Notes on the Translation of XPL or XPL/I Entities to C
------------------------------------------------------

Since XPL entities (such as variables and procedures) are not necessarily 
translated into C entities in a straightforward was as might be naively 
expected, here are some notes as to the details of such translations.

First, identifiers.  All XPL identifiers are case-insensitive, whereas C is 
case-sensitive.  For example, identifiers `z` and `Z` are treated as identical
in XPL but different in C.  In C we translate all of these XPL identifiers
strictly to upper case.  However, in addition to alphanumerics and the 
underscore ('_'), XPL allows the following 3 characters to appear in identifiers
as well: '@', '#', '$'.  These characters are not allowed in identifiers
in C.  Where needed in translation, they are replaced by 'a', 'p', and 'd', 
respectively.  Because these are translated as lower-case, they cannot be 
confused with other characters already present in the identifiers.  For 
additional name alterations, see the notes on PROCEDUREs below.

Second, variables.  Note that local variables of XPL procedures and values
of procedure parameters are *persistent*.  (See McKeeman p. 145.) I.e., storage
for these entities is not released after a procedure terminates, and if the 
same procedure is called later, any local variable not reinitialized in the new 
call, or any parameter not specified in the new call, retains the same value it 
had on the preceding call.  Besides which, unlike XPL, XPL/I does not respect 
array bounds, as well as allowing non-subscripted variables to be used with 
subscripts, thus accessing adjacent values in memory that wouldn't otherwise
be considered part of that value.  Furthermore, certain features of XPL/I
expect that variables are stored in the specific format of that era's IBM
System/360, rather than in the native format of any other target machine.

For all of the reasons mentioned above, XPL/I variables do *not* translate
to C variables.  Rather, in C there is a memory pool, consisting of an
array of bytes, that provides a single place for storage of all XPL/I variables 
(in whatever scope they are defined) and all procedure parameters.  Each of 
these is accessed in the C code by *numerical address* rather than by some C
variable name.  No C names are assigned to individual XPL/I variables!
Moreover, retrieval of data from that pool, or modification of
data in that pool, is via provided functions that are specific to the XPL/I
datatypes, and can convert as needed between the storage format and the format
expected by C.

(The paragraph above slightly simplifies, in that it really only describes the
storage of "normal" XPL variables of type FIXED, BIT, and CHARACTER, and in so 
far as CHARACTER is concerned, it only stores *pointers* to string data.  This
byte array is called `xvars`.  The string data for CHARACTER types is dynamic, 
in the sense that as string values are reassigned, string lengths may change, 
and thus the storage area for the data is subject to rearrangement and garbage
collection.  Moreover, string data is encoded in EBCDIC, and may not correspond
to the C convention of nul-termination of ASCII.  Consequently, the string data  
is stored separately from `xvars` on a heap-like pool called `xstrings`.  
Moreover, XPL/I allows for so-called COMMON blocks, which stores variables in a 
separate memory area.  We handle this simply by partitioning `xvars` into 
two areas, with "normal" variables going into one of the areas, and `COMMON`
variables going into the other; the same `xstring` area is used for both.)

Third, bare code.  XPL/I allows for code at the global scope, outside of any
PROCEDURE.  C does not allow for code (other than variable definitions) outside
of functions.  All XPL/I global code (other than variable definitions) resides,
after translation, in the C `main` function.

Fourth, PROCEDUREs.  XPL/I PROCEDUREs are indeed implemented as C functions.
However, XPL/I PROCEDURE definitions can typically be nested, with associated
scoping inheritance, but standard C does not allow nested function definitions.
(Nested definitions are allowed by some C extensions like `gcc`.)  Because of
that, nested XPL/I PROCEDURE definitions are not translated into nested C
function definitions.  Instead, all of the C functions are global.  The effect
of nesting is mimicked by mangling of the function names.  (The other effect of
nesting is the scoping of variables, but that can be enforced entirely by the 
compiler and is not a problem for the translated code as such.)  

As far as the mangling of PROCEDURE names is concerned, recall first that from
the notes on identifiers above, all identifiers are translated by converting
them to upper case, and by replacing the characters @ # $ (if present) to the
lower-case characters a p d (respectively).  *Additionally*, PROCEDURE names
are prepended with the lower-case character x.  Besides which, a nested
PROCEDURE's name is prepended with all of the names of its parent PROCEDUREs.
For example, if in XPL we had

    A: PROCEDURE;
        B: PROCEDURE;
            C: PROCEDURE;
                ...
            END C;
            ...
        END B;
        ...
    END A;

(which for concreteness return no values) then this would be translated in C 
more-or-less as:

    void A(void) {
        ...
    }
    void AxB(void) {
        ...
    }
    void AxBxC(void) {
        ...
    }

Fifth, parameter lists in CALLs to PROCEDUREs.  Because of the persistence of 
PROCEDURE parameters as mentioned above, parameter lists for PROCEDURE CALLs 
are often truncated by leaving out some parameters at the ends.  For PROCEDUREs 
allowing no parameters (such as in the example of name mangling just given), 
this cannot arise.  However, for all XPL/I PROCEDUREs allowing parameters, the 
translations to C as functions are implemented with the variable-length 
parameter lists supported by `stdarg.h` 
(see https://en.wikipedia.org/wiki/Stdarg.h).  All parameters in XPL/I are 
passed by value rather than by reference, except for strings (in which the 
string "descriptor", consisting of a length and a pointer, is passed).  This
identical technique is used for passing parameters to the C functions.  In 
particular, note that a string is passed as an integer descriptor rather than
as a C pointer.
'''

indentationQuantum = "  "

# Header file in which C prototypes for PROCEDUREs are placed.
pf = None

# A function for walkModel(), for allocating simulated memory.
variableAddress = 0 # Total contiguous bytes allocated in 24-bit address space.
areaNormal = 0 # End of COMMON and start of non-COMMON
useCommon = False # For allocating COMMON vs non-COMMON
useString = False # For allocating character data CHARACTER.
memory = bytearray([0] * (1 << 24));
memoryMap = {}
def allocateVariables(scope, extra = None):
    global variableAddress, memory, memoryMap
    
    # The following functions are the Python equivalents of the functions
    # with the same names in runtimeC.c, and behave identically except that 
    # they are used at compile-time for initialization rather than run-time.
    # Except that `getFIXED` is always going to return an unsigned value
    # rather than a signed value.
    def putFIXED(address, i):
        global memory
        memory[address + 0] = (i >> 24) & 0xFF
        memory[address + 1] = (i >> 16) & 0xFF
        memory[address + 2] = (i >> 8) & 0xFF
        memory[address + 3] = i & 0xFF
    
    def getFIXED(address):
        value = memory[address + 0]
        value = (value << 8) | memory[address + 1]
        value = (value << 8) | memory[address + 2]
        value = (value << 8) | memory[address + 3]
        return value
        
    def putCHARACTER(address, s):
        global memory
        designator = getFIXED(address)
        length = len(s)
        saddress = designator & 0xFFFFFF
        if nullStringMethod == 0:
            if length == 0:
                # In implementation 0, an empty string is stored in
                # the memory[] array as a string of length 1 containing
                # just the EBCDIC NUL character.
                putFIXED(address, saddress)
                memory[saddress] = 0
                return
        if length > 256:
            length = 256
        designator = ((length - 1) << 24) | saddress
        putFIXED(address, designator)
        # Encode the string's character data as an EBCDIC Python byte array.
        b = s.encode('cp1140')
        for i in range(length):
            memory[saddress + i] = b[i]
    
    for identifier in scope["variables"]:
        attributes = scope["variables"][identifier]
        if "PROCEDURE" in attributes:
            continue
        if "FIXED" in attributes:
            datatype = "FIXED"
        elif "BIT" in attributes:
            datatype = "BIT"
        elif "CHARACTER" in attributes:
            datatype = "CHARACTER"
        else:
            continue
        mangled = attributes["mangled"]
        if useString and "CHARACTER" not in attributes:
            continue
        if useCommon:
            if "common" not in attributes:
                continue
        else:
            if "common" in attributes or "parameter" in attributes:
                continue
        length = 1
        # The following needs tweaking TBD.
        if "top" in attributes:
            length = attributes["top"] + 1
        if "INITIAL" in attributes:
            initial = attributes["INITIAL"]
            if not isinstance(initial, list):
                initial = [initial]
        elif "CONSTANT" in attributes:
            # These are not misprints.  CONSTANT is treated just like INITIAL.
            # The CONSTANT attribute is not present in XPL, and is undocumented
            # in XPL/I.  There is a CONSTANT attribute in HAL/S, of course, and
            # the difference from the INITIAL attribute there is that you can't
            # change the value after declaration, and you can use the values 
            # in other INITIAL or CONSTANT attributes.  In the HAL/S-FC source
            # code, as far as I can see, you can use INITIAL for everything
            # declared as CONSTANT.  If this turns out not to be adequate, I'll
            # revisit it later.
            initial = attributes["CONSTANT"]
            if not isinstance(initial, list):
                initial = [initial]
        else:
            initial = []
        if useString:
            memoryMap[variableAddress] = (mangled, "EBCDIC codes")
            attributes["saddress"] = variableAddress
            address = attributes["address"]
            firstAddress = address
            for i in range(length):
                putFIXED(address, variableAddress)
                # INITIALize just CHARACTER variables.
                if "INITIAL" in attributes and "CHARACTER" in attributes and \
                        i < len(initial):
                    initialValue = initial[i]
                    if isinstance(initialValue, str):
                        if len(initialValue) > 256:
                            errxit("String initializer is %d characters" \
                                   % len(initialValue), scope)
                    elif isinstance(initialValue, int):
                        initialValue = "%d" % initialValue
                    else:
                        errxit("Cannot evaluate initializer to CAHARACTER", scope)
                    putCHARACTER(address, initialValue)
                address += 4
                variableAddress += 256
        else:
            memoryMap[variableAddress] = (mangled, datatype)
            attributes["address"] = variableAddress
            if identifier == "SYT_MAX": # ***DEBUG***
                pass
            # INITIALize FIXED or BIT variables.
            if "INITIAL" in attributes and \
                    ("FIXED" in attributes or "BIT" in attributes):
                for initialValue in initial:
                    if length <= 0:
                        errxit("Too many initializers", scope)
                    if isinstance(initialValue, int):
                        putFIXED(variableAddress, initialValue)
                    else:
                        # Not immediately an integer, but perhaps it's an
                        # expression whose value can be computed.  Let's try!
                        tokenized = xtokenize(initialValue)
                        tree = parseExpression(tokenized, 0)
                        if tree != None and "token" in tree and \
                                "number" in tree["token"]:
                            putFIXED(variableAddress, tree["token"]["number"])
                        else:
                            errxit("Initializer is not integer", scope);
                    length -= 1
                    variableAddress += 4
            variableAddress += 4 * length

# A function for `walkModel` that mangles identifier names.
def mangle(scope, extra = None):
    # Determine the mangling prefix.
    prefix = ""
    s = scope
    while True:
        symbol = s["symbol"]
        if symbol != "" and symbol[:1] != "_":
            prefix = symbol + "x" + prefix
        s = s["parent"]
        if s == None:
            break
    scope["prefix"] = prefix
    for identifier in scope["variables"]:
        scope["variables"][identifier]["mangled"] = prefix + identifier

# Recursively generate the source code for a C expression that evaluates a tree
# (previously returned by the `parseExpression` function) created from an XPL 
# expression.  Returns a pair:
#
#    Indicator of the type of the result: "FIXED", "CHARACTER", "INDETERMINATE".
#
#    String containing the generated code.
#
numericOperators = {"|", "&", "~", "+", "-", "*", "/", "mod"}
stringOperators = {"||"}
universalOperators = {"=", "<", ">", "~=", "~<", "~>", "<=", ">="}

def generateExpression(scope, expression):
    
    source = ""
    tipe = "INDETERMINATE" # Recall that `type` is a reserved word in Python.
    if not isinstance(expression, dict):
        return tipe, source
    token = expression["token"]
    if "number" in token:
        tipe = "FIXED"
        source = str(token["number"])
    elif "string" in token:
        tipe = "CHARACTER"
        source = '"' + \
                 token["string"].replace('"', '\\\"').replace("`", "''") + '"'
    elif "operator" in token:
        operator = token["operator"]
        if operator in numericOperators or operator in universalOperators:
            tipe = "FIXED"
        elif operator in stringOperators:
            tipe = "CHARACTER"
        operands = expression["children"]
        operand1 = operands[0]
        tipe1, source1 = generateExpression(scope, operand1)
        if tipe1 == None:
            errxit("Cannot evaluate " + str(operand1))
        elif tipe1 == "FIXED" and operator in stringOperators:
            #errxit("Mismatched string and numeric")
            source1 = "fixedToCharacter( " + source1 + " )"
            tipe1 = "CHARACTER"
        elif tipe1 == "CHARACTER" and operator in numericOperators:
            errxit("Mismatched string and numeric")
        if len(operands) == 1:
            if operator == "-":
                source = "xminus(" + source1 + ")"
            elif operator == "~":
                source = "xNOT(" + source1 + ")"
            else:
                errxit("Unsupported unary " + operator)
        elif len(operands) == 2:
            operand2 = operands[1]
            tipe2, source2 = generateExpression(scope, operand2)
            smod = "x"
            if tipe1 == "CHARACTER":
                smod = "xs"
            if tipe1 == None:
                errxit("Cannot evaluate " + str(operand1))
            elif tipe1 in ["FIXED", "BIT"] and operator in stringOperators:
                source1 = "fixedToCharacter( " + source1 + " )"
                tipe1 = "CHARACTER"
            elif tipe1 == "CHARACTER" and operator in numericOperators:
                errxit("Mismatched string and numeric")
            if tipe2 == None:
                errxit("Cannot evaluate " + str(operand2))
            elif tipe2 in ["FIXED", "BIT"] and operator in stringOperators:
                source2 = "fixedToCharacter( " + source2 + " )"
                tipe2 = "CHARACTER"
            elif tipe2 == "CHARACTER" and operator in numericOperators:
                errxit("Mismatched string and numeric")
            if operator == "+":
                source = "xadd(" + source1 + ", " + source2 + ")"
            elif operator == "-":
                source = "xsubtract(" + source1 + ", " + source2 + ")"
            elif operator == "*":
                source = "xmultiply(" + source1 + ", " + source2 + ")"
            elif operator == "/":
                source = "xdivide(" + source1 + ", " + source2 + ")"
            elif operator == "mod":
                source = "xmod(" + source1 + ", " + source2 + ")"
            elif operator == "=":
                source = smod + "EQ(" + source1 + ", " + source2 + ")"
            elif operator == "<":
                source = smod + "LT(" + source1 + ", " + source2 + ")"
            elif operator == ">":
                source = smod + "GT(" + source1 + ", " + source2 + ")"
            elif operator == "~=":
                source = smod + "NEQ(" + source1 + ", " + source2 + ")"
            elif operator == "<=" or operator == "~>":
                source = smod + "LE(" + source1 + ", " + source2 + ")"
            elif operator == ">=" or operator == "~<":
                source = smod + "GE(" + source1 + ", " + source2 + ")"
            elif operator == "|":
                source = "xOR(" + source1 + ", " + source2 + ")"
            elif operator == "&":
                source = "xAND(" + source1 + ", " + source2 + ")"
            elif operator == "||":
                source = "xsCAT(" + source1 + ", " + source2 + ")"
            else:
                errxit("Unsupported binary operator " + operator)
        else:
            errxit("Too many operands for " + operator)
    elif "identifier" in token or "builtin" in token:
        if "identifier" in token:
            symbol = token["identifier"]
            attributes = getAttributes(scope, symbol)
            if attributes != None:
                if "PROCEDURE" in attributes:
                    # Recall that the way PROCEDURE parameters are modeled,
                    # they are not passed to the C equivalents of the PROCEDUREs
                    # as parameters, but rather as static variables in 
                    # the `memory` array.  The trick in C to doing this in 
                    # middle of the expression is to convert a sequence of 
                    # several variable assignments and a function call to 
                    # convert an XPL call like `f(b,d,...,z)` to a C construct
                    # like `(a=b, c=d, ..., y=z, f())`, where `a`, `c`, ...,
                    # `y` parameters within the PROCEDURE definition. 
                    outerParameters = expression["children"]
                    mangled = attributes["mangled"]
                    if len(outerParameters) == 0:
                        source = mangled + "()"
                    else:
                        innerParameters = attributes["parameters"] 
                        innerScope = attributes["PROCEDURE"]
                        if len(outerParameters) > len(innerParameters):
                            errxit("Too many parameters in " + symbol)
                        source = "( "
                        for k in range(len(outerParameters)):
                            outerParameter = outerParameters[k]
                            innerParameter = innerParameters[k]
                            innerAddress = innerScope["variables"][innerParameter]["address"]
                            tipe, parm = generateExpression(scope, outerParameter)
                            source = source + "put" + tipe + "(" + \
                                     str(innerAddress) + ", " + parm + "), "
                        source = source + mangled + "() )"
                    if "return" in attributes:
                        tipe = attributes["return"]
                    else:
                        tipe = None
                    return tipe, source;
                else: # Must be a variable, possibly subscripted
                    indices = expression["children"]
                    index = ""
                    if len(indices) > 1:
                        errxit("Multi-dimensional arrays not allowed in XPL")
                    if len(indices) == 1:
                        tipe, index = generateExpression(scope, indices[0])
                    if "FIXED" in attributes or "BIT" in attributes:
                        tipe = "FIXED"
                        if index == "":
                            source = "getFIXED(" + str(attributes["address"]) + ")"
                        else:
                            source = "getFIXED(" + str(attributes["address"]) + \
                                     " + 4*" + index + ")"
                        return tipe, source
                    elif "CHARACTER" in attributes:
                        tipe = "CHARACTER"
                        if index == "":
                            source = "getCHARACTER(" + str(attributes["address"]) + ")"
                        else:
                            source = "getCHARACTER(" + str(attributes["address"]) + \
                                     " + 4*" + index + ")"
                        return tipe, source
                    else:
                        errxit("Unsupported variable type")
            else:
                errxit("Unknown variable %s" % symbol)
        else:
            symbol = token["builtin"]
            # Many builtins.
            if symbol in ["INPUT", "LENGTH", "SUBSTR", "BYTE", "SHL", "SHR",
                          "DATE", "TIME", "DATE_OF_GENERATION", "COREBYTE",
                          "COREWORD"]:
                if symbol in ["INPUT", "SUBSTR"]:
                    builtinType = "CHARACTER"
                else:
                    builtinType = "FIXED"
                parameters = expression["children"]
                first = True
                source = symbol + "("
                # Some special cases for omitted parameters.
                if symbol == "INPUT" and len(parameters) == 0:
                    source = source + "0"
                    first = False
                elif symbol == "SUBSTR" and len(parameters) == 2:
                    source = "bSUBSTR2("
                elif symbol == "BYTE" and len(parameters) == 1:
                    source = "bBYTE1("
                # Uniform processing.
                for parameter in parameters:
                    if not first:
                        source = source + ", "
                    first = False
                    tipe, p = generateExpression(scope, parameter)
                    source = source + p
                source = source + ")"
                return builtinType, source
            elif symbol == "MONITOR":
                # The parameters and return types of MONITOR vary dramatically
                # depending on the function number.  So we have to determine
                # that before deciding which runtime specific runtime function
                # to call, as opposed to just calling a single MONITOR function.
                # I'm going to assume that the function number is known at 
                # compile-time.  If not, then the implementation below will need
                # to be fleshed out somewhat.
                if len(expression["children"]) < 1:
                    errxit("No function number specified for MONITOR")
                if "number" not in expression["children"][0]["token"]:
                    errxit("Could not evaluate MONITOR function number")
                functionNumber = expression["children"][0]["token"]["number"]
                # Only certain monitor functions return values.
                if functionNumber == 1:
                    pass
                elif functionNumber == 2:
                    pass
                elif functionNumber == 6:
                    pass
                elif functionNumber == 7:
                    pass
                elif functionNumber == 9:
                    pass
                elif functionNumber == 10:
                    pass
                elif functionNumber == 12:
                    pass
                elif functionNumber == 13:
                    pass
                elif functionNumber == 14:
                    pass
                elif functionNumber == 15:
                    pass
                elif functionNumber == 18:
                    symbol = "MONITOR18"
                    builtinType = "FIXED"
                elif functionNumber == 19:
                    pass
                elif functionNumber == 21:
                    pass
                elif functionNumber == 22:
                    pass
                elif functionNumber == 23:
                    pass
                elif functionNumber == 32:
                    pass
                else:
                    errxit("MONITOR(%d) returns no value" % functionNumber)
            elif symbol == "ADDR":
                parameters = expression["children"]
                if len(parameters) != 1:
                    errxit("Wrong number of parameters for ADDR")
                token = parameters[0]["token"]
                if "identifier" not in token:
                    errxit("Parameter of ADDR not an identifier")
                identifer = token["identifier"]
                sattributes = getAttributes(scope, identifier)
                if sattributes == None:
                    errxit("Parameter of ADDR(%s) is undefined or out of scope"\
                           % identifier)
                subscripts = parameters[0]["children"]
                if len(subscripts) == 0:
                    return "FIXED", str(attributes["address"])
                elif len(subscripts) == 1:
                    tipes, sources = generateExpression(scope, subscripts[0])
                    if tipes != FIXED:
                        errxit("Subscript of %s in ADDR is non-integer or uncalculable"\
                               % identifier)
                    source = "(%d + 4 * (%s))" % (attributes["address"], sources)
                    return "FIXED", source 
                else:
                    errxit("In ADDR(%s(...)), %s has too many subscripts" % \
                           identifier)
            else:
                errxit("Builtin %s not yet supported" % symbol)
        parameters = expression["children"]
        source = symbol + "("
        for i in range(len(parameters)):
            parameter = parameters[i]
            if i > 0:
                source = source + ","
            tipex, sourcex = generateExpression(scope, parameter)
            if tipex != "INDETERMINATE":
                if tipe == "INDETERMINATE":
                    tipe = tipex
                if tipe != tipex:
                    errxit("Mismatched expression types")
            source = source + " " + sourcex
        source = source + " )"
    else:
        errxit("Unsupported token " + str(token))
    return tipe, source

# The `generateSingleLine` function is used by `generateCodeForScope`.
# As the name implies, it operates on the pseudo-code for a single 
# pseudo-statement, generating the C source code for it, and printing that
# source code to the output file.
lineCounter = 0  # For debugging purposes only.
forLoopCounter = 0
inlineCounter = 0
def generateSingleLine(scope, indent, line, indexInScope):
    global forLoopCounter, lineCounter, inlineCounter
    if lineCounter == 936: # ***DEBUG***
        pass
    lineCounter += 1
    if len(line) < 1: # I don't think this is possible!
        return
    # For inserting `case` and `break` into `switch` statements.
    if scope["parent"] != None:
        parent = scope["parent"]
        if "switchCounter" in parent:
            indent0 = indent[:-len(indentationQuantum)]
            if "ELSE" in line:
                parent["ifCounter"] += 1
            if parent["ifCounter"] == 0:
                if parent["switchCounter"] > 0:
                    print(indent + "break;")
                print(indent0 + "case %d:" % parent["switchCounter"])
                parent["switchCounter"] += 1
            if parent["ifCounter"] > 0:
                parent["ifCounter"] -= 1
            if "IF" in line or "ELSE" in line:
                parent["ifCounter"] += 1
    if "ASSIGN" in line:
        print(indent + "{")
        indent += indentationQuantum
        LHSs = line["LHS"]
        RHS = line["RHS"]
        tipeR, sourceR = generateExpression(scope, RHS)
        definedS = False
        if tipeR in ["FIXED", "BIT"]:
            print(indent + "int32_t numberRHS = " + sourceR + ";")
        elif tipeR == "CHARACTER":
            definedS = True
            print(indent + "string_t stringRHS;")
            
            print(indent + "strcpy(stringRHS, %s);" % sourceR)
        else:
            errxit("Unknown RHS type: " + str(RHS))
        
        # Use this wherever a stringRHS is needed but only a numberRHS has
        # perhaps been provided.
        def autoConvert():
            nonlocal definedS;
            if tipeR in ["FIXED", "BIT"]:
                if not definedS:
                    print(indent + "string_t stringRHS;")
                    definedS = True
                print(indent + "strcpy(stringRHS, fixedToCharacter(numberRHS));")

        for i in range(len(LHSs)):
            LHS = LHSs[i]
            tokenLHS = LHS["token"]
            if "identifier" in tokenLHS:
                identifier = tokenLHS["identifier"]
                attributes = getAttributes(scope, identifier)
                address = attributes["address"]
                children = LHS["children"]
                if "FIXED" in attributes or "BIT" in attributes:
                    if len(children) == 0:
                        print(indent + "putFIXED(" + str(address) + ", numberRHS);") 
                    elif len(children) == 1:
                        tipeL, sourceL = generateExpression(scope, children[0])
                        print(indent + "putFIXED(" + str(address) + "+ 4*(" + \
                              sourceL + "), numberRHS);") 
                    else:
                        errxit("Too many subscripts")
                elif "CHARACTER" in attributes:
                    if tipeR in ["FIXED", "BIT"]:
                        autoConvert()
                    elif tipeR != "CHARACTER":
                        errxit("LHS/RHS type mismatch in assignment.")
                    if len(children) == 0:
                        print(indent + "putCHARACTER(" + str(address) + ", stringRHS);") 
                    elif len(children) == 1:
                        tipeL, sourceL = generateExpression(scope, children[0])
                        print(indent + "putCHARACTER(" + str(address) + "+ 4*(" + \
                              sourceL + "), stringRHS);") 
                    else:
                        errxit("Too many subscripts")
                else:
                    errxit("Undetermined LHS type")
            elif "builtin" in tokenLHS:
                builtin = tokenLHS["builtin"]
                children = LHS["children"]
                if builtin == "OUTPUT":
                    autoConvert()
                    if len(children) == 0:
                        print(indent + "OUTPUT(0, stringRHS);")
                    elif len(children) == 1:
                        tipe, source = generateExpression(scope, children[0])
                        
                        print(indent + "OUTPUT(" + source + ", stringRHS);")
                    else:
                        errxit("Corrupted device number in OUTPUT")
                else:
                    errxit("Unsupported builtin " + builtin)
            else:
                errxit("Bad LHS " + str(LHS))
        indent = indent[: -len(indentationQuantum)]
        print(indent + "}")
    elif "FOR" in line:
        '''
        Regarding XPL iterative loops (DO var = from TO to [ BY b ]), there 
        are several things to note from McKeeman section 6.13 p. 144.
        
            1.  The expressions for `from`, `to`, and `by` (if present) are
                evaluated once, and never reevaluated as the loop progresses.
            2.  The expression for `by` must be *positive*. 
            3.  The loop exits when `var` is strictly greater than `from`, and
                not (as in Python) until it equals or exceeds the end of range.
            4.  `var` will always be assigned a value, even if the exit
                condition immediately fails without executing any of the inner
                statements, and after termination, `var` will retain the value 
                at which the loop exited. 
                
        The principal difficulty in implementing this is the constraint that
        `to` and `by` are not reevaluated during the loop.  This implies that
        their values should be stored in variables that persist throughout the
        lifetime of the loop.  Distinct variables with distinct names have to be 
        introduced for this purpose for each nested for-loop encountered.
        
        One issue *not* explained in McKeeman is that the syntax allows the 
        loop variable itself to be subscripted.  In that case, is the subscript
        evaluated just once, or is it reevaluated every time through the loop?
        Either way is open to abuses.  In looking at the XPL/I source code for
        `HAL/S-FC`, I don't find any cases of subscripted variables being used
        for loop counters in this way, so my inclination right now is to 
        simply disallow it, regardless of what the syntax theoretically allows.
        '''
        print(indent + "{")
        line["scope"]["extraIndent"] = True
        indent2 = indent + indentationQuantum
        fromName = "from%d" % forLoopCounter
        toName = "to%d" % forLoopCounter
        byName = "by%d" % forLoopCounter
        forLoopCounter += 1
        index = line["index"]
        token = index["token"]
        variable = token["identifier"]
        if (len(index["children"])) > 0:
            errxit("Subscripted loop variables not supported.")
        attributes = getAttributes(scope, variable)
        address = attributes["address"]
        print(indent2 + "int32_t %s, %s, %s;" % (fromName, toName, byName))
        tipe, source = generateExpression(scope, line["from"])
        print(indent2 + fromName + " = " + source + ";")
        tipe, source = generateExpression(scope, line["to"])
        print(indent2 + toName + " = " + source + ";")
        tipe, source = generateExpression(scope, line["by"])
        print(indent2 + byName + " = " + source + ";")
        print((indent2 + \
              "for (putFIXED(" + str(address) + ", " + fromName + \
              ");\n" + indent2 + "     getFIXED(%d) <= %s;\n" + indent2 + \
              "     putFIXED(%d, getFIXED(%d) + %s)) {" ) \
              % (address, toName, address, address, byName))
    elif "WHILE" in line:
        tipe, source = generateExpression(scope, line["WHILE"])
        print(indent + "while (1 & (" + source + ")) {")
    elif "BLOCK" in line:
        print(indent + "{")
    elif "IF" in line:
        tipe, source = generateExpression(scope, line["IF"])
        print(indent + "if (1 & (" + source + "))")
    elif "GOTO" in line:
        print(indent + "goto " + line["GOTO"] + ";")
    elif "TARGET" in line:
        print(indent + line["TARGET"] + ":", end="")
        if indexInScope >= len(scope["code"]) - 1:
            print(";")
        else:
            print()
    elif "ELSE" in line:
        print(indent + "else")
    elif "RETURN" in line:
        if line["RETURN"] == None:
            # There are examples in ANALYZER.xpl of PROCEDURES that don't
            # return values having their values used in IF statements.
            # McKeeman says that such returns will be random, because they'll
            # just be leftover values from some unspecified register.  I'll
            # alway return a 0.
            #print(indent + "return ;")
            print(indent + "return 0;")
        else:
            tipe, source = generateExpression(scope, line["RETURN"])
            print(indent + "return " + source + ";")
    elif "ELSE" in line:
        print(indent + "else")
    elif "EMPTY" in line:
        print(indent + ";")
    elif "CALL" in line:
        procedure = line["CALL"]
        if procedure == "INLINE":
            patchFilename = baseSource + "/patch%d.c" % inlineCounter
            originalInline = scope["pseudoStatements"][indexInScope]
            try:
                indent2 = indent + indentationQuantum
                patchFile = open(patchFilename, "r")
                print(indent + "{ // (%d) %s" % (inlineCounter, originalInline))
                for patchLine in patchFile:
                    print(indent2 + patchLine.rstrip())
                print(indent + "}")
                patchFile.close()
            except:    
                print(indent + "; // (%d) %s" % (inlineCounter, originalInline))
            inlineCounter += 1
        else:
            outerParameters = line["parameters"] 
            attributes = getAttributes(scope, procedure)
            try: # ***DEBUG***
                mangled = attributes["mangled"]
            except:
                pass
            if len(outerParameters) == 0:
                print(indent + mangled + "();")
            else:
                innerScope = attributes["PROCEDURE"]
                indent2 = indent + indentationQuantum
                print(indent + "{")
                innerParameters = attributes["parameters"]
                if len(outerParameters) > len(innerParameters):
                    errxit("Too many parameters in CALL to " + symbol)
                for k in range(len(outerParameters)):
                    outerParameter = outerParameters[k]
                    innerParameter = innerParameters[k]
                    innerAddress = innerScope["variables"][innerParameter]["address"]
                    tipe, parm = generateExpression(scope, outerParameter)
                    print(indent2 + "put" + tipe + "(" + \
                             str(innerAddress) + ", " + parm + "); ")
                print(indent2 + mangled + "();")
                print(indent + "}")
    elif "CASE" in line:
        tipe, source = generateExpression(scope, line["CASE"])
        print(indent + "switch (" + source + ") {")
        scope["switchCounter"] = 0
        scope["ifCounter"] = 0
    else:
        print(indent + "Unimplemented:", end="", file=debugSink)
        printDict(line)

# `generateCodeForScope` is a function that's plugged into
# `walkModel`.  It generates all of the code for a scope and its sub-scopes
# *until* it reaches an embedded procedure definition.  It generates separate
# calls to `walkModel` for each such embedded procedure.  Each procedure
# (and the global scope) creates a separate C source-code file.
# The optional parameter `extra` is a dictionary with the following key/value
# pairs:
#
#    "of" is the output file, already opened for writing. If None, then the 
#    function creates its own and assumes it's at the top-level scope of the 
#    generated function.
#
#    "indent" is a string of blanks for the indentation of the parent scope.
#
def generateCodeForScope(scope, extra = { "of": None, "indent": "" }):
    
    if "generated" in scope:
        return
    scope["generated"] = True;
    
    of = extra["of"]
    indent = extra["indent"]
    if "extraIndent" in scope:
        indent = indent + indentationQuantum
    
    if extra["of"] == None:
        pass
    
    if "PROCEDURE" in scope and of != None:
        walkModel(scope, generateCodeForScope, { "of": None, "indent": ""})
        return
    
    # Make sure we've got an open output file of the appropriate name.
    scopeName = scope["symbol"]
    scopePrefix = scope["prefix"]
    if scopeName == "":
        functionName = "main"
    else:
        functionName = scopePrefix[:-1] # Remove final "x".
        functionName.replace("#", "p").replace("@", "a").replace("$", "d")
    topLevel = False
    if of == None:
        of = open(outputFolder + "/" + functionName + ".c", "w")
        topLevel = True
        stdoutOld = sys.stdout
        sys.stdout = of # Redirect all `print` to this file.
    
    if topLevel:
        print("/*")
        print("  File " + functionName + \
              ".c generated by XCOM-I, " + \
              datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + ".")
        if functionName == "main":
            msg = "  XPL/I source-code file"
            if len(inputFilenames) > 1:
                msg = msg + "s"
            msg = msg + " used:"
            for inputFilename in inputFilenames:
                msg = msg + " " + os.path.basename(inputFilename)
            print(msg + ".")
            print("  Recommended requirements:  GNU `gcc` and GNU `make`.")
            print("  To build the program (aout) from the command line:")
            print("          cd %s/" % outputFolder)
            print("          make")
            print("  To run the program:")
            print("          aout [OPTIONS]")
            print("  Use `aout --help` to see the available OPTIONS.")
        print("*/")
        print()
        print('#include "runtimeC.h"')
        print('#include "procedures.h"')
        print()
        if functionName == "main":
            if verbose:
                print("/*")
                print("  Memory Map:")
                print("%24s        %-16s %-8s" % \
                      ("Address (Hex)", "Data Type", "Variable"))
                print("%24s        %-16s %-8s" % \
                      ("-------------", "---------", "--------"))
                for address in sorted(memoryMap):
                    print("       %8d (%06X)        %-16s %s" % \
                          (address, address, memoryMap[address][1], \
                           memoryMap[address][0]))
                if areaNormal == 0:
                    print("  COMMON:     (empty)")
                else:
                    print("  COMMON:     0x%06X-0x%06X" % \
                          (0, areaNormal - 1))
                if variableAddress == areaNormal:
                    print("  Non-COMMON: (empty)")
                else:
                    print("  Non-COMMON: 0x%06X-0x%06X" % \
                          (areaNormal, variableAddress - 1))
                if variableAddress >= len(memory):
                    print("  Unused:     (none)")
                else:
                    print("  Unused:     0x%06X-0x%06X" % \
                          (variableAddress, 0xFFFFFF))
                print("*/")
                print()
            print("uint32_t sizeOfCommon = %d;" % areaNormal)
            print("uint32_t sizeOfNonCommon = %d;" % (variableAddress-areaNormal));
            print()
            print("int\nmain(int argc, char *argv[])\n{")
            print()
            print("  if (parseCommandLine(argc, argv)) exit(0);")
            print()
        else:
            attributes = scope["parent"]["variables"][scopeName]
            variables = scope["variables"]
            if "return" in attributes:
                returnType = attributes["return"]
            else:
                # Even in XPL (vs XPL/I), PROCEDUREs without any specified
                # type may still return values.  There are examples in 
                # ANALYZER.xpl of that happening.
                returnType = "int32_t" # "void"
            if returnType == "FIXED":
                returnType = "int32_t"
            elif returnType == "BIT":
                returnType = "uint32_t"
            elif returnType == "CHARACTER":
                returnType = "char *"
            header = returnType + "\n" + functionName + "(void)"
            print("\n" + header + ";", file=pf)
            print(header + "\n{")
            print()
    indent = indent + indentationQuantum
    
    #---------------------------------------------------------------------
    # All of the code generation for actual XPL statements occurs between
    # these two horizontal lines.
    
    lastReturned = False
    numCode = len(scope["code"])
    for i in range(numCode):
        line = scope["code"][i]
        if verbose and i in scope["pseudoStatements"] and \
                None == re.search("\\bCALL +INLINE *\\(", \
                                  scope["pseudoStatements"][i].upper()):
            print(indent + "// " + scope["pseudoStatements"][i] + \
                  (" (%d)" % lineCounter))
        if line == None or len(line) == 0: # ***DEBUG***
            pass
        lastReturn = "RETURN" in line
        generateSingleLine(scope, indent, line, i)
        if "scope" in line: # Code for an embedded DO...END block.
            generateCodeForScope(line["scope"], { "of": of, "indent": indent} )
    
    #---------------------------------------------------------------------
    
    if scope["parent"] != None and "switchCounter" in scope["parent"]:
        print(indent + "break;")
        scope["parent"].pop("switchCounter")
        scope["parent"].pop("ifCounter")
    # Add a precautionary RETURN 0 at the end of PROCEDUREs, for the reasons
    # described in the comments for CALL.  If there was already an explicit
    # RETURN here, or if the RETURN is somewhare else and this position cannot
    # be reached, the C compiler may complain, but hopefully won't fail.
    if not lastReturn and scope["symbol"] != '' and scope["symbol"][:1] != "_":
        print(indent + "return 0;")
    if "extraIndent" in scope:
        indent = indent[:-len(indentationQuantum)]
        print(indent + "}")
    if scope["parent"] == None:
        # End of main.c.
        print()
        if areaNormal > 0:
            print(indent + "if (COMMON_OUT != NULL) {")
            print(indent + indentationQuantum + "fwrite(memory, sizeOfCommon, 1, COMMON_OUT);")
            print(indent + indentationQuantum + "fclose(COMMON_OUT);")
            print(indent + indentationQuantum + "COMMON_OUT = NULL;")
            print(indent + "}")
        print(indent + "return 0;")
    indent = indent[:-len(indentationQuantum)]
    print(indent + "}", end="")
    if "blockType" in scope:
        print(" // End of " + scope["blockType"])
    else:
        print()
    if topLevel:
        sys.stdout = stdoutOld # Restore previous stdout.

def generateC(globalScope):
    global useCommon, useString, pf, areaNormal
    
    pf = open(outputFolder + "/procedures.h", "w")
    print("/*", file=pf)
    print("  File procedures.h generated by XCOM-I, " + \
          datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + ".", file=pf)
    print("  Provides prototypes for the C functions corresponding to the", file=pf)
    print("  XPL/I PROCEDUREs.", file=pf)
    print("", file=pf)
    print("  Note: Due to the requirement for persistence, all function", file=pf)
    print("  parameters are passed via static addresses in the `memory`", file=pf)
    print("  array, rather than via parameter lists, so all parameter", file=pf)
    print("  lists are `void`.", file=pf)
    print("*/", file=pf)
    print("", file=pf)
    print("#include <stdint.h>", file=pf)

    # Provide mangled variable names.
    walkModel(globalScope, mangle)
    
    # Allocate and initialize simulated memory for each variable in whatever 
    # scope. The mechanism is to set an attribute
    # of "address" for each variable in each scope["variables"], and to
    # additionally set an attribute of "saddress" for each `CHARACTER` variable
    # to indicate where the string data (vs the string descriptor) is stored.
    # Both of these attributes are indices in the 24-bit simulated memory.
    # Thus in XPL code translated to C, the code generator looks up addresses
    # of XPL variables, and generates C code that operates on absolute numerical
    # addresses rather than on symbolic addresses.  After the allocation is 
    # complete, the total amount of simulated memory used is given by the global
    # variable `variableAddress`.  The memory is partitioned so as to put the
    # COMMON at the lowest addresses, because COMMON is supposed to persist
    # after the program ends and a new program with the same COMMON is loaded.
    # I don't think we actually need COMMON, but if any COMMON is encountered, 
    # then it requires COMMON partitions to be saved (say, to a disk file)
    # and then reloaded later.  It's better to put COMMON first, so as to have 
    # addresses that don't need to be changes after reloading.
    useCommon = True # COMMON
    useString = False
    walkModel(globalScope, allocateVariables)
    useCommon = True # COMMON string data
    useString = True
    walkModel(globalScope, allocateVariables)
    areaNormal = variableAddress
    useCommon = False # normal variables
    useString = False
    walkModel(globalScope, allocateVariables)
    useCommon = False # normal string data
    useString = True
    walkModel(globalScope, allocateVariables)
    
    # Write out any special configuration settings, for use by
    # runtimeC.c.
    f = open(outputFolder + "/configuration.h", "w")
    print("// Configuration settings.", file=f)
    print("#define NULL_STRING_METHOD", nullStringMethod, file=f)
    if pfs:
        print("#define PFS", file=f)
    else:
        print("#define BFS", file=f)
    print("#define VARIABLE_ADDRESS", variableAddress, file=f)
    print("#define AREA_NORMAL", areaNormal, file=f)
    f.close()
    
    # Write out the initialized memory as a file called memory.c.
    f = open(outputFolder + "/memory.c", "w")
    print("// Initial memory contents.", file=f)
    print("#include \"runtimeC.h\"", file=f)
    print("uint8_t memory[MEMORY_SIZE] = {", file=f)
    for i in range(variableAddress):
        if 0 == i % 8:
            print("  ", end="", file=f)
        print("0x%02X" % memory[i], end="", file=f)
        if i < variableAddress - 1:
            print(", ", end="", file=f)
            if 7 == i % 8:
                j = i & 0xFFFFF8
                print(" // %8d 0x%06X" % (j, j), file=f)
        else:
            print("\n};", file=f)
    f.close()
    
    if debugSink != None:
        print('', file=debugSink)
        walkModel(globalScope, printModel)

    # Generate some code.
    walkModel(globalScope, generateCodeForScope, { "of": None, "indent": ""})
    
    pf.close()
    
#-----------------------------------------------------------------------------
# Interactive test mode for running this file in a stand-alone fashion rather
# than as a module.  Primarily for testing generation of C code for XPL
# expressions.

if debug:
    from xtokenize import xtokenize
    from parseExpression import parseExpression
    scope = { 
        "symbol" : "",
        "ancestors" : [],
        "parent" : None,
        "children" : [],
        "literals" : {},
        "variables" : {},
        "labels" : set(),
        "code": [],
        "blockCount" : 0,
        "lineNumber" : 0,
        "lineText" : '',
        "lineExpanded" : ''
        }

    print("Any of the following are accepted as input:")
    print("    DECLARE identifier;")
    print("    DECLARE identifier(number);")
    print("    expression")
    print("This test is *very* user-unfriendly in case of syntax errors.")
    while True:
        line = input("Input: ")
        tokenized = xtokenize(line)
        # Do a crude check to see if a new variable is being DECLARE'd.
        declaration = False
        for i in range(len(tokenized)):
            token = tokenized[i]
            if i == 0:
                if "reserved" not in token or token["reserved"] != "DECLARE":
                    break
            elif i == 1:
                if "identifier" not in token:
                    break
                identifier = token["identifier"]
            elif i == 2:
                if token not in [";", "("]:
                    break
                if token == ';':
                    scope["variables"][identifier] = {
                        "FIXED": True,
                        "address": variableAddress
                        }
                    variableAddress += 4
                    declaration = True
                    break
            elif i == 3:
                if "number" not in token:
                    break
                top = token["number"]
            elif i == 4:
                if token != ")":
                    break
            elif i == 5:
                if token != ';':
                    break
                scope["variables"][identifier] = {
                    "FIXED": True,
                    "top": top,
                    "address": variableAddress
                    }
                variableAddress += 4 * (top + 1)
                declaration = True
                break
        if declaration:
            print("Allocated %s" % identifier, scope["variables"][identifier])
            continue
        # If not a declaration, assume we're just parsing an expression.
        expression = parseExpression(tokenized, 0)
        print()
        if expression == None:
            print("Error:", expression["error"])
        else:
            print("%s\n%s" % generateExpression(scope, expression))
        print()
        