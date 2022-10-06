#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       specifyAGC.py
Purpose:        A lame way of producing a "specifications" file for 
                disassemblerAGC.py from a yaYUL assembly listing.
History:        2022-10-05 RSB  Wrote.
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
    "CADR": 'd',
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
minLength = 8
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
                    8.  If possible, adjacent symbol scopes will be combined
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
    rope.append([('u', "", "")]*0o44)

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
    
    fixedAddress = line[15:22].strip()
    fields = fixedAddress.split(",")
    if fields[0] == "":
        continue
    if len(fields) == 1 and fields[0].isdigit():
        address = int(fields[0], 8)
        if address < 0o4000 or address > 0o7777:
            continue
        bank = address // 0o2000
        address = (address % 0o2000) + 0o2000
    elif len(fields) == 2 and fields[0].isdigit() \
            and fields[1] != "" and fields[1].isdigit():
        bank = int(fields[0], 8)
        address = int(fields[1], 8)
        if bank < 0 or bank > 0o43 or address < 0o2000 or address > 3777:
            continue
    else:
        continue
    offset = address % 0o2000
    
    octal = line[32:37]
    if octal == "     ":
        continue
    octal2 = line[38:46].strip()
    
    symbol = line[46:54].strip()
    
    locationType = "u"
    left = line[65:73].strip()
    if left in interpreterOpcodes:
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
            locationType = rope[offset - 1][bank][0]
    
    rope[offset][bank] = (locationType, symbol, left)
    if octal2 != "":
        rope[offset + 1][bank] = (locationType.lower(), "", "")

if debug:
    # Just print a report of the contents of the rope array.
    # This can be used to determine if memory locations may
    # have been miscategorized by the analysis above.
    for bank in range(0o44):
        for i in range(len(rope)):
            data = rope[i][bank]
            print("%02o,%04o  %s   %-12s %-12s" % \
                (bank, i + 0o2000, data[0], data[1], data[2]))
    sys.exit(0)

# Convert the contents of the rope array into a specifications file.
# Each bank can be analyzed separately.

print("# Specification file suitable for disassemblerAGC.py --specs, "
      "auto-generated by specifyAGC.py.")
print("# The minimum length of specifications is set "
      "to %d words." % minLength)
nonCode = ['u', 'd', 'D']
rsbCount = 0
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
        # RSBnnnnn, where nnnnn is a number that increments with 
        # each label.
        if symbol == "":
            symbol = "RSB%05d" % rsbCount
            rsbCount += 1
    
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
                    if lookaheadType in nonCode:
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
                    continue
                if locationType in ["i", "I"]:
                    interpretive = "I"
                else:
                    interpretive = ""
                if len(symbolList) > 1:
                    print("# Due to specified minimum length, "
                          "combined scopes of symbols", symbolList)
                print("%s %02o %04o %04o %s" % (symbol, bank, 
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
            
