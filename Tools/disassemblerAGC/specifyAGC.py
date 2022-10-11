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
"""

import sys
from disassembleInterpretive import interpreterOpcodes

# Here's a list of opcodes and pseudo-ops I pasted in from 
# yaYUL/Pass.c (ParsersBlock2) and then massaged a bit.
# Pseudo-ops which allocate no rope are commented out.
ParsersBlock2 = {
    "-1DNADR": 'd',
    "-2CADR": 'd',
    "-2DNADR": 'd',
    "-3DNADR": 'd',
    "-4DNADR": 'd',
    "-5DNADR": 'd',
    "-6DNADR": 'd',
    "-CCS": 'b',
    "-DNCHAN": 'd',
    "-DNPTR": 'd',
    "-GENADR": 'd',
    #"=": 'd',
    #"=ECADR": 'd',
    #"=MINUS": 'd',
    "1DNADR": 'd',
    "2BCADR": 'd',
    "2CADR": 'd',
    "2DEC": 'd',
    "2DEC*": 'd',
    "2DNADR": 'd',
    "2FCADR": 'd',
    "2OCT": 'd',
    "3DNADR": 'd',
    "4DNADR": 'd',
    "5DNADR": 'd',
    "6DNADR": 'd',
    "AD": 'b',
    "ADRES": 'd',
    "ADS": 'b',
    "AUG": 'b',
    #"BANK": 'd',
    #"BLOCK": 'd',
    "BBCON": 'd',
    "BBCON*": 'd',
    #"BNKSUM": 'd',
    "BZF": 'b',
    "BZMF": 'b',
    "CA": 'b',
    "CAE": 'b',
    "CAF": 'b',
    #"CADR": 'd',
    "CCS": 'b',
    #"CHECK=": 'd',
    "COM": 'b',
    #"COUNT": 'd',
    #"COUNT*": 'd',
    "CS": 'b',
    "DAS": 'b',
    "DCA": 'b',
    "DCOM": 'b',
    "DCS": 'b',
    "DDOUBL": 'b',
    "DEC": 'd',
    "DEC*": 'd',
    "DIM": 'b',
    "DNCHAN": 'd',
    "DNPTR": 'd',
    "DOUBLE": 'b',
    "DTCB": 'b',
    "DTCF": 'b',
    "DV": 'b',
    "DXCH": 'b',
    #"EBANK=": 'd',
    "ECADR": 'd',
    "EDRUPT": 'b',
    #"EQUALS": 'd',
    #"ERASE": 'd',
    "EXTEND": 'b',
    "FCADR": 'd',
    "GENADR": 'd',
    "INCR": 'b',
    "INDEX": 'b',
    "INHINT": 'b',
    "LXCH": 'b',
    "MASK": 'b',
    "MSK": 'b',
    #"MEMORY": 'd',
    "MM": 'd',
    "MP": 'b',
    "MSU": 'b',
    "NDX": 'b',
    "NOOP": 'b',
    "NV": 'd',
    "OCT": 'd',
    "OCTAL": 'd',
    "OVSK": 'b',
    "QXCH": 'b',
    "RAND": 'b',
    "READ": 'b',
    "RELINT": 'b',
    "REMADR": 'd',
    "RESUME": 'b',
    "RETURN": 'b',
    "ROR": 'b',
    "RXOR": 'b',
    #"SBANK=": 'd',
    #"SECSIZ": 'd',
    #"SETLOC": 'd',
    "SQUARE": 'b',
    "STCALL": 'i',
    "STODL": 'i',
    "STODL*": 'i',
    "STORE": 'i',
    "STOVL": 'i',
    "STOVL*": 'i',
    "SU": 'b',
    "SUBRO": 'd',
    "TC": 'b',
    "TCR": 'b',
    "TCAA": 'b',
    "TCF": 'b',
    "TS": 'b',
    "VN": 'd',
    "WAND": 'b',
    "WOR": 'b',
    "WRITE": 'b',
    "XCH": 'b',
    "XLQ": 'b',
    "XXALQ": 'b',
    "ZL": 'b',
    "ZQ": 'b'
}

debug = False
minLength = 12
for param in sys.argv[1:]:
    if param == "--debug":
        debug = True
    elif param[:6] == "--min=":
        minLength = int(param[6:])
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
        """)
    else:
        print("Unknown parameter:", param)
        sys.exit(1)

