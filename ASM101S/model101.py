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
            2026-05-21 RSB  Per issue #1320, fixed processing order of RS/SRS
                            instructions.
            2026-05-23 RSB  Allowed for --force-d and --no-force-d.  Fixed
                            issue #1329.
            2026-05-25 RSB  Added check for `currentHash` to cover case of 
                            `EQU` prior to all `CSECT`s.  Added default `EQU`s
                            for `R0` through `R7` to `symtab`.  Other fixes
                            related to issue #1328.
            2026-05-28 RSB  Removed the defaults for `R0` through `R7` again,
                            per issue #1332.
            2026-05-29 RSB  `ORG` implementation (issue #1333).
            2026-05-31 RSB  Added "PRINT" to the `ignore` list.
'''

import sys
import copy
import re
import random
from expressions import error, unroll, astFlattenList, \
    evalArithmeticExpression, svGlobals, describeExpression, \
    selfDefiningTerm, setProgramSymtab
from fieldParser import parserASM
from asciiToEbcdic import asciiToEbcdic, ebcdicToAscii
from ibmHex import *

forceDisplacement = True
if "--force-d" in sys.argv:
    forceDisplacement = True
if "--no-force-d" in sys.argv:
    forceDisplacement = False

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
# THE ORIGINAL BUILD NEVER ENCODED AN SRS *BRANCH* DISPLACEMENT ABOVE 53.
# Measured off the as-received listings, independently of anything here: a
# two-byte encoding of a branch mnemonic is the SRS form and its displacement
# is byte1 >> 2.  Across 803 such encodings in the byte-exact modules the tail
# runs 49:2 50:2 51:1 52:1 53:1 and then stops -- 54 and 55 do not occur.
#
# This is applied where the instruction is ENCODED, not where `optimizeScratch`
# decides, because those see different numbers: the optimizer runs at the end of
# pass 1 against positions that do not yet include any literal pool, so DCICYC's
# `BC 07-1,#@LB260` decides on 48 and encodes 55.  Applying it as a decision
# threshold (srsCeiling = 54) breaks DMOD and takes DCICYC from 1983 mismatched
# bytes to 4756.
#
# Applying it here is safe for everything that already matches: those modules
# ARE the original's bytes, so every SRS branch displacement in them is 53 or
# less and this limit cannot fire.
srsBranchCeiling = 54
# `branchAliases` holds the mnemonics that CARRY their condition -- B, BE, BH
# and their suffixed forms -- and does NOT hold `BC`, which takes its mask as an
# operand.  DCICYC's case is a `BC`, so the limit has to name these too or it
# never fires where it is wanted.
srsBranchOperations = ("BC", "BCF", "BVC", "BVCF", "BCB", "BCT", "BCTB")

random.seed(16134176201611561415)
hashcodeLookup = {}
# The bits of a hashed value that name the symbol, as used by `unhash`.  A
# displacement added to a symbol lands in the low bits, so masking with this
# recovers the symbol the displacement is relative to.
hashcodeMask = 0xFFFFFFF000000000

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
# Rejoin the text of an AST fragment that the parser broke into tokens.  A
# `floatNumber` keeps its sign, digits, fraction and exponent as separate
# tokens, and anything that wants to read the number back as written has to put
# them together again.
def joinTokens(ast):
    if ast == None:
        return ""
    if isinstance(ast, str):
        return ast
    if isinstance(ast, (list, tuple)):
        return "".join(joinTokens(i) for i in ast)
    return str(ast)

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
fillPattern = [0x00, 0x00]  # Uninitialized memory fill; set via --fill

from model101tables import *

sects = {} # CSECTS and DSECTS.
# The internal key of the unnamed dummy section.  Deliberately not a legal
# symbol, so it cannot collide with a section the source names, nor with "",
# which is the unnamed CONTROL section.
unnamedDsect = "*DSECT*"
entries = set() # For `ENTRY`.
extrns = set() # For `EXTRN`.
rextrns = {} # For `EXTRN`
symtab = {}
setProgramSymtab(symtab)   # so T' can reach it; see expressions.py
if False:
    for i in range(8):
        symtab[f"R{i}"] = {
            'type': 'EQU', 
            'value': i, 
            'properties': {
                'section': None, 
                'pos1': None, 
                'length': None, 
                'alignment': None, 
                'text': f"R{i}       EQU     {1}"}
            }
relocations = [] # RLD entries
metadata = {
    "sects": sects,
    "entries": entries,
    "extrns": extrns,
    "rextrns": rextrns,
    "symtab": symtab,
    "relocations": relocations,
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
    if literalIndex(literalPool, attributeDict) == None:
        literalPool.append(copy.deepcopy(attributeDict))

# WHICH ENTRY OF A POOL IS THIS LITERAL, by the text the source wrote --
# `operand` -- and not by the whole attribute dictionary.
#
# Two literals are the same literal when they are written the same way; that is
# what pooling means.  Comparing the dictionaries also compares `value` and
# `assembled`, which is harmless for an absolute literal because those never
# move, and wrong for a RELOCATABLE one because they settle over the passes.
# `=Y(#DDCICYC)` is pooled on the collecting pass with whatever address the
# symbol had then, and looked up on a compile pass with the address it has
# ended up at, so it was never found:  "Literal not in literal pool", and
# "Literal has changed value" at the other site.  Y is the first relocatable
# literal type the grammar admits, which is why nothing met this before.
def literalIndex(literalPool, attributeDict):
    key = attributeDict.get("operand")
    for i in range(len(literalPool)):
        entry = literalPool[i]
        if isinstance(entry, dict) and entry.get("operand") == key:
            return i
    return None
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
        # The scale modifier arrives as a captured LIST, the same shape as
        # `ast["T"]` and `ast[t]` just above, which are both indexed with [0].
        # This one was not, so int() got the list and raised TypeError.
        s = ast["S"]
        if isinstance(s, (list, tuple)):
            s = s[0]
        try:
            scale = pow(2.0, -int(s))
        except (TypeError, ValueError):
            error(properties, \
                  "Cannot evaluate the scale modifier of a literal")
            return None
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
        # Rounded to short precision, not truncated; see roundFloatIBMShort.
        value = roundFloatIBMShort(msw, lsw)
    elif t == "D":
        l = 8
        msw, lsw = toFloatIBM("".join(ast["D"][0]), scale)
        value = (msw << 32) | lsw
    elif t == "Y":
        l = 2
        # Resolved the way `DC Y(...)` resolves its own operand: a relocatable
        # value arrives hashed, and the halfword wanted is the offset within
        # its section plus wherever that section landed.
        value = l2
        ySect, yOffset = unhash(l2)
        if ySect != None:
            value = yOffset + sects.get(ySect, {}).get("offset", 0)
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
    zsymbol = None
    if t == "Z":
        # A Z literal has no quoted value; it carries an address expression
        # and a flags expression, and the pool key has to distinguish two
        # literals that differ only in those.
        a1 = describeExpression(ast["A1"])
        operand += "(,%s,%s)" % (a1, describeExpression(ast["A2"]))
        # The leading identifier of the address expression is the symbol the
        # linker must relocate, exactly as the identifier in `DC Z(sym,...)`
        # is.  Everything after it is the absolute part already in bytes 0-1.
        m = re.match(r"[A-Z@#$][A-Z0-9@#$]*", a1)
        if m:
            zsymbol = m.group(0)
    elif t == "Y":
        # A Y literal is parenthesised too, and its value is an EXPRESSION, so
        # the pool key has to be written the way the source writes it.  The
        # quoted form below would have joined the expression's tokens.
        operand += "(%s)" % describeExpression(ast["Y"][0])
    else:
        operand += "'%s'" % "".join(ast[t][0])
    attributes = { "value": l2, "T": t, "L": l, "operand": operand, "assembled": bytes }
    if zsymbol != None:
        attributes["zsymbol"] = zsymbol
    return attributes

#=============================================================================
# `optimizeScratch` analyzes the "scratch" structures created during the 
# "collect" pass, to resolve ambiguities in how those mnemonics which could be
# either SRS instructions or RS instructions are coded.

def optimizeScratch():
    global symtab, sects, literalPools
    # How many instructions this run shortened, so the caller can iterate to a
    # fixed point instead of guessing a repeat count.
    adjustments = 0

    def adjust(scratch, properties, i):
        nonlocal adjustments
        adjustments += 1
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
                if "name" in entry2 and entry2["name"] in symtab:
                    # A labelled statement whose label is not in the symbol
                    # table YET.  This pass only slides locations about, and a
                    # symbol with no entry has no location to slide; `EQU
                    # FCMBEND-FCMBSTRT` is the shape that gets here, its value
                    # not being computable until both ends are known.  The EQU
                    # pass below sets it.  Indexing unconditionally was a
                    # KeyError that killed nine OI301700 modules outright.
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
                if properties["ast"] == None:
                    # The EQU's operand did not parse, which was diagnosed
                    # where it was parsed.  Subscripting the None here turned
                    # that diagnosis into a traceback.
                    continue
                v = evalArithmeticExpression(properties["ast"]["v"], {}, \
                                             properties, symtab, \
                                             symtab[sect]["value"] + entry["pos1"] // 2, \
                                             severity=0)
                if v == None:
                    # The EQU's operand parsed but could not be evaluated,
                    # which is diagnosed where it was evaluated.  Passing the
                    # None on to unhash() turned that into a TypeError.
                    continue
                n = entry["name"]
                if n not in symtab:
                    # The EQU never made it into the symbol table, which is
                    # what happens when its operand could not be evaluated on
                    # an earlier pass -- `EQU FCMBEND-FCMBSTRT` cannot be,
                    # until both ends have been placed.  This pass is where
                    # the value gets established, so create the entry rather
                    # than index one that is not there; that KeyError killed
                    # nine OI301700 modules outright.
                    symtab[n] = { "type": "EQU", "value": v,
                                  "properties": properties }
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
            if ast == None or "X2" in ast or "noX" in ast:
                # `D2(,B2)` is as unambiguous as `D2(X2,B2)`: both are the
                # indexed form and neither has a short version.
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
                index = literalIndex(literalPool, attributes)
                if index == None:
                    # NOT AN ERROR HERE.  `optimizeScratch` runs at the end of
                    # pass 1 and nowhere else, and the pool it is consulting is
                    # built during that same pass, so a literal whose operand is
                    # a forward reference is legitimately absent at this moment.
                    # All that follows is that this one instruction cannot have
                    # its SRS/RS ambiguity resolved early; the compile passes
                    # resolve it with a complete pool.  Raised at severity 255
                    # it aborted the assembly instead, which is what made
                    # DCICYC's 34 such literals fatal.
                    error(properties, "Literal not in literal pool", \
                          severity = 0)
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
                #print(f"@{section} {value} {d2} {operation} {ast}", file=sys.stderr)
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
            # THE TEST ABOVE IS NOT THE DISPLACEMENT and never was: `u[2]` is
            # where the USING was established, `value` is where the operand
            # is, and only the DISTANCE between them has to fit the SRS field.
            # It shortens when the base happens to CAPTURE small rather than
            # when the displacement happens to BE small, which is why 714 of
            # BILDNEW5's 715 length differences are instructions reached
            # through a USING.
            #
            # It cannot simply be corrected, because `u[2]` and `value` are
            # from different moments.  Measured on the first of those 714,
            # `TH UNPRTFLG` in FAILEXEC:
            #
            #     captured u[2] = 544
            #     symtab now    = FAILDATA 1198, UNPRTFLG 1200
            #
            # so `value - u[2]` is 656 where the truth is 2.  The snapshot was
            # taken while `USING FAILDATA,B0` still named a symbol defined 657
            # cards further on.  RE-EVALUATING THE BASE EXPRESSION HERE gets
            # it right, because by the end of the pass the symbol is placed --
            # which is the whole reason this runs at the end of the pass.
            #
            # Kept as an ADDITIONAL chance rather than a replacement.  The
            # accidental test is load bearing: where the base is still wholly
            # unresolved it captures 0, passes, and shortens correctly for the
            # wrong reason, and modules that are byte-exact today depend on
            # that.  An `or` can only shorten more, never less.
            uBase = None
            uDisp = 10000000
            for r, u in enumerate(entry["using"]):
                if u == None or section != u[1] or len(u) < 5:
                    continue
                usingAst = u[3].get("ast")
                if usingAst == None or "r" not in usingAst or not usingAst["r"]:
                    continue
                try:
                    h2 = evalArithmeticExpression(usingAst["r"][0], {}, u[3], \
                                                  symtab, None, severity=0)
                except:
                    continue
                if h2 == None:
                    continue
                s2, a2 = unhash(h2)
                if s2 != section or a2 == None:
                    continue
                # `address` advanced by 4096 for each register in the USING's
                # list, so this one's window starts that much further on.
                dd = value - (a2 + 4096 * u[4])
                if dd >= 0 and dd < uDisp:
                    uDisp = dd
                    uBase = r
            if (b != None and d >= srsFloor and d < srsCeiling) or \
                    (uBase != None and uDisp >= srsFloor and uDisp < srsCeiling):
                adjust(scratch, properties, i)
                continue
    return adjustments

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
           "AGO", "ANOP", "SPACE", "MEXIT", "MNOTE", "SPON", "SPOFF",
           "PRINT", "ACTR",
           # COPY is acted on during macro expansion, which splices the copied
           # file into the source; the COPY statement itself then reaches the
           # code generator with nothing left to do, exactly as ACTR did.  It
           # was the single commonest diagnostic in the corpus, 2332 of them in
           # five modules alone.  EJECT is listing control and generates
           # nothing either.
           "COPY", "EJECT" }
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

# Fixed value of the R1 field (which is omitted) for certain RS/SRS instructions.
impliedR1 = {
    "SSM":  0x0,
    "LM":   0x4,
    "STM":  0x0,
    "LPS":  0x5,
    "SVC":  0x1,
    "TS":   0x0,
    "STDM": 0x0,
    "LDM":  0x0,
    "SHW":  0x2,
    "TD":   0x0,
    "TH":   0x3,
    "ZH":   0x1
    }
for n in list(impliedR1):
    value = impliedR1[n]
    impliedR1[n+"@"] = value
    impliedR1[n+"@#"] = value
    impliedR1[n+"#"] = value

# `dcBuffer` is used for assembling a single `DC` pseudo-op.  I don't know the
# maximum amount of data a single `DC` can generate ... but it's a *lot*.
# I've simply chosen a number here that while far less than the maximum, should
# be overkill for Shuttle flight software.
#
# It was not overkill.  The Shuttle flight software contains sixteen patch-space
# modules whose entire content is one `DC 594X'C6C6'`, which is 1188 bytes, and
# the buffer grows to fit now rather than refusing to assemble them.
dcBuffer = bytearray(1024)

# Evaluate a DC or DS length modifier and return it in BYTES.
#
# `Ln` is a length in bytes and `L.n` one in BITS (GC28-6514-8).  The whole
# token list, leading 'L' and all, used to be handed straight to the arithmetic
# evaluator, which could make nothing of a bare 'L' -- so EVERY length modifier
# failed, not merely the bit form, and `XL8`, `CL4` and `FL2` were as broken as
# `XL.8`.  RUNASM contains no length modifier at all, which is why 205 of 205
# never noticed; one FCOS module alone produced 312 of the resulting
# diagnostics.
#
# A bit length that is a whole number of bytes is simply that many bytes, which
# covers `L.8` -- by far the commonest form in the corpus, and just a way of
# writing one byte.  Anything else would change how the value is packed and is
# diagnosed rather than approximated.
def evalLengthModifier(properties, tokens):
    tokens = unroll(tokens)
    if isinstance(tokens, str):
        tokens = [tokens]
    tokens = list(tokens)
    if tokens and tokens[0] == "L":
        tokens = tokens[1:]
    bits = False
    if tokens and tokens[0] == ".":
        bits = True
        tokens = tokens[1:]
    sign = 1
    if tokens and tokens[0] in ("+", "-"):
        if tokens[0] == "-":
            sign = -1
        tokens = tokens[1:]
    value = evalArithmeticExpression(tokens, {}, properties)
    if value == None:
        return None
    value *= sign
    if not bits:
        return value
    if value % 8 != 0:
        error(properties, \
              "A bit length modifier that is not a whole number of bytes "
              "(L.%d) reached the byte-oriented path" % value)
        return None
    return value // 8

# The same thing in BITS, for the packed-bit-field path below.  Returns None
# when the modifier was not written as `L.n` at all, so the caller can tell
# `AL.8(...)`, which is a bit specification that happens to be a whole byte,
# from `AL8(...)`, which is a byte count.
# The size in BYTES of one element of a DC/DS suboperand, ignoring the
# duplication factor -- which is what the length attribute L' is built from.
# Returns None when the size cannot be established, and the caller then leaves
# the symbol without a length attribute rather than inventing one.
def dcSuboperandBytes(properties, suboperand):
    try:
        thisType = suboperand["t"][0]
    except:
        return None
    if suboperand.get("l", []) != []:
        # An explicit BIT length is a count of bits, and GC28-6514-8 says L' of
        # a symbol whose length is given by an expression is invalid anyway --
        # so this only rounds the bit form up to whole bytes and otherwise
        # takes the modifier as the byte count it is.
        bits = evalBitLengthModifier(properties, suboperand["l"])
        if bits != None:
            return max(1, (bits + 7) // 8)
        modifier = evalLengthModifier(properties, suboperand["l"])
        if modifier != None:
            return modifier
        return None
    natural = { "F": 4, "E": 4, "A": 4, "Z": 4, "D": 8, "H": 2, "Y": 2,
                "S": 2, "V": 4 }
    if thisType in natural:
        return natural[thisType]
    # The remaining types take their size from the value as written.
    try:
        text = suboperand["v"][0][1]
    except:
        return None
    if thisType == "C":
        return max(1, len(text))
    if thisType == "X":
        return max(1, (len(text.replace(",", "")) + 1) // 2)
    if thisType == "B":
        return max(1, (len(text) + 7) // 8)
    return None

def evalBitLengthModifier(properties, tokens):
    tokens = unroll(tokens)
    if isinstance(tokens, str):
        tokens = [tokens]
    tokens = list(tokens)
    if tokens and tokens[0] == "L":
        tokens = tokens[1:]
    if not tokens or tokens[0] != ".":
        return None
    tokens = tokens[1:]
    sign = 1
    if tokens and tokens[0] in ("+", "-"):
        if tokens[0] == "-":
            sign = -1
        tokens = tokens[1:]
    value = evalArithmeticExpression(tokens, {}, properties)
    if value == None:
        return None
    return sign * value

# Replicate the first `length` bytes of `dcBuffer`, which are one copy of the
# data a DC generates, until the buffer holds `duplicationFactor` copies of
# them.  Returns the resulting buffer length.
#
# All four of the DC paths that need this had written the loop as
#     while duplicationFactor > 1:
#         for i in range(length):
#             dcBuffer[dcBufferPtr] = dcBuffer[i]
#             dcBufferPtr += 1
# with nothing decrementing `duplicationFactor`, so the loop never ended and
# any DC with a factor above 1 copied until it ran off the end of the buffer
# and raised IndexError.  RUNASM has no DC duplication factors at all, which is
# why 205 of 205 never noticed; OI340600 has 165 of `DC 2F'...'` alone.
#
# A factor of zero is legal and generates no data whatever -- it is written to
# fix an alignment or to attach a label and a length attribute -- which the old
# shape also got wrong, by emitting one copy.
def replicateDC(properties, length, duplicationFactor):
    global dcBuffer
    if duplicationFactor <= 0:
        return 0
    total = length * duplicationFactor
    if total > len(dcBuffer):
        # Grow rather than refuse.  The buffer is a working area, not a limit
        # the language imposes, and treating it as one turned sixteen ordinary
        # patch-space modules into failures.
        dcBuffer = dcBuffer + bytearray(total - len(dcBuffer))
    pointer = length
    for copy in range(duplicationFactor - 1):
        for i in range(length):
            dcBuffer[pointer] = dcBuffer[i]
            pointer += 1
    return pointer

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
    defaultChunk = [fillPattern[i & 1] for i in range(memoryChunkSize)]
    def toMemory(bytes, alignment = 1):
        nonlocal collect, asis, compile, properties, name, operation
        if sect is None or sect not in sects:
            return
        pos1 = sects[sect].get("pos1", 0)
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
        if isinstance(bytes, bytearray):
            end = pos1 + len(bytes)
            if cVsD and compile:
                memory = sects[sect]["memory"]
                while end > len(memory):
                    memory.extend(defaultChunk)
                for i in range(len(bytes)):
                    memory[pos1 + i] = bytes[i]
            # ACCUMULATE ACROSS THE SUBOPERANDS OF ONE STATEMENT.  toMemory is
            # called once per suboperand, and both `pos1` and `assembled` used
            # to be overwritten by each call, so a statement was recorded as
            # its LAST suboperand alone -- `DC X'1122',X'33'` listed as
            # `00001 33`.  Everything downstream believed that: the listing
            # printed one suboperand, and --compare checked one suboperand and
            # left the others unexamined against the original build.
            #
            # A new statement, or a new pass over the same one, starts the run
            # again; a suboperand that continues where the last left off
            # extends it.  A gap -- alignment inserted between suboperands --
            # is filled from memory so the run stays contiguous, which is what
            # the consumers assume.
            samePass = properties.get("_assembledPass") == passCount
            if samePass and properties.get("_assembledEnd") != None and \
                    pos1 >= properties["_assembledEnd"] and \
                    pos1 - properties["_assembledEnd"] < 16 and \
                    "assembled" in properties:
                run = properties["assembled"]
                gap = pos1 - properties["_assembledEnd"]
                if gap > 0:
                    memory = sects[sect]["memory"]
                    for i in range(gap):
                        a = properties["_assembledEnd"] + i
                        run.append(memory[a] if a < len(memory) and \
                                   memory[a] != None else 0)
                run.extend(bytes)
                properties["assembled"] = run
            else:
                properties["pos1"] = pos1
                properties["assembled"] = bytearray(bytes)
            properties["_assembledEnd"] = end
            properties["_assembledPass"] = passCount
            sects[sect]["pos1"] = end
        else:
            properties["pos1"] = pos1
            sects[sect]["pos1"] += bytes
        if sects[sect]["pos1"] > sects[sect]["used"]:
            sects[sect]["used"] = sects[sect]["pos1"]

    # Common processing for all instructions. The `alignment` argument is one
    # of 1 (byte), 2 (halfword), 4 (word), 8 (doubleword).
    # The memory added for padding is 0-filled if `zero` is `True`, or left
    # unchanged if `False`.
    def commonProcessing(alignment=1, zero=False):
        global firstCSECT
        nonlocal repeatPass
        nonlocal cVsD, sect, name, operation
        nonlocal nameAssigned
        
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
        #
        # ON EVERY PASS, not only the collecting ones.  Instruction lengths are
        # still settling during the compile passes -- `repeatPass` exists
        # precisely because they are -- and a label recorded only while
        # collecting therefore keeps a position from before the instruction
        # ahead of it grew.  FCMNINIT's `#@LB1` was recorded at 00041, inside
        # the four-byte SSM that precedes it, while its listing address is
        # 00042; every branch to it was then one halfword short.
        # ONCE PER STATEMENT.  `commonProcessing` runs once per SUBOPERAND of a
        # `DC`, and it recorded the label at whatever the location counter had
        # reached, so a multi-suboperand constant walked its own label forward
        # through itself.  DCI#DATA's
        #
        #     DCIDOUT  DC  Y(DCIDOUT+2),Y(DCIDOUT+508),510H'0'
        #
        # sits at 000A4 and left DCIDOUT holding 0000A6.  Every value in the
        # module was computed against a different base: the first Y saw 00A4
        # and came out right, the second saw 00A5 and emitted 02A1 for the
        # original's 02A0, and a `DC Y(DCIDOUT)` elsewhere saw the 00A6 left
        # behind and emitted that for the original's 00A4.  Three bases, one
        # statement, which is why the module looked like two unrelated
        # off-by-small errors.
        if name != "" and not nameAssigned:
            nameAssigned = True
            pos2 = sects[sect]["pos1"] // 2
            if name in symtab and "preliminary" not in symtab[name]:
                oldSect = symtab[name]["section"]
                oldPos = symtab[name]["address"]
                if oldSect != sect or oldPos != pos2:
                    # A LABEL THAT MOVES ASKS FOR ANOTHER PASS.  It is not an
                    # error: instruction lengths are still settling, so a label
                    # naturally shifts, and every instruction ALREADY assembled
                    # on this pass used its old value.  Raising a diagnostic
                    # and carrying on leaves those instructions wrong.
                    #
                    # This never fired anyway.  The guard above asks for
                    # "preliminary" not to be in the entry, and nothing ever
                    # removes that flag once the preliminary pass sets it, so
                    # the whole check was dead for every label in the corpus.
                    #
                    # FIOPDHF is what it costs.  `BC 07-4,#@LB3` is assembled
                    # at halfword 13 while #@LB3 still holds 45 from the pass
                    # before; the label then settles to 44 further down the
                    # same pass, and the branch keeps a displacement one too
                    # large.  Its own listing prints the label at 00044 and the
                    # branch reaching 00045.
                    if compile:
                        repeatPass = True
            symtab[name].pop("preliminary", None)
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
        try:
            return symtab[sect]["value"] + sects[sect]["pos1"] // 2
        except:
            return 0
    
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
            # QUIET ON THE COLLECTING PASSES.  A subfield naming a symbol
            # defined further down the module cannot be evaluated on pass 1,
            # and that is what the later passes are for; reporting it at
            # severity 255 there aborted the assembly before it could reach
            # them.  29 OI301700 modules had subfield errors on pass 1 and on
            # no later pass, which is what identifies them as premature.  A
            # subfield that is still unevaluable when compiling is reported
            # exactly as before.
            error(properties, "Could not evaluate %s subfield" % subfield, \
                  severity = 255 if compile else 0)
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
        
    # Process source code, line-by-line
    for properties in source:
        #******** Should this line be processed or discarded? ********
        # A card already CONSUMED as a continuation still has to update the
        # flag, because its own column 72 says whether the card after it
        # continues too.  Returning early on "skip" left the flag set from the
        # statement that started the sequence, so the next real statement was
        # taken for a continuation and silently dropped -- its operand never
        # parsed, its `ast` left None, and the only symptom a "Cannot parse"
        # further down.  It bites the SECOND of two continued statements in a
        # row, which is why FCMINSSL assembles its first command-word skeleton
        # and neither of the two after it.
        if "skip" in properties:
            continuation = properties["continues"]
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
                    # Name the operand and the rule.  This message used to say
                    # only "Could not parse operands", which identifies
                    # neither what failed nor which grammar rejected it, and
                    # it is one of the two commonest diagnostics in the FCOS
                    # corpus.
                    error(properties, \
                          "Could not parse the operand of %s against rule " \
                          "'%s': %s" % (operation, \
                                        appropriateRules[operation], operand))
                    properties["astFailed"] = True
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
        # AN UNNAMED DSECT STILL SWITCHES SECTIONS.  The guard below skips any
        # statement without a label, which is right for everything except this:
        # a bare `DSECT` carries no name and was therefore skipped BEFORE the
        # section switch, so `sect` stayed at the enclosing CSECT and every
        # symbol in the dummy section was given a preliminary address inside
        # the control section.
        #
        # The main pass already gives it `unnamedDsect`, deliberately not a
        # legal symbol so it cannot collide with "" -- the unnamed CONTROL
        # section -- and this pass simply never learned the same trick.
        #
        # FCMBMASK is what it costs.  `USING TFBMP,R0` resolves TFBMP to
        # FCMBMASK+272 on pass 1 and to *DSECT*+0 on every pass after, and
        # `optimizeScratch` runs at the END of pass 1 against the pass-1
        # snapshot, so the arm that would have shortened `LH R4,TBMPVAR` could
        # never match its section.  The original assembles it 9C04, two bytes;
        # we emitted the four-byte 9CF0 0001 and every later address was a
        # halfword out.
        if operation == "DSECT" and name in [None, ""]:
            name = unnamedDsect
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
        if sect is None or sect not in sects:
            continue
        pos1 = sects[sect].get("pos1", 0)
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
    # BOUNDED.  A layout that oscillates rather than settling would otherwise
    # spin here forever; 20 is far above anything the corpus needs, the worst
    # observed being 6.
    while passCount < 3 or (repeatPass and passCount < 20):
        repeatPass = False
        passCount += 1
        # THE RELOCATIONS BELONG TO THE PASS THAT PRODUCED THEM.  They used to
        # be recorded on pass 3 exactly and never cleared, which was safe only
        # while pass 3 was always the last.  It no longer is: a label that moves
        # now asks for another pass, so a module can run to 4 or beyond and would
        # have kept addresses from a layout that later shifted.  Clearing here and
        # recording on every compile pass leaves the final pass's set standing.
        relocations.clear()
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
                # See the note on the same line in the preliminary pass above.
                continuation = properties["continues"]
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
            if properties.get("astFailed", False):
                # The operand did not parse, which was diagnosed where it was
                # parsed.  There is nothing to generate from a null AST, and
                # going on regardless is what turned that diagnosis into a
                # traceback -- `if "L2" in ast` on a None, and a bare
                # `properties["ast"]` lookup on a line that never had one.  The
                # condition holds identically on every pass, so skipping here
                # does not put the passes out of step with each other.
                continue

            name = properties["name"]
            if name.startswith("."):
                name = ""
            # A LABEL IS PLACED ONCE PER STATEMENT, not once per suboperand;
            # see `commonProcessing`.
            nameAssigned = False
            # AND THE STATEMENT'S OBJECT CODE BELONGS TO THIS PASS.  `toMemory`
            # accumulates into `assembled` and restarts the run when the pass
            # changes, which is right for a statement that emits something --
            # but a statement that emits NOTHING on this pass never calls
            # `toMemory` at all, so last pass's bytes simply stayed, and the
            # listing and --compare both read them.
            #
            # FCMSSYNC's `CNOP 2` is the case: on the compile pass it sits at
            # an even halfword address and correctly pads nothing, yet still
            # showed D800 from a pass on which it did pad, printed at 00020
            # where the `XR R7,R7` that follows also prints.  The comparison
            # counted the D800 and the original has 77E7 there.
            properties.pop("assembled", None)
            properties.pop("_assembledEnd", None)
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
                    # The name field of DSECT may be blank.  FCMBMASK's
                    # listing assembles one at statement 786.  It is the only
                    # module in either version that writes one -- one card, so
                    # this rejected an entire module over a single statement.
                    # A blank name defines the one UNNAMED dummy section,
                    # which any later blank-named DSECT continues.
                    # It needs an internal name only because "" is already the
                    # unnamed CONTROL section and merging the two would put
                    # dummy storage in the object.  The name below is not a
                    # legal symbol, so no source can name the section -- which
                    # is correct, since a blank name is exactly what makes it
                    # unnameable.  Symbols defined inside it still work; they
                    # carry their section with them.
                    name = unnamedDsect
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
                # EQU's optional second and third operands GIVE the symbol its
                # length and type attributes outright, rather than the
                # assembler deducing them from a DC or DS.  That is how the
                # position symbols are built: PDEF writes
                # `&N.X EQU &X,&X+1025,C'@'`, and the POS macro then reads
                # L'&N.X.  The value of the second operand is stored exactly as
                # written -- it is not a halfword count and must not be scaled
                # like the one a DC or DS implies.  The third is a character
                # self-defining term whose value IS the type character.
                if len(ast.get("len", [])) > 0:
                    lv = evalArithmeticExpression(ast["len"][0], {}, properties,
                                                  symtab, currentHash(),
                                                  severity = 0)
                    if lv != None:
                        symtab.setdefault(name, {})["lengthAttribute"] = lv
                if len(ast.get("typc", [])) > 0:
                    tc = joinTokens(ast["typc"][0])
                    ok, tv = selfDefiningTerm("C'%s'" % tc)
                    if ok:
                        symtab.setdefault(name, {})["typeAttribute"] = tc[:1]
                elif len(ast.get("typ", [])) > 0:
                    tv = evalArithmeticExpression(ast["typ"][0], {}, properties,
                                                  symtab, currentHash(),
                                                  severity = 0)
                    if tv != None and 0 <= tv < 256:
                        symtab.setdefault(name, {})["typeAttribute"] = \
                            ebcdicToAscii[tv] if tv < len(ebcdicToAscii) \
                            else "U"
                if operand.startswith("*") and sect != firstCSECT:
                    # `EQU *` in a section other than the first has to be
                    # converted from section-relative to absolute.  A DSECT
                    # is the exception and must be left alone: it is a
                    # template describing the shape of storage somebody else
                    # owns, it occupies no address of its own, and
                    # `preliminaryOffset` is deliberately not computed for
                    # one.  Reaching for it anyway was a KeyError and the
                    # commonest crash in the FCOS corpus -- five lines
                    # reproduce it, a DSECT with an `EQU *` in it.
                    if sects.get(sect, {}).get("dsect", False):
                        pass
                    elif sect is None or firstCSECT is None:
                        # `EQU *` before any CSECT has been opened, which is
                        # how issue #1333 met this line: KeyError(None) rather
                        # than KeyError('preliminaryOffset'), same statement.
                        # Nothing precedes it, so there is nothing to add.
                        pass
                    elif "preliminaryOffset" not in symtab.get(sect, {}):
                        error(properties, \
                              "EQU * appears in section %s, whose position " \
                              "has not been established; the value is left " \
                              "relative to that section" % sect)
                    else:
                        v = (v & 0xFFFFFF) + symtab[firstCSECT]["value"] \
                            + symtab[sect]["preliminaryOffset"]
                if err:
                    # Quiet on the collecting passes: an EQU whose operands are
                    # defined further down is ordinary, and FIOADCCL's
                    # `ICCLGTH EQU ICCEND-ICCSTRT` is exactly that.
                    if compile:
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
                if collect and not asis:
                    ltorg(sect)
                elif literalPoolNumber < len(literalPools):
                    # RE-RECORD THE POOL'S POSITION ON EVERY LATER PASS, not
                    # only the collecting ones.  This update sat inside
                    # `if collect:`, so the position was frozen at whatever
                    # pass 2 computed and the COMPILE passes -- the ones that
                    # get it right -- never corrected it.
                    #
                    # In FCMNINIT pass 2 puts the LTORG at 001CA and pass 3 at
                    # 001D2, which is where the original build has it.  The
                    # pool was therefore written 16 bytes early, straight over
                    # FCM25MS and FCMDLTIM.  Nothing was missing from the
                    # module; only the pool was misplaced.
                    literalPools[literalPoolNumber][1] = sects[sect]["pos1"]
                    # AND ADVANCE PAST IT.  `commonProcessing(4)` aligns the
                    # location counter and nothing moved it over the pool's own
                    # bytes, so whatever followed an LTORG was assembled on top
                    # of the literals.  FIOLGERR puts two Z constants after its
                    # LTORG and both landed at 00086, the address of the
                    # `=X'000007FF'` the pool holds; the original has them at
                    # 00088.
                    #
                    # This was invisible in 242 of 272 modules because their
                    # LTORG is the last statement that occupies space, so the
                    # overlap had nothing to collide with.
                    # `pos1` ONLY, DELIBERATELY NOT `used`.  Everywhere else
                    # those two move together, but "used" is documented at the
                    # between-passes bookkeeping above as NOT including a
                    # trailing pool, and that code adds `pool[4]` back to get a
                    # section's true length.  Forcing "used" here would make a
                    # TRAILING pool count twice and move every following CSECT:
                    # CTOE's #LCTOE went from 00140 to 00154, exactly its
                    # pool's 40 bytes, and eight RUNASM modules broke.
                    #
                    # Left alone, "used" still grows by itself for an INTERIOR
                    # pool, because the statements after the LTORG advance past
                    # it and carry "used" with them.
                    poolBytes = literalPools[literalPoolNumber][4]
                    if poolBytes:
                        sects[sect]["pos1"] += poolBytes
                literalPoolNumber += 1
                continue
            elif operation in ["USING", "DROP"]:
                ast = copy.deepcopy(properties["ast"])
                if operation == "DROP" and properties["operand"].strip() == "":
                    # A DROP WITH NO OPERAND DROPS EVERY ACTIVE BASE REGISTER.
                    # No source card in the corpus writes one, but a macro
                    # generates one -- FIOCMPLT meets it in an expansion -- and
                    # it arrived here as a null AST and was rejected as
                    # unparseable.
                    for _r in range(len(using)):
                        using[_r] = None
                    continue
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
                for k, r in enumerate(rlist):
                    if r == None or r < 0 or r > 7:
                        error(properties, "Bad register number")
                    elif operation == "USING":
                        # THE BASE EXPRESSION IS CARRIED ALONG, with this
                        # register's place in the USING's register list.  The
                        # resolved `address` beside it is a SNAPSHOT taken
                        # here, and where the base is a forward reference that
                        # snapshot is wrong by however far the symbol later
                        # moves -- FAILEXEC's `USING FAILDATA,B0` names a
                        # symbol defined 657 cards later and captures 544 for
                        # a location that ends pass 1 at 1198.  Nothing can be
                        # done about that HERE, because the symbol genuinely
                        # is not known yet; `optimizeScratch` re-evaluates
                        # this expression at the end of the pass, when it is.
                        using[r] = (h, section, address, properties, k)
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
            if sect is None or sect not in sects:
                error(properties, "Instruction outside of control section (undefined macro '%s'?)" % operation)
                continue
            sects[sect]["pos1"] += sects[sect]["pos1"] & 1
            
            #******** Process instruction ********
            
            # For our purposes, pseudo-ops like `DS` and `DC` that can have labels,
            # modify memory, and move the instruction pointer are "instructions".
            if operation == "DC": #name == "TENSTBL": ###DEBUG###TRAP###
                pass
            startingPos1 = sects[sect]["pos1"]
            if operation == "ORG":
                ast = properties["ast"]
                try:
                    if "here" in ast:
                        offset = 0
                    elif "plus" in ast:
                        offset = int(ast["dec"])
                    else:
                        offset = -int(ast["dec"])
                except:
                    error(properties, "Cannot parse %s operand" % operation)
                    continue
                newPos = startingPos1 + 2 * offset
                if newPos < 0:
                    error(properties, "ORG out of range", \
                          severity = 255 if compile else 0)
                    continue
                sects[sect]["pos1"] = newPos
                if newPos > sects[sect]["used"]:
                    sects[sect]["used"] = newPos
                if name != "":
                    if False and offset != 0:
                        error(properties, "Labels can be applied only for ORG *" % operation)
                    symtab[name]["value"] = (symtab[name]["value"] & 0xFFFFFFFF00000000) | (newPos // 2)
                continue
                
            elif operation in ["DC", "DS"]:
                ast = properties["ast"]
                if ast == None:
                    error(properties, \
                          "Cannot parse %s operand: %s" \
                          % (operation, repr(properties["operand"])))
                    continue
                flattened = astFlattenList(ast)
                dcBufferPtr = 0

                # THE LENGTH ATTRIBUTE, L'.  GC28-6514-8 page 15 defines it as
                # the length of the storage the symbol names -- `A1 DS CL8`
                # gives L'A1 = 8 -- taken from the FIRST suboperand and
                # ignoring the duplication factor.  There it is a count of
                # BYTES.  Here it is a count of HALFWORDS, because the AP-101S
                # is halfword-addressed and every other term of the expressions
                # L' appears in is in halfwords too.
                #
                # FIOCBLKS establishes that without reference to any manual.
                # Its `DC (TIOQPRI-(TIOQSELF+L'TIOQSELF))H'0'` runs from 000A4
                # to 000A9 in the original listing, so the duplication factor
                # is 5; with TIOQPRI-TIOQSELF = 7 that forces L'TIOQSELF to 2,
                # and TIOQSELF is `DS F`, four bytes.  asm101 computes it the
                # same way and says so in as many words.
                # Recorded only into an entry that already exists -- the
                # preliminary pass makes one for every named DC/DS -- so that a
                # name arriving here without one still fails where it used to
                # rather than acquiring a symbol table entry with nothing in it
                # but a length.
                if name in symtab and len(flattened) > 0:
                    lengthBytes = dcSuboperandBytes(properties, flattened[0])
                    if lengthBytes != None:
                        symtab[name]["lengthAttribute"] = \
                            max(1, (lengthBytes + 1) // 2)

                # BIT-LENGTH CONSTANTS, `DC AL.8(a),AL.5(b),AL.4(c),AL.15(d)`.
                # The operands are packed CONTIGUOUSLY, without regard to byte
                # boundaries, and the last byte is padded with zeros.  An
                # explicit length modifier also suppresses the alignment the
                # type would otherwise force.
                #
                # This is confirmed by the original build rather than assumed:
                # FCMINSSL's three command-word skeletons are
                # AL.8(FCMMSYNC=0), AL.5(FCMMIUA=B'01011'), AL.4 of an op-code
                # and AL.15(FCMMZERO=0), and the listing assembles them to
                # 00580000, 005C8000 and 00598000 -- which is what contiguous
                # packing of 8+5+4+15 bits gives and nothing else does.
                bitLengths = []
                packed = False
                for suboperand in flattened:
                    b = None
                    if suboperand.get("l", []) != []:
                        b = evalBitLengthModifier(properties, suboperand["l"])
                    bitLengths.append(b)
                    if b != None:
                        # ANY bit-length modifier packs, not only one that is
                        # not a whole byte.  `DC XL.8'24',YL.8(a-b)` is two
                        # bytes in the original build and was three here: the
                        # test below was `b % 8 != 0`, so a pair of L.8 fields
                        # missed the packing path entirely and the Y constant
                        # generated its natural halfword.
                        packed = True
                if packed:
                    commonProcessing(1)
                    bits = []
                    failed = False
                    for suboperand, width in zip(flattened, bitLengths):
                        if width == None or width <= 0:
                            # AN OPERAND WITHOUT A BIT-LENGTH MODIFIER IS NOT
                            # PART OF THE PACKING.  It is not an error either:
                            # the packed run that precedes it is padded out to
                            # a byte boundary and the plain constant is laid
                            # down at its own natural length, which is what
                            # GC28-6514-8 says and what the original build
                            # does.  BILDNEW5's
                            #     RDENVPTR DC AL.16(ENVIRONS),X'0001'
                            # assembles to 80000001 there -- the address
                            # constant's two bytes, then the hex constant's
                            # two -- and refusing the statement is how that
                            # module used to lose it.
                            width = dcSuboperandBytes(properties, suboperand)
                            if width == None or width <= 0:
                                error(properties, \
                                      "Cannot determine the length of a " \
                                      "constant packed beside bit-length ones")
                                failed = True
                                break
                            width *= 8
                            while len(bits) % 8 != 0:
                                bits.append(0)
                        if suboperand["d"] == []:
                            repeats = 1
                        else:
                            repeats = evalArithmeticExpression( \
                                          suboperand["d"], {}, properties, \
                                          symtab, currentHash(), \
                                          severity = 255 if compile else 0)
                            if repeats == None:
                                error(properties, \
                                      "Could not evaluate duplication factor")
                                failed = True
                                break
                        values = suboperand.get("v", [])
                        # HOW THE VALUE ARRIVES DEPENDS ON THE TYPE.  An
                        # address constant is parenthesised and may hold
                        # several expressions -- `[('(', expr, [], ')')]` --
                        # while a quoted one is a single literal in the shape
                        # `[("'", '24', "'")]`.  Slicing parentheses off a
                        # quoted constant produced a malformed AST and the
                        # message "Implementation error: AST for X{',',X} not
                        # appropriate", which is how BILDNEW5 and MENU12 fail.
                        thisType = suboperand["t"][0]
                        literal = None
                        if thisType in ("A", "Y", "Z", "S", "V"):
                            try:
                                inner = astFlattenList(values[0][1:-1])
                            except:
                                inner = astFlattenList(values)
                        else:
                            inner = []
                            try:
                                if thisType == "X":
                                    literal = int(values[0][1].replace(",", ""), 16)
                                elif thisType == "B":
                                    literal = int(values[0][1].replace(",", ""), 2)
                                elif thisType in ("F", "H"):
                                    # `quotedFloatList` hands back the sign and
                                    # the digits as SEPARATE tokens, so `-38`
                                    # arrives as ('-', '38') rather than as a
                                    # string.  `int()` of that raises, `literal`
                                    # stayed None and the statement was rejected
                                    # -- which is why every negative packed
                                    # constant failed while the positive ones
                                    # beside them assembled.  MENU12 writes 29
                                    # of them, `DC BL.5'10000',FL.11'-38'` and
                                    # the like.
                                    #
                                    # A COMMA IS NOT COSMETIC HERE, unlike in an
                                    # X constant: inside F or H it separates
                                    # whole constants, and this path packs one
                                    # value into one field.  Fail rather than
                                    # concatenate the digits into a number that
                                    # appears nowhere in the source.
                                    # `quotedFloatList` is
                                    # ["'", first, [more...], "'"], so the
                                    # extra values sit in element 2 and an
                                    # empty list there means there is just one.
                                    if values[0][2]:
                                        literal = None
                                    else:
                                        literal = int(joinTokens(values[0][1]))
                            except:
                                literal = None
                            if literal == None:
                                error(properties, \
                                      "Cannot pack a %s constant of this form " \
                                      "into a bit field" % thisType)
                                failed = True
                                break
                            inner = [None]
                        for expression in inner:
                            if literal != None:
                                v = literal
                            else:
                                # QUIET ON THE COLLECTING PASSES.  This site
                                # took the default severity of 255, so a plain
                                # forward reference was fatal on pass 1 even
                                # though pass 3 resolves it -- FIOCBLKS uses
                                # `AL.4(FIOMEBCC)` four statements before the
                                # `FIOMEBCC EQU B'0011'` that defines it.  The
                                # rest of the DC path already evaluates this
                                # way; only the bit-packing branch did not.
                                v = evalArithmeticExpression(expression, {}, \
                                                             properties, symtab, \
                                                             currentHash(), \
                                                             severity = \
                                                               255 if compile \
                                                               else 0)
                            if v == None:
                                if compile:
                                    error(properties, \
                                          "Cannot evaluate a bit-length constant")
                                failed = True
                                break
                            section, offset = unhash(v)
                            if section != None:
                                v = offset + \
                                    sects.get(section, {}).get("offset", 0)
                            for _ in range(repeats):
                                for shift in range(width - 1, -1, -1):
                                    bits.append((v >> shift) & 1)
                        if failed:
                            break
                    if failed:
                        continue
                    while len(bits) % 8 != 0:      # pad the last byte
                        bits.append(0)
                    data = bytearray(len(bits) // 8)
                    for i, bit in enumerate(bits):
                        if bit:
                            data[i // 8] |= 0x80 >> (i % 8)
                    if operation == "DC":
                        toMemory(data)
                    else:
                        toMemory(len(data))
                    continue
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
                    # RESET THE BUFFER FOR EACH SUBOPERAND.  `toMemory` is
                    # called once per suboperand, so whatever a suboperand
                    # leaves in `dcBuffer` must not be written again by the
                    # next one.  Only some of the type handlers zeroed the
                    # pointer themselves, so `DC X'1401D058',H'0'` wrote
                    # 1401D058 at offset 0 and then 1401D0580000 at offset 4 --
                    # ten bytes for a six-byte constant, with the X repeated.
                    dcBufferPtr = 0
                    if suboperand["d"] == []:
                        duplicationFactor = 1
                    else:
                        # WITH THE SYMBOL TABLE.  A duplication factor may
                        # be a parenthesised expression naming symbols --
                        # `DC (TTIOTNUM*2)H'0'`, `DC (TTQELNTH-1)C'TQ'` -- and
                        # this was evaluating it against an EMPTY symtab, so
                        # every such symbol was undefined by construction and
                        # seven modules could not assemble.  Quiet on the
                        # collecting passes, since the symbol may be defined
                        # further down.
                        duplicationFactor = \
                            evalArithmeticExpression(suboperand["d"], {}, \
                                                     properties, symtab, \
                                                     currentHash(), \
                                                     severity = \
                                                       255 if compile else 0)
                        if duplicationFactor == None:
                            if compile:
                                error(properties, \
                                      "Could not evaluate duplication factor")
                            continue
                    try:
                        suboperandType = suboperand["t"][0]
                    except:
                        error(properties, "Suboperand type not specified")
                        continue

                    # Z type has a different field layout (z/f, not l/v) -
                    # handle it before common l/v processing.
                    if suboperandType == "Z":
                        # ZCons: DC Z(symbol,,flags)
                        # Format: 4 bytes, fullword-aligned
                        # Creates an external reference with relocation
                        commonProcessing(4)
                        if operation == "DC":
                            # Get the symbol name from the 'z' field, or --
                            # for the `Z(,expression,flags)` form, which has no
                            # such field -- from the leading identifier of the
                            # expression, exactly as the `=Z(,...)` literal
                            # does.  Without this the constant still assembles
                            # to the right bytes but carries NO relocation, so
                            # the linker never fills its address in.
                            symbolName = suboperand.get('z')
                            # The expression form, `Z(sym+n,...)`: the symbol
                            # to relocate is its leading identifier, exactly as
                            # for the `Z(,expr,flags)` form below, and the
                            # address is the whole expression's value.
                            zxExpression = None
                            if not symbolName and suboperand.get('zx'):
                                zxExpression = suboperand['zx'][0]
                                mzx = re.match(r"[A-Z@#$][A-Z0-9@#$]*", \
                                               describeExpression(zxExpression))
                                if mzx:
                                    symbolName = mzx.group(0)
                            # THE `Z(,expr,flags)` FORM CARRIES ITS ADDRESS IN
                            # THAT EXPRESSION and only the SYMBOL was being
                            # taken from it, so any displacement was dropped and
                            # the address field emitted as zero.
                            # FIOMM128's `DC Z(,FIOMUWB1+8192,0)` wants 2000 and
                            # assembled 0000; FIOMGDSP's `Z(,FIOBRU+4,0)` wants
                            # 0004.  A LOCAL symbol shows it too -- FIOMM128's
                            # `Z(,FIOMACNS+36,8)` is 00F4 where FIOMACNS alone
                            # is 00D0, exactly 36 short.
                            a1Expression = None
                            if not symbolName and suboperand.get('A1'):
                                a1 = describeExpression(suboperand['A1'])
                                mz = re.match(r"[A-Z@#$][A-Z0-9@#$]*", a1)
                                if mz:
                                    symbolName = mz.group(0)
                                    a1Expression = suboperand['A1']
                            flags = 0
                            if 'f' in suboperand and suboperand['f'] is not None:
                                flags = evalArithmeticExpression(suboperand['f'], {},
                                                                 properties, symtab,
                                                                 currentHash())
                                if flags is None:
                                    flags = 0

                            if symbolName:
                                # Add to externs if not already declared
                                if symbolName not in symtab:
                                    extrns.add(symbolName)
                                    symtab[symbolName] = {
                                        "type": "EXTERNAL",
                                        "value": getHashcode(symbolName)
                                    }
                                    rextrns[symtab[symbolName]["value"]] = symbolName
                                elif symtab[symbolName].get("type") != "EXTERNAL":
                                    if symbolName not in extrns:
                                        extrns.add(symbolName)

                                if compile:
                                    pos1 = sects[sect]["pos1"]
                                    relocations.append({
                                        'symbol': symbolName,
                                        'section': sect,
                                        'address': pos1,
                                        'flags': flags,
                                        'type': 'Z'
                                    })

                            # emit 4 bytes: [address, address, flags, 0]
                            # Bytes 0-1: Address
                            # Byte 2: Flags
                            # Byte 3: Reserved
                            #
                            # A LOCALLY DEFINED SYMBOL GETS ITS ADDRESS HERE.
                            # Zero is right only when the linker will fill the
                            # field, which is to say when the symbol is
                            # external.  FCMG3INT's
                            # `DC Z(FCG3INL1,FCMCBLKS,X'D')` names a label of
                            # its own at 0B, and the one below it names FCG3INL2
                            # at 42; the original build assembles those
                            # addresses and ASM101S assembled 0000 for both.
                            zAddress = 0
                            # `zx` is the `Z(sym+n,...)` form and `A1` the
                            # `Z(,sym+n,...)` one; both put the address in an
                            # expression and both resolve the same way.
                            zaExpression = zxExpression \
                                           if zxExpression != None \
                                           else a1Expression
                            if zaExpression != None:
                                zv = evalArithmeticExpression( \
                                        zaExpression, {}, properties, symtab, \
                                        currentHash(), \
                                        severity = 255 if compile else 0)
                                if zv != None:
                                    zxSect, zxOffset = unhash(zv)
                                    zAddress = zxOffset + \
                                        sects.get(zxSect, {}).get("offset", 0) \
                                        if zxSect != None else zv
                            zEntry = symtab.get(symbolName) if symbolName \
                                     else None
                            if zaExpression != None:
                                pass          # already resolved just above
                            elif zEntry != None and \
                                    zEntry.get("type") != "EXTERNAL":
                                zSect, zOffset = unhash(zEntry.get("value", 0))
                                if zSect != None:
                                    zAddress = zOffset + \
                                        sects.get(zSect, {}).get("offset", 0)
                                else:
                                    zAddress = zEntry.get("address", 0)
                            dcBuffer[dcBufferPtr] = (zAddress >> 8) & 0xFF
                            dcBufferPtr += 1
                            dcBuffer[dcBufferPtr] = zAddress & 0xFF
                            dcBufferPtr += 1
                            dcBuffer[dcBufferPtr] = flags & 0xFF
                            dcBufferPtr += 1
                            dcBuffer[dcBufferPtr] = 0
                            dcBufferPtr += 1
                            toMemory(dcBuffer[:dcBufferPtr])
                        else:
                            # DS Z - just reserve 4 bytes
                            toMemory(duplicationFactor * 4)
                        continue

                    if suboperand.get("l", []) == []:
                        lengthModifier = None
                    else:
                        lengthModifier = \
                            evalLengthModifier(properties, suboperand["l"])
                        if lengthModifier == None:
                            error(properties, \
                                  "Could not evaluate the length modifier '%s'" \
                                  % describeExpression(suboperand["l"]))
                            continue
                    astValue = suboperand.get("v")
                    if suboperandType == "C":
                        # Character constants used to generate NOTHING here --
                        # no bytes, no advance of the location counter, and no
                        # diagnostic either.  RUNASM contains no `DC C'...'`
                        # anywhere, so 205 of 205 never showed it.
                        commonProcessing(1)
                        if operation == "DC":
                            quoted = suboperand["v"][0]
                            text = quoted[1]
                            for piece in quoted[2]:
                                # "''" inside a string is one quote.
                                text += "'" + piece[1]
                            text = text.replace("&&", "&")
                            if lengthModifier != None:
                                # Padded on the RIGHT with blanks, or truncated
                                # on the right, which is what distinguishes a
                                # character constant from the numeric types.
                                text = text[:lengthModifier]
                                text += " " * (lengthModifier - len(text))
                            dcBufferPtr = 0
                            for character in text:
                                dcBuffer[dcBufferPtr] = \
                                    asciiToEbcdic[ord(character)]
                                dcBufferPtr += 1
                            length = dcBufferPtr
                            dcBufferPtr = replicateDC(properties, length, \
                                                      duplicationFactor)
                            toMemory(dcBuffer[:dcBufferPtr])
                            continue
                        length = lengthModifier
                        if length == None:
                            length = len(suboperand["v"][0][1])
                        toMemory(duplicationFactor * length)
                        continue
                    elif suboperandType == "X":
                        commonProcessing(1)
                        # Adjust the string to have an even number of digits,
                        # 0-padded or truncated to the length modifier, if any.
                        try:
                            # `flattened[0]`, not `suboperand`: the FIRST
                            # suboperand of the statement rather than the one
                            # being generated.  `DC Y(0),X'000000020000'`
                            # therefore fetched the Y constant's value for the
                            # X constant, and every X constant that is not the
                            # first operand of its DC was wrong or refused.
                            # Commas inside a hex constant separate FULLWORDS
                            # for the reader and are not part of the value.
                            # Every one of the 658 such constants across both
                            # PASS versions is written in groups of exactly
                            # eight digits, so concatenating them is right for
                            # all of them -- but that also means the corpus
                            # cannot distinguish concatenation from padding
                            # each group to a fullword on its own.  A constant
                            # whose groups are NOT uniform would tell the two
                            # apart, and none exists, so say so rather than
                            # guess.
                            hexString = suboperand["v"][0][1]
                            if "," in hexString:
                                widths = {len(g) for g in hexString.split(",")}
                                if len(widths) > 1 or widths != {8}:
                                    error(properties, \
                                          "The groups of this hexadecimal " \
                                          "constant are not all one fullword; " \
                                          "whether they concatenate or are " \
                                          "each padded separately is not " \
                                          "established, and the object code " \
                                          "here may be WRONG")
                            hexString = hexString.replace(",", "")
                            if lengthModifier == None:
                                count = len(hexString)
                                # An odd number of digits is padded to an even
                                # one.  This was `count % 1`, which is zero
                                # for every integer there is, so it never
                                # padded anything.
                                count += (count & 1)
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
                            if not isinstance(hexString, str):
                                # Whatever was found is not the digit string
                                # this path assumes.  The message used to
                                # blame comma-separated groups, which was a
                                # guess and was usually wrong -- the real
                                # cause was the `flattened[0]` above.
                                error(properties, \
                                      "Cannot parse the hexadecimal value of " \
                                      "%s: %s" % (operation, repr(hexString)))
                                continue
                            # THE DUPLICATION FACTOR USED TO BE IGNORED HERE,
                            # and only here -- every other constant type
                            # applies it.  `DC 594X'C6C6'` therefore generated
                            # one halfword instead of 594 of them, silently.
                            # The whole of PCH27SRC and its fifteen siblings
                            # are a single such statement, patch space filled
                            # with C6, so each of them was short by 1186
                            # bytes.
                            dcBufferPtr = 0
                            for i in range(0, count, 2):
                                dcBuffer[dcBufferPtr] = \
                                    int(hexString[i:i+2], 16)
                                dcBufferPtr += 1
                            dcBufferPtr = replicateDC(properties, dcBufferPtr, \
                                                      duplicationFactor)
                            toMemory(dcBuffer[:dcBufferPtr])
                        else:
                            toMemory(duplicationFactor * (count // 2))
                    elif suboperandType == "B":
                        commonProcessing(1)
                        # THIS WAS A STUB -- `commonProcessing(1)` and nothing
                        # else -- so `DC B'...'` emitted no bytes AND reserved
                        # no space, silently.  A bit-length modifier goes to the
                        # packing path above and never arrives here, which is
                        # why the form that IS common in the corpus worked and
                        # the plain one did not.
                        #
                        # FIOCBLKS writes 81 of them, `TBCD0000 DC B'0000...'`
                        # and its fellows, each a full word; the original build
                        # assembles 324 bytes that ASM101S did not assemble at
                        # all.
                        #
                        # A binary constant is padded or truncated on the LEFT,
                        # like the other numeric types.
                        try:
                            digits = suboperand["v"][0][1]
                        except:
                            error(properties, "Cannot parse B value")
                            continue
                        if lengthModifier != None:
                            nBytes = lengthModifier
                        else:
                            nBytes = max(1, (len(digits) + 7) // 8)
                        digits = digits.rjust(nBytes * 8, "0")[-nBytes * 8:]
                        if operation == "DC":
                            dcBufferPtr = 0
                            for i in range(0, nBytes * 8, 8):
                                dcBuffer[dcBufferPtr] = int(digits[i:i+8], 2)
                                dcBufferPtr += 1
                            dcBufferPtr = replicateDC(properties, dcBufferPtr, \
                                                      duplicationFactor)
                            toMemory(dcBuffer[:dcBufferPtr])
                        else:
                            toMemory(duplicationFactor * nBytes)
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
                            # Honour it, rather than the `pass` that used to
                            # stand here and left F and H at their natural 4
                            # and 2 bytes however they were written.
                            if lengthModifier < 1:
                                error(properties, \
                                      "Length modifier %d is out of range" % \
                                      lengthModifier, \
                                            severity = 255 if compile else 0)
                                continue
                            length = lengthModifier
                            multiplier = 1 << (8 * length - 1)
                            mask = (1 << (8 * length)) - 1
                        # THE SCALE MODIFIER moves the binary point: the value
                        # is multiplied by two to the MINUS scale before being
                        # taken as a fraction of the full word.  Checked
                        # against the original build, which assembles
                        # `DC FS4'10'` as 50000000 -- 10 x 2^-4 is 0.625, and
                        # 0.625 x 2^31 is 0x50000000 -- `DC FS20'100000'` as
                        # 0C350000, and `DC FS-19'1E-6'` as 431BDE83.  That
                        # last comes out right only when the product is
                        # ROUNDED rather than truncated, which is what the
                        # literal path has always done.
                        scaleFactor = 1.0
                        if suboperand.get("s", []) != []:
                            sv = unroll(suboperand["s"])
                            if isinstance(sv, str):
                                sv = [sv]
                            digits = "".join(x for x in sv if x != "S")
                            try:
                                scaleFactor = pow(2.0, -int(digits))
                            except:
                                error(properties, \
                                      "Cannot evaluate the scale modifier")
                                continue
                        if operation == "DC":
                            # `suboperand["v"]` holds ONE quotedFloatList, and
                            # every value after the first lives inside its
                            # repetition element.  Iterating it directly saw
                            # only `exp[1]`, the first, so `DC F'1,2'` silently
                            # generated just the 1 -- and once the duplication
                            # factor worked, `DC 2F'1,2'` silently generated
                            # 1,1.  The E/D path below already flattened it
                            # properly; this is the same shape.
                            for exp1 in astFlattenList(suboperand["v"][0][1:-1]):
                                # A SCALE MODIFIER APPLIES TO A WHOLE NUMBER
                                # TOO.  It is not that S cannot appear on an
                                # integer -- `DC FS4'10'` is exactly that --
                                # nor that it may be ignored there.  It must be
                                # applied: ten under a scale of four is 0.625
                                # of a fullword, 50000000, not the integer ten.
                                # The fast path for digit-only values silently
                                # dropped it.
                                if scaleFactor == 1.0 and \
                                        isinstance(exp1, str) and exp1.isdigit():
                                    v = int(exp1) & mask
                                elif scaleFactor == 1.0 and \
                                        isinstance(exp1, tuple) and len(exp1) == 2 \
                                        and exp1[0] == '-' and exp1[1].isdigit():
                                    v = int("".join(exp1)) & mask
                                else:
                                    exp1 = "".join(exp1)
                                    # THE SCALED VALUE IS TAKEN AS A FRACTION OF
                                    # THE FIELD ONLY WHEN IT IS ONE, which is
                                    # the rule `evalLiteralAttributes` has
                                    # always applied to the identical constant
                                    # written as a literal, and this path did
                                    # not: it multiplied by the field width
                                    # unconditionally.  `DC F'1800E6'` is
                                    # 1800000000, a fullword integer with room
                                    # to spare, and became 1.8e9 x 2^31 clamped
                                    # to 7FFFFFFF.
                                    #
                                    # IT IS NOT "UNSCALED MEANS INTEGER".  That
                                    # was tried and it broke CTOI, ETOC, ITOC
                                    # and KTOC, all of which write `DC F'0.625'`
                                    # with no scale modifier at all and expect
                                    # 50000000.  Magnitude decides it, not the
                                    # presence of an S:  0.625 is a fraction,
                                    # 1800E6 is a count, and `DC FS4'10'` is
                                    # 0.625 once the scale has been applied.
                                    v = float(exp1) * scaleFactor
                                    if v > -1.0 and v < 1.0:
                                        v *= multiplier
                                        if v >= multiplier:
                                            v = multiplier - 1
                                        elif v <= -multiplier:
                                            v = -multiplier + 1
                                    v = round(v) & mask
                                j = (length - 1) * 8
                                for i in range(length):
                                    dcBuffer[dcBufferPtr] = (v >> j) & 0xFF
                                    dcBufferPtr += 1
                                    j -= 8
                            length = dcBufferPtr
                            dcBufferPtr = replicateDC(properties, length, \
                                                      duplicationFactor)
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
                                if fpLength == 4:
                                    # A short constant keeps only the top 24
                                    # bits of the fraction, and the original
                                    # ROUNDS the rest rather than dropping it.
                                    msw = roundFloatIBMShort(msw, lsw)
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
                            dcBufferPtr = replicateDC(properties, length, \
                                                      duplicationFactor)
                            toMemory(dcBuffer[:dcBufferPtr])
                            continue
                        toMemory(duplicationFactor * length)
                    elif suboperandType == "A":
                        if lengthModifier != None:
                            commonProcessing(1)
                        elif operation != "DC":
                            # `DS A` reached NEITHER of the commonProcessing
                            # calls below, and commonProcessing is what
                            # replaces a label's PRELIMINARY value with its
                            # real one.  So every `DS A` label kept the
                            # placeholder the preliminary pass gave it, which
                            # is 4 bytes times the number of labels before it
                            # in the section -- TCVTIOQ came out as 220, being
                            # the 56th label in TFCVT, where it belongs at 78.
                            # Its listing address was right the whole time;
                            # only the symbol table was wrong, so instructions
                            # referring to it got a displacement out of range
                            # and were assembled long.  It also never got the
                            # fullword alignment an A-type constant is due.
                            commonProcessing(4)
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
                                dcBufferPtr = replicateDC(properties, length, \
                                                          duplicationFactor)
                                toMemory(dcBuffer[:dcBufferPtr])
                                continue
                            # `DC A(expression)` NEVER EMITTED ITS VALUE.  Only
                            # the `A'hexadecimal'` form above wrote anything;
                            # the ordinary parenthesised form fell through to
                            # the `toMemory(count)` below, and that call only
                            # ADVANCES the location counter -- toMemory writes
                            # into memory only when handed a bytearray.  So the
                            # four bytes were never assigned and the comparison
                            # reported them missing.
                            #
                            # It went unnoticed because an A constant inside a
                            # DSECT generates no object code to compare, and
                            # that is where most of them are.  FIOMGTQE's
                            # `FIOMMTXD DC A(FIOMMCTM)` is in the CSECT: the
                            # original assembles 00030D40, being the 200000 its
                            # EQU gives, and ASM101S assembled nothing at all.
                            for exp in astFlattenList(suboperand["v"][0][1:-1]):
                                v = evalArithmeticExpression(exp, {}, \
                                                             properties, symtab, \
                                                             currentHash(), \
                                                             severity = \
                                                               255 if compile \
                                                               else 0)
                                if v == None:
                                    if compile:
                                        error(properties, \
                                              "Cannot evaluate A-type constant")
                                    v = 0
                                aSect, aOffset = unhash(v)
                                if aSect != None:
                                    v = aOffset + \
                                        sects.get(aSect, {}).get("offset", 0)
                                    # AND IT NEEDS AN RLD ENTRY.  Emitting the
                                    # resolved value satisfies a comparison
                                    # against the LISTING, which shows that
                                    # value whether or not the constant
                                    # relocates -- so the sweep cannot see this
                                    # missing and did not.  A link can:  without
                                    # it an A constant naming an external symbol
                                    # is never relocated.  objectWriter gives
                                    # anything that is not Y or Z the 4-byte
                                    # flags, 0x1C, which is what this wants.
                                    if compile:
                                        rldSymbol = aSect
                                        for sn, sd in sects.items():
                                            if sd.get("dsect") or \
                                                    "offset" not in sd:
                                                continue
                                            so = sd["offset"]
                                            su = sd["used"] // 2
                                            if v >= so and v < so + su \
                                                    and sn != sect:
                                                rldSymbol = sn
                                                break
                                        relocations.append({
                                            'symbol': rldSymbol,
                                            'section': sect,
                                            'address': sects[sect]["pos1"] \
                                                       + dcBufferPtr,
                                            'type': 'A'
                                        })
                                for j in (24, 16, 8, 0):
                                    dcBuffer[dcBufferPtr] = (v >> j) & 0xFF
                                    dcBufferPtr += 1
                            length = dcBufferPtr
                            dcBufferPtr = replicateDC(properties, length, \
                                                      duplicationFactor)
                            toMemory(dcBuffer[:dcBufferPtr])
                            continue

                        toMemory(duplicationFactor * 4)
                    elif suboperandType == "Y":
                        if lengthModifier != None:
                            commonProcessing(1)
                        else:
                            commonProcessing(2)
                        if lengthModifier != None:
                            pass
                        if operation == "DC":
                            # As in the integer path above, every address after
                            # the first lives inside the repetition element of
                            # a single `addresses`, so iterating "v" directly
                            # handed the whole `( e1, [[',',e2],...] , )` tuple
                            # to the evaluator.  `DC Y(L1,L2)` therefore
                            # produced one halfword and an "Eval error type 3"
                            # rather than two addresses.
                            for exp in astFlattenList(suboperand["v"][0][1:-1]):
                                # QUIET ON THE COLLECTING PASSES.  A Y constant
                                # may name a symbol EQU'd further down the
                                # module -- FCMBMT02's `DC Y(FCMCNT)` at line
                                # 328 against `FCMCNT EQU 52` at line 837 --
                                # which is exactly what the later passes are
                                # for.  Reporting it at severity 255 on pass 1
                                # aborted the assembly over a symbol that was
                                # in the table, with the right value, by the
                                # end.  58 modules were blocked by forward
                                # references of this kind.
                                v = evalArithmeticExpression(exp, {}, \
                                                             properties, \
                                                             symtab, \
                                                             currentHash(), \
                                                             severity = \
                                                               255 if compile \
                                                               else 0)
                                if v == None:
                                    if compile:
                                        error(properties, \
                                              "Cannot evaluate Y-type constant")
                                    v = 0
                                ySect, yOffset = unhash(v)
                                if ySect == None:
                                    # A NEGATIVE OFFSET FROM AN EXTERNAL SYMBOL
                                    # borrows out of the 32-bit offset field
                                    # into the four-bit buffer above it, and
                                    # `unhash` returns None,None for any value
                                    # whose buffer is dirty.  The relocation
                                    # below was therefore never emitted and the
                                    # low sixteen bits fell through raw:
                                    # FCMCBLKS' `DC Y(CZ2VNOMB-1)` assembled
                                    # FFFF where the original has 0001.  The
                                    # hashcode itself survives the borrow, so
                                    # the symbol is still recoverable.
                                    #
                                    # THE ORIGINAL EMITS THE MAGNITUDE, not the
                                    # two's complement -- eight instances, six
                                    # at -1 in FCMCBLKS and two at -2 in
                                    # FIOMDPPG, and the field is an unsigned
                                    # address the linker adds the symbol to.
                                    # Positive offsets are untouched and go on
                                    # matching, as FIOPDIPG's dozens do.
                                    # A hashcode is `random << 36`, so a bare
                                    # symbol has zeros below bit 36 and
                                    # subtracting from it borrows out of the
                                    # HASHCODE, not out of the buffer field:
                                    # `hash - n` is `((random-1) << 36) +
                                    # (2**36 - n)`.  The symbol is therefore
                                    # the one whose hashcode is one greater.
                                    _yHash = (v & hashcodeMask) + (1 << 36)
                                    _yLow = v & 0xFFFFFFFFF
                                    if _yHash in hashcodeLookup and \
                                            _yLow >= (1 << 35):
                                        ySect = hashcodeLookup[_yHash]
                                        yOffset = abs(_yLow - (1 << 36))
                                if ySect is not None and compile:
                                    combinedOffset = yOffset + sects.get(ySect, {}).get("offset", 0)
                                    # Resolve actual CSECT from combined offset
                                    rldSymbol = ySect
                                    for sn, sd in sects.items():
                                        if sd.get("dsect") or "offset" not in sd:
                                            continue
                                        so = sd["offset"]
                                        su = sd["used"] // 2
                                        if combinedOffset >= so and combinedOffset < so + su and sn != sect:
                                            rldSymbol = sn
                                            break
                                    yAddr = sects[sect]["pos1"] + dcBufferPtr
                                    relocations.append({
                                        'symbol': rldSymbol,
                                        'section': sect,
                                        'address': yAddr,
                                        'type': 'Y'
                                    })
                                    v = combinedOffset
                                dcBuffer[dcBufferPtr] = (v >> 8) & 0xFF
                                dcBufferPtr += 1
                                dcBuffer[dcBufferPtr] = v & 0xFF
                                dcBufferPtr += 1
                            length = dcBufferPtr
                            dcBufferPtr = replicateDC(properties, length, \
                                                      duplicationFactor)
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
                    err = False    # The mnemonics below supply R1 themselves,
                                   # and left `err` holding whatever the last
                                   # RR instruction assembled had put there --
                                   # or unset, if they came first.
                    if operation in ["SPM"]:
                        if "r1" in ast and len(ast["r1"]) != 0:
                            error(properties, f"Cannot specify register R1.")
                        r1 = 0
                    elif operation in rrBranchAliases:
                        # `BR`, `NOPR`, `BZR` and the rest are all `BCR` with
                        # the condition mask written into the mnemonic, so the
                        # single operand is R2 and R1 must not be given.
                        if "r1" in ast and len(ast["r1"]) != 0:
                            error(properties, f"Cannot specify condition.")
                        r1 = rrBranchAliases[operation]
                    else:
                        err, r1 = evalInstructionSubfield(properties, "R1", \
                                                          ast, symtab)
                    if err or r1 < 0 or r1 > 7:
                        error(properties, 
                              f"Invalid register R1; must be 0-7")
                        r1 = 0
                    err, r2 = evalInstructionSubfield(properties, "R2", ast, symtab)
                    if operation == "LFXI":
                        if err or r2 < -2 or r2 > 13:
                            error(properties, 
                                  f"Invalid immediate value; must be -2 through 13")
                            r2 = -2
                            err = False
                        r2 = (r2 + 2) & 0x0F
                        properties["adr2"] = r2
                    elif operation == "LFLI":
                        if err or r2 < 0 or r2 > 15:
                            error(properties, 
                                  f"Invalid immediate value; must be 0-15")
                            r2 = 0
                            err = False
                        r2 &= 0x0F
                    elif err or r2 < 0 or r2 > 7:
                        error(properties, 
                              f"Invalid register R2; must be 0-7")
                        r2 = 0
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
                if operation in argsSRSonly:
                    dataSize = 2
                ast = properties["ast"]
                literalAttributes = None
                if ast == None:
                    # An RS/SRS mnemonic with no operand field at all, so
                    # there was nothing to parse and nothing to generate from.
                    # This used to print the surrounding lines and then fall
                    # straight into `"L2" in ast` and raise TypeError.
                    error(properties, \
                          "%s requires an operand" % operation)
                    continue
                if "L2" in ast:
                    literalAttributes = evalLiteralAttributes(properties, ast, symtab)
                    if literalAttributes == None:
                        continue
                    if collect and not asis:
                        if literalIndex(literalPools[-1], \
                                        literalAttributes) == None:
                            literalPools[-1].append(literalAttributes)
                    else:
                        pool = literalPools[literalPoolNumber]
                        i = literalIndex(pool, literalAttributes)
                        if i == None:
                            error(properties, \
                                  "Literal is not in the pool: %s" \
                                  % literalAttributes.get("operand"))
                            continue
                        # A RELOCATABLE LITERAL SETTLES like anything else that
                        # depends on an address, so a changed value is news to
                        # act on rather than an error: store it and go round
                        # again.  Treating it as an error was right only while
                        # every literal was absolute.
                        if pool[i].get("value") != literalAttributes.get("value"):
                            pool[i] = literalAttributes
                            repeatPass = True
                if not compile:
                    toMemory(dataSize)
                    continue
                if operation == "B":
                    pass # ***DEBUG*** ***TRAP compile***
                data = bytearray(dataSize)
                if ast != None:
                    # R1 is syntactically omitted for various instructions,
                    # and an implied R1 is used instead.
                    if operation in branchAliases:
                        r1 = branchAliases[operation]
                    elif operation in impliedR1:
                        r1 = impliedR1[operation]
                        err = False
                    else:
                        err, r1 = evalInstructionSubfield(properties, "R1", ast, symtab)
                        if r1 == None:
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
                        # IS THE OPERAND EXTERNAL AT ALL, offset or not?
                        # `rextrns` is keyed by the bare hashcode, so an EXTRN
                        # carrying a displacement -- `FIOBCES1+2`, which keeps
                        # the symbol in the hashcode and the 2 in the low bits
                        # -- is absent from it and `extrnD2` is False.
                        extrnBase = extrnD2 or \
                                    (d2 != None and \
                                     (d2 & hashcodeMask) in rextrns)
                        if not err and d2 != None: 
                            properties["adr1"] = d2 & 0xFFFF
                            err, b2 = evalInstructionSubfield(properties, "B2", ast, symtab)
                            if not err: 
                                err, x2 = evalInstructionSubfield(properties, "X2", ast, symtab)
                                if x2 == None and "noX" in ast:
                                    # `D2(,B2)` names no index but still
                                    # selects the indexed addressing mode: the
                                    # original build assembles `LH R2,d(,R2)`
                                    # as 9AF6 000A, which is generateRS1 with
                                    # b2=2, x2=0 and the 0b100 bit set, and
                                    # never as the two-byte short form.
                                    x2 = 0
                                if not err:
                                    if operation in ["ST"]: ###DEBUG###TRAP###
                                        pass
                                    # A register in parentheses is the BASE
                                    # only if it can be one.  If no USING is
                                    # active for it and the displacement is a
                                    # RELOCATABLE symbol -- which therefore
                                    # already draws its base from some other
                                    # USING -- then the register is an INDEX,
                                    # and an indexed operand cannot take the
                                    # short form.
                                    #
                                    # `b2 > 3` was a narrower version of the
                                    # same idea.  It misses FPMEVENQ's
                                    # `LH R2,TEQEVAR1(R1)`, where TEQEVAR1 is
                                    # based on R0 by `USING TFEQE,R0` and R1
                                    # was DROPped forty lines earlier: ASM101S
                                    # read R1 as a base and emitted 9A11 where
                                    # the original build has 9AF4 2004.
                                    droppedBase = False
                                    if b2 != None and 0 <= b2 < len(using) \
                                            and using[b2] == None and \
                                            d2 != None and unhash(d2)[0] != None \
                                            and "$" not in operation:
                                        droppedBase = True
                                    # `$` NAMES A BASE REGISTER, NOT AN INDEX.
                                    # It selects the FORM, not the addressing:
                                    # ap101s-notes.py records it as long-form
                                    # with the addressing bits CLEAR and the
                                    # second byte 0xF0 | base, established from
                                    # the original binaries -- BILDNEW5's
                                    # `BC$ 7,0(R2)` is C7F2 0000 where `BC@` is
                                    # C7F6 5000.  So the reasoning above, that
                                    # a register with no active USING against a
                                    # relocatable symbol must be an index, does
                                    # not apply: under `$` the programmer is
                                    # promising the register holds the base.
                                    # FCMTRACE's `BL$ FCMWRAP(R3)` is C2F3 001C
                                    # in the original -- base 3, AM=0, and the
                                    # displacement the symbol's own offset --
                                    # against our C2F7 601C with R3 indexed.
                                    atStar = "@" in operation or "#" in operation \
                                        or (b2 != None and b2 > 3) or droppedBase
                                    # ONLY IF SOMETHING ELSE SUPPLIES THE BASE.
                                    # The register can be read as an INDEX only
                                    # when a USING provides a base to replace
                                    # it with; otherwise it IS the base and
                                    # moving it into x2 while leaving b2 alone
                                    # puts the same register in both fields.
                                    # FCMTRACE's `ST@# R4,0(R2)` assembled
                                    # 34F6 5800 -- b2=2 in the F6 AND x2=2 in
                                    # the 58 -- where the original has
                                    # 34F6 1800, the same base with no index.
                                    # Its displacement is an absolute 0, so
                                    # `unUsing` has nothing to match and there
                                    # was never a second base to be had.
                                    if atStar and x2 == None:
                                        b, d = unUsing(using, d2)
                                        if b != None:
                                            x2 = b2
                                            b2 = b
                                            d2 = d
                                    done = False
                                    forceRS = (operation in argsRSonly)
                                    # `$` CLEARS THE ADDRESSING BITS TOO.
                                    # ap101s-notes.py: "the opcode is unchanged
                                    # from the unsuffixed mnemonic and the
                                    # addressing bits stay clear ... in the long
                                    # form the second byte is 0xF0 | base
                                    # register".  So the form is not merely
                                    # long, it is AM=0 with the displacement
                                    # taken absolutely.  FCMCSYNC's
                                    # `BNZ$ FCMCSLPE` is C3F3 00DA in the
                                    # original -- AM=0, base 3, the symbol's own
                                    # section offset -- against our C3F7 0042,
                                    # AM=1 with a PC-relative displacement that
                                    # reaches the same place.
                                    forceAM0 = ("$" in operation)
                                    forceAM1 = False
                                    if operation in ["BC", "BCT"]:
                                        # From the STATEMENT's own position,
                                        # not `currentHash()`, which is the
                                        # section's running position and by
                                        # here can be a halfword further on.
                                        # The displacement then comes out one
                                        # short forward and one long backward.
                                        # The alias path a few lines below has
                                        # always computed it this way; these
                                        # two disagreeing was the bug.
                                        #
                                        # FIOPDHF falls from 22 wrong bytes to
                                        # 2 on this alone.
                                        d = d2 - (properties["pos1"] // 2 \
                                                  + symtab[sect]["value"] + 1)
                                        if d < 0 and d > -0b111000:
                                            d = (-d & 0b111111)
                                            data = generateSRS(properties, \
                                                               operation+"B", \
                                                               r1, d, \
                                                               {"BC":0b10, 
                                                                "BCT":0b11}[operation])
                                            done = True
                                        elif operation == "BC" and \
                                                d >= 0 and d < srsBranchCeiling:
                                            # A FORWARD `BC` also has a short
                                            # form, and only the backward one
                                            # was written here.  The two-bit
                                            # field distinguishes them -- BCF
                                            # 00 forward, BVCF 01, BCB 10
                                            # backward, BCTB 11 -- so there is
                                            # a short forward BC but no short
                                            # forward BCT, which is why the
                                            # backward case alone looked like
                                            # the whole story.
                                            #
                                            # FIOPDHF's `BC 07-4,#@LB3` jumps
                                            # 48 halfwords forward, well within
                                            # the 56 the field holds, and the
                                            # original build assembles it DBC0
                                            # while this emitted C3F7 0030.
                                            data = generateSRS(properties, \
                                                               "BCF", r1, \
                                                               d & 0b111111, \
                                                               0b00)
                                            done = True
                                    # NOT WHEN A REGISTER IS INDEXING IT.  The
                                    # short branch form has neither an index
                                    # field nor a base field -- its two bits
                                    # are the FORM selector, BCF 00, BVCF 01,
                                    # BCB 10, BCTB 11 -- so shortening simply
                                    # drops the register.  FCMTRACE's
                                    # `BL$ FCMWRAP(R3)` assembled DA54, a short
                                    # forward branch that happens to reach the
                                    # right place, where the original keeps the
                                    # four-byte form that can still name R3.
                                    #
                                    # THE TEST IS `x2`, NOT `specifiedB2`.  The
                                    # `$` suffix puts the register in the INDEX,
                                    # and `specifiedB2` is computed from `b2`
                                    # earlier still, while it is None; it reads
                                    # False here even though the operand plainly
                                    # carries `(R3)`.  Guarding on it changes
                                    # nothing at all, which cost two attempts.
                                    # AND NOT WHEN THE FORM IS FORCED.  `$`
                                    # selects the long form and sets `forceRS`
                                    # through `argsRSonly`, which every other
                                    # shortening path honours and this one did
                                    # not, so a `BL$` was shortened anyway.
                                    elif operation in branchAliases and \
                                            x2 in [None, 0] and not forceRS:
                                        d = d2 - (properties["pos1"] // 2 + symtab[sect]["value"] + 1)
                                        if d >= 0 and d < 0b111000:
                                            d = d & 0b111111
                                            if operation in bvcfAliases:
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
                                    # DID B2 COME FROM A `USING`, or from the fallback below that
                                    # means "no USING matched, but the target is in this section"?
                                    # Both can leave b2 == 3, and the two want opposite
                                    # displacements.
                                    usingB2 = False
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
                                            usingB2 = True
                                    if b2 != None and (b2 < 0 or b2 > 3) and \
                                            operation not in shiftOperations:
                                        if x2 == None and b2 >= 4 and b2 <= 7:
                                            x2 = b2
                                            b2 = None
                                        else:
                                            error(properties, "B2 out of range", \
                                                  severity = 255 if compile else 0)
                                            done = True
                                    opcode = argsSRSorRS[operation]
                                    # `forceAM0` is purely empirical.
                                    #
                                    # BUT NOT WHEN THE MNEMONIC CARRIES `@` OR
                                    # `#`.  Those two bits live in the AM=1
                                    # form and nowhere else -- every `@`/`#`
                                    # card in the original build has 0xFC
                                    # through 0xFF in its second byte -- so
                                    # forcing AM=0 asks for a form that cannot
                                    # express the instruction at all, and the
                                    # AM=0 arm below, which admits neither
                                    # flag, then rejected the statement with
                                    # "Could not interpret line as SRS or RS".
                                    # BILDNEW5's TESTING member writes eight
                                    # such cards -- `LM@ MOVPOINT` under
                                    # `USING MOVPOINT,B0` among them -- and
                                    # they are all it had left of that
                                    # complaint.  The flags are read off the
                                    # mnemonic here because `ia` and `i`
                                    # themselves are not computed until below.
                                    forceAM0 = forceAM0 or ( (opcode & 1) != 0 \
                                                and b2 not in [3, None] and x2 == None \
                                                and "@" not in operation \
                                                and "#" not in operation)
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
                                        ia = int("@" in operation)
                                        i =  int("#" in operation)
                                        if b2 == None:
                                            ib2 = 3
                                        else:
                                            ib2 = b2
                                        # `ib2 == 3` WAS DOING DOUBLE DUTY: the sentinel for "no base
                                        # register", and the legitimate base register B3.  A symbol
                                        # reached through `USING TFTQE,R3` therefore took the
                                        # section-relative path and got a NEGATIVE displacement, which
                                        # generateSRS masked into six bits and turned into a large
                                        # positive one.  FPMIDLE's `LH R3,TTQEFLGS` assembled 9BD7,
                                        # displacement 53, where the original has 9B17, displacement 5:
                                        # the base register right and only the displacement wrong,
                                        # 64 + (-11).
                                        if ib2 == 3 and not usingB2:
                                            d = dSRS
                                            d1 = dRSAM1
                                        else:
                                            d = uUnhashedValue
                                            d1 = unhashedValue
                                            
                                        #uhSect, uhD2 = unhash(d2)
                                        #uuB2, uuD2 = unUsing(using, d2)
                                        # `forceDisplacement` is an experimental
                                        # thing right now that tries to use
                                        # displacements (D2) directly in the 
                                        # encoded instruction, versus somehow
                                        # computing them relative to something.
                                        # See issues #1324, #1325, #1326.
                                        # Note that `unhashedValue` is 
                                        # `d2&0xFFFFFF`.  We already know that
                                        # `d2` is not `None`.  And possibly
                                        # other stuff I'm rechecking here.
                                        if forceDisplacement and \
                                                operation not in shiftOperations and \
                                                not extrnD2 and \
                                                not forceAM1 and \
                                                not forceRS and \
                                                x2 == None and \
                                                r1 != None and \
                                                "B2" in ast and \
                                                b2 < 4 and \
                                                i == 0 and ia == 0 and \
                                                unhashedValue >= 0 and \
                                                (unhashedValue % dUnitizer) == 0 and \
                                                unhashedValue < 0x38 * dUnitizer:
                                            # For SRS-type instructions.
                                            ud2 = (d2 & 0xFFFFFFFF00000000) | ((d2 & 0xFFFFFFFF) // dUnitizer)
                                            data = generateSRS(properties, operation, r1, ud2, b2)
                                            #if "adr1" in properties:
                                            #    properties.pop("adr1")
                                        elif forceDisplacement and \
                                                operation not in shiftOperations and \
                                                not extrnD2 and \
                                                not forceAM0 and \
                                                x2 == None and \
                                                r1 != None and \
                                                "B2" in ast and \
                                                b2 < 4 and \
                                                i == 0 and ia == 0 and \
                                                unhashedValue >= 0 and \
                                                unhashedValue < 0x10000:
                                            # For extended RS-type instructions.
                                            data = generateRS0(properties, operation, r1, d2, b2)
                                            if "adr1" in properties:
                                                properties.pop("adr1")
                                        elif forceDisplacement and \
                                                operation not in shiftOperations and \
                                                not extrnD2 and \
                                                not forceAM0 and \
                                                x2 != None and \
                                                r1 != None and \
                                                "B2" in ast and \
                                                b2 < 4 and \
                                                unhashedValue >= 0 and \
                                                unhashedValue < 0x800:
                                            # For indexed RS-type instructions.
                                            data = generateRS1(properties, operation, ia, i, r1, d2, x2, b2)
                                            if "adr1" in properties:
                                                properties.pop("adr1")
                                        elif operation in shiftOperations:
                                            if b2 == None:
                                                d = d2
                                            else:
                                                d = 56 + b2
                                            data = generateSRS(properties, operation, r1, d, shiftOperations[operation])
                                            if "adr1" in properties:
                                                properties.pop("adr1")
                                            properties["adr2"] = d2 & 0x3F
                                        # NOT WHEN A `USING` SUPPLIED THE BASE
                                        # REGISTER.  By this point `d2` has been
                                        # replaced by the offset from that
                                        # register, so a symbol reached through
                                        # `USING CDDLOCAL,R1` arrives here as a
                                        # small number and matches -- and this
                                        # branch then throws the register away
                                        # and addresses the symbol relative to
                                        # the instruction counter instead.
                                        # DCICYC's `LA R2,CLOCIOR` assembled
                                        # EAF7 0012, the 0x12 being 0x58 - 0x46,
                                        # where the original has EAF1 0058:
                                        # base register 1, displacement 0x58,
                                        # exactly what the USING says.
                                        elif operation == "LA" and \
                                                not usingB2 and \
                                                x2 == None and b2 != None \
                                                and d2 > -2048 and d2 < 2048:
                                            if d2 >= 0 and d2 < srsCeiling and len(data) == 2:
                                                data = generateSRS(properties, operation, r1, d2, ib2)
                                            elif d2 < icRS:
                                                # What's happening here is that we
                                                # generate an RS AM=1 instruction,
                                                # but we set the I bit-field to 1
                                                # to cause d2 to be subtracted from
                                                # the updated IC.
                                                data = generateRS1(properties, operation, 0, 1, r1, icRS - d2, 0, 3)
                                            else: # d2 >= ic + 2
                                                data = generateRS1(properties, operation, 0, 0, r1, d2 - icRS, 0, 3)
                                        # A FORWARD SHORT BRANCH CANNOT HOLD A
                                        # NEGATIVE DISPLACEMENT.  Only `BCB`
                                        # and `BCTB` take one, and they negate
                                        # it a few lines below; everything else
                                        # arriving here with d < 0 has no short
                                        # form at all.  The range check further
                                        # down tests only `d >= srsCeiling`, so
                                        # a negative value passed it and
                                        # `generateSRS` masked it into six bits:
                                        # DCICYC's `BC 6,#@LB259` is 65
                                        # halfwords BACK and assembled DEFC, a
                                        # forward branch of 63, where the
                                        # original has the four-byte C6F7 0842.
                                        # That is not a different-but-valid
                                        # encoding, it is a branch to the wrong
                                        # address.
                                        elif (len(data) == 2 and \
                                              (d >= srsFloor or operation not in \
                                               ("BC", "BCF", "BVC", "BVCF") and \
                                               operation not in branchAliases) and \
                                              d < (srsBranchCeiling \
                                                   if (operation in branchAliases \
                                                       or operation in \
                                                          srsBranchOperations) \
                                                   else srsCeiling)) or \
                                               (not (ib2 == 3 and \
                                                     operation in fpOperationsSP) and \
                                                not forceRS and x2 == None and \
                                                (specifiedB2 or ib2 == 3) and \
                                                d >= srsFloor and \
                                                d < srsBranchCeiling and \
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
                                                error(properties, "SRS displacement out of range", \
                                                      severity = 255 if compile else 0)
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
                                        # `BCT` BELONGS IN THIS LIST and was
                                        # missing, so a backward BCT fell past
                                        # here to the AM=0 form and encoded its
                                        # target as an absolute section offset.
                                        # FCMBCEMD's `BCT R5,#@LB34` assembled
                                        # D5F3 007B where the original has
                                        # D5F7 08BD -- the same address reached
                                        # as 0x138 - 0xBD instead of as 0x7B.
                                        #
                                        # `d1 <= 0` rather than `d1 < 0` because
                                        # the original build writes `*+2` -- a
                                        # displacement of exactly zero -- as the
                                        # negative form too, i=1 with magnitude
                                        # 0.  PC-0 and PC+0 are the same address,
                                        # so both encodings are correct and only
                                        # one of them is what was built.
                                        # `OST`, `LPS` and `SSM` REACH BACKWARD
                                        # THE SAME WAY.  Nothing about this
                                        # encoding is peculiar to branches: a
                                        # section-relative reference to a lower
                                        # address is written AM=1 with the `i`
                                        # bit and the magnitude, whatever the
                                        # operation.  FCMBOOT's
                                        # `OST R5,FCMBEX0N+2` assembled
                                        # 2DFB 007E -- AM=0 with the absolute
                                        # section offset 0x7E -- where the
                                        # original has 2DFF 08C9, the same
                                        # address reached as 0x147 - 0xC9.
                                        # FPMSDERR's `SSM FPMAREGS` is the same
                                        # instruction shape.
                                        # ONLY FOR A LOCAL TARGET.  An EXTRN is
                                        # resolved by the linker, so it keeps
                                        # the absolute form and its relocation:
                                        # FIOPDHF's `OST R2,FIOBCES1+2` is the
                                        # same instruction against an EXTRN and
                                        # the original assembles it 2AFB 0002,
                                        # not the backward form.  Guarding only
                                        # the three new operations leaves the
                                        # branch mnemonics exactly as they were.
                                        elif (operation in ["BC", "BIX", "BAL", "BCT"] or \
                                              (operation in ["OST", "LPS", "SSM"] \
                                               and not extrnBase)) and \
                                                x2 in [None, 0] and \
                                                d1 > -2048 and d1 <= 0:
                                            if extrnD2:
                                                data = generateRS0(properties, operation, r1, 0, 3)
                                                if compile:
                                                    rldAddr = sects[sect]["pos1"] + 2  # byte offset of displacement field
                                                    relocations.append({
                                                        'symbol': rextrns[originalD2],
                                                        'section': sect,
                                                        'address': rldAddr,
                                                        'type': 'Y'
                                                    })
                                            else:
                                                # ELEVEN BITS, NOT TEN.
                                                # `generateRS1` packs bits 10-8
                                                # into data[2] and 7-0 into
                                                # data[3], so the mask is 0x7FF;
                                                # 0x3FF silently dropped bit 10
                                                # of any magnitude of 1024 or
                                                # more.  DCICYC's
                                                # `BC 07-1,#@LB29` needs 0x4D5
                                                # and assembled 0x0D5, reaching
                                                # 0048D instead of 0008D.
                                                data = generateRS1(properties, operation, 0, 1, r1, 0x7FF & -d1, 0, ib2)
                                        elif not forceAM0 and \
                                                (x2 != None or ia or \
                                                 i or (not usingB2 and \
                                                       d1 >= 0 and d1 < 2048)):
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
                                                error(properties, "X2 out of range", \
                                                      severity = 255 if compile else 0)
                                                x2 = 0
                                            data = generateRS1(properties, operation, ia, i, r1, d1, x2, ib2)
                                        elif x2 == None and not ia and not i:
                                            # RS AM=0 here
                                            if operation in ["B", "BZ"]: ###DEBUG###
                                                pass
                                            if b2 != None:
                                                d0 = d2 & 0xFFFF
                                            elif (d2 in rextrns) or \
                                                    ((d2 & hashcodeMask) in rextrns):
                                                # An EXTRN, with or without a
                                                # displacement.  Only the bare
                                                # symbol used to be recognised,
                                                # because `rextrns` is keyed by
                                                # the hashcode alone and
                                                # `FP$COMSA+14` carries the 14
                                                # in the low bits.  Such a
                                                # reference then fell through
                                                # to the search for a base
                                                # register, found none -- an
                                                # external address is resolved
                                                # by the linker, not by a USING
                                                # -- and was reported as an
                                                # uninterpretable operand.  It
                                                # was the broadest complaint in
                                                # the corpus, across 44 modules.
                                                if d2 in rextrns:
                                                    externalSymbol = rextrns[d2]
                                                    d0 = 0
                                                else:
                                                    externalSymbol = \
                                                        rextrns[d2 & hashcodeMask]
                                                    d0 = d2 & 0xFFFFFFFF
                                                b2 = 3
                                                if compile:
                                                    rldAddr = sects[sect]["pos1"] + 2  # byte offset of displacement field
                                                    relocations.append({
                                                        'symbol': externalSymbol,
                                                        'section': sect,
                                                        'address': rldAddr,
                                                        'type': 'Y'
                                                    })
                                            else:
                                                section, offset = unhash(d2)
                                                if section in sects and \
                                                        "offset" in sects[section]:
                                                    d0 = offset + sects[section].get("offset", 0) - sects[sect].get("offset", 0)
                                                    b2 = 3
                                                    if compile:
                                                        rldSymbol = section
                                                        for sn, sd in sects.items():
                                                            if sd.get("dsect") or "offset" not in sd:
                                                                continue
                                                            so = sd["offset"]
                                                            su = sd["used"] // 2
                                                            if d0 >= so and d0 < so + su and sn != sect:
                                                                rldSymbol = sn
                                                                break
                                                        rldAddr = sects[sect]["pos1"] + 2
                                                        relocations.append({
                                                            'symbol': rldSymbol,
                                                            'section': sect,
                                                            'address': rldAddr,
                                                            'type': 'Y'
                                                        })
                                                if b2 == None:
                                                    # There is no base register
                                                    # from which the operand's
                                                    # address can be reached --
                                                    # no USING covers it.  The
                                                    # message used to say only
                                                    # "Could not interpret
                                                    # operand", which named
                                                    # neither the instruction
                                                    # nor the address and was
                                                    # the broadest complaint in
                                                    # the corpus.
                                                    whichSect, whichOffset = \
                                                        unhash(d2)
                                                    error(properties, \
                                                          "No USING covers the operand of "
                                                          "'%s %s' (section %s, offset %s)" % \
                                                          (operation,
                                                           properties["operand"].strip()[:32],
                                                           whichSect, whichOffset))
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
                                # Alone among the subfield evaluations here,
                                # this one used to ignore `err` and go straight
                                # to `i1 &= 0xFFFF`, which raises TypeError when
                                # I1 could not be evaluated or was simply
                                # absent.  Report it and leave the instruction
                                # zeroed, as the base-register failure below
                                # already does.
                                if err or i1 == None:
                                    error(properties, \
                                          "Could not evaluate I1 subfield")
                                else:
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
                
            if operation in cnopFills:
                # CNOP aligns the location counter and FILLS the gap with
                # no-ops, which is what distinguishes it from the silent
                # alignment commonProcessing() performs for DC and DS.
                #
                # The operand is a number of HALFWORDS within a fullword, and
                # the target is simply its parity:  `CNOP 2` aligns to an even
                # halfword address, which is a fullword boundary, and `CNOP 1`
                # to an odd one.  That is IBM's `CNOP b,w` with w fixed at a
                # fullword and b counted in halfwords, 2 standing where 0
                # would.
                #
                # The three spellings are three processors and they fill with
                # their own no-ops:  CNOP is the CPU's and fills with D800,
                # which is what ASM101S already generates for `NOP 0`, and
                # @CNOP is the MSC's and fills with C000.  Both were read off
                # the original build in ~/workspace/PFS/"OI301700 as
                # received" -- 10 and 59 filled instances respectively, plus
                # 42 more that needed no fill and emitted nothing, and the
                # parity rule holds for every one.
                commonProcessing(1)
                ast = properties["ast"]
                fill = cnopFills[operation]
                if ast == None:
                    error(properties, "%s requires an operand" % operation)
                    continue
                err, halfwords = evalInstructionSubfield(properties, "v", ast, \
                                                         symtab)
                if err or halfwords == None:
                    error(properties, "Could not evaluate %s operand" % operation, \
                          severity = 255 if compile else 0)
                    continue
                target = halfwords % 2
                # `pos1` is a byte offset, so the halfword address is pos1//2.
                # AN ALREADY-ALIGNED CNOP NEEDS NO FILL, and so needs no known fill
                # instruction.  The diagnostic below used to be raised on sight of
                # the directive, rejecting a whole module over an alignment that was
                # already satisfied:  FIODDUPG's `#CNOP 2` sits at 00018 and the
                # statement after it is at 00018 too, so the original build emitted
                # nothing there either.  Complain only when a gap must actually be
                # filled -- which is also the only case in which the fill value could
                # be read off a listing.
                while (sects[sect]["pos1"] // 2) % 2 != target:
                    if fill == None:
                        error(properties, \
                              "%s needs to fill a gap here, and its fill " \
                              "instruction is unknown -- no instance needing " \
                              "one has been seen in the original build" \
                              % operation)
                        break
                    toMemory(bytearray(fill))
                continue

            if operation in mscMemory or operation in mscBranch or \
                    operation in mscImmediate or operation in mscImmediate11 \
                    or operation in mscOpx or operation in ["@BC", "@BXC"]:
                # The two-byte MSC instructions, in the three formats derived
                # and checked against the original build.  See `mscMemory`,
                # `mscBranch` and `mscImmediate` for where each opcode comes
                # from and how far it is verified.
                commonProcessing(2)
                ast = properties["ast"]
                data = bytearray(2)
                if ast == None:
                    error(properties, "%s requires an operand" % operation)
                    toMemory(data)
                    continue

                def mscField(subfield):
                    '''Evaluate one MSC operand, resolving a hashed address to
                    its combined offset the way the BCE generator does.'''
                    err, value = evalInstructionSubfield(properties, subfield, \
                                                         ast, symtab)
                    if err or value == None:
                        return None
                    section, offset = unhash(value)
                    if section is None:
                        return value
                    return offset + sects.get(section, {}).get("offset", 0)

                if operation in mscOpx:
                    # @STP, whose operand is the OPX field in the second
                    # nibble rather than an immediate value.  See `mscOpx`.
                    value = mscField("A1")
                    if value == None:
                        error(properties, \
                              "Could not evaluate %s operand" % operation, \
                                    severity = 255 if compile else 0)
                        toMemory(data)
                        continue
                    if not 0 <= value <= 7:
                        error(properties, \
                              "%s operand %d is not an OPX value; OPX is " \
                              "three bits and the POO names 0 through 3" \
                              % (operation, value), \
                                    severity = 255 if compile else 0)
                    data[0] = (mscOpx[operation] << 4) | (value & 0x0F)
                    data[1] = 0
                    toMemory(data)
                    continue

                if operation in mscImmediate or operation in mscImmediate11:
                    value = mscField("A1")
                    if value == None:
                        error(properties, \
                              "Could not evaluate %s operand" % operation, \
                                    severity = 255 if compile else 0)
                        toMemory(data)
                        continue
                    if operation in mscImmediate11:
                        if not 0 <= value <= 0x7FF:
                            error(properties, \
                                  "%s operand %d does not fit in the 11-bit " \
                                  "immediate field" % (operation, value), \
                                        severity = 255 if compile else 0)
                    elif not -128 <= value <= 255:
                        error(properties, \
                              "%s operand %d does not fit in the 8-bit " \
                              "immediate field" % (operation, value), \
                                    severity = 255 if compile else 0)
                    if value != 0 and operation in mscImmediateZeroOnly:
                        error(properties, \
                              "%s is written with a non-zero operand, %d.  " \
                              "It appears only ever with zero in the original " \
                              "build, so where its opcode ends and its " \
                              "operand begins is not established and the " \
                              "object code here may be WRONG" \
                              % (operation, value))
                    if operation in mscImmediate11:
                        # An eleven-bit operand: opcode nibble, index flag,
                        # then the value across both bytes.
                        data[0] = (mscImmediate11[operation] << 4) \
                                  | ((value >> 8) & 0x07)
                    else:
                        data[0] = mscImmediate[operation]
                    if "X1" in ast:
                        if operation in mscImmediateIndexable:
                            data[0] |= 0x08
                        else:
                            error(properties, \
                                  "%s is written with an index, which does " \
                                  "not appear in the original build for this " \
                                  "instruction; the index bit is not encoded " \
                                  "and the object code here is WRONG" \
                                  % operation)
                    data[1] = value & 0xFF
                    toMemory(data)
                    continue

                # What is left is PC-relative, so it needs the address of the
                # halfword AFTER this instruction.  `pos1` is a byte offset
                # and `commonProcessing` has not yet advanced it past these
                # two bytes, hence the +2.
                target = mscField("A1")
                if target == None:
                    error(properties, \
                          "Could not evaluate %s operand" % operation, \
                          severity = 255 if compile else 0)
                    toMemory(data)
                    continue
                updatedPC = (sects[sect]["pos1"] + \
                             sects.get(sect, {}).get("offset", 0) + 2) // 2
                displacement = target - updatedPC
                indexed = 1 if "X1" in ast else 0

                if operation in mscMemory:
                    if not -1024 <= displacement <= 1023:
                        error(properties, \
                              "%s is %d halfwords away, out of range of the " \
                              "11-bit PC-relative displacement" \
                              % (operation, displacement), \
                                    severity = 255 if compile else 0)
                    word = (mscMemory[operation] << 12) | (indexed << 11) | \
                           (displacement & 0x7FF)
                else:
                    if operation in ["@BC", "@BXC"]:
                        # @BC and @BXC state the condition as their first
                        # operand rather than in the mnemonic, the branch
                        # target being the second.  @BXC is the index-register
                        # form, which is what M distinguishes.
                        indexed = 1 if operation == "@BXC" else 0
                        condition = mscField("CC")
                        if condition == None or not 0 <= condition <= 7:
                            error(properties, \
                                  "%s requires a condition code of 0 to 7 " \
                                  "as its first operand" % operation)
                            toMemory(data)
                            continue
                    else:
                        indexed, condition = mscBranch[operation]
                    if not -128 <= displacement <= 127:
                        error(properties, \
                              "%s is %d halfwords away, out of range of the " \
                              "8-bit PC-relative displacement" \
                              % (operation, displacement), \
                                    severity = 255 if compile else 0)
                    word = (0x20 | (indexed << 3) | condition) << 8 | \
                           (displacement & 0xFF)
                data[0] = (word >> 8) & 0xFF
                data[1] = word & 0xFF
                toMemory(data)
                continue

            if operation in mscLong:
                # The four-byte MSC instructions.  See `mscLong` for the
                # layout and where it comes from.
                commonProcessing(2)
                ast = properties["ast"]
                subop, mbit, field = mscLong[operation]
                data = bytearray(4)
                if ast == None:
                    error(properties, "%s requires an operand" % operation)
                    toMemory(data)
                    continue

                def mscLongField(subfield):
                    err, value = evalInstructionSubfield(properties, subfield, \
                                                         ast, symtab)
                    if err or value == None:
                        return None
                    section, offset = unhash(value)
                    if section is None:
                        return value
                    return offset + sects.get(section, {}).get("offset", 0)

                if field == "operand":
                    # The delta of @CALL, or the BCE number of @LBB and @LBP,
                    # which is written as the first of the two operands.
                    if "CC" not in ast:
                        error(properties, \
                              "%s requires two operands" % operation)
                        toMemory(data)
                        continue
                    field = mscLongField("CC")
                    if field == None:
                        error(properties, \
                              "Could not evaluate the first operand of %s" \
                              % operation)
                        toMemory(data)
                        continue
                    if not 0 <= field <= 31:
                        error(properties, \
                              "The first operand of %s is %d, outside the " \
                              "5-bit field it is placed in" \
                              % (operation, field), \
                                    severity = 255 if compile else 0)
                address = mscLongField("A1")
                if address == None:
                    # Quiet on the collecting passes.  FIOHISAM writes
                    # `DATALOAD @LH DATA(1)` at card 171 and `DATA EQU 0` at
                    # card 255, an ordinary forward reference that pass 3
                    # resolves; diagnosing it at full severity on pass 1 threw
                    # the module away.  Sixth site of this kind.
                    if compile:
                        error(properties, \
                              "Could not evaluate the address operand of %s" \
                              % operation)
                    toMemory(data)
                    continue
                if not -0x20000 <= address <= 0x3FFFF:
                    error(properties, \
                          "The address operand of %s is %d, outside the " \
                          "18-bit address field" % (operation, address), \
                                severity = 255 if compile else 0)
                word = (0xF << 28) | ((1 if "X1" in ast else 0) << 27) | \
                       (subop << 24) | ((field & 0x1F) << 19) | \
                       (mbit << 18) | (address & 0x3FFFF)
                data[0] = (word >> 24) & 0xFF
                data[1] = (word >> 16) & 0xFF
                data[2] = (word >> 8) & 0xFF
                data[3] = word & 0xFF
                toMemory(data)
                continue

            if operation in argsMSC:
                # The MSC instructions the survey of the original build did
                # NOT settle:  the long forms F0 to FD, the four whose high
                # byte varies and so carries a modifier, and those seen only
                # ever with a zero operand, whose opcode/operand boundary is
                # therefore unconstrained by the evidence.  See the entry
                # "MSC instructions still unencoded" in ap101s-notes.db for
                # the list and the reasoning.
                #
                # These say so rather than emit a guess.  Four zero bytes are
                # obviously wrong; a plausible but wrong halfword is not, and
                # that is the worse failure.
                commonProcessing(2)
                error(properties, \
                      "%s is an MSC instruction whose encoding has not been " \
                      "established; four zero bytes are generated in its " \
                      "place and the object code is WRONG" % operation)
                toMemory(bytearray(4))
                continue
                
            if operation in bceLong:
                # The four-byte BCE instructions.  See `bceLong` for where the
                # opcodes and the three operand layouts come from; they were
                # derived from the original build rather than from the POO,
                # which names the operands but not the bit layout.
                commonProcessing(2)
                ast = properties["ast"]
                opcode, layout = bceLong[operation]
                data = bytearray(4)
                data[0] = opcode
                if ast == None:
                    error(properties, "%s requires an operand" % operation)
                    toMemory(data)
                    continue

                def bceField(subfield):
                    '''Evaluate one BCE operand.  An address comes back hashed
                    and has to be resolved to its combined offset, exactly as a
                    Y-type address constant does.'''
                    err, value = evalInstructionSubfield(properties, subfield, \
                                                         ast, symtab)
                    if err or value == None:
                        return None
                    section, offset = unhash(value)
                    if section is None:
                        return value
                    return offset + sects.get(section, {}).get("offset", 0)

                first = bceField("A1")
                if first == None:
                    error(properties, "Could not evaluate %s operand" % operation, \
                          severity = 255 if compile else 0)
                    toMemory(data)
                    continue
                if "X1" in ast:
                    # An index used to be captured under the same name as the
                    # second operand, so this silently became a displacement.
                    # Where the long format puts the index bit is not known.
                    error(properties, \
                          "%s is written with an index, whose bit position " \
                          "in the long BCE format is not established; it is " \
                          "not encoded and the object code here is WRONG" \
                          % operation)
                second = bceField("A2") if "A2" in ast else 0
                if second == None:
                    error(properties, \
                          "Could not evaluate second operand of %s" % operation)
                    second = 0

                if layout == "ADDRESS":
                    # THE SAME BORROW as the Y constant above.  `#LBR@ FIOBRE-2`
                    # with FIOBRE an EXTRN evaluates to `hash - 2`, whose low
                    # 24 bits are FFFFFE; FIOMDPPG assembled FAFF FFFE where
                    # the original has FA00 0002.  The POO gives this field as
                    # an 18-bit unsigned address, in which a negative constant
                    # cannot be represented at all, and the original writes the
                    # magnitude.  Positive offsets already work -- FIOPDIPG's
                    # `#LBR@ FIOPDBR+2` and its dozens of fellows match -- and
                    # are untouched, the test below being false for them.
                    _bHash = (first & hashcodeMask) + (1 << 36)
                    _bLow = first & 0xFFFFFFFFF
                    if _bHash in hashcodeLookup and _bLow >= (1 << 35):
                        first = abs(_bLow - (1 << 36))
                    field = first & 0xFFFFFF
                    data[1] = (field >> 16) & 0xFF
                    data[2] = (field >> 8) & 0xFF
                    data[3] = field & 0xFF
                elif layout == "IUACOMMAND":
                    # A 5-BIT IUA over a 19-BIT COMMAND, not a byte over a
                    # halfword.  This was wrong for years and could not have
                    # been caught by the corpus, whose operands here are
                    # EXTRN symbols that assemble to zero either way.  The
                    # one source line that settles it says so in its own
                    # comment:  `#CMDI 15,0    CMD WORD=X'00780000'`, and
                    # 0x780000 is 15 shifted by 19, not by 16.  It checks out
                    # against the symbolic form too -- FIOFFIUA EQU 10 and
                    # FIOMDMRT EQU X'00031C20' give F6531C20, which is
                    # exactly what the original build emits.
                    if not 0 <= first <= 31:
                        error(properties, \
                              "The IUA of %s is %d, outside its 5-bit field" \
                              % (operation, first), \
                                    severity = 255 if compile else 0)
                    field = ((first & 0x1F) << 19) | (second & 0x7FFFF)
                    data[1] = (field >> 16) & 0xFF
                    data[2] = (field >> 8) & 0xFF
                    data[3] = field & 0xFF
                else:
                    # DISPCOUNT, IUACOMMAND and PARAMETER share a shape: one
                    # byte then one halfword.  For PARAMETER the opcode byte is
                    # 00 and the operands are an IUA and a command, the word
                    # being data that follows a #MIN or #MOUT rather than an
                    # instruction in its own right.
                    data[1] = first & 0xFF
                    data[2] = (second >> 8) & 0xFF
                    data[3] = second & 0xFF
                toMemory(data)
                continue

            if operation in bceShort1 or operation in bceShort2:
                # The two-byte BCE instructions.  See `bceShort1` and
                # `bceShort2` for the layouts and where they come from.
                commonProcessing(2)
                ast = properties["ast"]
                data = bytearray(2)
                if ast == None:
                    error(properties, "%s requires an operand" % operation)
                    toMemory(data)
                    continue

                def bceShortField(subfield):
                    err, value = evalInstructionSubfield(properties, subfield, \
                                                         ast, symtab)
                    if err or value == None:
                        return None
                    section, offset = unhash(value)
                    if section is None:
                        return value
                    return offset + sects.get(section, {}).get("offset", 0)

                first = bceShortField("A1")
                if first == None:
                    error(properties, \
                          "Could not evaluate %s operand" % operation, \
                          severity = 255 if compile else 0)
                    toMemory(data)
                    continue

                if operation in bceShort2:
                    # `TC,DISP`:  a 5-bit transfer count over an 8-bit
                    # displacement off the BCE's base register.
                    count = first
                    displacement = bceShortField("A2") if "A2" in ast else 0
                    if displacement == None:
                        error(properties, \
                              "Could not evaluate the displacement of %s" \
                              % operation)
                        displacement = 0
                    if not 0 <= count <= 31:
                        error(properties, \
                              "The transfer count of %s is %d, outside the " \
                              "5-bit field it is placed in" \
                              % (operation, count), \
                                    severity = 255 if compile else 0)
                    if not -128 <= displacement <= 255:
                        error(properties, \
                              "The displacement of %s is %d, outside its " \
                              "8-bit field" % (operation, displacement), \
                                    severity = 255 if compile else 0)
                    word = (bceShort2[operation] << 13) | \
                           ((count & 0x1F) << 8) | (displacement & 0xFF)
                else:
                    opcode, mbit, kind = bceShort1[operation]
                    if mbit == "index":
                        mbit = 1 if "X1" in ast else 0
                    displacement = first
                    if kind == "relative":
                        # PC-relative from the updated BCE program counter,
                        # which is the halfword after this instruction.
                        displacement -= (sects[sect]["pos1"] + \
                                sects.get(sect, {}).get("offset", 0) + 2) // 2
                        if not -1024 <= displacement <= 1023:
                            error(properties, \
                                  "%s is %d halfwords away, out of range of " \
                                  "the 11-bit displacement" \
                                  % (operation, displacement), \
                                        severity = 255 if compile else 0)
                    elif not -1024 <= displacement <= 2047:
                        error(properties, \
                              "The operand of %s is %d, outside the 11-bit " \
                              "field it is placed in" \
                              % (operation, displacement), \
                                    severity = 255 if compile else 0)
                    word = (opcode << 12) | (mbit << 11) | \
                           (displacement & 0x7FF)
                data[0] = (word >> 8) & 0xFF
                data[1] = word & 0xFF
                toMemory(data)
                continue

            if operation in argsBCE:
                # The two-byte BCE instructions, which are NOT encoded:  their
                # opcode/operand boundary could not be read off the original
                # build, most of their observed operands being zero.  Say so
                # rather than emit a guess, since wrong object code that
                # assembles quietly is worse than none.
                commonProcessing(2)
                error(properties, \
                      "%s is a BCE instruction whose encoding has not been " \
                      "established; four zero bytes are generated in its " \
                      "place and the object code is WRONG" % operation)
                toMemory(bytearray(4))
                continue

            # Name the operation.  This is the catch-all at the end of the
            # instruction dispatch, and it accounted for 16720 diagnostics
            # across 166 of OI340600's 225 modules -- by far the commonest
            # thing the assembler says -- while giving no clue whatever as to
            # what it had failed to recognise.
            error(properties, "Unrecognized operation '%s'" % operation)
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
                # A LITERAL POOL BEGINS ON A FULLWORD BOUNDARY whatever it
                # holds.  Seeded at 2, a pool whose widest member is a halfword
                # was aligned to a halfword and started two bytes early wherever
                # the section happened to end odd.  FPMWAIT's pool holds one
                # `=H'1'` and nothing else; the original build puts it at 00056
                # and we put it at 00055.  FPMRES is the same with `=Y(...)`.
                pool[2] = 4
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
            # TO A FIXED POINT.  This was `for sect in sects:
            # optimizeScratch()`, and the function takes no argument and never
            # reads `sect`, so the number of times it ran was the number of
            # control sections the module happened to have.  Each run gives
            # instructions left ambiguous by the last one another chance
            # against shorter addresses, so the count is not cosmetic -- it
            # decides how far the shortening goes.  Running it ONCE was tried
            # and is worse: 242 rather than 243, and DMOD and DSNCS stop being
            # byte-exact, so some modules genuinely need the second look.
            for _optimizePass in range(20):
                if optimizeScratch() == 0:
                    break
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
            # A SECTION OF ZCONS AND NOTHING ELSE.  Measured off the
            # as-received listings, the original aligns control sections one
            # way and ZCON sections another, and the alignment now happens at
            # the TOP of the loop so it can differ per section.
            def zconOnlySection(sect):
                items = [e for e in sects[sect].get("scratch", []) \
                         if e.get("length")]
                if not items:
                    return False
                for e in items:
                    if e.get("operation") != "DC":
                        return False
                    if not str(e.get("operand", "")).lstrip().startswith("Z("):
                        return False
                return True

            # THE RULE, from 132 inter-CSECT boundaries in the corpus:
            #
            #   ordinary section after ordinary   127 cases, FULLWORD
            #   first ZCON section after one        1 case,  DOUBLEWORD
            #   ZCON section after a ZCON section   1 case,  PACKED, no padding
            #
            # The 127 are what rule out a blanket doubleword: they land on
            # byte 4, which is not a doubleword boundary.  FIOCGR is the only
            # module in the corpus with ZCON sections and supplies both of the
            # other cases -- #ZFIOCGR at byte 48 after a section ending at 44,
            # and #ZRIOCGR packed against it at 4C.
            #
            # THIS IS PROBABLY THE RIGHT BYTES FOR THE WRONG REASON, and it is
            # recorded that way deliberately.  PFS/mafgen/DASS_G16.ASC, the
            # linked memory map, shows what is actually going on:
            #
            #     000000-0001A5  FCMPSA    01A6   N O N H A L
            #     0001A6-0001A7  --------  0002   C H E C K S U M
            #     0001A8-0001A9  #ZFIOCGR  0002
            #     0001AA-0001AB  #ZRIOCGR  0002
            #
            # -- addresses in halfwords, so that CHECKSUM is a FULLWORD.  A
            # checksummed section is followed by a checksum word and the ZCONs
            # then pack tight behind it.  Applied inside FIOCGR's own module
            # that accounts for BOTH boundaries with one mechanism: #CFIOCGR
            # ends at byte 44, a checksum fullword occupies 44-47, #ZFIOCGR
            # lands at 48 and #ZRIOCGR packs at 4C.  It also explains why the
            # other 127 boundaries show plain fullword rounding -- those
            # sections are not checksummed.
            #
            # What nothing here explains is how the ASSEMBLER knew to reserve
            # the word, since the gap is in the assembly listing, before any
            # linking.  Until that is understood, this reproduces the layout by
            # asserting an alignment rule instead, which is fitted to n=1 in
            # each ZCON case and is the only module in the corpus with ZCON
            # sections at all.  If a second one turns up, or if the reservation
            # mechanism is found, replace this rather than extend it.
            lastOffset = 0
            previousWasZcon = False
            for sect in sects:
                if sects[sect]["dsect"]:
                    continue
                thisIsZcon = zconOnlySection(sect)
                if thisIsZcon and previousWasZcon:
                    pass                                  # packed
                elif thisIsZcon:
                    lastOffset = (lastOffset + 3) & 0xFFFFFC   # doubleword
                else:
                    lastOffset = (lastOffset + 1) & 0xFFFFFE   # fullword
                sects[sect]["offset"] = lastOffset
                offset = sects[sect]["used"]
                for pool in literalPools:
                    if len(pool) == len(emptyPool):
                        continue
                    if pool[0] == sect:
                        offset = pool[1] + pool[4]
                        break
                lastOffset += offset // 2
                previousWasZcon = thisIsZcon
        pass
    
    # Let's append the literal pools to their CSECTs.
    fill = list(fillPattern)
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
            # A ZCON in the pool needs the same relocation a `DC Z(...)` gets,
            # or the linker never fills in its address.
            zsymbol = pool[i].get("zsymbol")
            if zsymbol != None:
                relocations.append({
                    "symbol": zsymbol,
                    "section": pool[0],
                    "address": offset,
                    "flags": (pool[i]["value"] >> 8) & 0xFF,
                    "type": "Z"
                    })
        sects[pool[0]]["used"] = desiredLength
    
    return metadata
