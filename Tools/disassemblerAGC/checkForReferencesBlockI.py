#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       checkForReferences.py
Purpose:        Check if code references fixed-memory or erasable locations
                as operands of basic instructions or arguments of interpretive
                opcodes.  This file is for Block I only.
History:        2022-10-14 RSB  Split off from disassemblerAGC.py.

Analyzes the erasable and rope to determine where *references* 
appear within the rope.  Each reference is identified by the 
subroutine in which it is referenced and the offset from the start
of the subroutine.  After patterns are matched, those can then be
used to converte to absolute addresses.
"""

from auxiliaryBlockI import *
from disassembleInterpretiveBlockI import interpreterOpcodes

# Detects interpretive opcodes that don't decrement their stand-alone
# arguments, and hence the arguments are marked as type 'L' rather than 'A'.
def dontDecrement(opcode):
    return ("," in opcode) or \
        opcode in ["CALL", "STQ", "GOTO", "STCALL", "BHIZ", "BMN",
                   "BOV", "BOVB", "BPL", "BZE", "CLRGO", "SETGO",
                   "BOFF", "BOF", "BOFCLR", "BOFINV", "BOFSET", "BON", "BONCLR",
                   "BONINV", "BONSET", "RTB"]

branches = ["CALL", "GOTO", "STCALL", "BHIZ", "BMN", "BOV", "BOVB", "BPL", 
            "BZE", "CLRGO", "SETGO", "BOFF", "BOF", "BOFCLR", "BOFINV", "BOFSET", 
            "BON", "BONCLR", "BONINV", "BONSET", "RTB"]

import sys
def checkForReferences(rope, erasable, erasableBySymbol, fixedSymbols,
                       fixedInterpretiveReferencesBySymbol):            

    for bank in range(startingCoreBank, numCoreBanks):
        lastLeft = ""
        lastRight = ""
        lastLeftComma = False
        lastRightComma = False
        left = ""
        right = ""
        lastSymbol = ""
        sinceSymbol = 0
        for offset in range(sizeCoreBank):
            lastLastLeft = ""
            lastLastRight = ""
            location = rope[offset][bank]
            for fixup in [1, 3]:
                if location[fixup][:1] == "{" and location[fixup][-1:] == "}":
                    location[fixup] = location[fixup][1:-1]
            if len(location[4]) > 0 and location[4][0][:1] == "{" \
                    and location[4][0][-1:] == "}":
                location[4][0] = location[4][0][1:-1]
            #print(location, file=sys.stderr)
            
            if location[0] not in ['b', 'B', 'i', 'I']:
                lastSymbol = ""
                continue
            if location[0] in ['B', 'I']:
                lastSymbol = location[1]
                sinceSymbol = -1
                #print(location, file=sys.stderr)
            sinceSymbol += 1
            if lastSymbol == "":
                print("Implementation error: Bad lastSymbol at %02o,%04o" \
                        % (bank, offset + coreOffset), location, sinceSymbol)
            operand = location[3]
            # This tracks just "pure" references to the symbols, as opposed to
            # (for example) SYMBOL +5.  I'd like to do the latter as well, but
            # I don't quite see how to do it for now.
            if location[2] != "":
                lastLastLeft = lastLeft
                lastLastRight = lastRight
                lastLeft = location[2]
                left = lastLeft
                if len(operand) == 1:
                    lastRight = operand[0]
                else:
                    lastRight = ""
                
                #if lastSymbol == "FBR3":
                #    print(location, operand, file=sys.stderr)
                
                if location[0] in ['i', 'I'] \
                        and lastRight in interpreterOpcodes:
                    continue                
                    
                lastLeftComma = dontDecrement(lastLeft)
                lastRightComma = dontDecrement(lastRight)
                
            if len(operand) == 1:
                # Try to determine if the operand is a simple numeric.
                rem = operand[0]
                if operand[0][:1] in ["+", "-"]:
                    rem = operand[0][1:]
                if rem[-1:] == "D":
                    rem = rem[:-1]
                if len(rem) > 0 and rem.isdigit():
                    continue
            if len(operand) != 1:
                continue
            referenceType = ""
            if location[0] in ['b', 'B'] and operand[0] not in erasableBySymbol:
                if lastLeft in ["TC", "TCF", "AD", "BZF", "BZMF", "CA", "CAF",
                                "CS", "MASK", "MP"]:
                    rope[offset][bank][4] = (operand[0], lastSymbol, sinceSymbol, "B")
                elif lastLeft in ["DCA", "DCS"]:
                    rope[offset][bank][4] = (operand[0], lastSymbol, sinceSymbol, "D")
            elif location[0] in ['b', 'B']:
                if location[2] in ["DAS", "DCA", "DCS", "DXCH"]:
                    referenceType = 'D'
                elif location[2][0] == "-":
                    referenceType = 'C'
                else:
                    referenceType = 'B'
            elif location[0] in ['i', 'I']:
                referenceType = 'A'
                if operand[0][-2:] in [",1", ",2"]:
                    symbol = operand[0][:-2]
                    indexed = True
                    # Maybe I should eventually deal with indexed arguments, 
                    # but they're rare and for right now are causing me 
                    # more trouble than they seem to be worth, so let's
                    # just discard them.
                    continue
                else:
                    symbol = operand[0]
                    indexed = False
                if symbol not in erasableBySymbol and symbol not in fixedSymbols:
                    continue
                fixed = True
                if symbol in erasableBySymbol:
                    fixed = False
                if lastLastLeft == "STADR" or lastLastRight == "STADR":
                    referenceType = 'I'
                elif location[2] == "0":
                    referenceType = "E"
                elif location[2] in ["STORE", "STCALL", "STODL", "STOVL", 
                                        "STODL*", "STOVL*"]:
                    referenceType = 'S'
                elif indexed:
                    referenceType = 'K'
                if referenceType != "" and fixed:
                    if symbol not in fixedInterpretiveReferencesBySymbol:
                        fixedInterpretiveReferencesBySymbol[symbol] = []
                    fixedInterpretiveReferencesBySymbol[symbol].append( \
                        (lastSymbol, sinceSymbol, referenceType) )
            else:
                continue
            if operand[0] in erasableBySymbol:
                symbolInfo = erasableBySymbol[operand[0]]
                b = symbolInfo[0]
                a = symbolInfo[1]
                erasable[a][b]["references"].append((lastSymbol,sinceSymbol,
                                                        referenceType,
                                                        operand[0]))
                        