# Initialization of data structures.
rope = []
for address in range(0o2000):
    rope.append([['u', "", "", []]]*0o44)
erasable = []
for address in range(0o400):
    erasable.append([])
    for bank in range(8):
        erasable[address].append({ "symbols": [], "references": []})

# Read and analyze the assembly listing.  Afterward, the rope array contains
# a description, for each fixed-memory location, of the type of location and
# the symbol associated with it, if any.  The types are:
#   "u"             unused
#   "d" or "D"      data, w/o or w/ a symbolic name
#   "b" or "B"      basic, w/o or w/ a program label
#   "i" or "I"      interpretive (including arguments), w/o or w/ a symbol
# This program is unaware of the disassembler's "special symbols" -- i.e.,
# those which accept a data argument immediately following their invocation
# via TC -- and hence characterizes those locations as data rather than as
# basic.
for line in sys.stdin:
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

    left = line[65:73].strip()
    
    addressField = line[24:31].strip()
    if left in ["=", "EQUALS", "CHECK="] and \
            (addressField == "" or addressField.isdigit()):
        continue
    if left == "ERASE" and addressField == "" and line[74:82].strip().isdigit() and \
            line[85:93].strip() == "-" and line[96:104].strip().isdigit():
        addressField = line[74:82].strip()
    if addressField == "" or addressField[:4] == "0000":
        addressField = line[15:22].strip()
        if addressField[:1] == "?":
            continue
    fields = addressField.split(",")
    fixed = True
    if fields[0] == "":
        continue
    elif len(fields) == 1 and fields[0].isdigit():
        address = int(fields[0], 8)
        if address < 0o1400:
            fixed = False
            bank = address // 0o400
            address = (address % 0o400) + 0o1400 
        else:
            if address < 0o4000 or address > 0o7777:
                continue
            bank = address // 0o2000
            address = (address % 0o2000) + 0o2000
    elif len(fields) == 2 and fields[0][0] == "E" and fields[0][1].isdigit() \
            and fields[1] != "" and fields[1].isdigit():
        fixed = False
        bank = int(fields[0][1], 8)
        address = int(fields[1], 8)
        if bank < 0 or bank > 7 or address < 0o1400 or address > 0o1777:
            continue
    elif len(fields) == 2 and fields[0].isdigit() \
            and fields[1] != "" and fields[1].isdigit():
        bank = int(fields[0], 8)
        address = int(fields[1], 8)
        if bank < 0 or bank > 0o43 or address < 0o2000 or address > 0o3777:
            continue
    else:
        continue
    if fixed:
        offset = address % 0o2000
    else:
        offset = address % 0o400
    
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
    if not fixed:
        if symbol != "":
            erasable[offset][bank]["symbols"].append(symbol)
        continue
    
    locationType = "u"
    if left in interpreterOpcodes or left.isdigit():
        if symbol == "":
            locationType = "i"
        else:
            locationType = "I"
    elif left in ParsersBlock2:
        if symbol == "":
            locationType = ParsersBlock2[left]
        else:
            locationType = ParsersBlock2[left].upper()
    elif (left == "" or left.isdigit()) and offset > 0:
            locationType = rope[offset - 1][bank][0].lower()
    
    right = line[74:112].strip().split()
    
    rope[offset][bank] = [locationType, symbol, left, right]
    if octal2 != "":
        rope[offset + 1][bank] = [locationType.lower(), "", "", []]

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
for bank in range(0o44):
    offset = 0
    while True:
        if offset >= 0o2000:
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
            symbol = "R%02o,%04o" % (bank, offset + 0o2000)
            rope[offset][bank][0] = rope[offset][bank][0].upper()
            rope[offset][bank][1] = symbol
    
        # Let's look ahead, to find either the next symbol or
        # else a change to data, either one of which would be
        # the end of scope for the current code area.
        symbolList = [symbol]
        found = False
        for newOffset in range(offset + 1, 0o2000):
            lookahead = rope[newOffset][bank]
            lookaheadType = lookahead[0]
            lookaheadSymbol = lookahead[1]
            if lookaheadType in nonCode or lookaheadSymbol != "":
                if newOffset < offset + minLength:
                    if lookaheadType != locationType:
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
                    symbolList.append(lookaheadSymbol)
                    lookahead[1] = "{" + lookahead[1] + "}"
                    lookahead[0] = lookahead[0].lower()
                    continue
                if locationType in ["i", "I"]:
                    interpretive = "I"
                else:
                    interpretive = ""
                if len(symbolList) > 1:
                    print("# Due to specified minimum length, "
                          "combined scopes of symbols", symbolList)
                print("%s %02o %04o %04o %s" % (normalize(symbol), bank, 
                    offset + 0o2000, newOffset + 0o2000, interpretive))
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
for address in range(0o400):
    for bank in range(8):
        for symbol in erasable[address][bank]["symbols"]:
            erasableBySymbol[symbol] = (bank, address)

