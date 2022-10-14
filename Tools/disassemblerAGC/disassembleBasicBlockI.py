#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       disassembleBasicBlockI.py
Purpose:        Disassembler for a basic word, for the Block I AGC.
History:        2022-10-13 RSB  Wrote.
"""

from registersBlockI import registersAndIoChannels

# Disassemble a word containing a basic instruction.  This has the same
# interface as the Block II disassembleBasic() function in disassembleBasic.py.
# I basically just follow what it says in the "Basic Insruction Representation"
# and "Basic Instruction Set" sections of 
# http://www.ibiblio.org/apollo/Block1.html.
def disassembleBasic(word, extended):
    newExtended = False
    CCC = word & 0o70000
    AAA_AAA = word & 0o07777
    opcodeString = "?"
    operandString = "%04o" % AAA_AAA
    if operandString in registersAndIoChannels:
        operandString = registersAndIoChannels[operandString]
    if CCC == 0o00000:
        opcodeString = "TC"   
        if operandString == "A":
            opcodeString = "XAQ"
            operandString = ""
        elif operandString == "Q":
            opcodeString = "RETURN"
            operandString = ""
    elif CCC == 0o10000:
        opcodeString = "CCS"   
    elif CCC == 0o20000:
        opcodeString = "INDEX" 
        if operandString in ["0016", "RELINT"]:
            opcodeString = "RELINT"
            operandString = ""
        elif operandString in ["0017", "INHINT"]:
            opcodeString = "INHINT"
            operandString = ""
        elif operandString == "BRUPT": # 0025
            opcodeString = "RESUME"
            operandString = ""
        elif operandString == "5777":
            opcodeString = "EXTEND"
            operandString = ""  
            newExtended = True
    elif CCC == 0o30000:
        if operandString.isdigit() and int(operandString, 8) >= 0o2000:
            opcodeString = "CAF"
        else:
            opcodeString = "XCH" 
        if operandString == "A":
            opcodeString = "NOOP"
            operandString = ""
    elif CCC == 0o40000:
        if extended:
            opcodeString = "MP"
            if operandString == "A":
                opcodeString = "SQUARE"
                operandString = ""
        else:
            opcodeString = "CS"   
            if operandString == "A":
                opcodeString = "COM" 
                operandString = ""
    elif CCC == 0o50000:
        if extended:
            opcodeString = "DV"
        else:
            if operandString.isdigit() and int(operandString, 8) >= 0o2000:
                opcodeString = "OVIND"
            else:
                opcodeString = "TS"   
            if operandString == "A":
                opcodeString = "OVSK"
                operandString = ""
            elif operandString == "Z":
                opcodeString = "TCAA"
                operandString = ""
    elif CCC == 0o60000:
        if extended:
            opcodeString = "SU"
        else:
            opcodeString = "AD"
            if operandString == "A":
                opcodeString = "DOUBLE"
                operandString = ""
    elif CCC == 0o70000:
        opcodeString = "MASK"   

    return opcodeString, operandString, newExtended

