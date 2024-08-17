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

import sys
import traceback
import datetime
import os
import copy
import re
from auxiliary import *
from parseCommandLine import *
from xtokenize import xtokenize
from parseExpression import parseExpression
from asciiToEbcdic import asciiToEbcdic
from callTree import callTree
from guessINLINE import guessINLINE, guessFiles

stdoutOld = sys.stdout

debug = False # Standalone interactive test of expression generation.
sizeReducer = True # For reducing size of executable.

ppFiles = { "filenames": "" }

# Reserve the top of memory for some literal strings.
amountOfPrivateMemory = 10000
physicalMemoryLimit = 0x1000000 - amountOfReservedMemory - amountOfPrivateMemory

# Just for engineering
errxitRef = 0
def errxit(msg, action="abend"):
    print("%s: %s" % \
          (lineRefs[errxitRef], 
           lines[errxitRef].strip()
                          .replace(replacementQuote, "''")
                          .replace(replacementSpace, " ")), file = sys.stderr)
    print(msg, file=sys.stderr)
    if showBacktrace:
        print("Backtrace:", file=sys.stderr)
        traceback.print_stack(file=sys.stderr)
    if action == "abend":
        if winKeep:
            input()
        sys.exit(1)
    elif action == "return":
        return
    print("Unknown action (%s) requested", file = sys.stderr)
    if winKeep:
        input()
    sys.exit(2)

def normalizedLabel(label):
    return label.replace("@","a").replace("#","p").replace("$","d").replace("_","u")

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

# Header file in which C prototypes for PROCEDUREs are placed.
pf = None

# A function for walkModel(), for allocating simulated memory.
commonBase = 0
nonCommonBase = 0
freeBase = 0
freePoint = 0
freeLimit = 0
regions = []
variableAddress = 0 # Total contiguous bytes allocated in 24-bit address space.
useCommon = False # For allocating COMMON vs non-COMMON
useString = False # For allocating character data CHARACTER.
memory = bytearray([0] * (1 << 24));
'''
`memoryMap` is a dictionary whose keys are addresses in `memory` and whose
values are themselves dictionaries with the keys:
    "mangled"           the mangled name of a variable
    "datatype"          BASED, FIXED, BIT, CHARACTER, EBCDIC, BITSTRING
    "numElements"       Number of elements if variable subscripted, or else 0
    "record"            dict describing the RECORD if BASED RECORD
    "numFieldsInRecord" Number of fields in the RECORD, or 0
    "recordSize"        Sum of all dirWidths in the RECORD, or 0
    "dirWidth"          Number of bytes required in the variable index
    "bitWidth"          from BIT(bitWidth), or 0 if not BIT
    "parentAddress"     For datatype EBCDIC or BITSTRING, address of descriptor.
    "common"            Present if variable is in COMMON
'''
memoryMap = {}

# The following are used for enforcing order of argument evaluation in 
# calls to library functions (including operators like +, ||, etc.).  Each
# argument or operand in each instance of a call to such a function has its
# own dedicated global variable used only for the purpose of holding the value
# of the expression.  These are numbered sequentially.  Integers and descriptors
# have separate counts, since they are separate types.  The global variables
# themselves will have names like iarg%d or darg%d be in arguments.c, and the 
# externs for them will be in arguments.h, which runtimeC.h will #include.
currentInt = 0
currentDesc = 0

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

def putHALFWORD(address, i):
    global memory
    memory[address + 0] = (i >> 8) & 0xFF
    memory[address + 1] = i & 0xFF

# The value returned by `getBIT` or stored to memory by `putBIT` is a 
# dictionary with the following keys:
#    "bitWidth"
#    "numBytes"
#    "bytes"
# "bytes" corresponds to the array of bytes used by the runtime library,
# but since Python has infinite-precision integers, it's easer to just use
# a Python integer than an array of bytes.

def getBIT(address):
    bitWidth = memoryMap[address]["bitWidth"]
    if bitWidth < 1 or bitWidth > 2048:
        errxit("%s: getBIT(%d) width out of range (%d) at 0x%06X" % \
               (identifier, bitWidth, bitWidth, address))
    numBytes = memoryMap[address]["numBytes"]
    if bitWidth > 32:
        descriptor = getFIXED(address)
        descriptorFromLength = (descriptor >> 24) & 0xFF
        if numBytes - 1 != descriptorFromLength:
            errxit("%s: putBIT(0x%06X) widths don't match (%d != %d bytes)" % \
                    (identifier, address, numBytes - 1, lengthFromDescriptor))
        address = descriptor & 0xFFFFFF;
    value = 0
    for i in range(numBytes):
        value = (value << 8) | memory[address]
        address += 1
    shiftedBy = bitWidth % 8
    if shiftedBy != 0:
        value = value >> (8 - shiftedBy)
    return {
        "bitWidth": bitWidth,
        "numBytes": numBytes,
        "bytes":  value
        }

def putBIT(address, value):
    global variableAddress, freeLimit
    bitWidth = value["bitWidth"]
    if bitWidth < 1 or bitWidth > 2048:
        errxit("%s: putBIT(0x%06X) width (%d) out of range" % \
               (identifier, address, bitWidth));
    numBytes = value["numBytes"]
    if bitWidth > 32:
        descriptor = getFIXED(address)
        if descriptor == 0: # Not yet assigned a value:
            descriptor = ((numBytes - 1) << 24) | (variableAddress & 0xFFFFFF)
            putFIXED(address, descriptor)
        lengthFromDescriptor = ((descriptor >> 24) & 0xFF) + 1
        if numBytes != lengthFromDescriptor:
            errxit("putBIT(0x%06X) widths don't match (%d != %d bytes)" % \
                   (address, numBytes, lengthFromDescriptor))
        address = descriptor & 0xFFFFFF
    bytes = value["bytes"] # & ((1 << bitWidth) - 1)
    if bitWidth > 32:
        shiftedBy = bitWidth % 8
        if shiftedBy != 0:
            bytes = bytes << (8 - shiftedBy)
    for i in range(numBytes - 1 , -1, -1):
        memory[address + i] = bytes & 0xFF
        bytes = bytes >> 8

# Note that unlike the runtime function of the same name, this version of
# putCHARACTER doesn't need to deal with compactification, since the
# *first* time, all variables can be allocated right where they belong
# without needing to be moved.  In fact, string data can just always be
# put at the current value of variableAddress.
def putCHARACTER(address, s):
    global memory
    length = len(s)
    saddress = variableAddress
    if length == 0:
        putFIXED(address, 0)
        return
    if length > 256:
        length = 256
    descriptor = ((length - 1) << 24) | saddress
    putFIXED(address, descriptor)
    # Encode the string's character data as an EBCDIC Python byte array.
    for i in range(length):
        try:
            memory[saddress + i] = asciiToEbcdic[ord(s[i])]
        except:
            errxit("Memory overflow (%06X,%d) or else illegal character in \"%s\"" %\
                   (saddress, i, s))

# `allocateVariables`, run via `walkModel` is used to assign memory addresses
# to variables defined in the various scope.  `walkModel` is run several times
# in succession, one for each of the memory regions in the memory model.  For
# this purpose, I assign each of those regions a number, from lowest memory
# to highest.  Refer to https://www.ibiblio.org/apollo/XPL.html#MemoryModel.
# Not all regions (0 and 6) have anything in them that `allocateVariable`
# can allocate at compile-time.
baseRestriction = 0
rootBASED = 0
#lastBASED = 0
reservedMemory = {
    "numReserved": 0,
    "nextReserved": 0x1000000
    }
def allocateVariables(scope, region):
    global variableAddress, memory, memoryMap, rootBASED, reservedMemory, \
           physicalMemoryLimit
    
    for identifier in scope["variables"]:
        attributes = scope["variables"][identifier]
        if baseRestriction > 0 and "BASED" not in attributes:
            continue
        if baseRestriction < 0 and "BASED" in attributes:
            continue
        if "PROCEDURE" in attributes:
            continue
        if "LABEL" in attributes:
            continue
        if "parameter" in attributes:
            continue
        if "common" in attributes and region not in [1, 3, 5]:
            continue
        if "common" not in attributes and region == 1:
            continue
        if "BASED" in attributes:
            if region not in [1, 2]:
                continue
        else:
            if "FIXED" in attributes and region not in [1, 2]:
                continue
            if "BIT" in attributes and attributes["BIT"] <= 32 and \
                    region not in [1, 2]:
                continue
            if "CHARACTER" in attributes and region not in [3, 5]:
                continue
            if "BIT" in attributes and attributes["BIT"] > 32 and \
                    region not in [3, 5]:
                continue
        if "FIXED" in attributes:
            datatype = "FIXED"
            # Realign at word boundary, as suggested by comment at line 305 in
            # xcom4.xpl.
            variableAddress = (variableAddress + 3) & 0xFFFFFC;
        elif "BIT" in attributes:
            datatype = "BIT"
            bitWidth = attributes["BIT"]
            numBytes = (bitWidth + 7) // 8
            if numBytes == 3:
                numBytes = 4
        elif "CHARACTER" in attributes:
            datatype = "CHARACTER"
        elif "BASED" in attributes:
            datatype = "BASED"
        else:
            continue
        mangled = attributes["mangled"]
        if "library" in attributes:
            library = attributes["library"]
        else:
            library = False
        
        '''
        if useString and datatype != "CHARACTER":
            continue
        if useCommon:
            if "common" not in attributes:
                continue
        else:
            if "common" in attributes or "parameter" in attributes:
                continue
        '''
            
        length = 1
        initial = None
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
        if "top" in attributes:
            numElements = attributes["top"] + 1
        else:
            numElements = 0

        if region == 5:
            if len(initial) > 0:
                memoryMap[variableAddress] = {
                    "mangled": mangled, 
                    "datatype": "EBCDIC", 
                    "numElements": numElements,
                    "record": {},
                    "numFieldsInRecord": 0,
                    "recordSize": 0,
                    "dirWidth": 0,
                    "bitWidth": 0,
                    "parentAddress": 0,
                    "library": library
                }
                if "common" in attributes:
                    memoryMap[variableAddress]["common"] = True
                if "BIT" in attributes:
                    memoryMap[variableAddress]["datatype"] = "BITSTRING"
                address = attributes["address"]
                memoryMap[variableAddress]["parentAddress"] = address
                firstAddress = address
                for i in range(length):
                    # INITIALize (just CHARACTER and BIT(>32) variables).
                    if datatype == "CHARACTER":
                        if initial != None and i < len(initial):
                            initialValue = initial[i]
                            if isinstance(initialValue, str):
                                if len(initialValue) > 256:
                                    errxit("String initializer is %d characters" \
                                           % len(initialValue), scope)
                            elif isinstance(initialValue, int):
                                initialValue = "%d" % initialValue
                            else:
                                errxit("Cannot evaluate initializer to CHARACTER", scope)
                        else:
                            initialValue = ""
                        putCHARACTER(address, initialValue)
                        variableAddress += len(initialValue)
                    else: # datatype == "BIT(>32)":
                        bitWidth = attributes["BIT"]
                        numBytes = (bitWidth + 7) // 8
                        value = {
                            "bitWidth": bitWidth,
                            "numBytes": numBytes,
                            "bytes": initial[i]
                            }
                        putBIT(address, value)
                        variableAddress += numBytes
                    address += attributes["dirWidth"]
            continue
        
        if "BASED" in attributes:
            if "RECORD" in attributes:
                record = attributes["RECORD"]
            else:
                datatype = "BASED"
                record = { '': attributes }
            if rootBASED == 0:
                rootBASED = variableAddress
            putFIXED(variableAddress, 0) # Pointer
            bitWidth = 0
            if "recordSize" in attributes:
                recordSize = attributes["recordSize"]
            elif "FIXED" in attributes or "CHARACTER" in attributes:
                recordSize = 4
            elif "BIT" in attributes:
                bitWidth = attributes["BIT"]
                if bitWidth <= 8:
                    recordSize = 1
                elif bitWidth <= 16:
                    recordSize = 2
                else:
                    recordSize = 4
            ndescript = 0
            if "CHARACTER" in attributes or \
                    ("BIT" in attributes and attributes["BIT"] > 32):
                ndescript = 1
            elif "RECORD_CHAR" in attributes:
                ndescript = len(attributes["RECORD_CHAR"])
            address = 0
            allocated = 0
            used = 0
            options = 0
            if "top" in attributes:
                # Although being implemented as a BASED RECORD, this object is
                # really a DECLARE RECORD.  As such, it has a size known at
                # compile time.  We're going to allocate that space in the
                # memory that XCOM-I "reserves" between `physicalMemoryLimit`
                # and 0x1000000.  This area grows downward, as tracked by the
                # `reservedMemory` dictionary, pushing `physicalMemoryLimit`
                # downward if necessary.
                size = attributes["recordSize"] * length
                nextReserved = reservedMemory["nextReserved"] - size
                reservedMemory["nextReserved"] = nextReserved
                reservedMemory["numReserved"] += 1
                if nextReserved < physicalMemoryLimit:
                    physicalMemoryLimit = nextReserved
                    errxit("Please use --reserved=N (N>=%d) for the entire XPL program chain" % \
                           physicalMemoryLimit, scope)
                address = nextReserved
                allocated = size
                used = size
                options = 3 << 24 # constant and unmoveable
            putFIXED(variableAddress + 0, address)
            putHALFWORD(variableAddress + 4, recordSize)
            putHALFWORD(variableAddress + 6, ndescript) # #descriptors
            putFIXED(variableAddress + 8, allocated) # allocated
            putFIXED(variableAddress + 12, used) # used
            '''
            if lastBASED > 0:
                putFIXED(lastBASED + 16, variableAddress)
            lastBASED = variableAddress
            '''
            putFIXED(variableAddress + 16, 0) # next
            putFIXED(variableAddress + 20, options) # options
            putHALFWORD(variableAddress + 24, 0) # global factor
            putHALFWORD(variableAddress + 26, 0) # group factor
            attributes["address"] = variableAddress
            memoryMap[variableAddress] = {
                "mangled": mangled, 
                "datatype": datatype, 
                "numElements": 0, 
                "record": record, 
                "numFieldsInRecord": 0,
                "recordSize": recordSize,
                "dirWidth": 28,
                "bitWidth": bitWidth,
                "parentAddress": 0,
                "library": library
            }
            if "common" in attributes:
                memoryMap[variableAddress]["common"] = True
            variableAddress += 28
            continue
        record = {}
        bitWidth = 0
        if "BIT" in attributes:
            bitWidth = attributes["BIT"]
        memoryMap[variableAddress] = {
            "mangled": mangled, 
            "datatype": datatype, 
            "numElements": numElements, 
            "record": record, 
            "numFieldsInRecord": 0,
            "recordSize": 0,
            "dirWidth": attributes["dirWidth"],
            "bitWidth": bitWidth,
            "parentAddress": 0,
            "library": library
        }
        if "common" in attributes:
            memoryMap[variableAddress]["common"] = True
        attributes["address"] = variableAddress
        # INITIALize FIXED or BIT variables.
        if initial != None and \
                ("FIXED" in attributes or \
                 ("BIT" in attributes and attributes["BIT"] <= 32)):
            for initialValue in initial:
                if length <= 0:
                    errxit("Too many initializers", scope)
                if not isinstance(initialValue, int):
                    # Not immediately an integer, but perhaps it's an
                    # expression whose value can be computed.  Let's try!
                    tokenized = xtokenize(scope, initialValue)
                    tree = parseExpression(tokenized, 0)
                    if tree != None and "token" in tree and \
                            "number" in tree["token"]:
                        initialValue = tree["token"]["number"]
                    else:
                        errxit("Initializer is not integer", scope);
                if "BIT" in attributes:
                    bitWidth = attributes["BIT"]
                    numBytes = (bitWidth + 7) // 8
                    if numBytes == 3:
                        numBytes = 4
                    putBIT(variableAddress, \
                           { 
                               "bytes": initialValue,
                               "bitWidth": bitWidth,
                               "numBytes": numBytes
                           })
                else: # "FIXED" in attributes
                    putFIXED(variableAddress, initialValue)
                length -= 1
                variableAddress += attributes["dirWidth"]
        variableAddress += attributes["dirWidth"] * length