# Analyze the erasable and rope to determine where erasable references 
# appear within the rope.  Each reference is identified by the 
# subroutine in which it is referenced and the offset from the start
# of the subroutine.  After patterns are matched, those can then be
# converted to absolute addresses.

# Detects interpretive opcodes that don't decrement their stand-alone
# arguments, and hence the arguments are marked as type 'L' rather than 'A'.
def dontDecrement(opcode):
    return ("," in opcode) or \
        opcode in ["CALL", "STQ", "GOTO", "STCALL", "BHIZ", "BMN",
                   "BOV", "BOVB", "BPL", "BZE", "CLRGO", "SETGO",
                   "BOFF", "BOFCLR", "BOFINV", "BOFSET", "BON", "BONCLR",
                   "BONINV", "BONSET"]

for bank in range(0o44):
    lastLeft = ""
    lastRight = ""
    lastLeftComma = False
    lastRightComma = False
    left = ""
    right = ""
    argCount = 0
    lastSymbol = ""
    sinceSymbol = 0
    for offset in range(0o2000):
        lastLastLeft = ""
        lastLastRight = ""
        location = rope[offset][bank]
        if location[0] not in ['b', 'B', 'i', 'I']:
            lastSymbol = ""
            continue
        if location[0] in ['B', 'I']:
            lastSymbol = location[1]
            sinceSymbol = -1
        sinceSymbol += 1
        if lastSymbol == "":
            print("Implementation error: Bad lastSymbol at %02o,%04o" \
                    % (bank, offset + 0o2000))
        operand = location[3]
        # This tracks just "pure" references to the symbols, as opposed to
        # (for example) SYMBOL +5.  I'd like to do the latter as well, but
        # I don't quite see how to do it for now.
        if location[2] != "":
            argCount = -1
            lastLastLeft = lastLeft
            lastLastRight = lastRight
            lastLeft = location[2]
            left = lastLeft
            if len(operand) == 1:
                lastRight = operand[0]
            else:
                lastRight = ""
            lastLeftComma = dontDecrement(lastLeft)
            lastRightComma = dontDecrement(lastRight)
            numLeftArgs = 0
            numRightArgs = 0
            argTypes = ['A']*4
            if location[0] in ['i', 'I']:
                if lastLeft in interpreterOpcodes:
                    numLeftArgs = interpreterOpcodes[lastLeft][2]
                    if lastRight in interpreterOpcodes:
                        numRightArgs = interpreterOpcodes[lastRight][2]
                elif lastLeft == "STCALL":
                    numLeftArgs = 1
                i = 0
                for j in range(numLeftArgs):
                    if lastLeftComma:
                        argTypes[i] = 'L'
                    i += 1
                for j in range(numRightArgs):
                    if lastRightComma:
                        argTypes[i] = 'L'
                    i += 1      
        argCount += 1
        #print("%02o,%04o '%s' '%s' '%s' '%s'" % (bank, offset+0o2000, lastLeft, \
        #                                lastRight, lastLastLeft, lastLastRight))
        if len(operand) == 1 and operand[0] in erasableBySymbol:
            if location[0] in ['b', 'B']:
                if location[2] in ["DAS", "DCA", "DCS", "DXCH"]:
                    referenceType = 'D'
                elif location[2][0] == "-":
                    referenceType = 'C'
                else:
                    referenceType = 'B'
            elif location[0] in ['i', 'I']:
                referenceType = 'A'
                if lastLastLeft == "STADR" or lastLastRight == "STADR":
                    referenceType = 'I'
                elif location[2] == "0":
                    referenceType = "E"
                elif location[2] in ["STORE", "STCALL", "STODL", "STOVL"]:
                    referenceType = 'S'
                elif argCount > 0:
                    referenceType = argTypes[argCount - 1]
            else:
                continue
            symbolInfo = erasableBySymbol[operand[0]]
            b = symbolInfo[0]
            a = symbolInfo[1]
            erasable[a][b]["references"].append((lastSymbol,sinceSymbol,
                                                    referenceType))
        
