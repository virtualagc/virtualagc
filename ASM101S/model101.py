'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   model101.py
Purpose:    This object-code generation for ASM101S, specific to the assembly 
            language of the IBM AP-101S computer.
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-09-05 RSB  Began.
'''

import random
from expressions import error, unroll, astFlattenList, evalArithmeticExpression
from fieldParser import parserASM

'''
A unique but "random" 28-bit "random", excluding all 0's and all 1's, 
left-shifted by 36 bits, is assigned as a hashcode to each CSECT (or DSECT) and 
each EXTRN symbol. These are explicitly seeded, so as to make the sequence 
repeatable, but the exact seed isn't significant.

The purpose of this sequence of random numbers is to provide a workable (if 
unfortunately not theoretically perfect) means of computing arithmetical 
expressions optionally involving addresses of symbols.  Addresses are limited
to 24 bits in AP-101S, but prior to linking we don't know the actual addresses
but only the offsets within control sections.  And for EXTRN symbols, we don't
even know that much.  The values we use in computing arithmetical expressions
are 64-bit signed integers like so:
    hashcode + 32-bit offset For local symbols
    hashcode                 For EXTRN symbols
    32-bit number            For plain number
For correctly-formed expressions (i.e., those not involving illegal combinations
of address symbols), this always produces the correct results.  (Note that 
"pairing" of EXTRN symbols in expressions is not allowed.)  In particular, we're
concerned about producing the correct results for expressions like:
    symbol + number
    symbol1 - symbol2        where both symbols are in the same control section.

The hashed addresses are stored directly in the `symtab` dictionary,
so that they're easily accessed by the expression evaluator when presented with
a symbol.  At the end of the recursive evaluation of such an expression, the 
final hashcode can be extracted from the result and looked up in the
`hashcodeLookup` dictionary to determine what CSECT or EXTRN symbol it relates
to, if any.  Here's an example, involving an EXTRN symbol, two local symbols in
the same control section (thus having the same hashcode in their hashed 
addresses) and a few literal numbers:
    LOCAL1 + NUMBER1 + EXTERN - LOCAL2 + NUMBER2 * NUMBER3 
In the computation, the symbols are represented by the numerical values
    EXTERN = hashcode1
    LOCAL1 = hashcode2 + offset1
    LOCAL2 = hashcode2 + offset2
Since hashcode2-hashcode2 cancels out, the result of the calculation is
    result = hashcode1 + (offset1 + NUMBER1 - offset2 + NUMBER2 * NUMBER3)
or just
    result = hashcode1 + NUMBER4
which can be separated by the operations:
    NUMBER4  = result & 0x00000000FFFFFFFF
    buffer   = result & 0x0000000F00000000
    hashcode = result & 0xFFFFFFF000000000
`buffer` is an unused area between the 32-bit numerical value and the 28-bit
`hashcode`.