# A function for `walkModel` that mangles identifier names.
mangledLabels = []
maxLengthMangled = 0
def mangle(scope, extra = None):
    global mangledLabels, maxLengthMangled
    # Determine the mangling prefix.
    prefix = ""
    s = scope
    while True:
        symbol = s["symbol"].replace("@", "a").replace("#", "p").replace("$","d").replace("_","u")
        if symbol != "" and symbol[:1] != scopeDelimiter:
            prefix = symbol + "x" + prefix
        s = s["parent"]
        if s == None:
            break
    scope["prefix"] = prefix
    for identifier in scope["variables"]:
        attributes = scope["variables"][identifier]
        mangled = prefix + \
            identifier.replace("@", "a").replace("#", "p").replace("$","d").replace("_","u")
        attributes["mangled"] = mangled
        if "LABEL" in attributes:
            mangledLabels.append(mangled)
            if len(mangled) > maxLengthMangled:
                maxLengthMangled = len(mangled)
        if False and "RECORD" in attributes:
            record = attributes["RECORD"]
            newRecord = {}
            for field in record:
                newField = field.replace("@", "a").replace("#", "p").replace("$","d").replace("_","u")
                newRecord[newField] = record[field]
            attributes["RECORD"] = newRecord

# A function for `walkModel` that collects some statistics about BASED RECORD.
maxRecordFields = 0
maxRecordFieldName = 0
def basedStats(scope, extra = None):
    global maxRecordFields, maxRecordFieldName
    variables = scope["variables"]
    for variable in variables:
        attributes = variables[variable]
        if "BASED" not in attributes or "RECORD" not in attributes:
            continue
        fields = attributes["RECORD"]
        numFields = len(fields)
        if numFields > maxRecordFields:
            maxRecordFields = numFields
        for field in fields:
            lenName = len(field)
            if lenName > maxRecordFieldName:
                maxRecordFieldName = lenName

# A function for figuring out `setjmp`/`longjmp` vs normal `goto`.  Basically,
# it:
#    Finds all of the `goto` statements.
#
#    Ignores any of them which are local to the innermost enclosing PROCEDURE.
#
#    But if not local, adds the label to the "longjmpLabels" dictionary of the
#    enclosing PROCEDURE of the `goto`, and adds it to the "setjmpLabels"
#    dictionary of the target PROCEDURE as well.  The value of the entry 
#    in both cases is the `attributes` of the target label in the target
#    PROCEDURE.
globalScope = None
globalSetjmp = set()
def mapJump(scope, extra = None):
    global globalSetjmp, globalScope
    
    # While `globalScope` is defined in XCOM-I.py, we can't import it from
    # there since XCOM-I.py imports from us, and that would be a vicious circle.
    # So lets's just deduce what it must be.
    if globalScope == None:
        globalScope = scope
        while globalScope["parent"] != None:
            globalScope = globalScope["parent"]
    
    # Look for all of the `GOTO` statements in the current scope.  
    procedureOfLongjmp = None
    code = scope["code"]
    for token in code:
        if "GOTO" in token:
            label = token["GOTO"]
            # We've found a `goto`.  The question we now have to answer
            # is whether the target `label` is within the immediately-
            # enclosing PROCEDURE (if any).  A simple `getAttributes` 
            # would find the label, but won't tell us anything about whether
            # or not it's within the PROCEDURE or not, so we don't use it.
            found = False
            inOurProc = True
            attributes = None
            procedureOfSetjmp = globalScope
            ourParentProcedure = findParentProcedure(scope)
            s = scope;
            while s != None:
                if label in s["variables"] and "LABEL" in s["variables"][label]:
                    found = True
                    procedureOfSetjmp = findParentProcedure(s)
                    break
                s = s["parent"]
            if ourParentProcedure != procedureOfSetjmp:
                inOurProc = False
            attributes = procedureOfSetjmp["variables"][label]
            # At this point:
            #    `found` indicates whether the `label` was found in scope at all.
            #    If `found`:
            #        `s` is the scope in which `label` was found.
            #        `procedureOfSetjmp` is its enclosing PROCEDURE.
            #        `attributes` are `label`'s attributes there.
            #        `inOurProc` is whether `label` was in the innermost procedure.
            if inOurProc:
                continue    # Nothing to do!
            if not found:
                errxit("No label %s found in scope of GOTO %s" % (label, label))
            if procedureOfLongjmp == None:
                procedureOfLongjmp = findParentProcedure(scope)
            if "longjmpLabels" not in procedureOfLongjmp:
                procedureOfLongjmp["longjmpLabels"] = {}
            procedureOfLongjmp["longjmpLabels"][label] = attributes
            if "setjmpLabels" not in procedureOfSetjmp:
                procedureOfSetjmp["setjmpLabels"] = {}
            procedureOfSetjmp["setjmpLabels"][label] = attributes
            globalSetjmp.add(attributes["mangled"])

def sortJumps(scope, extra = None):
    if "setjmpLabels" in scope:
        scope["sortedSetjmpLabels"] = list(sorted(scope["setjmpLabels"]))
        #print("'%s'" % scope["symbol"], scope["sortedSetjmpLabels"])

# A special case of `generateExpression` (see below), which also happens to
# be called by `generateExpression`, to generate the source code for an 
# expression of the form `ADDR(...)`.  Returns just the string containing the
# source code, or else abends on error.  The `parameter` parameter is the
# parameter for ADDR as an expression tree.
def generateADDR(scope, parameter):
    token = parameter["token"]
    if "builtin" in token and token["builtin"] == "DESCRIPTOR":
        # SPACELIB uses the address of `DESCRIPTOR` to detect the upper
        # boundary of `COMMON`.  Before I realized that, I chose to arrange
        # memory somewhat differently, and to implement `DESCRIPTOR` as a 
        # function rather than a variable.  The following is a workaround for
        # that, in lieu of altering the design.
        return regions[1][1]
    elif "builtin" in token:
        # I allow this because there's some stuff in HAL/S-FC source code that
        # attempts various memory-management operations by exploiting hidden
        # knowledge of how memory is allocated ... such as where the 
        # `COMPACTIFY` function is located in memory relative to certain kinds
        # of variables.  All of which is completely irrelevant to what's going
        # on underneath the hood in XCOM-I.  Whether the value returned is in 
        # any way adequate is, of course, questionable.
        print("Warning: ADDR(%s) of builtin" % token["builtin"], file=sys.stderr)
        return "0"
    if "identifier" in token: # not a structure field.
        # Might still be a BASED variable, though.
        bVar = token["identifier"]
        # Treat labels specially.  Return negative number indicative of the
        # order in which labels are encountered in the enclosing procedure:
        parentProcedure = findParentProcedure(scope)
        if bVar in parentProcedure["allLabels"]:
            negativeIndex = -(1 + parentProcedure["allLabels"].index(bVar))
            return "%d" % negativeIndex
        # XCOM3 uses ADDR(COMPACTIFY) to generate an address for an error 
        # message.  Rather than mess with it, just treat it ad hoc.
        if bVar == "COMPACTIFY":
            return "0"
        bSubs = parameter["children"]
        attributes = getAttributes(scope, bVar)
        if attributes == None:
            errxit("Cannot identify symbol %s in ADDR" % bVar)
        bVar = attributes["mangled"]
        if "BASED" in attributes:
            if 0 == len(bSubs):
                # This is a special case. See comments in runtimeC.h.
                return 'ADDR("%s", 0x80000000, NULL, 0)' % bVar
            elif 1 == len(bSubs):
                types, sources = generateExpression(scope, bSubs[0])
                types, sources = autoconvert(types, ["FIXED"], sources)
                return 'ADDR("%s", %s, NULL, 0)' % (bVar, sources)
            else:
                errxit("Wrong subscripting in ADDR(%s(...))" % bVar)
        fVar = bVar
        fSubs = bSubs
        if len(fSubs) == 0:
            sources = "0";
        elif len(fSubs) == 1:
            tipes, sources = generateExpression(scope, fSubs[0])
            tipes, sources = autoconvert(tipes, ["FIXED"], sources)
        else:
            errxit("Wrong number of subscripts of %s in ADDR" % fVar)
        return 'ADDR(NULL, 0, "%s", %s)' % (fVar, sources)
    elif "operator" in token and token["operator"] == ".": # BASED.
        b = parameter["children"][0]
        f = parameter["children"][1]
        bVar = b["token"]["identifier"]
        attributes = getAttributes(scope, bVar)
        if attributes == None:
            errxit("Cannot find variable %s" % bVar)
        bVar = attributes["mangled"]
        fVar = f["token"]["identifier"]
        bSubs = b["children"]
        fSubs = f["children"]
        if len(bSubs) == 0:
            sourceb = 0
        elif len(bSubs) == 1:
            typeb, sourceb = generateExpression(scope, bSubs[0])
            typeb, sourceb = autoconvert(typeb, ["FIXED"], sourceb)
        else:
            errxit("Wrong subscripting in %s(...).%s(...)" % (bVar, fVar))
        if len(fSubs) == 0:
            sourcef = 0
        elif len(fSubs) == 1:
            typef, sourcef = generateExpression(scope, fSubs[0])
            typef, sourcef = autoconvert(typef, ["FIXED"], sourcef)
        else:
            errxit("Wrong subscripting in %s(...).%s(...)" % (bVar, fVar))
        return 'ADDR("%s", %s, "%s", %s)' % (bVar, sourceb, fVar, sourcef)
    else:
        errxit("Unparsable token in generateADDR: " + str(token))


# `operatorTypes` relates the number of operands, the input type, the output 
# type, operator name, and runtime-library function name, in a way that's 
# hopefully easy to search and to determine auto-conversions.  The keys of the
# top-level of the hierarchy are the number of operands (1 or 2, for unary or
# binary).  The next level is the datatype of the operands (both operands being
# the same type).  The next level is the operator name itself.  The atomic
# values of the lowest level are order pairs of the output datatype and the
# runtime-function library name associated with the operation.
#
# Searches would go something like this, given an operator name, a number of
# operands, and datatypes of each operand, you can immediately find a match,
# if any.  If there's no match, then there's a short list of the possible ways
# to autoconvert the datatype(s) of the operands.  We can then do a search on
# each of those possibilities.
allOperators = {"|", "&", "~", "+", "-", "*", "/", "mod", "||", "=", "<", ">", 
                "~=", "~<", "~>", "<=", ">="}
operatorTypes = {
    1: { 
        "FIXED": { 
            "-": ("FIXED", "xminus"),
            "~": ("FIXED", "xNOT")
            },
        "BIT": {  },
        "CHARACTER": {}
        },
    2: {
        "FIXED": {
            "+": ("FIXED", "xadd"),
            "-": ("FIXED", "xsubtract"),
            "*": ("FIXED", "xmultiply"),
            "/": ("FIXED", "xdivide"),
            "mod": ("FIXED", "xmod"),
            "=": ("FIXED", "xEQ"),
            "<": ("FIXED", "xLT"),
            ">": ("FIXED", "xGT"),
            "~=": ("FIXED", "xNEQ"),
            "~<": ("FIXED", "xGE"),
            "~>": ("FIXED", "xLE"),
            "<=": ("FIXED", "xLE"),
            ">=": ("FIXED", "xGE"),
            "|": ("FIXED", "xOR"), 
            "&": ("FIXED", "xAND")
            },
        "BIT": { },
        "CHARACTER": {
            "||": ("CHARACTER", "xsCAT"),
            "=": ("FIXED", "xsEQ"),
            "<": ("FIXED", "xsLT"),
            ">": ("FIXED", "xsGT"),
            "~=": ("FIXED", "xsNEQ"),
            "~<": ("FIXED", "xsGE"),
            "~>": ("FIXED", "xsLE"),
            "<=": ("FIXED", "xsLE"),
            ">=": ("FIXED", "xsGE")
        }
    }
}

# This function is used by `autoconvert` to create a CHARACTER variable (both
# descriptor and data) in the reserved area set aside at the top of physical
# memory.  Returns the descriptor.  Amusingly -- or not! --, there's a need for
# this precisely *once* in HAL/S-FC, in PASS4, where the code
#    CALL MOVE(8, 'HALSDF  ', SDFNAM);
# was used in place of
#    SDFNAM = 'HALSDF  ';
# (And yes, there was a reason for that; SDFNAM is a pointer to character data 
# rather than a descriptor.)  Incidentally, this maneuver fooled not only me, 
# but also fooled the contemporary embedded comments in the SDFPROCE module to 
# say that SDFNAM was an "EXTERNAL VARIABLE REFERENCED" rather than an 
# "EXTERNAL VARIABLE CHANGED".
def reserveLiteral(string):
    global reservedMemory, physicalMemoryLimit
    length = len(string)
    if length == 0:
        return 0
    nextReserved = reservedMemory["nextReserved"] - 4 - length
    if nextReserved < physicalMemoryLimit:
        physicalMemoryLimit = nextReserved;
    descriptor = ((length - 1) << 24) | (nextReserved + 4)
    putFIXED(nextReserved, descriptor)
    for i in range(length):
        memory[nextReserved + 4 + i] = asciiToEbcdic[ord(string[i])]
    reservedMemory["numReserved"] += 1
    reservedMemory["nextReserved"] = nextReserved
    return descriptor

