'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   model101.py
Purpose:    Object-code generation for ASM101S, specific to the assembly 
            language of the IBM AP-101S computer.
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-09-05 RSB  Began.
'''

import copy
import random
from expressions import error, unroll, astFlattenList, \
    evalArithmeticExpression, svGlobals
from fieldParser import parserASM
from ibmHex import *

'''
******************************************************************************
                               *** Warning ***
                               
    There are several issues with the design of the assembly-language
    itself, or at least with my understanding of how to deal with its issues,
    that turn some aspects of the code-generator's algorithm in an ad hoc
    mess of special cases, with no guarantee that the algorithm is generally
    correct.
    
    A big culprit is the use of the same mnemonic in many cases for:
    
            SRS-type instruction (which assemble to halfwords)
                                    vs
            RS-type instructions of subtype AM=1 (assembling to fullwords)
                                    vs
            RS-type instructions of subtype AM=0 (assembling to fullwords)
    
    Another big culprit is the fact that *some* SRS-type instructions and 
    RS-type subtype AM=0 instructions (but no AM=1 instructions) differ in 
    their addressing of halfword operands vs fullword operands ... with 
    *no* documented way to determine which instructions do and which do not.
    
    As I say, this makes the code that computes these distinctions a real,
    huge mess.  It needs to be redesigned, but at present I see no obvious
    way to do so.
******************************************************************************

Structure of the Code Generator
-------------------------------

The Assembler as a whole proceeds in a sequence of 5 passes, more or less, 
of which the first one has already occurred befor the code generator 
(`generateObjectCode`) has been called.  That initial pass resolves all of the 
macro language (variables of the form &VAR, sequence symbols of the 
form .SYMBOL, macro expansion, and inclusion of code via the `COPY` pseudo-op, 
continuation lines), leaving only lines of "pure" AP-101 assembly-language 
code for processing.  Besides this, it has also divided the lines in to fields 
`name`, `operation`, and `operand`, the latter of which may include the 
end-of-line comment, if any.

Thus `generateObjectCode` itself has 4 passes:

    Pass 0: Uses the operand parser (`parserASM`) to parse each operand and 
            provide the parsed form as an AST (`ast`) appropriate to the 
            particular `operation`.  (This is provided as a separate pass, so
            that the "lookahead" in pass 1, see below, does not have reparse
            any lines.)
    Pass 1: Processes `CSECT` pseudo-ops and any other pseudo-ops affecting
            the control sections and the position pointers within the control
            sections.  It's purpose is to resolve all symbols, and in particular
            to determine the addresses of all symbols.  To do so, it must
            determine the alignments and amount of memory occupied by all
            CPU/MSC/DCE instructions and DC/DS pseudo-ops.  However, there
            is ambiguity for some mnemonics as to whether they are RS-type
            instructions or SRS-type instructions, the two of which occupy
            different amounts of memory, and this ambiguity cannot be resolved
            syntactically in most cases.  Therefore, where there is ambiguity,
            pass 2 must sometimes perform a certain amount of lookahead, 
            involving the `ast` and other intermediate data created in pass 1, 
            to determine the sizes of memory displacements that can resolve the 
            ambiguity.
    Pass 2: Pass 1 has done a good job (or at least *the* job) of correctly
            determining the size of SRS vs RS instructions, but a poor job
            determining the locations of symbols for the symbol table.  Pass 2
            is essentially a repeat of Pass 1, except that it just directly
            uses the instruction sizes determined by Pass 1, rather than 
            attempting to determine them itself.
    Pass 3: Uses the results of passes 0 and 2 to actually generate the 
            object code and constant data stored in memory.

Some of these passes have what might be thought of as "mini-passes" between
them and the next pass, in order to resolve minor issues.  

Pseudo-Addresses
----------------

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
    hashcode + 32-bit offset For local symbols (offset is in halfwords)
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

"Second Operands" of SRS and RS Instructions
--------------------------------------------

For some instructions, the "second operand" (or more-specifically, D2) is in
units of halfwords, while in others it is in units of fullwords.  For example,
if the address of a byte is 40 (decimal), then its halfword address is 20 and
its fullword address is 10.  I.e., D2 might be 20 or 10 respectively.

