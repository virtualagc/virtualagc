#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       specifyAGC.py
Purpose:        A lame way of producing a "specifications" file for 
                disassemblerAGC.py from a yaYUL assembly listing.
History:        2022-10-05 RSB  Wrote.  This version seems to work
                                properly for identification of program
                                labels in core rope.
                2022-10-06 RSB  Began implementing variable names in
                                erasable.
                2022-10-07 RSB  Accounted for different address encoding
                                for double-word basic instructions vs
                                single-word instructions.
                2022-10-09 RSB  Fixed erasables, I hope!
                2022-10-14 RSB  Began supporting --block1 and --blk2.
                2022-10-20 RSB  Format of erasable references changed to
                                allow separation of aliased erasables.
                                By default, now no longer invents fictitious
                                symbols like Rbb,aaaa.  A new switch,
                                --invent, restores that functionality.
                2022-10-22 RSB  Added --qrhack
"""

import sys
import copy

debug = False
minLength = 12
block1 = False
blk2 = False
invent = False
qrhack = False
for param in sys.argv[1:]:
    if param == "--debug":
        debug = True
    elif param == "--block1":
        block1 = True
    elif param == "--blk2":
        blk2 = True
    elif param[:6] == "--min=":
        minLength = int(param[6:])
    elif param == "--invent":
        invent = True
    elif param[:8] == "--qrhack":
        qrhack = True
    elif param == "--help":
        print("""
        Usage:
        
            specifyAGC.py [OPTIONS] <AGCPROGRAM.lst >AGCPROGRAM.specs
            
        This program accepts an assembly listing of an AGC program, as output
        by the yaYUL assembler, and produces a "specifications file" suitable
        for use in the disassemblerAGC.py program (with its --specs command
        line switch).  
        
        The OPTIONS for this program are:
        
        --help      Show this information screen.
        --debug     Instead of creating a specifications file, instead output
                    messages on stdout which make it clear how specifyAGC.py
                    analyzed the assembly listing.
        --min=N     Sets a minimum length (in words, decimal) for the 
                    specification of any individual symbol.  The default is 
                    12.  If possible, adjacent symbol scopes will be combined
                    to meet this minimum requirement, but scopes will be 
                    rejected if they are shorter than the minimum and cannot 
                    be combined.
        --invent    By default, match-patterns begin at program labels.
                    However, it's not necessarily true that the code following
                    a data word always has a program label, so the code 
                    after a data word but prior to a program label will by 
                    default be ignored and not used for pattern matching.
                    If the --invent switch is used, then a fictitious label
                    of the form Rbb,aaaa (where bb is a bank number and aaaa
                    is the address within the bank) will be invented in order
                    to include that code.  The drawback is that since the 
                    fictitious labels don't exist within the baseline source 
                    code, it's a little extra effort if you need to find it.
        --qrhack[=QPLACE,RETAA]  (Implemented here, but not in disassemblerAGC.py,
                    so this option is harmless but not useful at present.)  
                    In some places within some code versions we find instruction 
                    sequences like this,
                        TC MAKECADR / TS RETAA / stuff / XCH RETAA / TC BANKJUMP
                    while in corresponding places in other code versions we 
                    instead find
                        XCH Q / TS QPLACE / stuff / TC QPLACE
                    where the "stuff" in the middle is identical.  Of course, 
                    they won't match, as-is.  The --qrhack option attempts to 
                    create patterns that match either.  The octal addresses 
                    in erasable of QPLACE and RETAA in the ROPE may be specified
                    for compatibility with disassemblerAGC.py's command-line
                    switches, but are ignored.
        """)
    else:
        print("Unknown parameter:", param)
        sys.exit(1)

if block1:
    from disassembleInterpretiveBlockI import interpreterOpcodes, parsers
    from registersBlockI import registersByName
    from auxiliaryBlockI import *
    from checkForReferencesBlockI import checkForReferences
elif blk2:
    #print("BLK2 not yet supported", file=sys.stderr)
    #sys.exit(1)
    from disassembleInterpretiveBLK2 import interpreterOpcodes, parsers
    from registers import registersByName       # Same as Block II, I hope.
    from auxiliaryBLK2 import *                     # Same as Block II, I hope.
    from checkForReferencesBLK2 import checkForReferences
else:
    from disassembleInterpretive import interpreterOpcodes, parsers
    from registers import registersByName
    from auxiliary import *
    from checkForReferences import checkForReferences

# Initialization of data structures.
rope = []
for address in range(sizeCoreBank):
    # type, symbol, left, right, reference. Each reference is a triple:
    # (
    #   referenced symbol, 
    #   referring symbol, 
    #   offset into referring symbol,
    #   reference type
    # )
    rope.append([])
    for bank in range(numCoreBanks):
        rope[-1].append(['u', "", "", [], ()])
erasable = []
for address in range(sizeErasableBank):
    erasable.append([])
    for bank in range(numErasableBanks):
        erasable[address].append({ "symbols": [], "references": []})

# Read and analyze the assembly listing.  Afterward, the rope array contains
# a description, for each fixed-memory location, of the type of location and
# the symbol associated with it, if any.  The types are:
#   "u"             unused
#   "d" or "D"      data, w/o or w/ a symbolic name
#   "b" or "B"      basic, w/o or w/ a program label
#   "i" or "I"      interpretive (including arguments), w/o or w/ a symbol
#   "c"             code outside of the scope of a program label.
# This program is unaware of the disassembler's "special symbols" -- i.e.,
# those which accept a data argument immediately following their invocation
# via TC -- and hence characterizes those locations as data rather than as
# basic.
lineNumber = 0
for line in sys.stdin:
    lineNumber += 1
    field = line[:6]
    if len(field) != 6 or not field.isdigit():
        continue
    if line[6:7] != ",":
        continue
    field = line[7:13]
    if len(field) != 6 or not field.isdigit():
        continue
    if line[13:14] != ":":
        continue
    fields = line.strip().split("#")
    line = fields[0].strip()

    left = line[64:73].strip()  # Begins one column early to catch
                                # the occasional prefixed '-'.
    
    addressField = line[24:31].strip()
    if left in ["=", "EQUALS", "CHECK="] and ( addressField == "" or \
            (len(addressField) != 4 and addressField.isdigit()) ):
        continue
    if left == "ERASE" and addressField == "" and line[74:82].strip().isdigit() and \
            line[85:93].strip() == "-" and line[96:104].strip().isdigit():
        addressField = line[74:82].strip()
    if addressField == "" or addressField[:4] == "0000":
        addressField = line[15:22].strip()
        if addressField[:1] == "?":
            continue
    if addressField == "":
        continue
    error, fixed, bank, address, offset = parseAddressString(addressField) 
    if error or bank == -1:
        continue
    
    octal = line[32:37]
    if octal == "     " and fixed:
        continue
    octal2 = line[38:46].strip()
    
    # We ignore symbols attached to pure interpretive operands, since we 
    # have no way to disassemble starting at one of them.  
    if left == "":
        symbol = ""
    else:
        symbol = line[46:54].strip()
    # And I don't like symbols that are pure numerics either.
    dummy = symbol
    if dummy[:1] in ["+", "-"]:
        dummy = dummy[1:]
    if dummy[-1:] == "D":
        dummy = dummy[:-1]
    if dummy.isdigit():
        symbol = ""  
    # Also, sometimes symbols are chosen to coincide with interpretive
    # opcodes, such as "DLOAD*" in Aurora12.  This can bollix us, and
    # rather than track down and fix every way it can bollix us, let's 
    # just eliminate them entirely.
    if symbol in interpreterOpcodes:
        symbol = ""
    if not fixed:
        if symbol != "":
            erasable[offset][bank]["symbols"].append(symbol)
        continue
    if left in ["=", "EQUALS"]:
        continue
         
    locationType = "u"
    if left.isdigit():
        if offset > 0:
            locationType = rope[offset - 1][bank][0]
            if symbol == "":
                locationType = locationType.lower()
            else:
                locationType = locationType.upper()
    if left in interpreterOpcodes:
        if symbol == "":
            locationType = "i"
        else:
            locationType = "I"
    elif left in parsers:
        if symbol == "":
            locationType = parsers[left]
        else:
            locationType = parsers[left].upper()
    elif (left == "" or left.isdigit()) and offset > 0:
            locationType = rope[offset - 1][bank][0].lower()
    
    right = line[74:112].strip().split()
    if len(right) > 0:
        dummy = right[0]
        if dummy in registersByName:
            right = [""] + right
    
    rope[offset][bank] = [locationType, symbol, left, right, []]
    if octal2 != "":
        rope[offset + 1][bank] = [locationType.lower(), "", "", [], []]
    
    #if symbol == "NOUN":
    #    print("%02o,%04o" % (bank, offset), rope[offset][bank], file=sys.stderr)
    #    sys.exit(1)

# This function converts a symbol name into a form that won't cause 
# us problems later when our output file is read back by 
# disassemblerAGC.py.  Specifically, we don't like the character
# "'" in symbol names, so we replace it by "!", which as far as I
# can tell isn't used in AGC symbol names.
def normalize(symbol):
    return symbol.replace("'", "!")

# Convert the contents of the rope array into specifications.
# Each bank can be analyzed separately.
print("# Specification file suitable for disassemblerAGC.py --specs, "
      "auto-generated by specifyAGC.py.")
print("# The minimum length of specifications is set "
      "to %d words." % minLength)
print("# Core rope:")
nonCode = ['u', 'd', 'D']
emptyHacks = {"inRETAA":[], "outRETAA":[], "inQPLACE":[], "outQPLACE":[]}
for bank in range(numCoreBanks):
    offset = 0
    while True:
        if offset >= sizeCoreBank:
            break
        locationInfo = rope[offset][bank]
        locationType = locationInfo[0]
        symbol = locationInfo[1]
        
        # Try to find code.
        if locationType in nonCode:
            offset += 1
            continue
        
        # We have reached code.  If it doesn't already have a
        # symbolic label, we invent one for it, of the form
        # Rbb,aaaa, where bb,aaaa is the address.
        if symbol == "":
            if invent:
                symbol = "R%02o,%04o" % (bank, offset + coreOffset)
                rope[offset][bank][0] = rope[offset][bank][0].upper()
                rope[offset][bank][1] = symbol
            else:
                rope[offset][bank][0] = 'c' # Mark as code without a scope.
                offset += 1
                continue
    
        # Let's look ahead, to find either the next symbol or
        # else a change to data, either one of which would be
        # the end of scope for the current code area.
        #symbolList = [symbol]
        derivedSymbols = {}
        found = False
        lookaheadType = locationType.lower()
        hacks = copy.deepcopy(emptyHacks)
        hackStack = ""
        index = 0
        if qrhack and locationType == 'B':
            key = ""
            if len(locationInfo[3]) > 0:
                if locationInfo[3][0] == "" and len(locationInfo[3]) > 0:
                    key = locationInfo[2] + " " + locationInfo[3][1]
                else:
                    key = locationInfo[2] + " " + locationInfo[3][0]
            if key in ["TC MAKECADR", "XCH Q", "XCH RETAA"]:
                hackStack = key
        for newOffset in range(offset + 1, sizeCoreBank):
            index += 1
            if len(rope[newOffset][bank][4]) == 4:
                print("- %s %s %d %s" % rope[newOffset][bank][4])
            lookahead = rope[newOffset][bank]
            lastLookaheadType = lookaheadType.lower()
            lookaheadType = lookahead[0]
            if qrhack and locationType == 'B':
                key = ""
                if len(lookahead[3]) > 0:
                    if lookahead[3][0] == "" and len(lookahead[3]) > 0:
                        key = lookahead[2] + " " + lookahead[3][1]
                    else:
                        key = lookahead[2] + " " + lookahead[3][0]
                if hackStack == "TC MAKECADR" and key == "TS RETAA":
                    hacks["inRETAA"].append(index - 1)
                elif hackStack == "XCH Q" and key == "TS QPLACE":
                    hacks["inQPLACE"].append(index - 1)
                elif hackStack == "XCH RETAA" and key == "TC BANKJUMP":
                    hacks["outRETAA"].append(index - 1)
                else:
                    pass
                hackStack = ""
                if key in ["TC MAKECADR", "XCH RETAA", "XCH Q"]:
                    hackStack = key
                elif key == "TC QPLACE":
                    hacks["outQPLACE"].append(index)
            lookaheadSymbol = lookahead[1]
            if lookaheadType in nonCode or lookaheadSymbol != "":
                if newOffset < offset + minLength:
                    derivedSymbols[lookaheadSymbol] = newOffset - offset
                    if lookaheadType.lower() != lastLookaheadType: # locationType:
                        # The scope is irreparably too short and will
                        # be rejected.
                        offset = newOffset
                        print("# The scope for symbol %s is shorter "
                              "than the specified minimum length." \
                              % symbol)
                        found = True
                        break
                    # The scope is too short, but is eligible for
                    # combination with the next scope.
                    #symbolList.append(lookaheadSymbol)
                    lookahead[1] = "{" + lookahead[1] + "}"
                    lookahead[0] = lookahead[0].lower()
                    continue
                if locationType in ["i", "I"]:
                    interpretive = "I"
                else:
                    interpretive = ""
                #if len(symbolList) > 1:
                #    print("# Due to specified minimum length, "
                #          "combined scopes of symbols", symbolList)
                if not qrhack or hacks == emptyHacks:
                    hacks = ""
                print("%s %02o %04o %04o %s" % (normalize(symbol), bank, 
                    offset + coreOffset, newOffset + coreOffset, interpretive),
                    str(hacks).replace(" ",""))
                for derivedSymbol in derivedSymbols:
                    print("%s = %s + %o" % (normalize(derivedSymbol), 
                                     normalize(symbol), \
                                     derivedSymbols[derivedSymbol]))
                offset = newOffset
                found = True
                break
         
        # It's possible to have gotten here without having found the
        # end of the symbol's scope, if the bank has overflowed.
        # That's not possible with debugged AGC code, but it is with
        # (for example) a not-yet completed reconstruction.  That
        # final incomplete scope is simply rejected.
        if not found:
            break

# Make erasable searchable by symbol.
erasableBySymbol = {}
for address in range(sizeErasableBank):
    for bank in range(numErasableBanks):
        for symbol in erasable[address][bank]["symbols"]:
            erasableBySymbol[symbol] = (bank, address)
fixedSymbols = set()
for bank in range(numCoreBanks):
    for offset in range(sizeCoreBank):
        symbol = rope[offset][bank][1]
        if symbol[:1] == "{" and symbol[-1:] == "}":
            symbol = symbol[1:-1]
        if symbol != "" and symbol not in erasableBySymbol:
            fixedSymbols.add(symbol)
fixedInterpretiveReferencesBySymbol = {}

# Analyze the erasable and rope to find references to them from code.
checkForReferences(rope, erasable, erasableBySymbol, 
                    fixedSymbols, fixedInterpretiveReferencesBySymbol)
                    
# Output erasable specifications.  There are several types:
#   B   Operand of a single-word basic instruction (like XCH or CA)
#   C   A complemented basic instruction (like -CCS)
#   D	Operand of a double-word basic instruction (like DXCH or DCA).
#   S   Inline operand of interpretive STORE, STCALL, STODL, or STOVL
#   A   Normal argument of interpretive.
#   L   Normal argument of an interpretive that shouldn't be decremented.
#   I   Interpretive STXXX preceded by STADR.
#   E   Interpretive argument which doesn't decrement and has no bank number.
#   H   Like L, but interpretive half-memory.
#   K   Like I, but only for negative values.

print("# Erasables")
for bank in range(numErasableBanks):
    for i in range(len(erasable)):
        data = erasable[i][bank]
        if False: # Original method
            # The output lines have space-delimited fields as follows:
            #   The literal "+"
            #   List of symbols (w/o spaces)
            #   List of reference (w/o spaces).  Each reference is of the form of a
            #                                    tuple (spaces removed) with three 
            #                                    entries:
            #                                    Program label of containing subroutine.
            #                                    Offset (decimal) from start of subroutine.
            #                                    Type of reference.
            for i in range(len(data["symbols"])):
                data["symbols"][i] = normalize(data["symbols"][i])
            for i in range(len(data["references"])):
                d = list(data["references"][i])
                d[0] = normalize(d[0])
                data["references"][i] = tuple(d)
            if len(data["symbols"]) > 0 and len(data["references"]) > 0:
                print("+", str(data["symbols"]).replace(" ",""),
                      str(data["references"]).replace(" ", ""))
        else: # Newer method.
            # The output lines have the format:
            #   Literal "+"
            #   The symbol referenced.
            #   Program label of referencing subroutine.
            #   Non-negative offset (octal) from program label to reference.
            #   Type of reference.
            for i in range(len(data["references"])):
                d = list(data["references"][i])
                #print(d, file=sys.stderr)
                print("+", normalize(d[3]), normalize(d[0]), "%o" % d[1], d[2])
print("# Fixed references in basic")
for bank in range(numCoreBanks):
    for i in range(sizeCoreBank):
        data = rope[i][bank][4]
        if len(data) < 4 or data[3] == "":
            continue
        print("-", normalize(data[0]), normalize(data[1]), "%o" % data[2], data[3])
print("# Fixed references in interpretive")
for symbol in sorted(fixedInterpretiveReferencesBySymbol):
    refs = fixedInterpretiveReferencesBySymbol[symbol]
    for ref in refs:
        print("-", normalize(symbol), normalize(ref[0]), "%o" % ref[1], ref[2])
                  
if debug:
    # Print a report of the contents of the rope and erasable.
    # This can be used to determine if memory locations may
    # have been miscategorized by the analysis above.
    print("============================================================")
    print("Rope:")
    for bank in range(numCoreBanks):
        for i in range(len(rope)):
            data = rope[i][bank]
            print("%02o,%04o  %s   %-12s %-12s" % \
                (bank, i + coreOffset, data[0], data[1], data[2]), data[3])
    print("============================================================")
    print("Erasable:")
    for bank in range(numErasableBanks):
        for i in range(len(erasable)):
            data = erasable[i][bank]
            if len(data["symbols"]) > 0:
                print("E%o,%04o" % (bank, i + 0o1400), data)
    sys.exit(0)