But (you ask), what if the NUMBER4 part of the calculation overflows?  If there
is positive overflow, it can almost always be detected by the value of the 
`buffer`, but in extreme cases it results in a `hashcode` which is illegal
and fails lookup.  If there's negative overflow, then in almost all cases
`hashcode` will be all 1's, but since all 1's is not a legal hashcode, we can
use it as an indication that the result is purely numerical, without a 
hashcode.
'''
random.seed(16134176201611561415)
hashcodeLookup = {}
def getHashcode(symbol):
    hashcode = random.randint(1, (1 << 28) - 1) << 36
    hashcodeLookup[hashcode] = symbol
    return hashcode
# Reverses the hashing of a computed result of an arithmetic expression.
# returns
#    sect,number
# where sect==None for a pure numerical result, or is the name of an EXTRN
# or CSECT for an address result.  In case of error None,None is returned.
def unhash(result):
    offset   = result & 0x00000000FFFFFFFF
    buffer   = result & 0x0000000F00000000
    hashcode = result & 0xFFFFFFF000000000
    if hashcode in [0, 0xFFFFFFF000000000]:
        # A purely-numerical value
        return None, result
    if buffer == 0 and hashcode in hashcodeLookup:
        return hashcodeLookup[hashcode], offset
    return None, None

#=============================================================================
# Various tables or the instruction set.

ap101 = True
system390 = False

# First, the CPU instructions, categorized by instruction types, accompanied
# by opcodes.  When the opcode is given as -1, it's a special case in terms
# of how the code is generated.  (There are other special cases, though, which
# are not so-marked, such as almost all conditional branches..)
argsE = {}
argsRR = { "AR": 0b00000, "CR": 0b00010, "CBL": 0b00001, "DR": 0b01001, 
           "XUL": 0b00000, "LR": 0b00011, "LCR": 0b11101, "LFXI": 0b10111, 
           "MR": 0b01000, "SR": 0b00001, "BALR": 0b11100, "BCR": 0b11000, 
           "BCRE": 0b11000, "BCTR": 0b11010, "BVCR": 0b11001, "NCT": 0b11100, 
           "NR": 0b00100, "XR": 0b01110, "OR": 0b00101, "SUM": 0b10011, 
           "AEDR": 0b01010, "AER": 0b01010, "CEDR": 0b00011, "CER": 0b01001, 
           "CVFX": 0b00111, "CVFL": 0b00111, "DEDR": 0b00010, "DER": 0b01101,
           "LER": 0b01111, "LECR": 0b01111, "LFXR": 0b00100, "LFLI": 0b10001, 
           "LFLR": 0b00101, "MEDR": 0b00110, "MER": 0b01100, "SEDR": 0b01011, 
           "SER": 0b01011, "MVH": 0b01101, "SPM": 0b11001, "SRET": 0b10010, 
           "LXAR": 0b01000, "STXAR": 0b10100, "ICR": 0b11011, 
           "BR": 0b11000, "NOPR": 0b11000, 
           "LACR": 0b11101, "PC": 0b01101 }
argsI = {}
argsRRE = {}
argsRRF = {}
argsRX = {}
argsRXE = {}
argsRXF = {}
argsRS = { "A": 0b00000, "AH": 0b10000, "AST": 0b00000, "C": 0b00010, 
           "CH": 0b10010, "D": 0b01001, "IAL": 0b11100, "IHL": 0b100000, 
           "L": 0b00011, "LA": 0b11101, "LH": 0b10011, "LM": 0b11001, 
           "M": 0b01000, "MH": 0b10101, "MIH": 0b10011, "ST": 0b00110, 
           "STH": 0b10111, "STM": 0b11001, "S": 0b00001, "SST": 0b00001, 
           "SH": 0b10001, "TD": 0b10100, "BAL": 0b11100, "BIX": 0b11011, 
           "BC": 0b11000, "BCT": 0b11010, "BCV": 0b11001, "N": 0b00100, 
           "NST": 0b00100, "X": 0b01110, "XST": 0b01110, "O": 0b00101,
           "OST": 0b00101, "SHW": 0b10100, "TH": 0b10100, "ZH": 0b10100, 
           "AED": 0b01010, "AE": 0b01010, "CED": 0b00011, "CE": 0b01001, 
           "DED": 0b00010, "DE": 0b01101, "LED": 0b0111, "LE": 0b01111, 
           "MVS": 0b01100, "MED": 0b00110, "ME": 0b01100, "SED": 0b01011, 
           "SE": 0b01011, "STED": 0b00111, "STE": 0b00111, "DIAG": 0b11000, 
           "ISPB": 0b11101, "LPS": 0b11001, "SSM": 0b10001, "SCAL": 0b11010, 
           "SVC": 0b11001, "TS": 0b10111, "LXA": 0b01000, "LDM": 0b01101,
           "STXA": 0b10100, "STDM": 0b10010, 
           "B": 0b11000, "NOP": 0b11000, "BH": 0b11000, "BL": 0b11000, 
           "BE": 0b11000, "BNH": 0b11000, "BNL": 0b11000, "BNE": 0b11000, 
           "BO": 0b11000, "BP": 0b11000, "BM": 0b11000, "BZ": 0b11000, 
           "BNP": 0b11000, "BNM": 0b11000, "BNZ": 0b11000, "BNO": 0b11000, 
           "BLE": 0b11000, "BN": 0b11000 }
for m in sorted(argsRS):
    argsRS[m + "@"] = argsRS[m]
    argsRS[m + "@#"] = argsRS[m]
    argsRS[m + "#"] = argsRS[m]
argsRSE = {}
argsRSL = {}
argsRSI = {}
argsRI = { "AHI": 0b10110000, "CHI": 0b10110101, "MHI": 0b10110111, 
           "NHI": 0b10110110, "XHI": 0b10110100, "OHI": 0b10110010, 
           "TRB": 0b10110011, "ZRB": 0b10110001, 
           "LHI": -1, "SHI": -1 }
argsRIL = {}
argsSRS = { "BCB": 0b11011, "BCF": 0b11011, "BCTB": 0b11011, "BVCF": 0b11011, 
            "SLL": 0b11110, "SLDL": 0b11111, "SRA": 0b11110, "SRDA": 0b11111, 
            "SRDL": 0b11111, "SRL": 0b11110, "SRR": 0b11110, "SRDR": 0b11111,
            "A": 0b00000, "AH": 0b10000, "C": 0b00010, "CH": 0b10010, 
            "D": 0b01001, "IAL": 0b11100, "L": 0b00011, "LA": 0b11101, 
            "LH": 0b10011, "M": 0b01000, "MH": 0b10101, "ST": 0b00110, 
            "STH": 0b10111, "S": 0b00001, "SH": 0b10001, "TD": 0b10100,
            "BC": 0b11000, "N": 0b00100, "X": 0b01110, "O": 0b00101, 
            "SHW": 0b10100, "TH": 0b10100, "ZH": 0b10100, "AE": 0b01010, 
            "DE": 0b01101, "LE": 0b01111, "ME": 0b01100, "SE": 0b01011 }
argsSI = { "CIST": 0b10110101, "MSTH": 0b10110000, "NIST": 0b10110110, 
           "XIST": 0b10110100, "SB": 0b10110010, "TB": 0b10110011, 
           "ZB": 0b10110001, "TSB": 0b10110111 }
argsS = {}
argsSS = {}
argsSSE = {}

# Now, the MSC instructions.
argsMSC = { "@A": -1, "@B": -1, "@BN": -1, "@BNN": -1, "@BNP": -1, "@BNZ": -1, "@BU": -1, "@BU@": -1, "@BXN": -1,
         "@BXNN": -1, "@BXNP": -1, "@BXNZ": -1, "@BXP": -1, "@BXZ": -1, "@BZ": -1, "@C": -1, "@CI": -1, 
         "@CNOP": -1, "@DLY": -1, "@INT": -1, "@L": -1, "@LAR": -1, "@LF": -1, "@LH": -1, "@LI": -1, "@LMS": -1, 
         "@LXI": -1, "@N": -1, "@NIX": -1, "@RAI": -1, "@RAW": -1, "@RBI": -1, "@REC": -1, "@RFD": -1, "@RNI": -1, 
         "@RNW": -1, "@SAI": -1, "@SEC": -1, "@SFD": -1, "@SIO": -1, "@ST": -1, "@STF": -1, "@STH": -1, "@STP": -1, 
         "@TAX": -1, "@TI": -1, "@TM": -1, "@TMI": -1, "@TSZ": -1, "@TXA": -1, "@TXI": -1, "@WAT": -1, "@X": -1, 
         "@XAX": -1, "@BC": -1, "@BXC" "@CALL": -1, "@CALL@": -1, "@LBB": -1, "@LBB@": -1, "@LBP": -1, 
         "@LBP@": -1 }

# And BCE instructions.
argsBCE = { "#@#DEC": -1, "#@#HEX": -1, "#@#SCN": -1, "#BU": -1, "#BU@": -1, "#CMD": -1, "#CMDI": -1, 
           "#CNOP": -1, "#DLY": -1, "#DLYI": -1, "#LBR": -1, "#LBR@": -1, "#LTO": -1, "#LTOI": -1, "#MIN": -1,
           "#MIN@": -1, "#MINC": -1, "#MOUT": -1, "#MOUT@": -1, "#MOUTC": -1, "#ORG": -1, "#RDL": -1, 
           "#RDLI": -1, "#RDS": -1, "#RIB": -1, "#SIB": -1, "#SPLIT": -1, "#SSC": -1, "#SST": -1, "#STP": -1, 
           "#TDL": -1, "#TDLI": -1, "#TDS": -1, "#WAT": -1, "#WIX": -1
       }

instructionsWithoutOperands = argsE | argsBCE
instructionsWithOperands = argsRR | argsI | argsRRE | argsRRF | argsRX | \
                           argsRXE | argsRXF | argsRS | argsRSE | argsRSL | \
                           argsRSI | argsRI | argsRIL | argsSRS | \
                           argsSI | argsS | argsSS | argsSSE | argsMSC
knownInstructions = instructionsWithoutOperands | instructionsWithOperands

# The field values are the masks.
branchAliases = {"B": 15, "BR": 15, "NOP": 0, "NOPR": 0, "BH": 2, "BL": 4, 
                 "BE": 8, "BNH": 13, "BNL": 11, "BNE": 7, "BO": 1, "BP": 2, 
                 "BM": 4, "BZ": 8, "BNP": 13, "BNM": 11, "BNZ": 7, "BNO": 14,
                 "BLE": 13, "BN": 4}

#=============================================================================
# Generate object code for AP-101S.

'''
Work is done in place on the `source` array, which is a list of "property"
structures, one for each line if source code, including all of the macro
definitions from the macro library.  However, all manipulations of symbolic
variables and expansion of macros has been performed, so only the lines of
pure assembly-language code (i.e., CPU instructions and related pseudo-ops)
are processed.  Moreover, while continuation lines are present, all after the
first in any sequence have been merged into the first line of the sequence.
The `macros` argument is provided merely to have a list of operations which
can be ignored.