So far, my reading of the AP-101S Principles of Operation has not elicited any 
complete, unambiguous explanation of which instructions or which.  My 
probably-imperfect inferences are these:

  1.  As a rule of thumb, if the most-significant bit of the opcode is 0, then
      the instruction uses fullword addresses, while if it is 1, then the
      instruction uses halfword addresses.
  2.  However, floating-point instructions are exceptions, and always use 
      halfword addresses.  (There's some support for that as well, maybe, in that
      on p. 8-3 the POO says "Second operands for the floating point set are
      no longer restricted by hardware to even halfword boundary address 
      locations.")
  3.  These rules apply only to SRS and RS AM=0 instructions, whereas halfword
      addressing is always used for RS AM=1 instructions.

One implication of these rules is that in cases an SRS or RS AM=0 instruction
might require a fullword D2 where the displacement is actually odd number of
halfwords, then an RS AM=1 instruction would have to be used instead.

Determining Types of SRS/RS Instructions
----------------------------------------

(in progress)

Regarding those mnemonics which may be SRS or RS type instructions, depending
on the particular mnemonic there are up to 4 cases to distinguish between:

  1.  Instructions which *must* be type SRS.
  2.  Instructions which *must* be type RS AM=0.
  3.  Instructions which *must* be type RS AM=1.
  4.  Instructions which might be some one of several of the above.

Here are the rules to classify an instruction in this group.

  A.  If the mnemonic is in the SRS-only set, then it is SRS.  (Obviously!)
  B.  If there is an explicit X2, then the instruction is RS AM=1.
  C.  If there's no explicit B2 and D2 is a constant (i.e., without an 
      upper-word hash) then code as RS AM=0 with B2=3.  (Recall:  For AM=0 B2=3, 
      base register is discarded.)
  D.  If no explicit B2 but D2's hash matches current control section:
      1)  Special case of mnemonic BC (possibly aliased from B, BZ, etc.) and
          displacement from updated IC is >-56 and <0, code as BCB.
      2)  Special case of mnemonic BC (possibly aliased) and displacement from
          updated IC is >=0  and <56, code as BCF.
      3)  If displacement from updated IC is >=0 and <2048, then code as 
          RS AM=1 (with B2=3, X2=0, IA=0, I=0).
      4)  If the current control section is in USING, then code as
          RS AM=0 (with B2=USING reg for current section).
      5)  Otherwise, fail.
  E.  If no explicit B2 but D2's hash match one in USING:
  `   1)  If the unhashed D2 is >=0 and <56, code as SRS
          (with B2=register from USING).
      2)  If the unhashed D2 is >=0 and <2048, code as RS AM=1 (with B2 from
          USING).
      3)  Code as RS AM=0 (with B2 from USING).
  F.  If explicit B2 and ...
  
'''
srsFloor = 0
srsCeiling = 56
#srsCeiling = 55

random.seed(16134176201611561415)
hashcodeLookup = {}
def getHashcode(symbol):
    for h in hashcodeLookup:
        if hashcodeLookup[h] == symbol:
            return h
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
# Similar to `unhash`, but uses the `USING` list, and returns a pair
# B2,D2 (or None,None in case of error).
def unUsing(using, hashed):
    b2 = None
    d2 = None
    for i in range(len(using)):
        u = using[i]
        if u == None:
            continue
        j = hashed - u[0]
        if j < 0 or j > 0xFFFFFF:
            continue
        if d2 == None or j < d2:
            b2 = i
            d2 = j
    return b2,d2

ap101 = True
system390 = False

from model101tables import *

sects = {} # CSECTS and DSECTS.
entries = set() # For `ENTRY`.
extrns = set() # For `EXTRN`.
rextrns = {} # For `EXTRN`
symtab = {}
metadata = {
    "sects": sects,
    "entries": entries,
    "extrns": extrns,
    "rextrns": rextrns,
    "symtab": symtab,
    "passCount": 0
    }
'''
`literalPools` is intended to keep track of what the System/360 assembler 
manual refers to as "literals" (vs what *I* refer to as literals), namely
strings like "=1234", "=X'ABCD'", and so on.  In IBM World(TM), these appear
within operands of instructions, but instead of treating them as immediate data,
perhaps because the instruction doesn't accept immediate data, the assembler
stores their values in a "literal pool" and uses their addresses in the code it
generates for the instructions using them.  The probem with them from my 
perspective is that the literal pools *always* follow (eventually!) the 
instructions using the literals, so literals are always end up being forward 
references.  Thus we need some way to track them until the literal pool is
eventually formed.  There can be multiple literal pools, each defined by the
appearance of a `LTORG` pseudo-op (marking the beginning of the pool), as well
as the default literal pool at the end of the first CSECT.  All literals
are stored in the literal pool defined by the *following* `LTORG`, or else in
the default pool if there are any literals after the final `LTORG`.  Duplicate
literals within any of these LTORG-to-LTORG intervals are stored only once in
that literal pool.  However, duplicates across literal pools are stored in each
of the corresponding literal pools.  Literals of the form "=A(...)", such as
"=A(*+5)" are not present in Shuttle flight software and are not supported.
If two literals have the same value but different attributes, then they are not
considered duplicates.  For example, =X'0000001234' and =X'1234' have the same
numerical values when considered as constants, but have different lenth 
attributes, because they occupy different amounts of memory.

There is one entry in `literalPools` for each literal pool, with the last one
being the default pool.  Thus if there are N `LTORG` pseudo-ops, then there are
N+1 entries.  Each entry is also a list.  The entries of those lists are:
    0. The name of the CSECT containing the literal pool.
    1. The byte offset within the CSECT at which the pool starts.
    2. The alignment (8, 4, 2) of the literal pool itself
    3. A list of the same length as `literalPools` itself, but only the entries
       corresponding to the ones below are used, and are the address offsets 
       into the literal pool of those entries.
    4. The total size (in bytes) of the pool.
    5+. Dictionaries, one for each unique literal in the section.
The dictionaries just mentioned have the keys:
    "value"        The integer, boolean, or string value of the literal.
    "L"            The length attribute.
    "T"            The type attribute.
    etc.           (Any other attributes it eventually occurs to me are needed.)
Note that when a new literal pool is started, it's always assigned to 
CSECT "" (even if there isn't one) and an address within the CSECT of 0.
These things are adjusted later when an `LTORG` or end of source is encountered
to close out the literal pool.  The literals do not necessary appear in the
pool in the same order as encounted in the source code.  Rather, the are sorted
primarily in reverse order of alignment boundaries (8, 4, 2), and only 
secondarily on the order encountered.  The offset list (item #3 above)
is filled in after completion of the pass which discovers all of the literals and 
assigns them to pools.  Naively, it may appear that it would make more sense 
to add the address offsets as new key/value pairs in items 4+ themselves, but 
that would render lookup impossible since you'd have to know the offset before
performing the lookup. 
'''
emptyPool = ["", None, None, [], 0]
literalPools = [copy.deepcopy(emptyPool)]
# Call this whenever an `LTORG` is encountered.
def ltorg(sect):
    global literalPools, sects
    literalPool = literalPools[-1]
    #if len(literalPool) >= len(emptyPool):
    literalPool[0] = sect
    literalPool[1] = sects[sect]["pos1"]
    literalPools.append(copy.deepcopy(emptyPool))
# Call this at the end of the source code.
def endOfSource():
    global literalPools, sects
    literalPool = literalPools[-1]
    if len(literalPool) == len(emptyPool):
        literalPools.pop()
        return
    for sect in sects:
        if not sects[sect]["dsect"]:
            literalPool[0] = sect
            literalPool[1] = sects[sect]["pos1"]
            return
# Call this whenever a new literal is discovered in an operand.
def addLiteral(attributeDict):
    global literalPools
    literalPool = literalPools[-1]
    if attributeDict not in literalPool:
        literalPool.append(copy.deepcopy(attributeDict))
# Evaluates AST of what System/360 calls a literal, returning either an 
# attributes dictionary for the literal pool or else None.
hMax = 1 << 15
fMax = 1 << 31
def evalLiteralAttributes(properties, ast, symtab):
    l2 = evalArithmeticExpression(ast["L2"], {}, properties, symtab, \
                                  star=None, severity=0)
    if l2 == None:
        return None
    ast = ast["L2"][0]
    t = ast["T"][0]
    scale = 1
    if "S" in ast and len(ast["S"]) > 0:
        scale = pow(2.0, -int(ast["S"]))
    numerical = True
    if t == "C":
        numerical = False
        value = value.replace("''", "'").replace("&&", "&")
        l = len(value)
        bytes = bytearray(l)
        for i in range(l):
            bytes[i] = toEbcdic(ord(value[i]))
    elif t == "B":
        l = (len(ast[t][0]) + 7) // 8
        value = l2
    elif t == "X":
        l = (len(ast[t][0]) + 1) // 2
        value = l2
    elif t == "H":
        l = 2
        value = l2 * scale
        if value > -1.0 and value < 1.0:
            value *= hMax
            if value >= hMax:
                value = hMax - 1
            elif value <= -hMax:
                value = -hMax + 1
        value = round(value)
    elif t == "F":
        l = 4
        value = l2 * scale
        if value > -1.0 and value < 1.0:
            value *= fMax
            if value >= fMax:
                value = fMax - 1
            elif value <= -fMax:
                value = -fMax + 1
        value = round(value)
    elif t == "E":
        l = 4
        msw, lsw = toFloatIBM("".join(ast["E"][0]), scale)
        value = msw
    elif t == "D":
        l = 8
        msw, lsw = toFloatIBM("".join(ast["D"][0]), scale)
        value = (msw << 32) | lsw
    elif t == "Y":
        l = 2
        value = l2
    elif t == "Z":
        l = 4
        value = l2
    else:
        error(properties, "Unknown constant-type specifier '%s'" % t)
        return None
    if numerical:
        bytes = bytearray(l)
        for i in range(l - 1, -1, -1):
            bytes[i] = value & 0xFF
            value = value >> 8
    if "L" in ast and len(ast["L"]) > 0:
        # Note that we treat the length modifier as a count of halfwords 
        # rather than bytes, in contradiction to the System/360 assembly-
        # language manual.
        l = 2 * int(ast["L"][0]) 
        if l < len(bytes):
            if numerical:
                bytes = bytes[-l:]
            else:
                bytes = bytes[:l]
        while l > len(bytes):
            if numerical:
                bytes.insert(0, 0)
            else:
                bytes.append(0x40) # EBCDIC space
    operand = "=%s" % t
    if len(ast["L"]) > 0:
        operand += "L%s" % ast["L"][0]
    if "S" in ast and len(ast["S"]) > 0:
        operand += "S%s" % ast["S"][0]
    operand += "'%s'" % "".join(ast[t][0])
    attributes = { "value": l2, "T": t, "L": l, "operand": operand, "assembled": bytes }
    return attributes

#=============================================================================
# `optimizeScratch` analyzes the "scratch" structures created during the 
# "collect" pass, to resolve ambiguities in how those mnemonics which could be
# either SRS instructions or RS instructions are coded.

def optimizeScratch():
    global symtab, sects, literalPools
    
    def adjust(scratch, properties, i):
        entry = scratch[i]
        entry["length"] = 2
        properties["length"] = 2
        entry["ambiguous"] = False
        lastEntry = entry
        for j in range(i+1, len(scratch)):
            entry2 = scratch[j]
            if sect == entry2["sect"]:
                nextPos1 = lastEntry["pos1"] + lastEntry["length"]
                lastEntry = entry2
                if "alignment" in entry2["properties"]:
                    alignment = entry2["properties"]["alignment"]
                    if alignment > 2:
                        rem = nextPos1 % alignment
                        if rem > 0:
                            nextPos1 += alignment - rem
                nextPos2 = nextPos1 // 2
                entry2["pos1"] = nextPos1
                entry2["properties"]["pos1"] = nextPos1
                entry2["pos2"] = nextPos2
                entry2["debug"] = "%05X" % nextPos2
                if "name" in entry2:
                    name = entry2["name"]
                    sym2 = symtab[name]
                    sym2["address"] = nextPos2
                    sym2["value"] = (sym2["value"] & 0xFFFFFFF000000000) | nextPos2
                    sym2["debug"] = "%05X" % sym2["address"]
    
    literalPoolNumber = 0
    for sect in sects:
        scratch = sects[sect]["scratch"]
        previouslyDefined = {}
        for i in range(len(scratch)):
            entry = scratch[i]
            properties = entry["properties"]
            operation = properties["operation"]
            if operation == "EQU":
                if "name" not in entry:
                    continue
                v = evalArithmeticExpression(properties["ast"]["v"], {}, \
                                             properties, symtab, \
                                             symtab[sect]["value"] + entry["pos1"] // 2, \
                                             severity=0)
                n = entry["name"]
                symtab[n]["value"] = v
                s, d = unhash(v)
                if s != None:
                    symtab[n]["section"] = s
                    symtab[n]["address"] = d
                    symtab[n]["dsect"] = sects[s]["dsect"]
                    symtab[n]["properties"] = properties
                continue
            elif operation == "LTORG":
                literalPoolNumber += 1
                continue
            if operation == "BP": ###DEBUG### ###TRAP optimize###
                pass
            properties["length"] = entry["length"]
            if "name" in entry:
                previouslyDefined[entry["name"]] = i
            if not entry["ambiguous"]:
                continue
            # We've found an ambiguous instruction (i.e., SRS vs RS) that we
            # must resolve.  First thing is that we have to parse the operand
            # to determine the target address we want to reach.
            #ast = parserASM(entry["operand"], "rsAll")
            ast = properties["ast"]
            if ast == None or "X2" in ast:
                entry["ambiguous"] = False
                continue
            if "B2" in ast:
                b2 = evalArithmeticExpression(ast["B2"], {}, properties, \
                                              symtab, \
                                              symtab[sect]["value"] + entry["pos1"] // 2, \
                                              severity=0)
                if b2 in [4, 5, 6, 7]:
                    # B2 was really X2.
                    entry["ambiguous"] = False
                    continue
            if "L2" in ast:
                l2 = evalArithmeticExpression(ast["L2"], {}, properties, \
                                              symtab, \
                                              symtab[sect]["value"] + entry["pos1"] // 2, \
                                              severity=0)
                attributes = evalLiteralAttributes(properties, ast, symtab)
                if attributes == None:
                    entry["ambiguous"] = False
                    continue
                literalPool = literalPools[literalPoolNumber]
                try:
                    index = literalPool.index(attributes)
                except:
                    error(properties, "Literal not in literal pool")
                    entry["ambiguous"] = False
                    continue
                offset = literalPool[3][index] + literalPool[1]
                d2 = symtab[literalPool[0]]["value"] + offset // 2
                pass
            elif "D2" in ast:
                d2 = evalArithmeticExpression(ast["D2"], {}, properties, \
                                              symtab, \
                                              symtab[sect]["value"] + entry["pos1"] // 2, \
                                              severity=0)
            if d2 == None:
                entry["ambiguous"] = False
                continue
            section, value = unhash(d2)
            if section == None:
                if "B2" in ast and value >= srsFloor and value < srsCeiling \
                        and operation != "BCT":
                    adjust(scratch, properties, i)
                    continue
                entry["ambiguous"] = False
                continue
            # Special cases that branch backward:
            if section == sect and \
                    (operation in branchAliases or operation in ["BCT", "BC"]):
                d = symtab[sect]["value"] + properties["pos1"] // 2 + 1 - d2
                if d >= srsFloor and d < srsCeiling:
                    adjust(scratch, properties, i)
                    continue
            if operation == "BCT":
                entry["ambiguous"] = False
                continue
            # Check for the case `OPCODE R1,D2`, where `D2` is a location in
            # the current CSECT.
            if section == sect and \
                    (operation in branchAliases or operation == "BC"): # operation not in fpOperations:
                d = value - properties["pos1"] // 2 - 1
                if d >= srsFloor and d < srsCeiling:
                    adjust(scratch, properties, i)
                    continue
            # Check for the case `OPCODE R1,D2`, where `D2` is a location in
            # a CSECT currently in `USING`.
            b = None
            d = 10000000
            for u in entry["using"]:
                if u != None and section == u[1]:
                    if u[2] < d:
                        d = u[2]
                        b = u[1]
            if b != None and d >= srsFloor and d < srsCeiling:
                adjust(scratch, properties, i)
                continue
    return

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
           "AGO", "ANOP", "SPACE", "MEXIT", "MNOTE", "SPON", "SPOFF" }
hexDigits = "0123456789ABCDEF"

'''
Data for the compilation that isn't on a line-by-line basis.  Regarding the
`symtab` dictionary, there's an entry for each symbol, and each entry is 
itself a dictionary.  Each of those dictionaries has a "type" key to indicate 
the general category it falls into, chosen from among the following:

   "EXTERNAL"    Indicates an `EXTRN` symbol.
   "DATA"        Indicates `DS` or `DC`.
   "INSTRUCTION" Indicates a program label.
   "CSECT"       Indicates `CSECT`, `DSECT`, or `START`.
   "EQU"         Indicates `EQU`.
   "LITERAL"     Indicates an integer, boolean, or string constant value.
   ... presumably, more later ...

Note that there is no "type":"ENTRY".  That's because an `ENTRY` symbol will
already have some other type, such as "INSTRUCTION" or "DATA".  Instead, an
`ENTRY` symbol has an extra key, "entry":True.
   
Besides the "type" key, there could be one or more of following keys:
   "section"     (string) Name of the control section containg the symbol.
   "address"     (integer) Halfword ddress of the symbol within the control section.
   "value"       Tricky, so see explanation that follows.

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

# `dcBuffer` is used for assembling a single `DC` pseudo-op.  I don't know the
# maximum amount of data a single `DC` can generate ... but it's a *lot*.
# I've simply chosen a number here that while far less than the maximum, should
# be overkill for Shuttle flight software.
dcBuffer = bytearray(1024)
firstCSECT = None
def generateObjectCode(source, macros):
    global dcBuffer, firstCSECT, literalPools
    
    #-----------------------------------------------------------------------
    # Setup
    
    collect = False
    asis = False
    compile = False
    sect = None # Current section.
    for key in macros:
        ignore.add(key)
    properties = {}
    
    name = ""
    operation = ""
    using = [None]*8
    hashMask = 0xFFFFFFF000000000

    #-----------------------------------------------------------------------
    
    # If a single `USING` is defined, get it.
    def onlyOneUsing():
        found = None
        for i in range(len(using)):
            if using[i] != None:
                if found == None:
                    found = i
                else:
                    return None
        return found
    
    # A function for writing to memory or allocating it without writing to
    # it, as appropriate, though in this case "not writing to it" means 
    # zeroing it.  This occurs in the current CSECT or DSECT
    #    `bytes`        Is either a number (for DS) indicating how much memory
    #                   to allocate, or else a `bytearray` (for DC) of the
    #                   actual bytes to store.
    # Alignment must have been done prior to entry.
    memoryChunkSize = 4096
    defaultChunk = [0xC9]*memoryChunkSize
    for i in range(1, memoryChunkSize, 2):
        defaultChunk[i] = 0xFB
    def toMemory(bytes, alignment = 1):
        nonlocal collect, asis, compile, properties, name, operation
        try:
            pos1 = sects[sect]["pos1"]
        except: ###DEBUG###TRAP###
            pass
        if collect:
            if operation == "DS": ###DEBUG###
                pass
            pos2 = pos1 // 2
            newScratch = {}
            if name != "":
                newScratch["name"] = name
                newScratch["alignment"] = alignment
            if isinstance(bytes, int):
                newScratch["length"] = bytes
            else:
                newScratch["length"] = len(bytes)
            newScratch = newScratch | {
                "ambiguous": (operation in argsSRSandRS or operation == "BCT"),
                "debug": "%05X" % pos2,
                "pos1": pos1,
                "pos2": pos2,
                "sect": sect,
                "operation": operation,
                "operand": operand,
                "properties": properties,
                "using": copy.copy(using)
                }
            sects[sect]["scratch"].append(newScratch)
            properties["scratch"] = newScratch
        #if isinstance(bytes, int):
        #    if bytes == 0:
        #        return
        #else:
        #    if len(bytes) == 0:
        #        return
        properties["section"] = sect
        properties["pos1"] = pos1
        if isinstance(bytes, bytearray):
            end = pos1 + len(bytes)
            if cVsD and compile:
                memory = sects[sect]["memory"]
                while end > len(memory):
                    memory.extend(defaultChunk)
                for i in range(len(bytes)):
                    memory[pos1 + i] = bytes[i]
            properties["assembled"] = bytes
            sects[sect]["pos1"] = end
        else:
            sects[sect]["pos1"] += bytes
        if sects[sect]["pos1"] > sects[sect]["used"]:
            sects[sect]["used"] = sects[sect]["pos1"]

    # Common processing for all instructions. The `alignment` argument is one
    # of 1 (byte), 2 (halfword), 4 (word), 8 (doubleword).
    # The memory added for padding is 0-filled if `zero` is `True`, or left
    # unchanged if `False`.
    def commonProcessing(alignment=1, zero=False):
        global firstCSECT
        nonlocal cVsD, sect, name, operation
        
        # Make sure we're in *some* CSECT or DSECT
        if sect == None:
            cVsD = True
            sect = ""
            firstCSECT = sect
            symtab["_firstCSECT"] = firstCSECT
            if sect not in sects:
                sects[sect] = {
                    "pos1": 0,
                    "used": 0,
                    "memory": bytearray(defaultChunk),
                    "scratch": [],
                    "dsect": False
                    }
        
        # Perform alignment.
        if alignment > 1:
            if alignment > properties["alignment"]:
                properties["alignment"] = alignment
            pos1 = sects[sect]["pos1"]
            rem = pos1 % alignment
            if rem != 0:
                # I used to call toMemory() here to do this, but that can 
                # have unintended side effects such as assigning statements like
                # "DS 0F" a non-zero length.
                if zero:
                    memory = sects[sect]["memory"]
                    for pos1 in range(pos1, pos1 + alignment - rem):
                        memory[pos1] = 0
                else:
                    pos1 += alignment - rem
                sects[sect]["pos1"] = pos1
                if pos1 > sects[sect]["used"]:
                    sects[sect]["used"] = pos1
        
        # Add `name` (if any) to the symbol table.
        if collect and name != "":
            pos2 = sects[sect]["pos1"] // 2
            if name in symtab and "preliminary" not in symtab[name]:
                oldSect = symtab[name]["section"]
                oldPos = symtab[name]["address"]
                if oldSect != sect or oldPos != pos2:
                    error(properties, 
                          "Symbol %s address has changed: (%s,%d) -> (%s,%d)" \
                          % (name, oldSect, oldPos, sect, pos2 ))
            symtab[name].update( { "section": sect,  "address": pos2,
                             "value": symtab[sect]["value"] + pos2,
                             "debug": "%05X" % pos2,
                             "dsect": sects[sect]["dsect"] } )
            if operation in ["DC", "DS"]:
                symtab[name]["type"] = "DATA"
            else:
                symtab[name]["type"] = "INSTRUCTION"
    
    # Gets the hashed address of the current program counter.
    def currentHash():
        return symtab[sect]["value"] + sects[sect]["pos1"] // 2
    
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
        if d2 == None: ###DEBUG###
            pass
        if (d2 & hashMask) in [0, hashMask]:
            return None, (d2 & 0xFFFFFF)
        D2 = None
        B2 = None
        for i in range(len(using)):
            e = using[i]
            if e == None:
                continue
            d = d2 - e[0]
            if d >= 0 and d < 4096:
                # Note that "<=" is required in this test, rather than "<",
                # because the assembler manual states that if two candidate
                # registers result in the same D2, the higher-number register
                # is used.
                if D2 == None or d <= D2:
                    D2 = d
                    B2 = i
        return B2, D2
    
    #-----------------------------------------------------------------------
    # Pass 0
    passCount = 0
    svGlobals["_passCount"] = passCount
    metadata["passCount"] = passCount
    continuation = False
    sect = None
    using = [None]*8
        
    # Process shource code, line-by-line
    for properties in source:
        #******** Should this line be processed or discarded? ********
        if "skip" in properties:
            continue
        if properties["inMacroDefinition"] or properties["fullComment"] or \
                properties["dotComment"] or properties["empty"]:
            continue
        # We only need to look at the first line of any sequence of continued
        # lines.  (Probably obsoleted by "skip".
        if continuation:
            continuation = properties["continues"]
            continue
        continuation = properties["continues"]
        # Various types of lines we can immediately discard by looking at 
        # their `operation` fields
        operation = properties["operation"]
        if operation in ignore:
            continue
        operand = properties["operand"].rstrip()
        if operand != "":
            if operation in appropriateRules:
                ast = parserASM(operand, appropriateRules[operation])
                if ast == None:
                    error(properties, "Could not parse operands")
                properties["ast"] = ast
        
        # We need to create "preliminary" entries in the symbol table, for
        # the sole purpose of providing a temporary way to resolve forward
        # references in statements like "USING symbol,register" on the next
        # pass (which will correct these references).  
        # Also:  The original assembler transparently discarded `EXTRN` 
        # statements for already-defined symbols.  When I say "discarded", I
        # don't just mean "ignored", but that they literally did not appear in
        # the assembly listing.  Thus we have to go to the bother of detecting
        # this condition and dealing with it in the same way.
        if operation == "EXTRN":
            ast = unroll(ast)
            if ast != None and isinstance(ast, str):
                ast = [ast]
                already = set()
                for symbol in ast:
                    if symbol in symtab:
                        already.add(symbol)
                    else:
                        symtab[symbol] = { 
                            "type": "EXTERNAL",
                            "value": getHashcode(symbol),
                            "properties": properties
                             }
                for symbol in already:
                    ast.remove(symbol)
                properties["ast"] = ast
                if len(ast) == 0:
                    properties["empty"] = True
            continue
        if operation in ["EQU"]:
            continue
        if "name" not in properties:
            continue
        name = properties["name"]
        if name in [None, ""]:
            continue
        if operation in ["CSECT", "DSECT"]:
            sect = name
            if sect not in sects:
                sects[sect] = {
                    "pos1": 0,
                    "used": 0,
                    "memory": bytearray(defaultChunk),
                    "scratch": [],
                    "dsect": operation in "DSECT"
                    }
                if sect not in symtab:
                    symtab[sect] = { 
                        "section": sect, 
                        "address": 0, 
                        "type": "CSECT",
                        "value": getHashcode(sect) ,
                        "preliminary": True,
                        "n": properties["n"],
                        "dsect": sects[sect]["dsect"],
                        "properties": properties
                        }
            elif passCount == 3:
                if "references" not in symtab[sect]:
                    symtab[sect]["references"] = []
                symtab[sect]["references"].append(properties["n"])
            continue
        try: 
            pos1 = sects[sect]["pos1"]
        except: ###DEBUG###
            pass
        sects[sect]["pos1"] = pos1 + 4
        symtab[name] = { "section": sect,  "address": pos1,
                         "value": symtab[sect]["value"] + pos1,
                         "alignment": 4,
                         "debug": "%05X" % pos1,
                         "preliminary": True,
                         "n": properties["n"],
                         "dsect": sects[sect]["dsect"], 
                         "properties": properties }
        if operation in ["DC", "DS"]:
            symtab[name]["type"] = "DATA"
        elif False and name in entries:
            symtab[name]["type"] = "ENTRY"
        else:
            symtab[name]["type"] = "INSTRUCTION"
    
    '''
    #-----------------------------------------------------------------------
    # Experimental rework!
    import sieve
    sieve.setup(source, macros)
    while sieve.sieve(source):
        pass
    '''
            
    #-----------------------------------------------------------------------
    # Remaining passes.  In principle these are passes 1 through 3.  However,
    # it is possible for values of symbols defined by EQU to change during
    # pass 3, in which case pass 3 is repeated (through pass 4, 5, ...) until
    # no more changes occur.
    
    repeatPass = False
    passCount = 0
    while passCount < 3 or repeatPass:
        repeatPass = False
        passCount += 1
        metadata["passCount"] = passCount
        svGlobals["_passCount"] = passCount
        collect = (passCount in [1, 2])
        asis = (passCount == 2)
        compile = (passCount >= 3)
        continuation = False
        
        if asis:
            #continue
            sects.clear()
            #symtab.clear()
        else:
            ppos1 = 0
            for sect in sects:
                if sect in symtab:
                    if not sects[sect]["dsect"]:
                        ppos1 += ppos1 & 1
                        symtab[sect]["preliminaryOffset"] = ppos1
                        ppos1 += sects[sect]["used"] // 2
                        # The following is because the "used" field doesn't 
                        # seem to include the litera pool appended to the end
                        # of it, if any.
                        for pool in literalPools:
                            if pool[0] == sect:
                                ppos1 += ppos1 & 1
                                ppos1 += pool[4] // 2
                                break
                sects[sect]["pos1"] = 0
        sect = None
        using = [None]*8
        literalPoolNumber = 0
        # Process shource code, line-by-line
        for propNum in range(len(source)):
            properties = source[propNum]
            
            if "skip" in properties:
                continue
            # We only need to look at the first line of any sequence of continued
            # lines.
            if continuation:
                continuation = properties["continues"]
                continue
            continuation = properties["continues"]
            #******** Should this line be processed or discarded? ********
            if properties["inMacroDefinition"] or properties["fullComment"] or \
                    properties["dotComment"] or properties["empty"]:
                continue
            # Various types of lines we can immediately discard by looking at 
            # their `operation` fields
            operation = properties["operation"]
            if operation in ignore:
                continue
            
            name = properties["name"]
            if name.startswith("."):
                name = ""
            operand = properties["operand"].rstrip()
            if operand == "R7,=XL2'F'": ###DEBUG###
                pass
            
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
                if cVsD and sect == None:
                    firstCSECT = name
                    symtab["_firstCSECT"] = firstCSECT
                if name == "" and not cVsD:
                    error(properties, "Unnamed DSECT not allowed.")
                sect = name
                if sect not in sects:
                    sects[sect] = {
                        "pos1": 0,
                        "used": 0,
                        "memory": bytearray(defaultChunk),
                        "scratch": [],
                        "dsect": not cVsD
                        }
                    if sect not in symtab:
                        symtab[sect] = { 
                            "section": sect, 
                            "address": 0, 
                            "type": "CSECT",
                            "value": getHashcode(sect),
                            "dsect": sects[sect]["dsect"]
                            }
                properties["section"] = sect
                properties["pos1"] = sects[sect]["pos1"]
                continue
            elif operation == "END":
                break
            elif operation in ["ENTRY", "EXTRN"]:
                ast = properties["ast"]
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
                            if symbol in symtab:
                                symtab[symbol]["entry"] = True
                                if passCount == 3:
                                    if "references" not in symtab[symbol]:
                                        symtab[symbol]["references"] = []
                                    symtab[symbol]["references"].append(properties["n"])
                        else:
                            extrns.add(symbol)
                            if symbol not in symtab:
                                symtab[symbol] = {
                                    "type": "EXTERNAL",
                                    "value": getHashcode(symbol)
                                    }
                            rextrns[symtab[symbol]["value"]] = symbol
                continue
            elif operation == "EQU":
                if operand == "*-2" and compile: ###DEBUG###
                    pass
                if name == "":
                    error(properties, "EQU has no name field")
                    continue
                toMemory(0)
                oldValue = None
                if name in symtab:
                    if symtab[name]["type"] != "EQU":
                        error(properties, "EQU name already in use: %s" % name)
                        continue
                    oldValue = symtab[name]["value"]
                ast = properties["ast"]
                if ast == None:
                    error(properties, "Cannot parse operand of EQU")
                    continue
                err, v = evalInstructionSubfield(properties, "v", ast, symtab)
                if operand.startswith("*") and sect != firstCSECT:
                    v = (v & 0xFFFFFF) + symtab[firstCSECT]["value"] + symtab[sect]["preliminaryOffset"]
                if err:
                    error(properties, "Cannot evaluate EQU")
                    continue
                if oldValue != v and compile:  ###DEBUG###
                    repeatPass = True
                symtab[name] = {
                    "type": "EQU",
                    "value": v,
                    "properties": properties
                    }
                vs, vd = unhash(v)
                if vs != None:
                    symtab[name]["section"] = vs
                    symtab[name]["address"] = vd
                    symtab[name]["dsect"] = sects[vs]["dsect"]
                continue
            # For EXTRN see ENTRY.
            elif operation == "LTORG":
                commonProcessing(4)
                #commonProcessing(2)
                if collect:
                    if not asis:
                        ltorg(sect)
                    else:
                        literalPools[literalPoolNumber][1] = sects[sect]["pos1"]
                literalPoolNumber += 1
                continue
            elif operation in ["USING", "DROP"]:
                ast = copy.deepcopy(properties["ast"])
                if ast == None or "r" not in ast or not isinstance(ast["r"], list):
                    error(properties, "Cannot parse operand of " + operation)
                    continue
                rlist = copy.deepcopy(ast["r"])
                for i in range(len(rlist)):
                    rlist[i] = evalArithmeticExpression(rlist[i], {}, \
                                                        properties, \
                                                        symtab, currentHash())
                if operation == "USING":
                    if len(rlist) < 1:
                        error(properties, "No value specified")
                        continue
                    if rlist[0] == None:
                        error(properties, "Bad location")
                        continue
                    else:
                        h = rlist.pop(0)
                        section, address = unhash(h)
                        properties["using"] = address
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
            sects[sect]["pos1"] += sects[sect]["pos1"] & 1
            
            #******** Process instruction ********
            
            # For our purposes, pseudo-ops like `DS` and `DC` that can have labels,
            # modify memory, and move the instruction pointer are "instructions".
            if operation == "DC": #name == "TENSTBL": ###DEBUG###TRAP###
                pass
            startingPos1 = sects[sect]["pos1"]
            if operation in ["DC", "DS"]:
                ast = properties["ast"]
                if ast == None:
                    error(properties, "Cannot parse %s operand" % operation)
                    continue
                flattened = astFlattenList(ast)
                dcBufferPtr = 0
                # At this point, `flattened` should be a list with one entry for
                # each suboperand.  Those suboperands are in the form of 
                # dicts with the keys:
                #    'd'    duplication factor
                #    't'    type
                #    'l'    length modifier
                #    'v'    value
                # Each of these fields will itself be an AST.  The descriptions
                # of how these things are supposed to be interpreted is in the
                # length section "DC -- DEFINE CONSTANT" (pdf p. 46, numbered
                # p. 36) of the assembly-language manual (GC28-6514-8).
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
                            error(properties, "Could not evaluate length modifier")
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
                    elif suboperandType in ["F", "H"]:
                        if suboperandType == "H":
                            length = 2
                            multiplier = 1 << 15
                            mask = 0xFFFF
                        else:
                            length = 4
                            multiplier = 1 << 31
                            mask = 0xFFFFFFFF
                        if lengthModifier != None:
                            commonProcessing(1)
                        else:
                            commonProcessing(length)
                        if lengthModifier != None:
                            pass
                        if operation == "DC":
                            for exp in suboperand["v"]:
                                exp1 = exp[1]
                                if isinstance(exp1, str) and exp1.isdigit():
                                    v = int(exp1) & mask
                                elif isinstance(exp1, tuple) and len(exp1) == 2 \
                                        and exp1[0] == '-' and exp1[1].isdigit():
                                    v = int("".join(exp1)) & mask
                                else:
                                    exp1 = "".join(exp1)
                                    v = float(exp1) * multiplier
                                    if v >= multiplier:
                                        v = multiplier - 1
                                    elif v <= -multiplier:
                                        v = -multiplier + 1
                                    v = int(v) & mask
                                j = (length - 1) * 8
                                for i in range(length):
                                    dcBuffer[dcBufferPtr] = (v >> j) & 0xFF
                                    dcBufferPtr += 1
                                    j -= 8
                            length = dcBufferPtr
                            while duplicationFactor > 1:
                                for i in range(length):
                                    dcBuffer[dcBufferPtr] = dcBuffer[i]
                                    dcBufferPtr += 1
                            toMemory(dcBuffer[:dcBufferPtr])
                            continue
                        toMemory(duplicationFactor * length)
                    elif suboperandType in ["E", "D"]:
                        if suboperandType == "E":
                            fpLength = 4
                        else:
                            fpLength = 8
                        commonProcessing(4)  # Even doublewords are aligned to fullword.
                        if lengthModifier != None:
                            pass
                        length = fpLength
                        if operation == "DC":
                            length = 0
                            values = astFlattenList(suboperand["v"][0][1:-1])
                            for value in values:
                                # We now have to convert the `value` to an 
                                # IBM hexadecimal float, of either single
                                # precision (`fpLength==4`) or double 
                                # precision (`fpLength==8`). 
                                msw, lsw = toFloatIBM(''.join(value))
                                j = 24
                                for i in range(4):
                                    dcBuffer[dcBufferPtr] = (msw >> j) & 0xFF
                                    dcBufferPtr += 1
                                    j -= 8
                                if fpLength == 8:
                                    j = 24
                                    for i in range(4):
                                        dcBuffer[dcBufferPtr] = (lsw >> j) & 0xFF
                                        dcBufferPtr += 1
                                        j -= 8
                            length = dcBufferPtr
                            while duplicationFactor > 1:
                                for i in range(length):
                                    dcBuffer[dcBufferPtr] = dcBuffer[i]
                                    dcBufferPtr += 1
                            toMemory(dcBuffer[:dcBufferPtr])
                            continue
                        toMemory(duplicationFactor * length)
                    elif suboperandType == "A":
                        if lengthModifier != None:
                            commonProcessing(1)
                            pass
                        if operation == "DC":
                            commonProcessing(4)
                            if 'h' in suboperand:
                                lsw = int(suboperand["h"][0][1], 16)
                                j = 24
                                for i in range(4):
                                    dcBuffer[dcBufferPtr] = (lsw >> j) & 0xFF
                                    dcBufferPtr += 1
                                    j -= 8
                                length = dcBufferPtr
                                while duplicationFactor > 1:
                                    for i in range(length):
                                        dcBuffer[dcBufferPtr] = dcBuffer[i]
                                        dcBufferPtr += 1
                                toMemory(dcBuffer[:dcBufferPtr])
                                continue
                            pass
                        
                        toMemory(duplicationFactor * 4)
                    elif suboperandType == "Y":
                        if lengthModifier != None:
                            commonProcessing(1)
                        else:
                            commonProcessing(2)
                        if lengthModifier != None:
                            pass
                        if operation == "DC":
                            for exp in suboperand["v"]:
                                v = evalArithmeticExpression(exp, {}, \
                                                             properties, \
                                                             symtab, \
                                                             currentHash())
                                if v == None:
                                    error(properties, "Cannot evaluate Y-type constant")
                                    v = 0
                                dcBuffer[dcBufferPtr] = (v >> 8) & 0xFF
                                dcBufferPtr += 1
                                dcBuffer[dcBufferPtr] = v & 0xFF
                                dcBufferPtr += 1
                            length = dcBufferPtr
                            while duplicationFactor > 1:
                                for i in range(length):
                                    dcBuffer[dcBufferPtr] = dcBuffer[i]
                                    dcBufferPtr += 1
                            toMemory(dcBuffer[:dcBufferPtr])
                            continue
                        toMemory(duplicationFactor * 2)
                    else:
                        error(properties, 
                              "Unsupported DC/DS type %s" % suboperandType)
                        continue
                dcLength = sects[sect]["pos1"] - startingPos1
                continue
            
            if operation in argsRR:
                commonProcessing(2)
                if not compile:
                    toMemory(2)
                    continue
                if operation == "BR": ###DEBUG###
                    pass
                data = bytearray(2)
                ast = properties["ast"]
                if ast != None:
                    # Make sure we trap some special mnemonics:
                    if operation in ["SPM", "NOPR"]:
                        err = len(ast["R1"]) > 0
                        r1 = 0
                    elif operation == "BR":
                        err = len(ast["R1"]) > 0
                        r1 = 7
                    else:
                        err, r1 = evalInstructionSubfield(properties, "R1", \
                                                          ast, symtab)
                    if not err and r1 >= 0 and r1 <= 7:
                        err, r2 = evalInstructionSubfield(properties, "R2", ast, symtab)
                        lolim = 0
                        uplim = 7
                        if operation in ["LFXI", "LFLI"]:
                            lolim = 0
                            uplim = 15
                            if operation == "LFXI":
                                r2 += 2
                                properties["adr2"] = r2
                        if not err and r2 >= lolim and r2 <= uplim:
                            op = argsRR[operation]
                            data[0] = ((op & 0b111110) << 2) | r1
                            data[1] = 0b11100000 | ((op & 1) << 3) | r2
                toMemory(data)
                continue
                
            if operation in argsSRSorRS:
                commonProcessing(2)
                if operation == "LH": ###DEBUG### ***TRAP SRSorRS***
                    pass
                '''
                We have a conundrum here.  For the mnemonics in argsSRSandRS
                there is both an RS version of the instruction
                (2 halfwords) and an SRS version of the instruction (1 halfword).
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
                if collect and not asis:
                    dataSize = 4
                else:
                    dataSize = properties["length"]
                if operation in operation in argsSRSonly:
                    dataSize = 2
                ast = properties["ast"]
                literalAttributes = None
                if ast == None: ###DEBUG###
                    for p in range(propNum -10, propNum+1):
                        print(p, source[p])
                if "L2" in ast:
                    literalAttributes = evalLiteralAttributes(properties, ast, symtab)
                    if literalAttributes == None:
                        continue
                    if collect and not asis:
                        if literalAttributes not in literalPools[-1]:
                            literalPools[-1].append(literalAttributes)
                    elif literalAttributes in literalPools[literalPoolNumber]:
                        pass
                    else:
                        error(properties, \
                              "Literal has changed value: %s" % str(literalAttributes))
                        continue
                if not compile:
                    toMemory(dataSize)
                    continue
                if operation == "B":
                    pass # ***DEBUG*** ***TRAP compile***
                data = bytearray(dataSize)
                if ast != None:
                    err, r1 = evalInstructionSubfield(properties, "R1", ast, symtab)
                    if r1 == None:
                        # R1 is syntatically omitted for various instructions,
                        # and an implied R1 is used instead.
                        if operation in branchAliases:
                            r1 = branchAliases[operation]
                        elif operation in ["SHW", "SHW@", "SHW#", "SHW@#"]:
                            r1 = 2
                        elif operation in ["SVC", "ZH"]:
                            r1 = 1
                        elif operation in ["SSM", "TS", "LDM", "STDM"]:
                            r1 = 0
                        else:
                            # No matches, fall through to other types of instsructions.
                            pass
                    if r1 != None:
                        if literalAttributes != None:
                            # This can happen only if we already found that 
                            # "L2" is in `ast`, and hence the 2nd operand is
                            # a so-called "literal".
                            pool = literalPools[literalPoolNumber]
                            err = False
                            #d2 = symtab[sect]["value"] + \
                            #     (pool[1] + pool[3][pool.index(literalAttributes)]) // 2
                            d2 = (pool[1] + pool[3][pool.index(literalAttributes)]) // 2
                        else:
                            err, d2 = evalInstructionSubfield(properties, "D2", ast, symtab)
                        originalD2 = d2
                        extrnD2 = (d2 in rextrns)
                        if not err and d2 != None: 
                            properties["adr1"] = d2 & 0xFFFF
                            err, b2 = evalInstructionSubfield(properties, "B2", ast, symtab)
                            if not err: 
                                err, x2 = evalInstructionSubfield(properties, "X2", ast, symtab)
                                if not err:
                                    if operation in ["ST"]: ###DEBUG###TRAP###
                                        pass
                                    atStar = "@" in operation or "#" in operation \
                                        or (b2 != None and b2 > 3)
                                    if atStar and x2 == None:
                                        x2 = b2
                                        b, d = unUsing(using, d2)
                                        if b != None:
                                            b2 = b
                                            d2 = d
                                    done = False
                                    forceRS = (operation in argsRSonly)
                                    forceAM0 = False
                                    forceAM1 = False
                                    if operation in ["BC", "BCT"]:
                                        d = d2 - (currentHash() + 1)
                                        if d < 0 and d > -0b111000:
                                            d = (-d & 0b111111)
                                            data = generateSRS(properties, \
                                                               operation+"B", \
                                                               r1, d, \
                                                               {"BC":0b10, 
                                                                "BCT":0b11}[operation])
                                            done = True
                                    elif operation in branchAliases:
                                        d = d2 - (properties["pos1"] // 2 + symtab[sect]["value"] + 1)
                                        if d >= 0 and d < 0b111000:
                                            d = d & 0b111111
                                            if operation in ["BNC"]:
                                                o = "BVCF"
                                                b = 0b01
                                            else:
                                                o = "BCF"
                                                b = 0b00
                                            data = generateSRS(properties, o, r1, d, b)
                                            done = True
                                        elif d < 0 and d > -0b111000:
                                            d = (-d & 0b111111)
                                            data = generateSRS(properties, "BCB", r1, d, 0b10)
                                            done = True
                                        else:
                                            operation = "BC"
                                            forceRS = True
                                    isConstant = False
                                    specifiedB2 = (b2 != None)
                                    if not done and b2 == None:
                                        # Recall that `findB2D2` returns
                                        #    None,constantValue        or
                                        #    B2,unhashedValue          or
                                        #    None,None                 no match
                                        b2,newd2 = findB2D2(d2)
                                        if b2 == None:
                                            if newd2 == None:
                                                newd2 = d2 - symtab[sect]["value"]
                                                if newd2 >= 0 and newd2 < 4096 \
                                                        and newd2 < sects[sect]["used"] // 2:
                                                    b2 = 3
                                                    d2 = newd2
                                                else:
                                                    section,offset = unhash(d2)
                                                    if section != None:
                                                        forceAM0 = True
                                                    else:
                                                        error(properties, "Cannot determine B2(D2)")
                                                        done = True
                                            else:
                                                isConstant = True
                                                forceRS = True
                                        else:
                                            d2 = newd2
                                    if b2 != None and (b2 < 0 or b2 > 3) and \
                                            operation not in shiftOperations:
                                        if x2 == None and b2 >= 4 and b2 <= 7:
                                            x2 = b2
                                            b2 = None
                                        else:
                                            error(properties, "B2 out of range")
                                            done = True
                                    opcode = argsSRSorRS[operation]
                                    # `forceAM0` is purely empirical.
                                    forceAM0 = forceAM0 or ( (opcode & 1) != 0 \
                                                and b2 not in [3, None] and x2 == None)
                                    if extrnD2:
                                        forceAM0 = True
                                    forceAM1 = forceAM1 or (x2 != None)
                                    if not done:
                                        if operation == "BP": ###DEBUG###TRAP###
                                            pass
                                        # The logic of determining whether we
                                        # have to encode as
                                        #    SRS            vs
                                        #    RS AM=1        vs
                                        #    RS AM=0        
                                        # is quite complex, and we need to 
                                        # precompute a bunch of the values we
                                        # need to use in performing that logic.
                                        unhashedValue = d2 & 0xFFFFFF
                                        ic = sects[sect]["pos1"] // 2
                                        icSRS = ic + 1
                                        icRS = ic + 2
                                        if (opcode & 0b1000000001) == 0:
                                            # The conditional above is entirely
                                            # empirical.
                                            dUnitizer = 2
                                        else:
                                            dUnitizer = 1
                                        if "L2" in ast and dUnitizer == 2 and \
                                                b2 in [None, 3]:
                                            # We have to do this, because there's
                                            # no way for use to know that a 
                                            # literal is an integral number of
                                            # fullword addresses away from the
                                            # current location.
                                            forceRS = True
                                            forceAM0 = True
                                            forceAM1 = False
                                        isNumberD2 = False
                                        rawD2 = unroll(ast["D2"])
                                        if isinstance(rawD2, str) and rawD2.isdigit():
                                            isNumberD2 = True
                                        if isNumberD2:
                                            dSRSa = unhashedValue
                                            dRSAM1 = unhashedValue
                                        else:
                                            dSRSa = unhashedValue - icSRS
                                            dRSAM1 = unhashedValue - icRS
                                        dSRS = (dSRSa + dUnitizer - 1) // dUnitizer
                                        forbiddenSRS = (dSRSa % dUnitizer) != 0
                                        uUnhashedValue = (dUnitizer - 1 + unhashedValue) // dUnitizer
                                        ia = "@" in operation
                                        i =  "#" in operation
                                        if b2 == None:
                                            ib2 = 3
                                        else:
                                            ib2 = b2
                                        if ib2 == 3:
                                            d = dSRS
                                            d1 = dRSAM1
                                        else:
                                            d = uUnhashedValue
                                            d1 = unhashedValue
                                            
                                        #uhSect, uhD2 = unhash(d2)
                                        #uuB2, uuD2 = unUsing(using, d2)
                                        if operation in shiftOperations:
                                            if b2 == None:
                                                d = d2
                                            else:
                                                d = 56 + b2
                                            data = generateSRS(properties, operation, r1, d, shiftOperations[operation])
                                            if "adr1" in properties:
                                                properties.pop("adr1")
                                            properties["adr2"] = d2 & 0x3F
                                        elif operation == "LA" and \
                                                x2 == None and b2 != None \
                                                and d2 > -2048 and d2 < 2048:
                                            if d2 >= 0 and d2 < srsCeiling and len(data) == 2:
                                                data = generateSRS(properties, operation, r1, d2, ib2)
                                            elif d2 < icRS:
                                                # What's happening here is that we
                                                # generate an RS AM=1 instruction,
                                                # but we set the I bit-field to 1
                                                # to cause d2 to be subtracted from
                                                # the updateed IC.
                                                data = generateRS1(properties, operation, 0, 1, r1, icRS - d2, 0, 3)
                                            else: # d2 >= ic + 2
                                                data = generateRS1(properties, operation, 0, 0, r1, d2 - icRS, 0, 3)
                                        elif len(data) == 2  or \
                                               (not (ib2 == 3 and \
                                                     operation in fpOperationsSP) and \
                                                not forceRS and x2 == None and \
                                                (specifiedB2 or ib2 == 3) and \
                                                d >= srsFloor and d < srsCeiling and \
                                                not forbiddenSRS and \
                                                operation in branchAliases):
                                            # Is SRS.
                                            if operation in ["BCB", "BCTB"]: # Backward displacement
                                                d = -d
                                            if operation in ["BC", "BCF"]:
                                                operation = "BCF"
                                                ib2 = 0b00
                                            elif operation == "BVC":
                                                operation = "BVCF"
                                                ib2 = 0b01
                                            elif operation == "BCB":
                                                ib2 = 0b10
                                            elif operation == "BCTB":
                                                ib2 = 0b11
                                            if d >= srsCeiling:
                                                error(properties, "SRS displacement out of range")
                                            if len(data) == 4: ###DEBUG###
                                                pass
                                            data = generateSRS(properties, operation, r1, d, ib2)
                                        elif isConstant and literalAttributes == None:
                                            data = generateRS0(properties, operation, r1, d2 & 0xFFFF, 3)
                                        elif isNumberD2 and b2 != None and x2 == None and not i and not ia:
                                            data = generateRS0(properties, operation, r1, d2 & 0xFFFF, b2)
                                        elif literalAttributes != None:
                                            pool = literalPools[literalPoolNumber]
                                            d1 = (pool[1] + pool[3][pool.index(literalAttributes)]) // 2 \
                                                 - icRS
                                            data = generateRS1(properties, operation, 0, 0, r1, d1, 0, 3)
                                        elif operation in ["BC", "BIX", "BAL"] and x2 in [None, 0] and \
                                                d1 > -2048 and d1 < 0:
                                            if extrnD2:
                                                data = generateRS0(properties, operation, r1, 0, 3)
                                            else:
                                                data = generateRS1(properties, operation, 0, 1, r1, 0x3FF & -d1, 0, ib2)
                                        elif not forceAM0 and \
                                                (x2 != None or ia or \
                                                 i or (d1 >= 0 and d1 < 2048)):
                                            if operation in ["B"]: ###DEBUG###
                                                pass
                                            # RS AM=1 here
                                            if ib2 == 3:
                                                if d1 < 0:
                                                    d1 = -d1
                                                    i = 1
                                            if x2 == None:
                                                x2 = 0
                                            if x2 < 0 or x2 > 7:
                                                error(properties, "X2 out of range")
                                                x2 = 0
                                            data = generateRS1(properties, operation, ia, i, r1, d1, x2, ib2)
                                        elif x2 == None and not ia and not i:
                                            # RS AM=0 here
                                            if operation in ["B", "BZ"]: ###DEBUG###
                                                pass
                                            if b2 != None:
                                                d0 = d2 & 0xFFFF
                                            elif d2 in rextrns:
                                                b2 = 3
                                                d0 = 0
                                            else:
                                                section, offset = unhash(d2)
                                                if section in sects and \
                                                        "offset" in sects[section]:
                                                    d0 = offset # + sects[section]["offset"] - sects[sect]["offset"]
                                                    b2 = 3
                                                if b2 == None:
                                                    error(properties, "Could not interpret operand")
                                                    continue
                                            data = generateRS0(properties, operation, r1, d0, b2)
                                        else:
                                            error(properties, "Could not interpret line as SRS or RS")
                toMemory(data)
                continue
                
            if operation in argsRI:
                commonProcessing(2)
                if not compile:
                    toMemory(4)
                    continue
                data = bytearray(4)
                ast = properties["ast"]
                if ast != None:
                    err, r2 = evalInstructionSubfield(properties, "R2", ast, symtab)
                    if not err and r2 >= 0 and r2 <= 7: 
                        err, i1 = evalInstructionSubfield(properties, "I1", ast, symtab)
                        if not err: 
                            if i1 != None:
                                properties["adr2"] = i1 & 0xFFFF
                            if operation == "SHI":
                                i1 = -i1
                                operation = "AHI"
                            if operation == "LHI":
                                # LHI is not actually an RI instruction, though
                                # it is RI syntactically, but
                                # rather an alias for LA (an RS instruction)
                                # with special field values.
                                op = argsSRSorRS["LA"]
                                data[0] = ((op & 0b1111100000) >> 2) | r2
                                data[1] = 0b11110011 # AM=0, B2=11
                                
                            else:
                                op = argsRI[operation]
                                data[0] = (op & 0b1111111100000) >> 5
                                data[1] = ((op & 0b11111) << 3) | r2
                            i1 &= 0xFFFF
                            data[2] = i1 >> 8
                            data[3] = i1 & 0xFF
                toMemory(data)
                continue
                
            if operation in argsSI:
                commonProcessing(2)
                if not compile:
                    toMemory(4)
                    continue
                data = bytearray(4)
                ast = properties["ast"]
                if ast != None:
                    err, d2 = evalInstructionSubfield(properties, "D2", ast, symtab)
                    if not err:
                        if d2 != None:
                            properties["adr1"] = d2 & 0xFFFF
                        err, b2 = evalInstructionSubfield(properties, "B2", ast, symtab)
                        if not err:
                            if b2 == None:
                                b2, d2 = unUsing(using, d2)
                            if b2 != None and b2 >= 0 and b2 <= 3:
                                err, i1 = evalInstructionSubfield(properties, "I1", ast, symtab)
                                i1 &= 0xFFFF
                                properties["adr2"] = i1
                                d2 &= 0b111111
                                op = argsSI[operation]
                                data[0] = op
                                data[1] = (d2 << 2) | b2
                                data[2] = i1 >> 8
                                data[3] = i1 & 0xFF
                            else:
                                error(properties, "Cannot identify base register")
                toMemory(data)
                continue
                
            if operation in argsMSC:
                # MSC operations are really standardized enough for there to be
                # any advantage in segregating them this way, but it might provide
                # some clarity in maintenance to do so.
                commonProcessing(2)
                ast = properties["ast"]
                if ast != None:
                    toMemory(bytearray(4))
                    continue
                
            if operation in argsBCE:
                # BCE operations are really standardized enough for there to be
                # any advantage in segregating them this way, but it might provide
                # some clarity in maintenance to do so.
                commonProcessing(2)
                ast = properties["ast"]
                if ast != None:
                    toMemory(bytearray(4))
                    continue
                
            error(properties, "Unrecognized line")
            continue
        
        if collect and not asis:
            # Close out the final literal pool
            endOfSource()
            # Rearrange "literals" in the literal pool according to alignment,
            # and figure out their offsets into the pools.
            for pool in literalPools:
                if len(pool) == len(emptyPool):
                    continue
                offset = 0
                pool[2] = 2
                pool[3] = [None] * len(pool)
                pool[4] = 0
                for alignment in [8, 4, 2, 1]:
                    for i in range(len(emptyPool), len(pool)):
                        if pool[3][i] != None:
                            continue
                        if (pool[i]["L"] % alignment) != 0:
                            continue
                        if alignment > pool[2]:
                            pool[2] = alignment
                        rem = offset % alignment
                        if rem != 0:
                            offset += alignment - rem
                        pool[3][i] = offset
                        offset += pool[i]["L"]
                        if offset > pool[4]:
                            pool[4] = offset
                offset = sects[pool[0]]["used"]
                rem = offset % pool[2]
                if rem != 0:
                    offset += pool[2] - rem
                pool[1] = offset
            # Eliminate ambiguity between SRS and RS instructions.
            for sect in sects:
                optimizeScratch()
            if False: ###DEBUG###
                # This prints a stylized form of the source code.  We haven't generated
                # any object code at this point, but we should know all addresses,
                # and showing those in a form easily comparable to the original source
                # code is the goal
                for properties in source:
                    if "pos1" not in properties or properties["pos1"] == None:
                        continue
                    name = ""
                    symAddr = ""
                    if "name" in properties and not properties["name"].startswith("."):
                        name = properties["name"]
                        if name in symtab:
                            symAddr = "%05X" % symtab[name]["address"]
                    msg = "%-10s%5s %05X" % (properties["section"], symAddr, properties["pos1"] // 2)
                    length = properties["length"]
                    if length != None and \
                            properties["operation"] not in ["DS", "CSECT", "DSECT"]:
                        while length > 0:
                            msg += " 0000"
                            length -= 2
                    msg = "%-36s" % msg
                    msg += "%-9s%-6s%s" % (name, properties["operation"], properties["operand"])
                    print(msg)
                sys.exit(1)
            # The previous optimization may have shrunk CSECTs, which
            # may require moving LTORGs downward in memory.  Unfortunately,
            # the optimization operation above hasn't resulted in any free
            # way for us to know the new CSECT sizes.  I just crudely 
            # recalculate it by examining the entire source ... though it's not
            # really a trivial calculation.
            for sect in sects:
                sects[sect]["used"] = 0
                sects[sect]["pos1"] = 0
            for properties in source:
                try:
                    # ###FIXME### This doesn't account for the possibility of 
                    # `ORG` pseudo-ops.
                    sect = properties["section"]
                    alignment = properties["alignment"]
                    pos1 = sects[sect]["pos1"]
                    rem = pos1 % alignment
                    if rem != 0:
                        pos1 += alignment - rem
                    pos1 += properties["length"]
                    sects[sect]["pos1"] = pos1
                    if pos1 > sects[sect]["used"]:
                        sects[sect]["used"] = pos1
                except:
                    pass
            for i in range(len(literalPools)):
                pool = literalPools[i]
                if len(pool) == len(emptyPool):
                    continue
                sect = pool[0]
                usage = sects[sect]["used"]
                offset = pool[1]
                alignment = pool[2]
                if alignment < 2:
                    alignment = 2
                elif alignment > 4:
                    alignment = 4
                while offset - alignment >= usage:
                    offset -= alignment
                pool[1] = offset
        if asis:
            # For reasons I don't grasp, the assembler treats at least some
            # control sections as contiguous.  I don't grasp the rules for 
            # which sections those are.  For *now*, all CSECTs are treated
            # as contiguous (except for fullword realignment in between).
            # The way this is reflectes is that in `sects`, each CSECT (but not
            # DSECT) has a field `offset` that gives its offset (in bytes)
            # with respect to the first CSECT.  It's possible that the only
            # CSECT which should be treated this way is the one whose `CSECT`
            # pseudo-op is immediately preceded by an `LTORG` pseudo-op, or 
            # perhaps one with a special name (like "#L" plus the name of
            # another section), or who knows?  At any rate, this may perhaps
            # be revisited if more info becomes available somehow.
            lastOffset = 0
            for sect in sects:
                if sects[sect]["dsect"]:
                    continue
                sects[sect]["offset"] = lastOffset
                offset = sects[sect]["used"]
                for pool in literalPools:
                    if len(pool) == len(emptyPool):
                        continue
                    if pool[0] == sect:
                        offset = pool[1] + pool[4]
                        break
                lastOffset += offset // 2
                lastOffset = (lastOffset + 1) & 0xFFFFFE
        pass
    
    # Let's append the literal pools to their CSECTs.
    fill = [0xC9, 0xFB]
    for pool in literalPools:
        if len(pool) == len(emptyPool):
            continue
        assembled = sects[pool[0]]["memory"]
        desiredLength = pool[1] + pool[4]
        actualLength = len(assembled)
        if actualLength < desiredLength:
            assembled.extend(bytearray(desiredLength - actualLength))
            for i in range(actualLength, desiredLength):
                assembled[i] = fill[i & 1]
        for i in range(len(emptyPool), len(pool)):
            offset = pool[1] + pool[3][i]
            lassembled = pool[i]["assembled"]
            assembled[offset:offset+len(lassembled)] = lassembled
        sects[pool[0]]["used"] = desiredLength
    
    return metadata