# Get a list of possible autoconversions.  I'm frankly confused about
# what conversions are allowed, and McKeeman seems to cover them
# in a manner that (to me) seems obtuse.  On the other hand,
# conversions not originally allowed by XCOM won't appear in any
# existing XPL or XPL/I code, so I guess I'm free to perform illegal
# conversions if I feel like it, as long as I correctly do the 
# conversions that actually *were* allowed back then.  The `autoconvert`
# function takes the `current` datatype and a list of `allowed` datatypes,
# and returns a list of the possible conversions.  If none, then the 
# list is empty.  Entries in the list are ordered pairs, with a string
# indicating the datatype converted *to* as the first entry, and as the 
# second entry a formatting string with %s where the operand can be 
# inserted that provides the C code for performing the conversion at
# runtime.
def autoconvert(current, allowed, source=None):
    conversions = []
    
    # A special case:
    if current == "BIT" and "FIXED" in allowed and source != None and \
            source.startswith("getBIT("):
        # In this case, the stuff below would convert getBIT(n,...) to 
        # bitToFixed(getBIT(n,...)), which is kind of silly, so we just
        # take care of it directly.  Start by getting the bitWidth:
        fields = source[7:].split(",", 1)
        bitWidth = int(fields[0])
        if bitWidth <= 8:
            return "FIXED", "BYTE0(" + fields[1]
        elif bitWidth <= 16:
            return "FIXED", "COREHALFWORD(" + fields[1]
        elif bitWidth <= 32:
            return "FIXED", "COREWORD(" + fields[1]
    
    if current == "SDESC":
        if "CHARACTER" in allowed:
            conversions.append(("CHARACTER", "getCHARACTERd(%s)"))
            if source != None:
                return "CHARACTER", "getCHARACTERd(%s)" % source
        if "FIXED" in allowed:
            conversions.append(("FIXED", "%s"))
            if source != None:
                return "FIXED", source
    elif current == "CHARACTER":
        if "CHARACTER" in allowed:
            conversions.append(("CHARACTER", "%s"))
        if "FIXED" in allowed and source != None:
            if source.startswith("getCHARACTER("):
                # In this case, we interpret the FIXED as being the descriptor
                # of the string. 
                return "FIXED", "getFIXED" + source[12:]
            elif source.startswith('cToDescriptor(NULL, "'): 
                # In this case, we interpret the FIXED as being the descriptor
                # of a literal string.
                descriptor = reserveLiteral(source[21:-2])
                return "FIXED", descriptor
            else:
                # Otherwise, we construct a string descriptor (integer) from
                # the descriptor_t we've been given.  However, unlike
                # in real XPL (maybe!) this descriptor isn't guaranteed to be
                # persistent forever, so we're taking a chance that the XPL
                # code isn't going to use it as if it's permanent!
                return "FIXED", "makeDescriptor(%s)" % source
        if "BIT" in allowed:
            convertions.append(("BIT", "%s"))
    elif current == "BIT":
        if "BIT" in allowed:
            conversions.append(("BIT", "%s"))
        if "FIXED" in allowed:
            conversions.append(("FIXED", "bitToFixed(%s)"))
            #if source != None:
            #    print("***", source, file=sys.stderr)
        if "CHARACTER" in allowed:
            #conversions.append(("CHARACTER", 
            #                    "fixedToCharacter(bitToFixed(%s))"))
            conversions.append(("CHARACTER", "bitToCharacter(%s)"))
    elif current == "FIXED":
        if "FIXED" in allowed:
            conversions.append(("FIXED", "%s"))
        if "BIT" in allowed:
            conversions.append(("BIT", "fixedToBit(32, (int32_t) (%s))"))
        if "CHARACTER" in allowed:
            conversions.append(("CHARACTER", "fixedToCharacter(%s)"))
    if len(conversions) == 0:
        errxit("Cannot convert type %s to any of %s: %s" % (current, str(allowed), source))
    if source == None:
        return conversions
    return conversions[0][0], conversions[0][1] % source

# `autoconvertFull` combines a lot of operations typically associated with
# `autoconvert`.  Given an `expression` tree (of an unknown datatype), it
# determines the expression's datatype, and determines the conversion needed to
# the datatype implied by `toAttributes`.  Finally, it combines those two steps
# to return a string containing the source code for the expression in the 
# desired datatype.  The return is the usual datatype,source pair.
def autoconvertFull(scope, expression, toAttributes):
    fromType, source = generateExpression(scope, expression)
    if "CHARACTER" in toAttributes:
        toType = "CHARACTER"
    elif "FIXED" in toAttributes:
        toType = "FIXED"
    elif "BIT" in toAttributes:
        toType = "BIT"
    return autoconvert(fromType, [toType], source)

# `generateOperation` is called by `generateExpression` to evaluate the result
# of an operation from `operatorTypes`.  The global variable 
def generateOperation(scope, expression):
    global currentInt, currentDesc
    token = expression["token"]
    if "operator" not in token or token["operator"] not in allOperators:
        errxit("Non-operator in generateOperation")
    operator = token["operator"]
    operands = expression["children"]
    numOperands = len(operands)
    # Generate source code for the operands (sans any autoconversion to match
    # the operator's requirements).
    if numOperands == 1:
        type1, source1 = generateExpression(scope, operands[0])
    elif numOperands == 2:
        type1, source1 = generateExpression(scope, operands[0])
        type2, source2 = generateExpression(scope, operands[1])
    else:
        errxit("Wrong number of operands for operator %s" % operator)
    # Let's find all possible operand datatypes that match the operator:
    allowedDatatypes = {}
    for datatype in ["FIXED", "BIT", "CHARACTER"]:
        if operator in operatorTypes[numOperands][datatype]:
            allowedDatatypes[datatype] = \
                operatorTypes[numOperands][datatype][operator]
    if numOperands == 1:
        type1, source1 = autoconvert(type1, allowedDatatypes, source1)
        datatype, function = allowedDatatypes[type1]
        return datatype, "%s(%s)" % (function, source1)
    # Binary operator.
    if type1 in ["BIT", "FIXED"] and type2 in ["BIT", "FIXED"] and \
            operator in operatorTypes[2]["FIXED"]:
        type1, source1 = autoconvert(type1, ["FIXED"], source1)
        type2, source2 = autoconvert(type2, ["FIXED"], source2)
        datatype, function = operatorTypes[2]["FIXED"][operator]
        #return datatype, "%s(%s, %s)" % (function, source1, source2)
        cint1 = currentInt
        cint2 = currentInt + 1
        currentInt += 2
        return datatype, "( iarg%d = %s, iarg%d = %s, %s(iarg%d, iarg%d) )" % \
            (cint1, source1, cint2, source2, function, cint1, cint2)
    autoconversions1 = autoconvert(type1, allowedDatatypes)
    autoconversions2 = autoconvert(type2, allowedDatatypes)
    for autoconversion1 in autoconversions1:
        for autoconversion2 in autoconversions2:
            if autoconversion1[0] == autoconversion2[0]:
                # Found one that works for both operands!
                tipe = autoconversion1[0]
                source1 = autoconversion1[1] % source1
                source2 = autoconversion2[1] % source2
                datatype, function = allowedDatatypes[tipe]
                #return datatype, "%s(%s, %s)" % (function, source1, source2)
                if tipe == "CHARACTER":
                    dint1 = currentDesc
                    dint2 = currentDesc + 1
                    currentDesc += 2
                    return datatype, "( darg%d = %s, darg%d = %s, %s(darg%d, darg%d) )" % \
                        (dint1, source1, dint2, source2, function, dint1, dint2)
                elif tipe == "FIXED":
                    cint1 = currentInt
                    cint2 = currentInt + 1
                    currentInt += 2
                    return datatype, "( iarg%d = %s, iarg%d = %s, %s(iarg%d, iarg%d) )" % \
                        (cint1, source1, cint2, source2, function, cint1, cint2)
                else:
                    print("Info: Arg-order for function %s type %s not forced" %\
                           (function, datatype), file=sys.stderr)
                    return datatype, "%s(%s, %s)" % (function, source1, source2)
    errxit("No possible operand promotions found for operator %s" % operator)

# The dictionary `monitorParameterTypes` tells how many parameters each MONITOR
# function has, and what their datatypes are supposed to be.
mptF = ["FIXED"]
mptFC = ["FIXED", "CHARACTER"]
mptFF = ["FIXED", "FIXED"]
mptC = ["CHARACTER"]
monitorParameterTypes = {
    "0": mptF,
    "1": mptFC,
    "2": mptFC,
    "3": mptF,
    "4": mptFF,
    "5": mptF,
    "6": mptFF,
    "7": mptFF,
    "8": mptFF,
    "9": mptF,
    "10": mptC,
    "11": [],
    "12": mptF,
    "13": mptC,
    "14": mptFF,
    "15": [],
    "16": mptF,
    "17": mptC,
    "18": [],
    # 19 is nonstandard.
    # 20 is nonstandard.
    "21": [],
    "22": mptF,
    "23": [],
    # 24 through 30 are TBD
    "31": mptFF,
    "32": []
    # 33 is TBD.
    }
mrtFIXED = ["1", "2", "6", "7", "9", "10", "13", "14", "15", "18", "19", "21",
            "22", "32"]
mrtCHARACTER = ["12", "23"]
# `autoconvertMonitor` autoconverts datatypes of MONITOR parameters.  The 
# return is a type,source ordered pair.  A returned type of None means that
# the MONITOR function is only suitable for CALL, and returns no value itself.
def autoconvertMonitor(scope, parameters):
    if len(parameters) < 1:
        errxit("No function number given in MONITOR invocation")
    parameter = parameters[0]
    tipef, sourcef = generateExpression(scope, parameter)
    if not isinstance(sourcef, str) or not sourcef.isdigit():
        errxit("MONITOR function number is not an integer")
    if sourcef in mrtFIXED:
        returnType = "FIXED"
    elif sourcef in mrtCHARACTER:
        returnType = "CHARACTER"
    else:
        returnType = None
    functionName = "MONITOR" + sourcef
    pstart= 1
    if sourcef in ["19", "20"]:
        errxit("MONITOR 19, 20 not implemented")
    if sourcef == "22": # A special case.
        if len(parameters) < 2:
            errxit("Not enough parameters for MONITOR(22)")
        parameter = parameters[1]
        tipep, sourcep = generateExpression(scope, parameter)
        if sourcep == "0":
            functionName = functionName + "A"
            pstart = 2
            # Fall through.
    source = functionName + "("
    count = -1
    for parameter in parameters[pstart:]:
        count += 1
        if count > 0:
            source = source + ", "
        tipep, sourcep = generateExpression(scope, parameter)
        if sourcef == "13" and tipep == "FIXED" and sourcep == "0":
            tipep = "CHARACTER"
            sourcep = 'asciiToDescriptor("")'
        if sourcef in monitorParameterTypes:
            mpt = monitorParameterTypes[sourcef]
            if count >= len(mpt):
                errxit("Too many parameters for MONITOR(%s)" % sourcef)
            tipep, sourcep = autoconvert(tipep, [mpt[count]], sourcep)
            if tipep != mpt[count]:
                errxit("Could not autoconvert MONITOR(%s) parameter %d to %s" \
                       % (sourcef, count, mpt[count]))
        source = source + sourcep
    source = source + ")"
    return returnType, source

def getIdentifier(token):
    if "identifier" in token:
        return token["identifier"]
    if "builtin" in token:
        return token["builtin"]
    errxit("Token is neither an `identifier` nor a `builtin`: %s", str(token))