The only manipulations done to any particular entry of `source` are:
    1. The `errors` field may be augmented via the `error` function.
    2. Non-previously-existing fields may be added to hold object-code data.
I.e., no existing fields other than `errors` are affected.

Additionally, the function returns a dictionary of non-line-by-line info about
the assembly.

Note that addresses are in units of bytes.
'''
ignore = { "TITLE", 
           "GBLA", "GBLB", "GBLC", "LCLA", "LCLB",
           "LCLC", "SETA", "SETB", "SETC", "AIF",
           "AGO", "ANOP", "SPACE", "MEXIT", "MNOTE" }
hexDigits = "0123456789ABCDEF"

'''
Data for the compilation that isn't on a line-by-line basis.  Regarding the
`symtab` dictionary, there's an entry for each symbol, and each entry is 
itself a dictionary.  Each of those dictionaries has a "type" key to indicate 
the general category it falls into, chosen from among the following:

   "EXTERNAL"    Indicates an `EXTRN` symbol.
   "DATA"        Indicates `DS` or `DC`.
   "INSTRUCTION" Indicates a program label.
   "ENTRY"       Indicates an `ENTRY` point, but otherwise identical to an
                 "INSTRUCTION".
   "CSECT"       Indicates `CSECT`, `DSECT`, or `START`.
   "EQU"         Indicates `EQU`.
   "LITERAL"     Indicates an integer, boolean, or string constant value.
   ... presumably, more later ...
   