# Output erasable specifications.  There are several types:
#   B   Operand of a single-word basic instruction (like XCH or CA)
#   C   A complemented basic instruction (like -CCS)
#   D	Operand of a double-word basic instruction (like DXCH or DCA).
#   S   Inline operand of interpretive STORE, STCALL, STODL, or STOVL
#   A   Normal argument of interpretive.
#   L   Normal argument of an interpretive index opcode such as LXC,1.
#   I   Interpretive STXXX preceded by STADR.
#   E   Interpretive argument which doesn't decrement and has no bank number.

# The output lines have space-delimited fields as follows:
#   The literal "+"
#   List of symbols (w/o spaces)
#   List of reference (w/o spaces).  Each reference is of the form of a
#                                    tuple (spaces removed) with three 
#                                    entries:
#                                    Program label of containing subroutine.
#                                    Offset (decimal) from start of subroutine.
#                                    Type of reference.
print("# Erasables")
for bank in range(8):
    for i in range(len(erasable)):
        data = erasable[i][bank]
        for i in range(len(data["symbols"])):
            data["symbols"][i] = normalize(data["symbols"][i])
        for i in range(len(data["references"])):
            d = list(data["references"][i])
            d[0] = normalize(d[0])
            data["references"][i] = tuple(d)
        if len(data["symbols"]) > 0 and len(data["references"]) > 0:
            print("+", str(data["symbols"]).replace(" ",""),
                  str(data["references"]).replace(" ", ""))
                  
if debug:
    # Print a report of the contents of the rope and erasable.
    # This can be used to determine if memory locations may
    # have been miscategorized by the analysis above.
    print("============================================================")
    print("Rope:")
    for bank in range(0o44):
        for i in range(len(rope)):
            data = rope[i][bank]
            print("%02o,%04o  %s   %-12s %-12s" % \
                (bank, i + 0o2000, data[0], data[1], data[2]), data[3])
    print("============================================================")
    print("Erasable:")
    for bank in range(8):
        for i in range(len(erasable)):
            data = erasable[i][bank]
            if len(data["symbols"]) > 0:
                print("E%o,%04o" % (bank, i + 0o1400), data)
    sys.exit(0)