# Recursively generate the source code for a C expression that evaluates a tree
# (previously returned by the `parseExpression` function) created from an XPL 
# expression.  Returns a pair:
#
#    Indicator of the type of the result: "FIXED", "BIT", "CHARACTER".
#
#    String containing the generated code.
#
# In case of error, some kinds return None,None while others abort execution.
def generateExpression(scope, expression):
    source = ""
    tipe = "INDETERMINATE" # Recall that `type` is a reserved word in Python.
    if not isinstance(expression, dict):
        return tipe, source
    token = expression["token"]
    if "operator" in token:
        operator = token["operator"]
    else:
        operator = None
    if "number" in token:
        tipe = "FIXED"
        source = str(token["number"])
    elif "string" in token:
        tipe = "CHARACTER"
        source = 'cToDescriptor(NULL, "' + token["string"]\
                            .replace('"', '\\\"')\
                            .replace(replacementQuote, "'") + '")'
    elif operator == ".":
        # The operator is the separator between the name of a  BASED RECORD 
        # (possibly subscripted) and the name of one of its fields (also 
        # possibly subscripted).
        if len(expression["children"]) != 2:
            errxit("Wrong number of children for '.' operator")
        baseExpression = expression["children"][0]
        fieldExpression = expression["children"][1]
        '''
        if "identifier" not in baseExpression["token"]:
            errxit("Base of '.' operator not an identifier")
        if "identifier" not in fieldExpression["token"]:
            errxit("Field of '.' operator not an identifier")
        baseName = baseExpression["token"]["identifier"]
        fieldName = fieldExpression["token"]["identifier"]
        '''
        baseName = getIdentifier(baseExpression["token"])
        fieldName = getIdentifier(fieldExpression["token"])
        baseAttributes = getAttributes(scope, baseName)
        if baseAttributes == None:
            errxit("Base (%s) of '.' operator not found" % baseName)
        if "BASED" not in baseAttributes:
            errxit("Base (%s) of '.' operator is not a BASED variable" %\
                   baseName)
        if "RECORD" not in baseAttributes:
            errxit("BASED variable %s is not a RECORD" % baseName)
        recordAttributes = baseAttributes["RECORD"]
        if fieldName not in recordAttributes:
            errxit("BASED RECORD variable %s has no %s field" % \
                   (baseName, fieldName))
        fieldAttributes = recordAttributes[fieldName]
        # We're now in a position to form an expression that computes the
        # address of this based variable (i.e., in worst case, the address
        # of base(...).field(...)).  In pseudocode:
        #
        #    base address        ( = getFIXED(basedAddress) + 
        #                            recordSize * basedIndex)   )
        #    +
        #    offset of field into record
        #    +
        #    widthOfItem * fieldIndex
        baseSubscripts = baseExpression["children"]
        if len(baseSubscripts) == 0:
            sourceb = '0'
        elif len(baseSubscripts) == 1:
            typeb, sourceb = \
                generateExpression(scope, baseExpression["children"][0])
            typeb, sourceb = autoconvert(typeb, ["FIXED"], sourceb)
            if typeb != "FIXED":
                errxit("Subscript of %s not integer" % baseName)
        else:
            errxit("BASED variable %s not subscripted properly" % baseName)
        fieldSubscripts = fieldExpression["children"]
        if len(fieldSubscripts) == 0:
            sourcef = '0'
        elif len(fieldSubscripts) == 1:
            typef, sourcef = \
                generateExpression(scope, fieldExpression["children"][0])
            typef, sourcef = autoconvert(typef, ["FIXED"], sourcef)
            if typef != "FIXED":
                errxit("Subscript of field %s.%s not integer" % \
                       (baseName, fieldName))
        else:
            errxit("Field %s.%s not subscripted properly" % \
                   (baseName, fieldName))
        sourceAddress = "getFIXED(%s)" % memoryMap[baseAttributes['address']]["superMangled"] + \
                        " + %d * (%s)" % (baseAttributes["recordSize"],
                                          sourceb) + \
                        " + %d + " % fieldAttributes["offset"] + \
                        "%d * (%s)" % (fieldAttributes["dirWidth"], sourcef)
        if "CHARACTER" in fieldAttributes:
            return "CHARACTER", "getCHARACTER(%s)" % sourceAddress
        elif "FIXED" in fieldAttributes:
            return "FIXED", "getFIXED(%s)" % sourceAddress
        elif "BIT" in fieldAttributes:
            return "BIT", "getBIT(%d, %s)" % (fieldAttributes["BIT"], sourceAddress)
        else:
            errxit("Cannot find datatype of field %s.%s" % \
                   (baseName, fieldName))
    elif operator != None:
        # Generate the code for any unary or binary arithmetical, logical, or
        # character operator.
        tipe, source = generateOperation(scope, expression)
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
                        source = mangled + "(0)"
                    else:
                        innerParameters = attributes["parameters"] 
                        innerScope = attributes["PROCEDURE"]
                        if len(outerParameters) > len(innerParameters):
                            errxit("Too many parameters in " + symbol)
                        source = "( "
                        for k in range(len(outerParameters)):
                            outerParameter = outerParameters[k]
                            innerParameter = innerParameters[k]
                            try:
                                innerAttributes = innerScope["variables"][innerParameter]
                            except:
                                errxit("Parameter %s may not have been DECLAREd within the PROCEDURE" \
                                       % innerParameter)
                            innerAddress = memoryMap[innerAttributes["address"]]["superMangled"]
                            toType, parm = autoconvertFull(scope, \
                                                           outerParameter, \
                                                           innerAttributes)
                            if toType == "BIT":
                                function = "putBITp(%d, " % innerAttributes["BIT"]
                            elif toType == "CHARACTER":
                                function = "putCHARACTERp("
                            else:
                                function = "put" + toType + "("
                            source = source + function + \
                                 innerAddress + ", " + parm + "), "
                        source = source + mangled + "(0) )"
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
                        tipei, index = generateExpression(scope, indices[0])
                        tipei, index = autoconvert(tipei, ["FIXED"], index)
                        if tipei != "FIXED":
                            errxit("Array index can't be computed or not integer")
                    entryWidth = attributes["dirWidth"]
                    baseAddress = memoryMap[attributes["address"]]["superMangled"]
                    if "BASED" in attributes:
                        baseAddress = "getFIXED(%s)" % baseAddress
                        if "recordSize" in attributes:
                            entryWidth = attributes["recordSize"]
                        elif "BIT" in attributes and attributes["BIT"] <= 8:
                            entryWidth = 1
                        elif "BIT" in attributes and attributes["BIT"] <= 16:
                            entryWidth = 2
                        else:
                            entryWidth = 4
                    function = None
                    if "FIXED" in attributes:
                        tipe = "FIXED"
                    elif "BIT" in attributes:
                        tipe = "BIT"
                    elif "CHARACTER" in attributes:
                        tipe = "CHARACTER"
                    else:
                        errxit("Unsupported variable type")
                    if tipe == "BIT":
                        function = "getBIT(%d, " % attributes["BIT"]
                    else:
                        function = "get" + tipe + "("
                    if index == "":
                        source = function + baseAddress + ")"
                    else:
                        source = function + baseAddress + \
                                 " + %d*" % entryWidth + \
                                 index + ")"
                    return tipe, source
            else:
                errxit("Unknown variable %s" % symbol, action="return")
                return None,None
        else:
            symbol = token["builtin"]
            # Compile-time builtins.
            if symbol == "RECORD_WIDTH":
                children = expression["children"]
                if len(children) == 1 and "identifier" in children[0]["token"]:
                    var = children[0]["token"]["identifier"]
                    attributes = getAttributes(scope, var)
                    if "recordSize" in attributes:
                        return "FIXED", "%s" % attributes["recordSize"]
                    else:
                        errxit("Variable %s has no associated record width" % var)
                else:
                    errxit("Parameter of RECORD_WIDTH not an identifier")
            # Variables:
            if symbol in ["LINE_COUNT"]:
                return "FIXED", "LINE_COUNT"
            if symbol == "STRING":
                # `STRING` is in principle a built-in function, but it's 
                # better treated as a combination of other built-ins.
                parameters = expression["children"]
                if len(parameters) != 1:
                    errxit("Wrong number of parameters for STRING")
                parameter = parameters[0]
                tipe, source = generateExpression(scope, parameter)
                if source.startswith("getCHARACTER("):
                    return "SDESC", "getFIXED(" + source[13:]
                if source.startswith("getFIXED("):
                    return "CHARACTER", "getCHARACTER(" + source[9:]
                if tipe == "FIXED":
                    return "SDESC", source # "getFIXED(" + source + ")"
                if tipe == "CHARACTER":
                    return tipe, source
                tipe, source = autoconvert(tipe, ["FIXED"], source)
                if tipe != "FIXED":
                    errxit("Cannot interpret argument of STRING")
                return "SDESC", source
            # Many builtins.
            if symbol in ["INPUT", "LENGTH", "SUBSTR", "BYTE", "SHL", "SHR",
                          "DATE", "TIME", "DATE_OF_GENERATION", "COREBYTE",
                          "COREWORD", "FREEPOINT", "TIME_OF_GENERATION",
                          "FREELIMIT", "FREEBASE", "ABS", "NDESCRIPT",
                          "STRING_GT", "COREHALFWORD", "PARM_FIELD",
                          "DESCRIPTOR", "XPL_COMPILER_VERSION"]:
                if symbol in ["INPUT", "SUBSTR", "PARM_FIELD"]:
                    builtinType = "CHARACTER"
                else:
                    builtinType = "FIXED"
                parameters = expression["children"]
                source = symbol + "("
                # Some special cases for omitted parameters.
                if symbol in ["INPUT", "XPL_COMPILER_VERSION"] and \
                        len(parameters) == 0:
                    source = source + "0"
                    first = False
                elif symbol == "SUBSTR" and len(parameters) == 2:
                    source = "SUBSTR2("
                elif symbol == "BYTE":
                    if len(parameters) == 1:
                        source = "BYTE1("
                # (Almost) uniform processing of parameters.
                for parmNum in range(len(parameters)):
                    parameter = parameters[parmNum]
                    if parmNum != 0:
                        source = source + ", "
                    tipe, p = generateExpression(scope, parameter)
                    # Some special cases
                    #if parmNum == 0 and tipe == "BIT" and symbol == "BYTE":
                    #    source = "BYTE2("
                    #    symbol = "BYTE2"
                    if parmNum == 0 and symbol == "BYTE" and p.startswith('"'):
                        if len(parameters) == 1:
                            source = "BYTE1literal("
                        else:
                            source = "BYTEliteral("
                    # Datatype conversions for parameters:
                    autoconvertTo = tipe
                    if parmNum == 0:
                        if symbol in ["ABS", "COREBYTE", "COREWORD", "SHL",
                                      "SHR", "INPUT", "STRING", "COREHALFWORD",
                                      "DESCRIPTOR"]:
                            autoconvertTo = "FIXED"
                        elif symbol in ["BYTE", "LENGTH", "STRING_GT", 
                                        "SUBSTR"]:
                            autoconvertTo = "CHARACTER"
                    elif parmNum == 1:
                        if symbol in ["BYTE", "BYTE2", "SHL", "SHR", "SUBSTR"]:
                            autoconvertTo = "FIXED"
                        elif symbol in ["STRING_GT"]:
                            autoconvertTo = "CHARACTER"
                    elif parmNum == 2:
                        if symbol in ["SUBSTR"]:
                            autoconvertTo= "FIXED"
                    if autoconvertTo != tipe:
                        tipe, p = autoconvert(tipe, [autoconvertTo], p)
                    source = source + p
                source = source + ")"
                return builtinType, source
            elif symbol == "MONITOR":
                '''
                # The parameters and return types of MONITOR vary dramatically
                # depending on the function number.  So we have to determine
                # that before deciding which runtime specific runtime function
                # to call, as opposed to just calling a single MONITOR function.
                # I require the function number to be a literal integer.  
                # If not, this is all completely in adequate.
                if len(expression["children"]) < 1:
                    errxit("No function number specified for MONITOR")
                if "number" not in expression["children"][0]["token"]:
                    errxit("Could not evaluate MONITOR function number")
                functionNumber = expression["children"][0]["token"]["number"]
                # Only certain monitor functions return values.
                if functionNumber in {1, 2, 6, 7, 9, 10, 12, 13, 14, 15, 18, 
                                      21, 22, 23, 32}:
                    symbol = "MONITOR%d" % functionNumber;
                    builtinType = "FIXED"
                    if functionNumber in {12}:
                        builtinType = "CHARACTER"
                else:
                    errxit("MONITOR(%d) unimplemented or returns no value" % \
                           functionNumber)
                first = True
                source = symbol + "("
                for parameter in expression["children"][1:]:
                    if not first:
                        source = source + ", "
                    first = False
                    tipe, p = generateExpression(scope, parameter)
                    source = source + p
                source = source + ")"
                '''
                return autoconvertMonitor(scope, expression["children"])
            elif symbol == "ADDR":
                parameters = expression["children"]
                if len(parameters) != 1:
                    errxit("ADDR takes a single parameter")
                return "FIXED", generateADDR(scope, parameters[0])
            elif symbol == "RECORD_TOP":
                # This isn't really a built-in, but instead it's something 
                # from HAL/S-FC's SPACELIB, but for right now I'm pretending
                # that it's a built-in.  I believe that it's supposed to 
                # give you the highest memory address used by a BASED variable.
                # And this isn't really how you support this, but it's just a
                # placeholder.
                return "FIXED", "0"
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

# Creates an expression for ADDR(identifier), possibly with the identifier
# having subscripts (that can be expressions) or RECORD fields (possibly with
# subscripts that can be expressions).  If the base identifier has no subscript,
# a subscript of 0 is added to it, to avoid the special case in which ADDR()
# can return the address of a BASED's pointer rather than its data.  If I had
# been clever, I would have been using this for assignments from day 1, but I've
# introduced it belatedly only when working on `FILE`.  Returns type,source.
def getExpressionADDR(scope, expression):
    if "identifier" in expression["token"] and len(expression["children"]) == 0:
        expression["children"] = [ {
            "token": { "number": 0 }
            } ]
    addrExpression = {
        "token": { "builtin": "ADDR" },
        "children": [ expression ]
        }
    return generateExpression(scope, addrExpression)

# Return source for parameters of FILE (parm1,parm2) as type FIXED.
def getParmsFILE(scope, expression):
    children = expression["children"]
    if len(children) != 2:
        errxit("FILE(...) has wrong number of arguments")
    ne1Type, ne1Source = generateExpression(scope, children[0])
    ne1Type, ne1Source = autoconvert(ne1Type, ["FIXED"], ne1Source)
    ne2Type, ne2Source = generateExpression(scope, children[1])
    ne2Type, ne2Source = autoconvert(ne2Type, ["FIXED"], ne2Source)
    if ne1Type != "FIXED" or ne1Source == None:
        errxit("Cannot compute device number for FILE(...)")
    if ne2Type != "FIXED" or ne2Source == None:
        errxit("Cannot compute record number for FILE(...)")
    return ne1Source, ne2Source

# Return True on success, False on Failure
#inhibitInline = 0
def applyInlinePatch(scope, indent, originalInline):
    #global inhibitInline
    found = False
    patchFilename = None
    patchFile = None
    
    def openFile(pattern):
        nonlocal found, patchFilename, patchFile
        try:
            patchFilename = pattern % inlineCounter
            if baseSource != "":
                patchFilename = baseSource + "/" + patchFilename
            patchFile = open(patchFilename, "r")
            found = True
        except:
            pass
    
    if "P" in ifdefs:
        openFile("patch%dp.c")
    if not found and "B" in ifdefs:
        openFile("patch%db.c")
    if not found:  
        openFile("patch%d.c") 
    if not found:
        return False
    indent2 = indent + indentationQuantum
    if debugInlines and lastCallInline != lineCounter - 1:
        print(indent + "{ debugInline(%d); // (%d) %s" % \
              (inlineCounter, inlineCounter, originalInline))
    else:
        print(indent + "{ // (%d) %s" % (inlineCounter, originalInline))
    if traceInlines:
        print(indent2 + 'traceInline("%s p%d");' % \
              (findParentProcedure(scope)["symbol"], inlineCounter))
    #first = True
    for patchLine in patchFile:
        '''
        if first:
            first = False
            fields = patchLine.split("inlines=")
            if len(fields) == 2:
                fields = fields[1].split()
                fields = fields[0].split(",")
                if len(fields) == 1:
                    requestedInhibit = int(fields[0])
                elif len(fields) == 2:
                    if "P" in ifdefs:
                        requestedInhibit = int(fields[0])
                    elif "B" in ifdefs:
                        requestedInhibit = int(fields[1])
            inhibitInline = requestedInhibit
        '''
        print(indent2 + patchLine.rstrip())
    print(indent + "}")
    patchFile.close()
    return True