Besides the "type" key, there could be one or more of following keys:
   "section"     (string) Name of the control section containg the symbol.
   "address"     (integer) Address of the symbol within the control section.
   "value"       Tricky, so see explanatin that follows.

Regarding "value", this is what's used in computing the value of arithmetic 
expressions involving the symbol.  There are four cases:

1. For symbols which cannot be used in arithmetic expressions, there is no 
   "value" field.
2. For symbols representing addresses ("EXTERNAL", "DATA", "INSTRUCTION", 
   "ENTRY", "CSECT"), this is a 64-bit integer pseudo-address that combines the
   "section" and "address" fields into a single number.
3. For symbols representing constant values rather than addresses ("LITERAL"),
   is the actual integer, boolean, or string value of the constant.
4. "EQU" symbols may represent any of the cases mentioned above, and the "value"
   field will also match those cases accordingly.

The `unhash` function can be used to return any "value"-type integer into 
its constituent "section"/"address", or to determine that it's just an integer
value rather than an address at all.
'''
sects = {} # CSECTS and DSECTS.
entries = set() # For `ENTRY`.
extrns = set() # For `EXTRN`.
symtab = {}
metadata = {
    "sects": sects,
    "entries": entries,
    "extrns": extrns,
    "symtab": symtab,
    "passCount": 0
    }

def generateObjectCode(source, macros):
    
    #-----------------------------------------------------------------------
    # Setup
    
    compile = False
    sect = None # Current section.
    for key in macros:
        ignore.add(key)
    properties = {}
    
    #-----------------------------------------------------------------------
    
    # A function for writing to memory or allocating it without writing to
    # it, as appropriate, though in this case "not writing to it" means 
    # zeroing it.  This occurs in the current CSECT or DSECT
    #    `bytes`        Is either a number (for DS) indicating how much memory
    #                   to allocate, or else a `bytearray` (for DC) of the
    #                   actual bytes to store.
    # Alignment must have been done prior to entry.
    memoryChunkSize = 4096
    def toMemory(bytes):
        nonlocal compile, properties
        properties["section"] = sect
        properties["pos"] = sects[sect]["pos"]
        if isinstance(bytes, bytearray):
            pos = sects[sect]["pos"]
            end = pos + len(bytes)
            if cVsD and compile:
                memory = sects[sect]["memory"]
                if end > len(memory):
                    chunks = (end - len(memory) + memoryChunkSize - 1) \
                                // memoryChunkSize
                    memory.extend([0]*(chunks * memoryChunkSize - len(memory)))
                for i in range(len(bytes)):
                    memory[pos + i] = bytes[i]
            properties["assembled"] = bytes
            sects[sect]["pos"] = end
        else:
            sects[sect]["pos"] += bytes
        if sects[sect]["pos"] > sects[sect]["used"]:
            sects[sect]["used"] = sects[sect]["pos"]

    # Common processing for all instructions. The `alignment` argument is one
    # of 1 (byte), 2 (halfword), 4 (word), 8 (doubleword).
    # The memory added for padding is 0-filled if `zero` is `True`, or left
    # unchanged if `False`.
    name = ""
    operation = ""
    def commonProcessing(alignment=1, zero=False):
        nonlocal cVsD, sect, name, operation
        
        # Make sure we're in *some* CSECT or DSECT
        if sect == None:
            cVsD = True
            sect = ""
            if sect not in sects:
                sects[sect] = {
                    "pos": 0,
                    "used": 0,
                    "memory": bytearray(memoryChunkSize)
                    }
        
        # Perform alignment.
        if alignment > 1:
            rem = sects[sect]["pos"] % alignment
            if rem != 0:
                if zero:
                    toMemory(bytearray(alignment - rem))
                else:
                    toMemory(alignment - rem)
        
        # Add `name` (if any) to the symbol table.
        if name != "":
            pos = sects[sect]["pos"] // 2
            if name in symtab:
                oldSect = symtab[name]["section"]
                oldPos = symtab[name]["address"]
                if oldSect != sect or oldPos != pos:
                    error(properties, 
                          "Symbol %s address has changed: (%s,%d) -> (%s,%d)" \
                          % (name, oldSect, oldPos, sect, pos ))
            else:
                symtab[name] = { "section": sect,  "address": pos,
                                 "value": symtab[sect]["value"] + pos,
                                 "debug": "%05X" % pos }
                if operation in ["DC", "DS"]:
                    symtab[name]["type"] = "DATA"
                elif name in entries:
                    symtab[name]["type"] = "ENTRY"
                else:
                    symtab[name]["type"] = "INSTRUCTION"
    
    # Gets the hashed address of the current program counter.
    def currentHash():
        return symtab[sect]["value"] + sects[sect]["pos"]
    
    # Evaluate a single suboperand of the operand of an instruction like 
    # RR, RS, SRS, SI, RI.  Returns a pair (err,value).  The `err` is 
    # boolean and is True on error.  The value is an integer, or None if the
    # desired subfield isn't present.  The possible subfields are strings like
    # "R1", "R2", "D2", "X2", "B2", and so on.
    def evalInstructionSubfield(properties, subfield, ast, symtab={}):
        nonlocal sect
        if subfield not in ast:
            return False, None
        expression = ast[subfield]
        value = evalArithmeticExpression(expression, {}, properties, symtab, \
                                         currentHash(), severity=0)
        if value == None:
            error(properties, "Could not evaluate %s subfield" % subfield, \
                  severity=0)
            return True, None
        return False, value
    
    # For an instruction in which there's a nominal suboperand D2(B2) [or
    # D2(X2,B2)], but which is given in the source code simply as D2, determine
    # a suitable B2 and adjusted D2 from among the registers specified by 
    # `USING`.  The argument `d2` is given in hashed form.  The return value 
    # is B2,D2 where the base has been subtracted from the given d2, or else 
    # None,None if no candidates were found. As far as the `findB2D2` function 
    # is concerned, there's no actual upper limit on the returned D2; the 
    # calling code must determine for itself whether or not D2 is small enough.
    def findB2D2(d2):
        hashMask = 0xFFFFFFF000000000
        big = (d2 & hashMask) not in [0, hashMask]
        D2 = None
        B2 = None
        for i in range(len(using)):
            e = using[i]
            if e == None:
                continue
            if big:
                d = d2 - e[0]
            else:
                d = d2 - e[2]
            if d >= 0:
                # Note that "<=" is required in this test, rather than "<",
                # because the assembler manual states that if two candidate
                # registers result in the same D2, the higher-number register
                # is used.
                if D2 == None or d <= D2:
                    D2 = d
                    B2 = i
        return B2, D2
    
    #-----------------------------------------------------------------------
    # Process source code in a series of passes.  All of the initial passes
    # are for the purpose of determining the values or addresses of symbols, but
    # nothing is compiled to the memory of the control sections.  Only on the
    # final pass is such compilation done.  To track this, the variables
    # `compile` is used.  On the final pass it is true, but is False prior to
    # that.  In between passes, `sect` is reset to `None`, and all
    # control-section position-pointers are returned to 0.
    
    while True:
        metadata["passCount"] += 1
        continuation = False
        for sect in sects:
            sects[sect]["pos"] = 0
        sect = None
        using = [None]*8
        # Process shource code, line-by-line
        for properties in source:
            
            #******** Should this line be processed or discarded? ********
            if properties["inMacroDefinition"] or properties["fullComment"] or \
                    properties["dotComment"] or properties["empty"]:
                continue
            # We only need to look at the first line of any sequence of continued
            # lines.
            if continuation:
                continuation = properties["continues"]
                continue
            continuation = properties["continues"]
            # Various types of lines we can immediately discard by looking at 
            # their `operation` fields
            operation = properties["operation"]
            if operation in ignore:
                continue
            
            name = properties["name"]
            if name.startswith("."):
                name = ""
            operand = properties["operand"].rstrip()
            
            #******** Most pseudo-ops ********
            # Take care of pseudo-ops that don't add anything to AP-101S memory.
            # Each one of these should either `continue` or `break`, so as not to
            # fall through to instruction processing.
            if operation in ["CSECT", "DSECT"]:
                # The current section name starts as `None`, meaning none has been
                # assigned.  `START` or `CSECT` changes that to either "" (the
                # "unnamed" section) or an identifier. Code that must be assembled
                # when the section name is still `None` automatically switches to
                # the unnamed section.  I *could* check here that the name given
                # to the section is a valid identifier name, but I'm not bothering
                # with that just yet.
                cVsD = (operation == "CSECT")
                if name == "" and not cVsD:
                    error(properties, "Unnamed DSECT not allowed.")
                sect = name
                if sect not in sects:
                    sects[sect] = {
                        "pos": 0,
                        "used": 0,
                        "memory": bytearray(memoryChunkSize)
                        }
                    symtab[sect] = { 
                        "section": sect, 
                        "address": 0, 
                        "type": "CSECT",
                        "value": getHashcode(sect) 
                        }
                properties["section"] = sect
                properties["pos"] = sects[sect]["pos"]
                continue
            elif operation == "END":
                break
            elif operation in ["ENTRY", "EXTRN"]:
                ast = parserASM(operand, "identifierList")
                if ast == None:
                    error(properties, "Cannot parse operand of %s" % operation)
                else:
                    ast = unroll(ast)
                    symbols = []
                    if isinstance(ast, str):
                        symbols.append(ast)
                    else:
                        symbols.append(ast[0])
                        for e in ast[1]:
                            symbols.append(e[1])
                    for symbol in symbols:
                        if operation == "ENTRY":
                            entries.add(symbol)
                        else:
                            extrns.add(symbol)
                            symtab[symbol] = {
                                "type": "EXTERNAL",
                                "value": getHashcode(symbol)
                                }
                continue
            elif operation == "EQU":
                if name == "":
                    error(properties, "EQU has no name field")
                    continue
                oldValue = None
                if name in symtab:
                    if symtab[name]["type"] != "EQU":
                        error(properties, "EQU name already in use: %s" % name)
                        continue
                    oldValue = symtab[name]["value"]
                ast = parserASM(operand, "equOperand")
                if ast == None:
                    error(properties, "Cannot parse operand of EQU")
                    continue
                err, v = evalInstructionSubfield(properties, "v", ast, symtab)
                if err:
                    error(properties, "Cannot evaluate EQU")
                    continue
                if oldValue not in [None, v]:
                    error(properties, "EQU value of %s changed: %d -> %d" % \
                          (name, oldValue, value))
                    continue
                symtab[name] = {
                    "type": "EQU",
                    "value": v
                    }
                continue
            # For EXTRN see ENTRY.
            elif operation == "LTORG":
                continue
            elif operation in ["USING", "DROP"]:
                ast = parserASM(operand, "expressions")
                if ast == None or "r" not in ast or not isinstance(ast["r"], list):
                    error(properties, "Cannot parse operand of " + operation)
                    continue
                rlist = ast["r"]
                for i in range(len(rlist)):
                    rlist[i] = evalArithmeticExpression(rlist[i], {}, \
                                                        properties, \
                                                        symtab, currentHash())
                if operation == "USING":
                    if len(rlist) < 1 or rlist[0] == None:
                        error(properties, "Bad location")
                        continue
                    else:
                        h = rlist.pop(0)
                section, address = unhash(h)
                for r in rlist:
                    if r == None or r < 0 or r > 7:
                        error(properties, "Bad register number")
                    elif operation == "USING":
                        using[r] = (h, section, address)
                        h += 4096
                        address += 4096
                    else: # DROP
                        using[r] = None
                continue
            
            #******** Partial Alignment ********
            # The System/360 assembly-language manual claims that *some* data
            # (such as C'...' and X'...' data in `DC` pseudo-ops) is 
            # unaligned ... i.e., aligned to byte boundaries.  This is misleading.  
            # All `DC`, `DS`, and all instructions must minimally be aligned
            # halfword boundaries.  We know this if only because the 
            # addresses printed in assembly listings are all halfword addresses
            # rather than byte addresses.  I presume that the manual's claim
            # is really referring to suboperands beyond the first suboperand
            # when a single `DC` or `DS` has multiple suboperands in its 
            # operand.  Regardless, we should align to the halfword now.
            sects[sect]["pos"] += sects[sect]["pos"] & 1
            
            #******** Process instruction ********
            
            # For our purposes, pseudo-ops like `DS` and `DC` that can have labels,
            # modify memory, and move the instruction pointer are "instructions".
            
            if operation in ["DC", "DS"]:
                ast = parserASM(operand, operation.lower() + "Operands")
                if ast == None:
                    error(properties, "Cannot parse %s operand" % operation)
                    continue
                flattened = astFlattenList(ast)
                # At this point, `flattened` should be a list with one entry for
                # each suboperand.  Those suboperands are in the form of 
                # dicts with the keys:
                #    'd'    duplication factor
                #    't'    type
                #    'l'    length modifier
                #    'v'    value
                # Each of these fields will itself be an AST.
                for suboperand in flattened:
                    if suboperand["d"] == []:
                        duplicationFactor = 1
                    else:
                        duplicationFactor = \
                            evalArithmeticExpression(suboperand["d"], {}, \
                                                     properties)
                        if duplicationFactor == None:
                            error(properties, "Could not evaluate duplication factor")
                            continue
                    try:
                        suboperandType = suboperand["t"][0]
                    except:
                        error(properties, "Suboperand type not specified")
                        continue
                    if suboperand["l"] == []:
                        lengthModifier = None
                    else:
                        lengthModifier = \
                            evalArithmeticExpression(suboperand["l"], {}, \
                                                     properties)
                        if lengthModifier == None:
                            error(properties, "Count not evaluate length modifier")
                            continue
                    astValue = suboperand["v"]
                    if suboperandType == "C":
                        commonProcessing(1)
                        
                        pass
                    elif suboperandType == "X":
                        commonProcessing(1)
                        # Adjust the string to have an even number of digits,
                        # 0-padded or truncated to the length modifier, if any.
                        try:
                            hexString = flattened[0]["v"][0][1]
                            if lengthModifier == None:
                                count = len(hexString)
                                count += (count % 1)
                            else:
                                count = lengthModifier * 2
                            while len(hexString) < count:
                                hexString = "0" + hexString
                            hexString = hexString[-count:]
                        except:
                            error(properties, "Cannot parse X value")
                            continue
                        # Deal with memory.
                        if operation == "DC":
                            bytes = bytearray()
                            for i in range(0, count, 2):
                                b = hexString[i:i+2]
                                bytes.append(int(b, 16))
                            toMemory(bytes)
                        else:
                            toMemory(count // 2)
                    elif suboperandType == "B":
                        commonProcessing(1)
                        
                        pass
                    elif suboperandType == "F":
                        commonProcessing(1)
                        if lengthModifier != None:
                            pass
                        if operation == "DC":
                            pass
                        
                        toMemory(duplicationFactor * 4)
                    elif suboperandType == "H":
                        commonProcessing(1)
                        if lengthModifier != None:
                            pass
                        if operation == "DC":
                            pass
                        
                        toMemory(duplicationFactor * 2)
                    elif suboperandType == "E":
                        commonProcessing(1)
                        if lengthModifier != None:
                            pass
                        if operation == "DC":
                            pass
                        
                        toMemory(duplicationFactor * 4)
                    elif suboperandType == "D":
                        commonProcessing(1)
                        if lengthModifier != None:
                            pass
                        if operation == "DC":
                            pass
                        
                        toMemory(duplicationFactor * 8)
                    elif suboperandType == "A":
                        commonProcessing(1)
                        if lengthModifier != None:
                            pass
                        if operation == "DC":
                            pass
                        
                        toMemory(duplicationFactor * 4)
                    elif suboperandType == "Y":
                        commonProcessing(1)
                        if lengthModifier != None:
                            pass
                        if operation == "DC":
                            pass
                        
                        
                        toMemory(duplicationFactor * 2)
                    else:
                        error(properties, 
                              "Unsupported DC/DS type %s" % suboperandType)
                        continue
                continue
            
            if operation in argsRR:
                commonProcessing(2)
                if not compile:
                    toMemory(2)
                    continue
                data = bytearray(2)
                ast = parserASM(operand, "rrAll")
                if ast != None:
                    pass # FIXME
                toMemory(data)
                continue
                
            if operation in argsRS or operation in argsSRS:
                commonProcessing(2)
                '''
                We have a conundrum here.  It is often the case that (for the
                *same* mnemonic) there is both an RS version of the instruction
                (2 halfwords) and an SRS version of the instruction (1 halfword).
                The duplicates are:
                    A AE AH BC C CH D DE IAL L LA LE LH M ME MH
                    N O S SE SH SHW ST STH TD TH X ZH
                All of the SRS versions could be encoded as the RS version 
                without functional difficulty, I think, but aren't (presumably
                to save a little memory).  There's no syntactic difference.
                The old assembler decided, I guess, based on the size of D2:
                    0 <= DS < 56         -> SRS
                    56 <= DS             -> RS
                But we can't always determine the size of DS in earlier passes, 
                because it may involve unresolved forward references.
                Or in other words, we often cannot determine the size of the
                instruction without already knowing the size of the instruction.
                ***FIXME***
                '''
                dataSize = 4
                if operation in branchAliases:
                    dataSize = 2
                if not compile:
                    toMemory(dataSize)
                    continue
                data = bytearray(dataSize)
                ast = parserASM(operand, "rsAll")
                if ast != None:
                    err, r1 = evalInstructionSubfield(properties, "R1", ast, symtab)
                    if r1 == None:
                        # This happens for various aliased instructions.
                        if operation in branchAliases:
                            r1 = branchAliases[operation]
                        else:
                            # No matches, fall through to other types of instsructions.
                            pass
                    if r1 != None:
                        err, d2 = evalInstructionSubfield(properties, "D2", ast, symtab)
                        if not err: 
                            err, b2 = evalInstructionSubfield(properties, "B2", ast, symtab)
                            if not err: 
                                err, x2 = evalInstructionSubfield(properties, "X2", ast, symtab)
                                if not err:
                                    if b2 == None:
                                        b2,d2 = findB2D2(d2)
                                    if operation in argsRS:
                                        opcode = argsRS[operation]
                                    else:
                                        opcode = argsSRS[operation]
                                    data[0] = (opcode << 3) | r1
                                    if b2 == None or b2 > 3 or b2 < 0:
                                        error(properties, "No candidate B2 found")
                                    elif d2 < 56 or len(data) == 2:
                                        data[1] = 0xFF & ((d2 << 2) | b2)
                                    elif x2 != None:
                                        if x2 < 0 or x2 > 7:
                                            error(properties, "X2 out of range")
                                        else:
                                            data[1] = 0b11111100 | b2
                                            ia = "@" in operation
                                            i = "#" in operation
                                            data[2] = (x2 << 5) | \
                                                      (ia << 4) | \
                                                      (i << 3) | \
                                                      (d2 >> 8)
                                            data[3] = d2
                                    else:
                                        data[1] = 0b11111000 | b2
                                        d2 &= 0xFFFF
                                        data[2] = d2 >> 8
                                        data[3] = d2
                toMemory(data)
                continue
                
            if operation in argsRI:
                commonProcessing(2)
                if not compile:
                    toMemory(4)
                    continue
                data = bytearray(4)
                ast = parserASM(operand, "riAll")
                if ast != None:
                    err, r2 = evalInstructionSubfield(properties, "R2", ast, symtab)
                    if not err: 
                        err, i1 = evalInstructionSubfield(properties, "I1", ast, symtab)
                        if not err: 
                            pass # FIXME
                toMemory(data)
                continue
                
            if operation in argsSI:
                commonProcessing(2)
                if not compile:
                    toMemory(4)
                    continue
                data = bytearray(4)
                ast = parserASM(operand, "siAll")
                if ast != None:
                    pass # FIXME
                toMemory(data)
                continue
                
            if operation in argsMSC:
                # MSC operations are really standardized enough for there to be
                # any advantage in segregating them this way, but it might provide
                # some clarity in maintenance to do so.
                commonProcessing(2)
                ast = parserASM(operand, "mscAll")
                if ast != None:
                    toMemory(bytearray(4))
                    continue
                
            if operation in argsBCE:
                # BCE operations are really standardized enough for there to be
                # any advantage in segregating them this way, but it might provide
                # some clarity in maintenance to do so.
                commonProcessing(2)
                ast = parserASM(operand, "bceAll")
                if ast != None:
                    toMemory(bytearray(4))
                    continue
                
            error(properties, "Unrecognized line")
            continue
        
        if compile: # Compilation completed?
            break
        compile = True
        
    return metadata
