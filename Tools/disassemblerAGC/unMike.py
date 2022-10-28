#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       unMike.py
Purpose:        This one-off program (used for Sundial E) is used to
                convert the invented labels UBB,XXXX in Mike's 
                sundiale.disagc file to a file of patterns usable with
                disassemblerAGC.py's --flex option.  
History:        2022-10-28 RSB  Created.

In retrospect, this is completely the wrong thing to do.  I mean, it does
produce a result -- with enough effort -- but it's reinventing the wheel.
What I *should* have done is simply to reformat Mike's file so that it 
had the same column alignment as a normal listing file produced by yaYUL.
Having done that, I could treat Mike's file as a BASELINE, process it 
with specifyAGC.py, and then treated any other AGC versions I wanted to
test it against as ROPEs with disassemblerAGC.py --find.
"""

import sys

block1 = False
blk2 = False
for param in sys.argv[1:]:
    if param == "--block1":
        block1 = True
    if param == "--blk2":
        blk2 = True

if block1:
    from disassembleInterpretiveBlockI import interpreterOpcodes
elif blk2:
    from disassembleInterpretiveBLK2 import interpreterOpcodes
else:
    from disassembleInterpretive import interpreterOpcodes

lines = sys.stdin.readlines()

# An incomplete list.
dataPseudo = ["OCT", "2OCT", "DEC", "2DEC", "CADR", "2CADR",
                "BNKSUM", "BLOCK", "BANK", "SETLOC", "ECADR"]

def massage(basic, left, right):
    if basic:
        if left == "TC":
            if right == 'INTPRET':
                basic = False
            if right == 'Q':
                left = "RETURN"
                right = ""
        if right != "INTPRET":
            right = ""
        else:
            right = '"INTPRET"'
        if left == "CAF":
            left = "CA"
        if left == "OVSK":
            left = "TS"
            right = '"A"'
        if left == "ZL":
            left = "LXCH"
            right = '"ZERO"'
        if left == "COM":
            left = "CS"
            right = '"A"'
        if left == "DDOUBL":
            left = "DAS"
            right = '"L"'
    else:
        if left == "VSL1":
            left = "SL1R"
        if right == "VSL1":
            right = "SL1R"
        if left == "VCOMP":
            left = "DCOMP"
        if right == "VCOMP":
            right = "DCOMP"
        if left in ["STORE", "STODL", "STCALL", "STOVL"]:
            right = ""
        elif right not in interpreterOpcodes:
            right = ""
        else:
            right = '"%s"' % right
        if left == "EXIT" or right == "EXIT":
            basic = True
    if left == "@":
        left = ""
    return basic, left, right

index = 0  

while True:

    # Search for next invented label.
    found = False
    for i in range(index, len(lines)):
        line = lines[i]
        if ":" not in line or len(line) < 28:
            continue
        try:
            symbol = line[17:25].strip()
            fields = symbol.split(",")
            if len(fields) != 2:
                continue
            if fields[0][0] != "U":
                continue
            BB = int(fields[0][1:], 8)
            XXXX = int(fields[1], 8)
            found = True
            index = i
            break
        except:
            continue
    if not found:
        break
        
    # We're now at the start of an invented label, symbol, and have set
    # BB, XXXX, and index appropriately.  We need to generate a pattern
    # for it, starting here and continuing until hitting either the 
    # next symbol (invented or not) or data or the end of file.
    if line[26] == " ":
        line = line[:26] + "@" + line[27:]
        line[26] = "@"
    fields = line.split()
    if symbol != fields[3]:
        print("Implementation error", file=sys.stderr)
        sys.exit(1)
    left = fields[4]
    if left == "" or left in dataPseudo:
        index += 1
        continue
    right = ""
    if len(fields) > 5:
        right = fields[5]
    basic = (left != "" and left not in interpreterOpcodes)
    print('  "%s": [{' % symbol)
    print('    "dataWords": 0,')
    print('    "noReturn": False,')
    print('    "basic": %r,' % basic)
    print('    "pattern": [')
    basic, left, right = massage(basic, left, right)
    print('      [True, ["%s"], [%s]],' % (left, right))
    
    for i in range(index + 1, len(lines)):
        line = lines[i]
        possibleSymbol = line[17:25].strip()
        if possibleSymbol != "":
            break
        if ":" not in line or len(line) < 28:
            continue
        line = line[:17] + "@" + line[18:]
        try:
            if line[26] == " ":
                line = line[:26] + "@" + line[27:]
        except:
            print('"%s"' % line, file=sys.stderr)
            sys.exit(1)
        fields = line.split()
        left = fields[4]
        right = ""
        if len(fields) > 5:
            right = fields[5]
        if left in dataPseudo:
            break
        basic, left, right = massage(basic, left, right)
        print('      [True, ["%s"], [%s]],' % (left, right))
    index = i
    
    print('    ],')
    print('    "ranges": []')
    print('  }],')
    
    if index >= len(lines):
        break