# The `generateSingleLine` function is used by `generateCodeForScope`.
# As the name implies, it operates on the pseudo-code for a single 
# pseudo-statement, generating the C source code for it, and printing that
# source code to the output file.
lineCounter = 0  # For debugging purposes only.
forLoopCounter = 0
inlineCounter = 0
lastCallInline = -2
functionName = ""
def generateSingleLine(scope, indent2, line, indexInScope, ps = None):
    global forLoopCounter, lineCounter, inlineCounter, errxitRef
    global lastCallInline #, inhibitInline
    parentProcedureScope = findParentProcedure(scope)
    '''
    The following line is a ridiculous trick.  Originally, the line wasn't
    there, and `indent` was simply the 2nd parameter of this
    `generateSingleLine` function.  This worked (and still works) fine when
    I simply run XCOM-I.py.  *However*, at some point it began failing when
    I debug XCOM-I.py, and instead aborted at the first use of `indent` in
    this function, saying that it was a local variable that had not yet been
    assigned a value, which is patently false.  After several frustrating
    weeks of working around the inability to debug XCOM-I.py any longer, I
    found that changing the parameter to `indent2` and than immediately
    assigning `indent=indent2` debugged find.  Yikes!
    '''
    indent = indent2
    errxitRef = scope["lineRefs"][indexInScope]
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
                if "TARGET" in line:
                    parent["ifCounter"] += 1
                parent["switchCounter"] += 1
                if ps != None:
                    print(indent + "// " + \
                          ps.replace(replacementQuote, "''") \
                          + (" (%d)" % lineCounter))
            if parent["ifCounter"] > 0:
                parent["ifCounter"] -= 1
            if "IF" in line or "ELSE" in line or "TARGET" in line:
                parent["ifCounter"] += 1
    if "ASSIGN" in line:
        print(indent + "{")
        oldIndent = indent
        indent += indentationQuantum
        # Note that McKeeman p. 137 specifies that multiple assignments are done
        # right to left.  The order is important if you had an assignment like
        # X(I),I = J since the value X(I) gets assigned is different if the 
        # order is different.  But if I do it the way McKeeman specifies, I get
        # infinite loops not only in HAL/S-FC PASS1, but also in HAL_S_FC.py.
        # I think that the Intermetrics XPL compiler did it in left-to-right
        # order.  Whether McKeeman mispoke or not is hard to say, since none
        # of the legacy standard XPL code I've encountered has any problematic
        # multiple assignments affected by the order. 
        #LHSs = list(reversed(line["LHS"]))
        LHSs = line["LHS"]
        RHS = line["RHS"]
        # Assignments involving `FILE` are special, in my current 
        # implementation anyway, so treat them differently.
        fileOnRight = False
        if "token" in RHS and "builtin" in RHS["token"] and \
                RHS["token"]["builtin"] == "FILE":
            fileOnRight = True
            devR, recR = getParmsFILE(scope, RHS)
        for LHS in LHSs:
            fileOnLeft = False
            if "token" in LHS and "builtin" in LHS["token"] and \
                    LHS["token"]["builtin"] == "FILE":
                fileOnLeft = True
            if fileOnLeft or fileOnRight:
                if fileOnLeft:
                    devL, recL = getParmsFILE(scope, LHS)
                    if not fileOnRight:
                        typeR, addrR = getExpressionADDR(scope, RHS)
                else:
                    typeL, addrL = getExpressionADDR(scope, LHS)
                if fileOnLeft and not fileOnRight:
                    print(indent + "lFILE(%s, %s, %s);" % (devL, recL, addrR))
                elif fileOnRight and not fileOnLeft:
                    print(indent + "rFILE(%s, %s, %s);" % (addrL, devR, recR))
                else:
                    print(indent + "bFILE(%s, %s, %s, %s);" % (devL, recL, devR, recR))
                print(oldIndent + "}")
                return
        # Non-FILE case.  Note that there still could be some `FILE` on the
        # left (but not on the right), so we'll still have to check for that
        # below and bypass them.
        tipeR, sourceR = generateExpression(scope, RHS)
        definedS = False
        definedN = False
        definedB = False
        if tipeR == "SDESC":
            definedN = True
            print(indent + "int32_t numberRHS = (int32_t) (" + sourceR + ");")
            definedS = True
            print(indent + "descriptor_t *stringRHS = getCHARACTERd(" + sourceR + ");")
        elif tipeR == "FIXED":
            definedN = True
            print(indent + "int32_t numberRHS = (int32_t) (" + sourceR + ");")
        elif tipeR == "BIT":
            definedB = True
            print(indent + "descriptor_t *bitRHS = " + sourceR + ";")
        elif tipeR == "CHARACTER":
            definedS = True
            print(indent + "descriptor_t *stringRHS;")
            print(indent + "stringRHS = %s;"  % sourceR)
        else:
            errxit("Unknown RHS type: " + str(RHS))
        
        def autoConvert(fromType, toType):
            nonlocal definedS, definedN, definedB;
            
            conversions = autoconvert(fromType, [toType])
            conversion = conversions[0][1]
            fromVar2 = None
            if fromType == "SDESC":
                fromVar = "numberRHS"
                fromVar2 = "stringRHS"
            elif fromType == "CHARACTER":
                fromVar = "stringRHS"
            elif fromType == "FIXED":
                fromVar = "numberRHS"
            elif fromType == "BIT":
                fromVar = "bitRHS"
            if toType == "CHARACTER":
                toVar = "stringRHS"
                if not definedS:
                    print(indent + "descriptor_t *stringRHS;")
                    definedS = True
                if toVar != fromVar and toVar != fromVar2:
                    #print(indent + \
                    #      "stringRHS = cToDescriptor(NULL, \"%%s\", %s);" \
                    #      % (conversion % fromVar))
                    print(indent + "stringRHS = %s;" % (conversion % fromVar))
            elif toType == "FIXED":
                toVar = "numberRHS"
                if not definedN:
                    print(indent + "int32_t %s;" % toVar)
                    definedN = True
                if toVar != fromVar and toVar != fromVar2:
                    print(indent + "%s = %s;" % (toVar, conversion % fromVar))
            elif toType == "BIT":
                toVar = "bitRHS"
                if not definedB:
                    print(indent + "descriptor_t *%s;" % toVar)
                    definedB = True
                if toVar != fromVar:
                    print(indent + "%s = %s;" % (toVar, conversion % fromVar))

        for i in range(len(LHSs)):
            LHS = LHSs[i]
            tokenLHS = LHS["token"]
            if "builtin" in tokenLHS and tokenLHS["builtin"] == "FILE":
                continue # Already did this one above.
            if "operator" in tokenLHS and tokenLHS["operator"] == ".":
                expression = LHS
                # This was adapted from the code for '.' in 
                # `generateExpression`, which is why I've suddenly started
                # working with `expression` rather than `LHS`.  In fact, it's
                # the identical code until the very end.
                if len(expression["children"]) != 2:
                    errxit("Wrong number of children for '.' operator")
                baseExpression = expression["children"][0]
                fieldExpression = expression["children"][1]
                '''
                if "identifier" not in baseExpression["token"]:
                    errxit("Base of '.' operator not an identifier")
                if "identifier" not in fieldExpression["token"]:
                    errxit("Field of '.' operator not an identifier")
                baseName = baseExpression["token"]["identifier"]
                fieldName = fieldExpression["token"]["identifier"]
                '''
                baseName = getIdentifier(baseExpression["token"])
                fieldName = getIdentifier(fieldExpression["token"])
                baseAttributes = getAttributes(scope, baseName)
                if baseAttributes == None:
                    errxit("Base (%s) of '.' operator not found" % baseName)
                if "BASED" not in baseAttributes:
                    errxit("Base (%s) of '.' operator is not a BASED variable" %\
                           baseName)
                if "RECORD" not in baseAttributes:
                    errxit("BASED variable %s is not a RECORD" % baseName)
                recordAttributes = baseAttributes["RECORD"]
                if fieldName not in recordAttributes:
                    errxit("BASED RECORD variable %s has no %s field" % \
                           (baseName, fieldName))
                fieldAttributes = recordAttributes[fieldName]
                baseSubscripts = baseExpression["children"]
                if len(baseSubscripts) == 0:
                    sourceb = '0'
                elif len(baseSubscripts) == 1:
                    typeb, sourceb = \
                        generateExpression(scope, baseExpression["children"][0])
                    typeb, sourceb = autoconvert(typeb, ["FIXED"], sourceb)
                    if typeb != "FIXED":
                        errxit("Subscript of %s not integer" % baseName)
                else:
                    errxit("BASED variable %s not subscripted properly" % baseName)
                fieldSubscripts = fieldExpression["children"]
                if len(fieldSubscripts) == 0:
                    typef = "FIXED"
                    sourcef = '0'
                elif len(fieldSubscripts) == 1:
                    typef, sourcef = \
                        generateExpression(scope, fieldExpression["children"][0])
                    typef, sourcef = autoconvert(typef, ["FIXED"], sourcef)
                    if typef != "FIXED":
                        errxit("Subscript of field %s.%s not integer" % \
                               (baseName, fieldName))
                else:
                    errxit("Field %s.%s not subscripted properly" % \
                           (baseName, fieldName))
                try:
                    sourceAddress = "getFIXED(%s)" % memoryMap[baseAttributes['address']]["superMangled"] + \
                                    " + %d * (%s)" % (baseAttributes["recordSize"],
                                                      sourceb) + \
                                    " + %d + " % fieldAttributes["offset"] + \
                                    "%d * (%s)" % (fieldAttributes["dirWidth"], sourcef)
                except:
                    s = "Implementation problem:\n"
                    s = s + "  %s attributes:\n" % baseName
                    for a in baseAttributes:
                        s = s + "    %s: %s" % (str(a), str(baseAttributes[a])) + "\n"
                    s = s + "  %s attributes:\n" % fieldName
                    for a in fieldAttributes:
                        s = s + "    %s: %s" % (str(a), str(fieldAttributes[a])) + "\n"
                    errxit(s[:-1])
                if "CHARACTER" in fieldAttributes:
                    if tipeR == "FIXED":
                        print(indent + "putCHARACTER(%s, fixedToCharacter(numberRHS));" \
                                        % sourceAddress)
                    elif tipeR == "BIT":
                        print(indent + "putCHARACTER(%s, fixedToCharacter(bitToFixed(bitRHS)));" \
                                    % sourceAddress)
                    else:
                        print(indent + "putCHARACTER(%s, stringRHS);" \
                                    % sourceAddress)
                elif "FIXED" in fieldAttributes:
                    if tipeR == "BIT":
                        print(indent + "putFIXED(%s, bitToFixed(bitRHS));" \
                                    % sourceAddress)
                    else:
                        print(indent + "putFIXED(%s, numberRHS);" \
                                    % sourceAddress)
                elif "BIT" in fieldAttributes:
                    if tipeR == "FIXED":
                        print(indent + "putBIT(%d, %s, fixedToBit(%d, numberRHS));" % \
                              (fieldAttributes["BIT"], 
                               sourceAddress, fieldAttributes["BIT"]))
                    else:
                        print(indent + "putBIT(%d, %s, bitRHS);" % \
                              (fieldAttributes["BIT"], sourceAddress))
                else:
                    errxit("Cannot find datatype of field %s.%s" % \
                           (baseName, fieldName))

            elif "identifier" in tokenLHS:
                identifier = tokenLHS["identifier"]
                attributes = getAttributes(scope, identifier)
                try:
                    address = attributes["address"]
                except:
                    print(identifier, file=sys.stderr)
                    print(attributes, file=sys.stderr)
                    print(line, file=sys.stderr)
                    sys.exit(1)
                children = LHS["children"]
                entryWidth = attributes["dirWidth"]
                baseAddress = memoryMap[address]["superMangled"]
                if "BASED" in attributes:
                    baseAddress = "getFIXED(%s)" % baseAddress
                    if "recordSize" in attributes:
                        entryWidth = attributes["recordSize"]
                    elif "BIT" in attributes and attributes["BIT"] <= 8:
                        entryWidth = 1
                    elif "BIT" in attributes and attributes["BIT"] <= 16:
                        entryWidth = 2
                    else:
                        entryWidth = 4
                if len(children) == 1: # Compute index.
                    tipeL, sourceL = generateExpression(scope, children[0])
                    if tipeL != "FIXED":
                        tipeL, sourceL = autoconvert(tipeL, ["FIXED"], sourceL)
                if "FIXED" in attributes:
                    autoConvert(tipeR, "FIXED")
                    if len(children) == 0:
                        print(indent + "putFIXED(" + baseAddress + ", numberRHS);") 
                    elif len(children) == 1:
                        print(indent + "putFIXED(" + baseAddress + \
                              "+ %d*(" % entryWidth + \
                              sourceL + "), numberRHS);") 
                    else:
                        errxit("Too many subscripts")
                elif "BIT" in attributes:
                    autoConvert(tipeR, "BIT")
                    if len(children) == 0:
                        print(indent + "putBIT(%d, " % attributes["BIT"] +\
                               baseAddress + ", bitRHS);") 
                    elif len(children) == 1:
                        print(indent + "putBIT(%d, " % attributes["BIT"] + \
                              baseAddress + \
                              "+ %d*(" % entryWidth + \
                              sourceL + "), bitRHS);") 
                    else:
                        errxit("Too many subscripts")
                elif "CHARACTER" in attributes:
                    autoConvert(tipeR, "CHARACTER")
                    if len(children) == 0:
                        print(indent + "putCHARACTER(" + baseAddress + ", stringRHS);") 
                    elif len(children) == 1:
                        print(indent + "putCHARACTER(" + baseAddress + \
                              "+ %d*(" % entryWidth + \
                              sourceL + "), stringRHS);") 
                    else:
                        errxit("Too many subscripts")
                else:
                    errxit("Undetermined LHS type")
            elif "builtin" in tokenLHS:
                builtin = tokenLHS["builtin"]
                children = LHS["children"]
                if builtin in ["FREEPOINT", "FREELIMIT", "FREEBASE"]:
                    print(indent + "%s2(numberRHS);" % builtin)
                elif builtin in ["COREBYTE", "COREWORD", "COREHALFWORD",
                                 "DESCRIPTOR"]:
                    if len(children) == 1:
                        tipe, source = generateExpression(scope, children[0])
                        #if "1322" in source:
                        #    print("**", tipe, source, file=sys.stderr)
                        if tipe != "FIXED":
                            tipe, source = autoconvert(tipe, ["FIXED"], source)
                        if definedN:
                            print(indent + "%s2(%s, numberRHS);" % (builtin, source))
                        elif definedB:
                            print(indent + "%s2(%s, bitToFixed(bitRHS));" % (builtin, source))
                    else:
                        errxit("Cannot compute address for CORExxxx(...)")
                elif builtin == "OUTPUT":
                    autoConvert(tipeR, "CHARACTER")
                    if len(children) == 0:
                        print(indent + "OUTPUT(0, stringRHS);")
                    elif len(children) == 1:
                        tipe, source = generateExpression(scope, children[0])
                        
                        print(indent + "OUTPUT(" + source + ", stringRHS);")
                    else:
                        errxit("Corrupted device number in OUTPUT")
                elif builtin == "BYTE":
                    builtin = "lBYTEc"
                    if len(children) in [1, 2]:
                        typev, sourcev = getExpressionADDR(scope, children[0])
                    if len(children) == 2:
                        typei, sourcei = generateExpression(scope, children[1])
                        typei, sourcei = autoconvert(typei, ["FIXED"], sourcei)
                    else:
                        typei = "FIXED"
                        sourcei = "0"
                    if tipeR in "BIT":
                        tipeR, sourceR = autoconvert(tipeR, ["FIXED"], sourceR)
                        if tipeR != "FIXED":
                            errxit("Value to assign to BYTE wrong type")
                    if tipeR == "FIXED":
                        builtin = "lBYTEb"
                    print(indent + "%s(%s, %s, %s);" % \
                          (builtin, sourcev, sourcei, sourceR))
                elif builtin == "FILE":
                    if True:
                        # Get the ADDR of the RHS.
                        if "identifier" in RHS["token"] and len(RHS["children"]) == 0:
                            RHS["children"] = [ {
                                "token": { "number": 0 }
                                } ]
                        addrExpression = {
                            "token": { "builtin": "ADDR" },
                            "children": [ RHS ]
                            }
                        typea, sourcea = generateExpression(scope, addrExpression)
                    else:
                        # We're going to assume that the RHS represents an array
                        # of 8-bit values.
                        if len(RHS) == 0 or 'token' not in RHS or \
                                "identifier" not in RHS['token']:
                            errxit("In FILE(...)=BUFFER, require BUFFER to be an array of BIT(8)")
                        bufferName = RHS['token']['identifier']
                        bufferAttributes = getAttributes(scope, bufferName)
                        if bufferAttributes == None or \
                                "BASED" in bufferAttributes or \
                                "BIT" not in bufferAttributes or \
                                bufferAttributes["BIT"] != 8 or \
                                "top" not in bufferAttributes:
                            errxit("In FILE(...)=BUFFER, require BUFFER to be an array of BIT(8)")
                        sourcea = memoryMap[bufferAttributes["address"]]["superMangled"]
                    # Note: We can't have any knowledge at compile-time of the 
                    # record size needed by the file, since files are only 
                    # attached at runtime, so we cannot check whether or not
                    # the assigned buffer is adequate in size right now.
                    children = LHS["children"]
                    if len(children) != 2:
                        errxit("FILE(...) has wrong number of arguments")
                    ne1Type, ne1Source = generateExpression(scope, children[0])
                    ne1Type, ne1Source = autoconvert(ne1Type, ["FIXED"], ne1Source)
                    ne2Type, ne2Source = generateExpression(scope, children[1])
                    ne2Type, ne2Source = autoconvert(ne2Type, ["FIXED"], ne2Source)
                    if ne1Type != "FIXED" or ne1Source == None:
                        errxit("Cannot compute device number for FILE(...)")
                    if ne2Type != "FIXED" or ne2Source == None:
                        errxit("Cannot compute record number for FILE(...)")
                    print(indent + "lFILE(%s, %s, %s);" % \
                          (ne1Source, ne2Source, sourcea))
                else:
                    errxit("Unsupported builtin " + builtin)
            else:
                errxit("Bad LHS " + str(LHS))
        if definedB:
            print(indent + "bitRHS->inUse = 0;")
        if definedS:
            print(indent + "stringRHS->inUse = 0;")
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
        superMangled = memoryMap[address]["superMangled"]
        if "FIXED" in attributes:
            counterType = "FIXED"
        elif "BIT" in attributes:
            counterType = "BIT"
            bitWidth = attributes["BIT"]
        else:
            errxit("Loop counter is not FIXED or BIT(n).")
        print(indent2 + "int32_t %s, %s, %s;" % (fromName, toName, byName))
        tipe, source = generateExpression(scope, line["from"])
        if (tipe == "BIT"):
            tipe = "FIXED"
            source = "bitToFixed(" + source + ")"
        print(indent2 + fromName + " = " + source + ";")
        tipe, source = generateExpression(scope, line["to"])
        if (tipe == "BIT"):
            tipe = "FIXED"
            source = "bitToFixed(" + source + ")"
        print(indent2 + toName + " = " + source + ";")
        tipe, source = generateExpression(scope, line["by"])
        if (tipe == "BIT"):
            tipe = "FIXED"
            source = "bitToFixed(" + source + ")"
        print(indent2 + byName + " = " + source + ";")
        if counterType == "FIXED":
            print((indent2 + "for (putFIXED(%s, %s);\n" + \
                   indent2 + "     getFIXED(%s) <= %s;\n" + \
                   indent2 + "     putFIXED(%s, getFIXED(%s) + %s)) {" ) \
                  % (superMangled, fromName, superMangled, toName, 
                     superMangled, superMangled, byName))
        else: # counterType == "BIT"
            print(indent2 + \
              "for (putBIT(%d, %s, fixedToBit(%d, %s));\n" % \
                        (bitWidth, memoryMap[address]["superMangled"], 
                         bitWidth, fromName) + \
              indent2 + "     " + \
              "bitToFixed(getBIT(%d, %s)) <= %s;\n" % \
                        (bitWidth, memoryMap[address]["superMangled"], toName) + \
              indent2 + "     " +\
              "putBIT(%d, %s, fixedToBit(%d, bitToFixed(getBIT(%d, %s)) + %s))) {" % \
                        (bitWidth, memoryMap[address]["superMangled"], 
                         bitWidth, 
                         bitWidth, memoryMap[address]["superMangled"], byName) \
            )
    elif "WHILE" in line:
        tipe, source = generateExpression(scope, line["WHILE"])
        if (tipe == "BIT"):
            tipe = "FIXED"
            source = "bitToFixed(" + source + ")"
        print(indent + "while (1 & (" + source + ")) {")
    elif "UNTIL" in line:
        tipe, source = generateExpression(scope, line["UNTIL"])
        if (tipe == "BIT"):
            tipe = "FIXED"
            source = "bitToFixed(" + source + ")"
        print(indent + "do {")
        line["scope"]["afterEndOfScope"] = "while (!(1 & (" + source + ")));"
    elif "BLOCK" in line:
        print(indent + "{ r%s: ; " % line["scope"]["symbol"])
    elif "IF" in line:
        tipe, source = generateExpression(scope, line["IF"])
        if (tipe == "BIT"):
            tipe = "FIXED"
            source = "bitToFixed(" + source + ")"
        print(indent + "if (1 & (" + source + "))")
    elif "GOTO" in line:
        label = line["GOTO"]
        procScope = findParentProcedure(scope)
        if "longjmpLabels" in procScope and label in procScope["longjmpLabels"]:
            mangled = procScope["longjmpLabels"][label]["mangled"]
            '''
            Using a `longjmp` to escape the current procedure has the 
            disadvantage of defeating the mechanism for guarding against 
            reentry of the procedure ... not just for the current procedure,
            but for all of the procedures in the calling sequence, up to but 
            not including the procedure containing the target `setjmp`.  Note
            that this may *not* be the same functions that are the parents
            scope-wise.  It's really tricky, though, to have a backtrace on the
            calling sequence, even though in principle we are able to print out
            one for debugging purposes on some platforms.  So what I do instead
            is to reset all of the reentry guards on all functions when a 
            longjmp occurs.  I don't think this will cause a big problem, though
            it's irritating. .
            '''
            print(indent + "{ resetAllReentryGuards(); longjmp(jb%s, 1); }" \
                            % mangled)
        else:
            print(indent + "goto " + normalizedLabel(label) + ";")
    elif "TARGET" in line:
        nlabel = normalizedLabel(line["TARGET"])
        if "sortedSetjmpLabels" in parentProcedureScope and \
                line["TARGET"] in parentProcedureScope["sortedSetjmpLabels"]:
            sortedSetjmpLabels = parentProcedureScope["sortedSetjmpLabels"]
            setjmpCounter = sortedSetjmpLabels.index(line["TARGET"])
            # If we're here, it's because there are targets of longjmp in the
            # enclosing procedure.  Therefore, we have to enhance the "label:"
            # we'd normally put here, with `setjmp` and means to initialize the
            # such `setjmp`
            print(indent + "if (0) {")
            indent1 = indent + indentationQuantum
            indent2 = indent1 + indentationQuantum
            indent3 = indent2 + indentationQuantum
            print(indent1 + nlabel + ":")
            parentProc = findParentProcedure(scope)
            label = parentProc["variables"][sortedSetjmpLabels[setjmpCounter]]["mangled"]
            print(indent1 + "if (setjmpInitialize) {")
            print(indent2 + "if (!setjmp(jb%s))" % label)
            setjmpCounter += 1
            if (setjmpCounter >= len(sortedSetjmpLabels)):
                label = "setjmpInitialized"
            else:
                label = sortedSetjmpLabels[setjmpCounter]
            print(indent3 + "goto %s;" % normalizedLabel(label))
            print(indent1 + "}")
            print(indent + "}")
        else:
            print(indent + nlabel + ":", end="")
            if indexInScope >= len(scope["code"]) - 1:
                print(";")
            else:
                print()
    elif "ELSE" in line:
        print(indent + "else")
    elif "RETURN" in line:
        # Let's find out what the return type is supposed to be.  To do that,
        # we have to find the declaration of the procedure.  Before doing that,
        # we first have to figure out the name of the procedure.
        procScope = scope
        while procScope["symbol"].startswith(scopeDelimiter) or procScope["symbol"] == "":
            procScope = procScope["parent"]
            if procScope == None:
                expression = line["RETURN"]
                if expression == None: 
                    source = "0"
                else:
                    tipe, source = generateExpression(scope, expression)
                    tipe, source = autoconvert(tipe, ["FIXED"], source)
                indent2 = indent + indentationQuantum
                print(indent + "{")
                #print(indent2 + 'if (LINE_COUNT) printf("\\n");')
                #print(indent2 + "writeCOMMON(COMMON_OUT);")
                if standardXPL:
                    print(indent2 + "exit(%s);" % source)
                else:
                    print(indent2 + "RECORDuLINK(0);")
                print(indent + "}")
                return;
        procedureName = procScope["symbol"]
        procedureAttributes = getAttributes(procScope, procedureName)
        if procedureAttributes == None:
            errxit("PROCEDURE %s declaration not found" % procedureName)
        if "return" in procedureAttributes:
            toType = procedureAttributes["return"]
        else:
            toType = "FIXED"
        if toType == "BIT":
            toAttributes = { "BIT": procedureAttributes["bitsize"] }
        else:
            toAttributes = { toType: True }
        
        if line["RETURN"] == None:
            # There are examples in ANALYZER.xpl of PROCEDURES that don't
            # return values having their values used in IF statements.
            # McKeeman says that such returns will be random, because they'll
            # just be leftover values from some unspecified register.  I'll
            # alway return something simple of the appropriate type.
            if toType == "FIXED":
                source = "0"
            elif toType == "CHARACTER":
                source = 'cToDescriptor(NULL, "")'
            elif toType == "BIT":
                source = "fixedToBit(32, 0)"
        else:
            toType, source = autoconvertFull(scope, line["RETURN"], toAttributes)
        if reentryGuard:
            print(indent + "{ reentryGuard = 0; return " + source + "; }")
        else:
            print(indent + "return " + source + ";")
    elif "ELSE" in line:
        print(indent + "else")
    elif "EMPTY" in line:
        print(indent + ";")
    elif "CALL" in line:
        procedure = line["CALL"]
        if procedure == "INLINE":
            originalInline = scope["pseudoStatements"][indexInScope]
            if isinstance(line["parameters"][0], dict) and \
                    "string" in line["parameters"][0]["token"]:
                # Verbatim-C type INLINE
                print(indent + line["parameters"][0]["token"]["string"])
                lastCallInline = 0
                inlineCounter -= 1
            else: #elif inhibitInline == 0:
                if len(guessInlines) > 0:
                    if lastCallInline != lineCounter - 1:
                        guessFiles[inlineCounter] = []
                    guessINLINE(scope, functionName, line["parameters"], \
                                   inlineCounter, errxitRef, indexInScope)
                if not applyInlinePatch(scope, indent, originalInline):
                    if debugInlines and lastCallInline != lineCounter - 1:
                        print(indent + "debugInline(%d); // (%d) %s" % \
                              (inlineCounter, inlineCounter, originalInline))
                    else:
                        print(indent + "; // (%d) %s" % (inlineCounter, \
                                                         originalInline))
                lastCallInline = lineCounter
            #else:
            #    inhibitInline -= 1
            inlineCounter += 1
        else:
            if procedure == "MONITOR":
                typem, sourcem = autoconvertMonitor(scope, line["parameters"])
                print(indent + sourcem + ";")
            # Some builtins can be CALL'd
            elif procedure in ["LINK", "COMPACTIFY", "RECORDuLINK", "TRACE", 
                             "UNTRACE", "EXIT", "MONITOR"]:
                print(indent + procedure + "(", end = '')
                if procedure in ["COMPACTIFY", "RECORDuLINK"]:
                    print("0", end="")
                else:
                    parameters = line["parameters"]
                    for i in range(len(parameters)):
                        if i > 0:
                            print(", ", end = '')
                        parm = parameters[i]
                        tipe, parme = generateExpression(scope, parm)
                        print(parme, end = '')
                print(");")
            else:
                outerParameters = line["parameters"] 
                attributes = getAttributes(scope, procedure)
                if attributes == None:
                    errxit("PROCEDURE %s not found" % procedure)
                if "mangled" not in attributes:
                    errxit("Implementation: Mangled name of PROCEDURE %s not found in attributes: %s" \
                           % (procedure, str(attributes)))
                mangled = attributes["mangled"]
                if len(outerParameters) == 0:
                    print(indent + mangled + "(0);")
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
                        innerAttributes = innerScope["variables"][innerParameter]
                        innerAddress = memoryMap[innerAttributes["address"]]["superMangled"]
                        toType, parm = autoconvertFull(scope, outerParameter, innerAttributes)
                        if toType == "BIT":
                            function = "putBITp(%d, " % innerAttributes["BIT"] 
                        elif toType == "CHARACTER":
                            function = "putCHARACTERp("
                        else:
                            function = "put" + toType + "("
                        print(indent2 + function + \
                                 innerAddress + ", " + \
                                 str(parm) + "); ")
                    print(indent2 + mangled + "(0);")
                    print(indent + "}")
    elif "CASE" in line:
        tipe, source = generateExpression(scope, line["CASE"])
        if tipe != "FIXED":
            tipe, source = autoconvert(tipe, ["FIXED"], source)
        print(indent + "{ r%s: switch (" % line["scope"]["symbol"] + source + ") {")
        scope["switchCounter"] = 0
        scope["ifCounter"] = 0
    elif "ESCAPE" in line:
        blockType = scope["blockType"]
        whereTo = line["ESCAPE"]
        if whereTo == None:
            if blockType in ["DO block"]:
                print(indent + "goto e%s;" % normalizedLabel(scope["symbol"]))
            else: # Looping blocks.
                print(indent + "break;")
        else:
            bscope = scope;
            while "label" not in bscope or bscope["label"] != whereTo:
                bscope = bscope["parent"]
                if bscope == None:
                    errxit("DO ... END block labeled %s not found" % whereTo)
            print(indent + "goto e%s;" % normalizedLabel(bscope["symbol"]))
    elif "REPEAT" in line:
        blockType = scope["blockType"]
        whereTo = line["REPEAT"]
        if whereTo == None:
            if blockType in ["DO block", "DO CASE block"]:
                print(indent + "goto r%s;" % normalizedLabel(scope["symbol"]))
            else: # Looping blocks
                print(indent + "continue;")
        else:
            bscope = scope;
            while "label" not in bscope or bscope["label"] != whereTo:
                bscope = bscope["parent"]
                if bscope == None:
                    errxit("DO ... END block labeled %s not found" % whereTo)
            print(indent + "goto r%s;" % normalizedLabel(bscope["symbol"]))
    else:
        print(indent + "Unimplemented:", end="", file=debugSink)
        printDict(line)

