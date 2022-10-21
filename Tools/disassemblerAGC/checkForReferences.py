#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       checkForReferences.py
Purpose:        Check if code references fixed-memory or erasable locations
                as operands of basic instructions or arguments of interpretive
                opcodes.  This file is for Block II only.
History:        2022-10-14 RSB  Split off from disassemblerAGC.py.

Analyzes the erasable and rope to determine where *references* 
appear within the rope.  Each reference is identified by the 
subroutine in which it is referenced and the offset from the start
of the subroutine.  After patterns are matched, those can then be
used to converte to absolute addresses.
"""

from auxiliary import *
from disassembleInterpretive import interpreterOpcodes

# Detects interpretive opcodes that don't decrement their stand-alone
# arguments, and hence the arguments are marked as type 'L' rather than 'A'.
def dontDecrement(opcode):
    return ("," in opcode) or \
        opcode in ["CALL", "STQ", "GOTO", "STCALL", "BHIZ", "BMN",
                   "BOV", "BOVB", "BPL", "BZE", "CLRGO", "SETGO",
                   "BOFF", "BOF", "BOFCLR", "BOFINV", "BOFSET", "BON", "BONCLR",
                   "BONINV", "BONSET", "RTB", "CCALL"]

branches = ["CALL", "GOTO", "STCALL", "BHIZ", "BMN", "BOV", "BOVB", "BPL", 
            "BZE", "CLRGO", "SETGO", "BOFF", "BOF", "BOFCLR", "BOFINV", "BOFSET", 
            "BON", "BONCLR", "BONINV", "BONSET", "RTB", "CCALL"]
            
def checkForReferences(rope, erasable, erasableBySymbol,  
                        fixedSymbols, fixedInterpretiveReferencesBySymbol):            
    
    for bank in range(numCoreBanks):
        lastLeft = ""
        lastRight = ""
        lastLeftComma = False
        lastRightComma = False
        left = ""
        right = ""
        argCount = -1
        lastSymbol = ""
        sinceSymbol = 0
        for offset in range(sizeCoreBank):
            argCount += 1
            lastLastLeft = ""
            lastLastRight = ""
            location = rope[offset][bank]
            for fixup in [1, 3]:
                if location[fixup][:1] == "{" and location[fixup][-1:] == "}":
                    location[fixup] = location[fixup][1:-1]
            if len(location[4]) > 0 and location[4][0][:1] == "{" \
                    and location[4][0][-1:] == "}":
                location[4][0] = location[4][0][1:-1]
            if location[0] not in ['b', 'B', 'i', 'I']:
                lastSymbol = ""
                argCount = -1
                continue
            if location[0] in ['B', 'I']:
                lastSymbol = location[1]
                sinceSymbol = -1
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
                    
                lastLeftComma = dontDecrement(lastLeft)
                lastRightComma = dontDecrement(lastRight)
                
                # Check number of interpretive arguments, if applicable.
                argCount = 0
                numLeftArgs = 0
                numRightArgs = 0
                argTypes = ['A']*5
                if location[0] in ['i', 'I']:
                    if lastLeft in interpreterOpcodes:
                        numLeftArgs = interpreterOpcodes[lastLeft][2]
                        if lastRight in interpreterOpcodes:
                            numRightArgs = interpreterOpcodes[lastRight][2]
                    elif lastLeft == "STCALL":
                        numLeftArgs = 1
                    i = 1
                    for j in range(numLeftArgs):
                        if lastLeftComma and j == numLeftArgs - 1:
                            argTypes[i] = 'L'
                            if lastLeft not in branches:
                                argTypes[i] = 'H'
                        elif j == numLeftArgs - 1 and lastLeft in ['SSP']:
                            argTypes[i] = 'L'
                        i += 1
                    for j in range(numRightArgs):
                        if lastRightComma and j == numRightArgs - 1:
                            argTypes[i] = 'L'
                            if lastRight not in branches:
                                argTypes[i] = 'H'
                        elif j == numRightArgs - 1 and \
                                lastRight in ['SSP', 'CGOTO', 'CCALL']:
                            argTypes[i] = 'L'
                        i += 1  
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
                if lastLeft in ["TC", "TCF", "AD", "BZF", "BZMF", "CA",
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
                elif argCount > 0:
                    referenceType = argTypes[argCount]
                    #print("#", referenceType, argCount, argTypes, location)
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
                        