# Hex dump a range of memory.
def printMemory(address, length):
    allZeroes = True
    for i in range(length):
        if memory[address + i] != 0:
            allZeroes = False
            break
    if allZeroes:
        print("\t(0 repeats %d times)" % length)
        return
    for i in range(length):
        d = "%02X" % memory[address + i]
        if i == 0:
            print("\t" + d, end = "")
        elif i & 0xF == 0:
            print("\n\t" + d, end = "")
        else:
            print(" " + d, end = "")
    print()

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
    global stdoutOld, ppFiles, functionName
   
    if "generated" in scope:
        return
    scope["generated"] = True;
    
    of = extra["of"]
    indent = extra["indent"]
    if "extraIndent" in scope:
        indent = indent + indentationQuantum
    
    if extra["of"] == None:
        pass
    
    # Don't be fooled!  "PROCEDURE" is never in `scope`.  I'll remove these
    # sometime.
    if "PROCEDURE" in scope and of != None:
        walkModel(scope, generateCodeForScope, { "of": None, "indent": ""})
        return
    
    # Make sure we've got an open output file of the appropriate name.
    scopeName = scope["symbol"]
    scopePrefix = scope["prefix"]
    if "PROCEDURE" in scope:  # Apparently, this conditional is *never* true.
        print("Generating code for PROCEDURE %s" % (scopePrefix + scopeName))
    if scopeName == "":
        functionName = "main"
    else:
        functionName = scopePrefix[:-1] # Remove final "x".
        functionName.replace("#", "p").replace("@", "a").replace("$", "d").replace("_","u")
    topLevel = False
    if of == None:
        ppFiles["filenames"] = ppFiles["filenames"] + " " + functionName + ".c"
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
            print("  To build the program from the command line, using defaults:")
            print("          cd %s/" % outputFolder)
            print("          make")
            print("  View the Makefile to see different options for the `make`")
            print("  command above.  To run the program:")
            print("          %s [OPTIONS]" % outputFolder)
            print("  Use `%s --help` to see the available OPTIONS." % \
                  outputFolder)
        print("*/")
        print()
        print('#include "runtimeC.h"')
        if "setjmpLabels" in scope:
            print()
            for label in scope["setjmpLabels"]:
                print("jmp_buf jb%s;" % scope["setjmpLabels"][label]["mangled"])
        print()
        if functionName == "main":
            if verbose:
                print("// clang-format off")
                print("/*")
                print("            *** Memory Map ***")
                print(" %14s   %-11s %-8s" % \
                      ("Address (Hex)", "Data Type", "Variable"))
                print(" %14s   %-11s %-8s" % \
                      ("-------------", "---------", "--------"))
                for address in sorted(memoryMap):
                    memoryMapEntry = memoryMap[address]
                    symbol = memoryMapEntry["mangled"]
                    datatype = memoryMapEntry["datatype"]
                    numElements = memoryMapEntry["numElements"]
                    bitWidth = memoryMapEntry["bitWidth"]
                    if datatype == "BIT":
                        datatype = datatype + "(%d)" % bitWidth
                    if numElements == 0:
                        print("%6d (%06X)   %-11s %s" % \
                              (address, address, datatype, \
                               symbol))
                    else:
                        print("%6d (%06X)   %-11s %s(%d)" % \
                              (address, address, datatype, \
                               symbol, numElements-1))
                    if displayInitializers:
                        if numElements == 0:
                            numElements = 1
                        if datatype not in ["EBCDIC", "BITSTRING"]:
                            printMemory(address, numElements * memoryMapEntry["dirWidth"])
                        else:
                            length = 0
                            parentAddress = memoryMapEntry["parentAddress"]
                            for i in range(numElements):
                                d = getFIXED(parentAddress + 4 * i)
                                if d == 0:
                                    continue
                                length += ((d >> 24) & 0xFF) + 1
                            printMemory(address, length)
                print("*/")
                print("// clang-format on")
                print()
            #print("uint32_t sizeOfCommon = %d;" % areaNormal)
            #print("uint32_t sizeOfNonCommon = %d;" % (variableAddress-areaNormal));
            #print()
            print("int\nmain(int argc, char *argv[])\n{")
            print()
            print("  // Setup for MONITOR(6), MONITOR(7), MONITOR(21).  Initially,")
            print("  // entire physical memory is a single pre-allocated block.")
            print("  MONITOR6a(USER_MEMORY, PHYSICAL_MEMORY_LIMIT, 0);")
            print("  MONITOR6a(PRIVATE_MEMORY, PRIVATE_MEMORY_SIZE, 0);")
            print()
            print("  if (parseCommandLine(argc, argv)) exit(0);")
            print()
        else:
            attributes = getAttributes(scope, scopeName)
            variables = scope["variables"]
            
            # Let's make sure there's a list of all the labels in the procedure:
            localLabels = ["(unused)"]
            for v in variables:
                if "LABEL" in variables[v]:
                    localLabels.append(v)
            scope["localLabels"] = localLabels
    
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
                returnType = "descriptor_t *"
            elif returnType == "CHARACTER":
                returnType = "descriptor_t *"
            header = returnType + "\n" + functionName + "(int reset)"
            print("\n" + header + ";", file=pf)
            print(header + "\n{")
            #print()
        indent1 = indent + indentationQuantum
        indent2 = indent1 + indentationQuantum
        # Let's guard against reentry.
        if reentryGuard:
            print(indent1 + "static int reentryGuard = 0;")
            if functionName != "main":
                print(indent1 + "if (reset) { reentryGuard = 0; return (%s) 0; }" \
                      % returnType)
            print(indent1 + 'reentryGuard = guardReentry(reentryGuard, "%s");' % \
                                               functionName)
        # If there's a need to initialize buffers for calls to `setjmp`, we
        # have to do that right now.  I used to declare `setjmpInitialized`
        # as `static`.  However, I later noticed the warning from gnu.org
        # (https://www.gnu.org/software/libc/manual/html_node/Non_002dLocal-Details.html)
        # that "Return points are valid only during the dynamic extent of the
        # function that called setjmp to establish them. If you longjmp to a 
        # return point that was established in a function that has already 
        # returned, unpredictable and disastrous things are likely to happen."
        # So we in fact have to reinitialize the `setjmp` buffers every time
        # the function is called, which means that `setjmpInitialize` cannot
        # be static.
        if "sortedSetjmpLabels" in scope and len(scope["sortedSetjmpLabels"]) > 0:
            print(indent1 + "int setjmpInitialize = 1;") 
            print(indent1 + "if (setjmpInitialize) { ")
            print(indent2 + "goto %s; " % normalizedLabel(scope["sortedSetjmpLabels"][0]))
            print(indent2 + "setjmpInitialized: setjmpInitialize = 0;")
            print(indent1 + "}")
        
    indent = indent + indentationQuantum
        
    #---------------------------------------------------------------------
    # All of the code generation for actual XPL statements occurs between
    # these two horizontal lines.
    
    lastReturned = False
    numCode = len(scope["code"])
    for i in range(numCode):
        ps = None
        line = scope["code"][i]
        if verbose and i in scope["pseudoStatements"] and \
                None == re.search("\\bCALL +INLINE *\\(", \
                                  scope["pseudoStatements"][i].upper()):
            if scope["parent"] != None and "switchCounter" in scope["parent"]:
                ps = scope["pseudoStatements"][i]
            else:
                print(indent + "// " + \
                      scope["pseudoStatements"][i].replace(replacementQuote, "''") \
                      + (" (%d)" % lineCounter))
        lastReturned = "RETURN" in line
        generateSingleLine(scope, indent, line, i, ps)
        if "scope" in line: # Code for an embedded DO...END block.
            generateCodeForScope(line["scope"], { "of": of, "indent": indent} )
    
    #---------------------------------------------------------------------
    
    parent = scope["parent"]
    if parent != None and "switchCounter" in parent:
        print(indent + "break;")
        parent.pop("switchCounter")
        parent.pop("ifCounter")
    # Add a precautionary RETURN 0 at the end of PROCEDUREs, for the reasons
    # described in the comments for CALL.  If there was already an explicit
    # RETURN here, or if the RETURN is somewhare else and this position cannot
    # be reached, the C compiler may complain, but hopefully won't fail.
    if not lastReturned and scope["symbol"] != '' and \
            scope["symbol"][:1] != scopeDelimiter:
        if reentryGuard:
            print(indent + "{ reentryGuard = 0; return 0; }")
        else:
            print(indent + "return 0;")
    if "extraIndent" in scope: # End of the actual loop of a DO for-loop block.
        if "label" in scope and "blockType" in scope and \
                scope["blockType"] == "DO for-loop block":
            print(indent + "if (0) { r%s: continue; e%s: break; } // loop of block labeled %s" % \
                  (scope["symbol"], scope["symbol"], scope["label"]))
        indent = indent[:-len(indentationQuantum)]
        print(indent + "}")
    if parent == None:
        # End of main.c.
        print()
        if not standardXPL:
            if nonCommonBase > commonBase:
                #print(indent + "writeCOMMON(COMMON_OUT);")
                print(indent + "RECORDuLINK(0);")
        #print(indent + \
        #      'fprintf(stderr, "FYI: %d of %d buffers still active.\\n", countBuffers(), MAX_BUFFS);')
        #print(indent + "if (LINE_COUNT)")
        #print(indent + indentationQuantum + \
        #      "printf(\"\\n\"); // Flush buffer for OUTPUT(0) and OUTPUT(1).")
        if reentryGuard:
            print(indent + "{ reentryGuard = 0; return 0; } // Just in case ...")
        else:
            print(indent + "return 0; // Just in case ...")
    if "label" in scope and "blockType" in scope and \
            scope["blockType"] in ["DO WHILE block", "DO UNTIL block",]:
        print(indent + "if (0) { r%s: continue; e%s: break; } // block labeled %s" % \
              (scope["symbol"], scope["symbol"], scope["label"]))
    elif "blockType" in scope and scope["blockType"] == "DO block":
        print(indent + "e%s: ;" % scope["symbol"])
    indent = indent[:-len(indentationQuantum)]
    print(indent + "}", end="")
    if "afterEndOfScope" in scope:
        print(' ' + scope["afterEndOfScope"], end="")
    if "blockType" in scope:
        if scope["blockType"] == "DO CASE block":
            print("}", end="")
        print(" // End of " + scope["blockType"])
    else:
        print()
    if topLevel:
        sys.stdout = stdoutOld # Restore previous stdout.

def generateC(globalScope):
    global pf, nonCommonBase, freeBase, freePoint, freeLimit, \
            variableAddress, regions, baseRestriction
    
    pf = open(outputFolder + "/procedures.h", "w")
    print("/*", file=pf)
    print("  File procedures.h generated by XCOM-I, " + \
          datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + ".", 
          file=pf)
    print("  Provides prototypes for the C functions corresponding to the", 
          file=pf)
    print("  XPL/I PROCEDUREs and setjmp/longjmp.", file=pf)
    print("", file=pf)
    print("  Note: Due to the requirement for persistence, all function", 
          file=pf)
    print("  parameters are passed via static addresses in the `memory`", 
          file=pf)
    print("  array, rather than via parameter lists, so all parameter", 
          file=pf)
    print("  lists are `void`.", file=pf)
    print("*/", file=pf)
    print("", file=pf)
    print("#include <stdint.h>", file=pf)
    print("#include <setjmp.h>", file=pf)

    # Provide mangled variable names.
    walkModel(globalScope, mangle)
    
    # Compute call-tree.  This is used for eliminating PROCEDURES that are
    # never CALL'ed or used as functions within expressions.
    callTree(globalScope)
    
    # Determine contraints on BASED RECORD variables (max fields and max
    # field-name length.
    walkModel(globalScope, basedStats)
    
    # Find all GO TO that are out of their immediately-enclosing procedures,
    # so that we can determine which labels need to equipped with `setjmp`
    # and which GO TO need to be implemented with `longjmp`.
    walkModel(globalScope, mapJump)
    print("", file=pf)
    for label in sorted(globalSetjmp):
        print("extern jmp_buf jb%s;" % label, file=pf)
    walkModel(globalScope, sortJumps)
    
    # Memory region 0 is special, in that it contains data from MONITOR rather
    # than from XPL declarations, so let's take care of its allocation first.
    # First, the string whose descriptor is returned by `MONITOR(23)`.
    whereMonitor23 = variableAddress
    variableAddress += 4
    putCHARACTER(whereMonitor23, identifierString)
    variableAddress += len(identifierString)
    # Next, the options data returned by `MONITOR(13)`.  The data itself will
    # all be filled in by the runtime library, but we need to make sure that the
    # space is properly allocated and templated.
    whereMonitor13 = variableAddress
    # `MONITOR(13)` returns a pointer to a block of 6 `FIXED` values, 5 of which
    # are pointers to arrays of CHAR.
    MAX_TYPES = 64
    SIZE_ARRAY = 4 * MAX_TYPES
    saddress = variableAddress + 24
    putFIXED(variableAddress, 0) # `OPTIONS_CODE`
    putFIXED(variableAddress + 4, saddress) # Pointer to `CON`.
    putFIXED(variableAddress + 8, saddress + SIZE_ARRAY) # Pointer to `PRO`.
    putFIXED(variableAddress + 12, saddress + 2 * SIZE_ARRAY) # Pointer to `TYPE2`
    putFIXED(variableAddress + 16, saddress + 3 * SIZE_ARRAY) # Pointer to `VALS`
    putFIXED(variableAddress + 20, saddress + 4 * SIZE_ARRAY) # Pointer to `NPVALS` or `MONVALS`
    variableAddress = saddress;
    # Arrays of `CON`, `PRO`, `TYPE2`, `VALS`, `NPVALS` respectively.
    for i in range(5 * MAX_TYPES): 
        putFIXED(variableAddress, 0);
        variableAddress += 4;   
    regions.append( [0, variableAddress] )
    
    # Allocate and initialize simulated memory for memory regions 1-6.
    # The mechanism is to set an attribute
    # of "address" for each variable in scope["variables"], and to
    # additionally set an attribute of "saddress" for each `CHARACTER` variable
    # to indicate where the string data (vs the string descriptor) is stored.
    # Both of these attributes are indices in the 24-bit simulated memory.
    # Thus in XPL code translated to C, the code generator looks up addresses
    # of XPL variables, and generates C code that operates on absolute numerical
    # addresses rather than on symbolic addresses.
    topUsableMemory = physicalMemoryLimit - 1024
    for region in range(1, 6):
        start = variableAddress
        if region == 2:
            baseRestriction = 1
            walkModel(globalScope, allocateVariables, region)
            baseRestriction = -1
            walkModel(globalScope, allocateVariables, region)
        else:
            baseRestriction = 0  
            walkModel(globalScope, allocateVariables, region)
        if region == 5: 
            freeBase = start
            freePoint = variableAddress
            freeLimit = topUsableMemory - 512
            variableAddress = freeLimit
        regions.append( [start, variableAddress] )
    regions.append( [variableAddress, physicalMemoryLimit] )
    nonCommonBase = regions[2][0]
    
    # Make #define's for all of these variables in procedures.h
    print("// #defines for XPL variable names", file=pf)
    for address in memoryMap:
        variable = memoryMap[address]
        if variable["datatype"] not in ["FIXED", "CHARACTER", "BIT", "BASED"]:
            continue
        symbol = "m" + variable["mangled"].replace("@", "a") \
                                          .replace("#", "p") \
                                          .replace("$", "d") \
                                          .replace("_", "u")
        print("#define %s %d" % (symbol, address), file=pf)
        if noLabels:
            variable["superMangled"] = "%d" % address
        else:
            variable["superMangled"] = symbol
    
    # Make another version of `memoryMap` that's sorted by symbol name rather
    # than address.
    memoryMapIndexBySymbol = {}
    i = 0
    for address in memoryMap:
        entry = memoryMap[address]
        if entry["datatype"] not in ["FIXED", "BIT", "CHARACTER", "BASED"]:
            break
        memoryMapIndexBySymbol[entry["mangled"]] = i;
        i += 1

    # Write out the initialized memory as a file called memory.c.
    f = open(outputFolder + "/memory.c", "w")
    print("// Memory data generated by XCOM-i\n", file=f)
    print("#include \"runtimeC.h\"", file=f)
    print("", file=f)
    print("// Initial memory contents, prior to COMMON load ---------------\n",\
          file=f)
    if not sizeReducer:
        print("uint8_t memory[MEMORY_SIZE] = {", file=f)
        # This is my original behavior: To simply initialize the entirety of
        # memory, almost all of it 0.
        for i in range(freePoint):
            if 0 == i % 8:
                print("  ", end="", file=f)
            print("0x%02X" % memory[i], end="", file=f)
            if i < freePoint - 1:
                print(", ", end="", file=f)
                if 7 == i % 8:
                    j = i & 0xFFFFF8
                    print(" // %8d 0x%06X" % (j, j), file=f)
        restart = physicalTop - 8 - (physicalTop % 8)
        if variableAddress > 0:
            print(",", end="", file=f)
        print("  [0x%0X]=0x00," % (restart - 1), file=f)
        for i in range(restart, physicalTop):
            if 0 == i % 8:
                print("  ", end="", file=f)
            print("0x%02X" % memory[i], end="", file=f)
            if i < physicalTop - 1:
                print(", ", end="", file=f)
                if 7 == i % 8:
                    j = i & 0xFFFFF8
                    print(" // %8d 0x%06X" % (j, j), file=f)
        print("   // %8d 0x%06X" % (physicalTop - 8, physicalTop - 8), end="", file=f)
        print("\n};", file=f)
    else:
        # Here's my attempt to reduce the size of the executable file: Initialize
        # memory just to the point where it starts becoming all 0.
        for i in range(len(memory) - 1, -1, -1):
            if memory[i] != 0:
                break
        numInitialized = (i + 8) & ~7 
        print("uint8_t memory[MEMORY_SIZE];", file=f)
        print("uint8_t memoryInitializer[NUM_INITIALIZED] = {", file=f)
        for i in range(numInitialized):
            if 0 == i % 8:
                print("  ", end="", file=f)
            print("0x%02X" % memory[i], end="", file=f)
            if i < numInitialized - 1:
                print(", ", end="", file=f)
            else:
                print("  ", end="", file=f)
            if 7 == i % 8:
                j = i & 0xFFFFF8
                print(" // %8d 0x%06X" % (j, j), file=f)
        print("};", file=f)
    print("\n// Lists of fields of BASED variables ------------------------\n",\
          file=f)
    maxSymbolLength = 0
    numSymbols = 0
    for address in memoryMap:
        variable = memoryMap[address]
        symbol = variable["mangled"]
        datatype = variable["datatype"]
        if datatype not in ["FIXED", "CHARACTER", "BIT", "BASED"]:
            continue
        numSymbols += 1
        if len(symbol) > maxSymbolLength:
            maxSymbolLength = len(symbol)
    for address in memoryMap:
        variable = memoryMap[address]
        symbol = variable["mangled"]
        datatype = variable["datatype"]
        if datatype != "BASED":
            continue
        record = variable["record"]
        if len(record) == 1 and "" == list(record)[0]:
            print("// Note that BASED %s has no RECORD" % symbol, file=f)
        print("basedField_t based_%s[%d] = {" % (symbol, len(record)), file=f)
        i = 0
        recordSize = 0
        for key in record:
            attributes = record[key]
            dirWidth = 4;
            size = 0
            if "top" in attributes:
                size = 1 + attributes["top"]
            subDatatype = ''
            bitWidth = 0
            if "BIT" in attributes:
                subDatatype = "BIT"
                bitWidth = attributes["BIT"]
                if bitWidth <= 8:
                    dirWidth = 1
                elif bitWidth <= 16:
                    dirWidth = 2
            elif "CHARACTER" in attributes:
                subDatatype = "CHARACTER"
            else:
                subDatatype = "FIXED"
            if "offset" in attributes:
                offset = attributes["offset"]
            else:
                offset = 0
            print(indentationQuantum + \
                  '{ "%s", "%s", %d, %d, %d, %d }' % (
                                                  key, 
                                                  subDatatype, size,
                                                  dirWidth,
                                                  bitWidth, 
                                                  offset), \
                  end = "", file=f)
            if size == 0:
                recordSize += dirWidth
            else:
                recordSize += dirWidth * size
            i += 1
            if i < len(record):
                print(",", end="", file=f)
            print("", file=f)
        variable["numFieldsInRecord"] = len(record)
        variable["recordSize"] = recordSize
        print("};", file=f)
    print("\n// Memory map, sorted by addresses in XPL memory -------------\n",\
          file=f)
    print("memoryMapEntry_t memoryMap[NUM_SYMBOLS] = {", file=f)
    i = 0
    USER_MEMORY = None
    PRIVATE_MEMORY = None
    for address in memoryMap:
        i += 1
        variable = memoryMap[address]
        symbol = variable["mangled"]
        if symbol == "userMemory":
            USER_MEMORY = address;
        if symbol == "privateMemory":
            PRIVATE_MEMORY = address;
        datatype = variable["datatype"]
        if datatype == "BASED":
            numFieldsInRecord = variable["numFieldsInRecord"]
            recordSize = variable["recordSize"]
        else:
            numFieldsInRecord = 0
            recordSize = 0
        numElements = variable["numElements"]
        allocated = 0
        basedFields = "NULL"
        if datatype not in ["FIXED", "CHARACTER", "BIT", "BASED"]:
            continue
        dirWidth = variable["dirWidth"]
        bitWidth = variable["bitWidth"]
        parentAddress = variable["parentAddress"]
        if datatype == "BASED":
            basedFields = "based_" + symbol
        if i == numSymbols:
            comma = ''
        else:
            comma = ','
        common = "common" in variable
        library = variable["library"]
        print('  { %s, "%s", "%s", %d, %d, %s, %d, %d, %d, %d, %d, %d, %d }%s' % \
              (memoryMap[address]["superMangled"], symbol, datatype, 
               numElements, allocated, 
               basedFields, numFieldsInRecord, recordSize, dirWidth, bitWidth,
               parentAddress, common, library, comma), file=f)
    print("};", file=f)
    print("\n// Memory map, sorted by symbol name -------------------------\n",\
          file=f)
    print("// Note that the collation indicated below is that of the", file=f)
    print("// computer running XCOM-I, and may transparently change", file=f)
    print("// at runtime on computers with different collation.", file=f)
    print("memoryMapEntry_t *memoryMapBySymbol[NUM_SYMBOLS] = {", file=f)
    for entry in sorted(memoryMapIndexBySymbol):
        print("  &memoryMap[%d]," % memoryMapIndexBySymbol[entry], file=f)
    print("};", file=f)
    print("\n// Sorted list of all labels (mangled) -----------------------\n",\
          file=f)
    if len(mangledLabels) == 0:
        print("char *mangledLabels;", file=f)
    else:
        print("char *mangledLabels[NUM_MANGLED] = {", file=f)
        line = ""
        for mangledLabel in sorted(mangledLabels):
            if len(line) + len(mangledLabel) > 72:
                print(line + ",", file=f)
                line = ""
            if len(line) == 0:
                line = '  "' + mangledLabel + '"'
            else:
                line = line + ', "' + mangledLabel + '"'
        if len(line) > 0:
            print(line, file=f)
        print("};", file=f)
    print("\n// Initial memory regions ------------------------------------",\
          file=f)
    print("// Note that region 6 is often displaced downward by", file=f)
    print("// by application code prior to allocation for any BASED", file=f)
    print("// to leave a free region 7 at the top of memory.\n", file=f)
    print("memoryRegion_t memoryRegions[%d] = {" % len(regions), file=f)
    for i in range(len(regions)):
        if i > 0:
            print(",", file=f)
        print("  { %d, %d }" % tuple(regions[i]), end="", file=f)
        print(" /* (0x%06X, 0x%06X) */" % tuple(regions[i]), end="", file=f)
    print("\n};", file=f)
    f.close()
    
    # Write out any special configuration settings, for use by
    # runtimeC.c.
    f = open(outputFolder + "/configuration.h", "w")
    print("// Configuration settings, inferred from the XPL/I source.", file=f)
    fields = outputFolder.split("/\\")
    appName = fields[-1]
    if debuggingAid:
        print("#define DEBUGGING_AID", file=f)
    if reentryGuard:
        print("#define REENTRY_GUARD", file=f)
        print("void resetAllReentryGuards();", file=f)
    else:
        print("#define resetAllReentryGuards()", file=f)
    print("#define APP_NAME \"%s\"" % appName, file=f)
    print("#define XCOM_I_START_TIME %d" % TIME_OF_GENERATION, file=f)
    print("#define XCOM_I_START_DATE %d" % DATE_OF_GENERATION, file=f)
    print("#define MAJOR_VERSION %d" % majorVersionXCOMI, file=f)
    print("#define MINOR_VERSION %d" % minorVersionXCOMI, file=f)
    if "P" in ifdefs:
        print("#define PFS", file=f)
    if "B" in ifdefs:
        print("#define BFS", file=f)
    if standardXPL:
        print("#define STANDARD_XPL", file=f)
    if traceInlines:
        print("#define TRACE_INLINES", file=f)
    print("#define COMMON_BASE 0x%06X" % commonBase, file=f)
    print("#define NON_COMMON_BASE 0x%06X" % nonCommonBase, file=f)
    print("#define FREE_BASE 0x%06X" % freeBase, file=f)
    print("#define FREE_POINT 0x%06X // Initial value for `freepoint`" % \
          freePoint, file=f)
    print("#define PHYSICAL_MEMORY_LIMIT 0x%06X" % physicalMemoryLimit, file=f)
    print("#define PRIVATE_MEMORY_SIZE 0x%06X" % amountOfPrivateMemory, file=f)
    print("#define FREE_LIMIT 0x%06X" % freeLimit, file=f)
    print("#define NUM_SYMBOLS", numSymbols, file=f)
    print("#define MAX_SYMBOL_LENGTH", maxSymbolLength, file=f)
    print("#define MAX_DATATYPE_LENGTH %d" % len("CHARACTER"), file=f)
    print("#define MAX_RECORD_FIELDS %d" % maxRecordFields, file=f)
    print("#define MAX_RECORD_FIELD_NAME %d" % maxRecordFieldName, file=f)
    print("#define WHERE_MONITOR_23 %d" % whereMonitor23, file=f)
    print("#define WHERE_MONITOR_13 %d" % whereMonitor13, file=f)
    print("#define ROOT_BASED %d" % rootBASED, file=f)
    print("#define MAX_LENGTH_MANGLED %d" % maxLengthMangled, file=f)
    print("#define NUM_MANGLED %d" % len(mangledLabels), file=f)
    print("#define MAX_TYPE1 %d" % MAX_TYPES, file=f)
    print("#define MAX_TYPE2 %d" % MAX_TYPES, file=f)
    print("#define USER_MEMORY %d" % USER_MEMORY, file=f)
    print("#define PRIVATE_MEMORY %d" % PRIVATE_MEMORY, file=f)
    if sizeReducer:
        print("#define NUM_INITIALIZED %d" % numInitialized, file=f)
    print("", file=f)
    if len(mangledLabels) == 0:
        print("extern char *mangledLabels;", file=f)
    else:
        print("extern char *mangledLabels[NUM_MANGLED];", file=f)
    print("typedef char symbol_t[MAX_SYMBOL_LENGTH + 1];", file=f)
    print("typedef char datatype_t[MAX_DATATYPE_LENGTH + 1];", file=f)
    print("typedef struct {", file=f)
    print("  symbol_t symbol;", file=f)
    print("  datatype_t datatype;", file=f)
    print("  int numElements;", file=f)
    print("  int dirWidth;", file=f)
    print("  int bitWidth;", file=f)
    print("  int offset;", file=f)
    print("} basedField_t;", file=f)
    print("typedef struct {", file=f)
    print("  int address;", file=f)
    print("  symbol_t symbol;", file=f)
    print("  datatype_t datatype;", file=f)
    print("  int numElements;", file=f)
    print("  int allocated;", file=f)
    print("  basedField_t *basedFields;", file=f)
    print("  int numFieldsInRecord;", file=f)
    print("  int recordSize;", file=f)
    print("  int dirWidth;", file=f)
    print("  int bitWidth;", file=f)
    print("  int parentAddress;", file=f)
    print("  int common;", file=f)
    print("  int library;", file=f)
    print("} memoryMapEntry_t;", file=f)
    print("extern memoryMapEntry_t memoryMap[NUM_SYMBOLS]; // Sorted by address", 
          file=f)
    print("extern memoryMapEntry_t *memoryMapBySymbol[NUM_SYMBOLS]; // Sorted by symbol", 
          file=f)
    print("typedef struct {", file=f)
    print("  int start;", file=f)
    print("  int end;", file=f)
    print("} memoryRegion_t;", file=f)
    print("extern memoryRegion_t memoryRegions[%d];" % len(regions), file=f)
    print("", file=f)
    f.close()
    
    if debugSink != None:
        print('', file=debugSink)
        walkModel(globalScope, printModel)

    # Generate some code.
    walkModel(globalScope, generateCodeForScope, { "of": None, "indent": ""})
    
    pf.close()
    
    # Generate arguments.c and arguments.h.
    for ext in ["c", "h"]:
        af = open(outputFolder + "/arguments." + ext, "w")
        print("// Global variables for arguments of runtime-library functions.\n", file = af)
        if ext == "c":
            print('#include "runtimeC.h"\n', file = af)
        else:
            print("#ifndef ARGUMENTS_H", file = af)
            print("#define ARGUMENTS_H", file=af)
        for i in range(currentInt):
            if ext == "h":
                print("extern ", end="", file=af)
            print("int32_t iarg%d;" % i, file=af)
        for i in range(currentDesc):
            if ext == "h":
                print("extern ", end="", file=af)
            print("descriptor_t *darg%d;" % i, file=af)
        if ext == "h":
            print("\n#endif // ARGUMENTS_H", file=af)
        af.close()
        
    # Create resetAllReentryGuards.c
    if reentryGuard:
        rf = open(outputFolder + "/resetAllReentryGuards.c", "w")
        print("/*", file=rf)
        print("  File resetAllReentryGuards.c was generated by XCOM-I, " + \
              datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + ".", 
              file=rf)
        print("*/", file=rf)
        print("", file=rf)
        print('#include "runtimeC.h"', file=rf)
        print("", file=rf)
        print("void", file=rf)
        print("resetAllReentryGuards(void) {", file=rf)
        def resetGuardsInScope(scope, extra=None):
            for identifier in scope["variables"]:
                attributes = scope["variables"][identifier]
                if "PROCEDURE" in attributes:
                    print(indentationQuantum + attributes["mangled"] + "(1);", \
                          file=rf)
        walkModel(globalScope, resetGuardsInScope, None)
        print("}", file=rf)
        rf.close()    
    
    # Output the approximated patches.
    if len(guessFiles) > 0:
        fixmeFiles = []
        count = 0
        for n in guessFiles:
            if -1 not in guessInlines and n not in guessInlines:
                continue
            base = "guess%d" % n
            if "P" in ifdefs:
                filename = base + "p.c"
            elif "B" in ifdefs:
                filename = base + "b.c"
            else:
                filename = base + ".c"
            fp = open(filename, "w")
            guessFile = guessFiles[n]
            for i in range(len(guessFile)):
                guessLines = guessFile[i]
                for guessLine in guessLines:
                    print(guessLine, file=fp)
                    if "***FIXME***" in guessLine and filename not in fixmeFiles:
                        fixmeFiles.append(filename)
            fp.close()
            count += 1
        if count > 0:
            print("%d approximate patch-files guess*.c were produced in %s" % \
                  (count, os.getcwd()), file=sys.stderr)
            if len(fixmeFiles) == 0:
                print("None of the files are known to require fixes")
            else:
                print("%d files(s) are known to require fixes:" % len(fixmeFiles))
                for filename in fixmeFiles:
                    print("\t%s" % filename)
                print('To fix them, search for the string "***FIXME***".')
        else:
            print("No approximate patch-files were produced.", file=sys.stderr)

    
#-----------------------------------------------------------------------------
# Interactive test mode for running this file in a stand-alone fashion rather
# than as a module.  Primarily for testing generation of C code for XPL
# expressions.

if __name__ == "__main__":
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
        "lineExpanded" : '',
        "allLabels": []
        }

    print("Any of the following are accepted as input:")
    print("    DECLARE identifier;")
    print("    DECLARE identifier(number);")
    print("    expression")
    print("This test is *very* user-unfriendly in case of syntax errors.")
    while True:
        line = input("Input: ")
        tokenized = xtokenize(scope, line)
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
                        "address": variableAddress,
                        "dirWidth": 4
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
                    "address": variableAddress,
                    "dirWidth": 4
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
        