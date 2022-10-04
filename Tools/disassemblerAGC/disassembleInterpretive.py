#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       disassemblerInterpretive.py
Purpose:        Disassemble a word from an interpretive location.
History:        2022-09-28 RSB  Split off from disassemblerAGC.py.
"""

from engineering import endOfImplementation

# Disassemble a word for an interpretive location. 
# I got interpreterOpcodes from yaYUL/Pass.c, and just simple-mindedly 
# converted it to a Python3 acceptable form without regard to suitability.
# The fields (from yaYUL/yaYUL.h) were defined in C as:
#    typedef struct
#    {
#      char Name[MAX_LABEL_LENGTH + 1];
#      unsigned char Code;
#      unsigned char NumOperands;
#      unsigned char SwitchInstruction;      // 0 normally, 1 switch, 2 shifts.
#      int nnnn0000;
#      unsigned char ArgTypes[2];
#    } InterpreterMatch_t;
# The uninitialized fields below must be assumed to be 0.
# STORE, STCALL, STODL, and STOVL aren't included in interpretiveOpcodesRaw,
# as they must be handled differently.
interpreterOpcodesRaw = (
    ( "ABS", 0o0130, 0 ), 
    # ( "ABVAL", 0o0130, 0 ), 
    # ( "ARCCOS", 0o0050, 0 ), 
    ( "ACOS", 0o0050, 0 ),
    # ( "ARCSIN", 0o0040, 0 ), 
    ( "ASIN", 0o0040, 0 ),
    ( "AXC,1", 0o0016, 1 ), ( "AXC,2", 0o0012, 1 ),
    ( "AXT,1", 0o0006, 1 ), ( "AXT,2", 0o0002, 1 ),
    ( "BDDV", 0o0111, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "BDDV*", 0o0113, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "BDSU", 0o0155, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "BDSU*", 0o0157, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "BHIZ", 0o0146, 1 ), ( "BMN", 0o0136, 1 ),
    ( "BOFCLR", 0o0162, 2, 1, 0o000241 ), 
    # ( "BOF", 0o0162, 2, 1, 0o000341 ),
    ( "BOFF", 0o0162, 2, 1, 0o000341 ), 
    ( "BOFINV", 0o0162, 2, 1, 0o000141 ),
    ( "BOFSET", 0o0162, 2, 1, 0o000041 ), 
    ( "BON", 0o0162, 2, 1, 0o000301 ),
    ( "BONCLR", 0o0162, 2, 1, 0o000201 ), 
    ( "BONINV", 0o0162, 2, 1, 0o000101 ),
    ( "BONSET", 0o0162, 2, 1, 0o000001 ), 
    ( "BOV", 0o0176, 1 ),
    ( "BOVB", 0o0172, 1 ), ( "BPL", 0o0132, 1 ), 
    ( "BVSU", 0o0131, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "BVSU*", 0o0133, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "BZE", 0o0122, 1 ), ( "CALL", 0o0152, 1 ), 
    ( "CALRB", 0o0152, 1 ),
    ( "CCALL", 0o0065, 2, 0, 0o000000, ( 1, 0 ) ),
    ( "CCALL*", 0o0067, 2, 0, 0o000000, ( 1, 0 ) ),
    ( "CGOTO", 0o0021, 2, 0, 0o000000, ( 1, 0 ) ),
    ( "CGOTO*", 0o0023, 2, 0, 0o000000, ( 1, 0 ) ),
    ( "CLEAR", 0o0162, 1, 1, 0o000261 ), 
    ( "CLR", 0o0162, 1, 1, 0o000261 ),
    ( "CLRGO", 0o0162, 2, 1, 0o000221 ), 
    ( "COS", 0o0030, 0 ),
    ( "COSINE", 0o0030, 0 ), 
    ( "DAD", 0o0161, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DAD*", 0o0163, 1, 0, 0o000000, ( 1, 0 ) ), 
    ( "DCOMP", 0o0100, 0 ),
    ( "DDV", 0o0105, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DDV*", 0o0107, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DLOAD", 0o0031, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DLOAD*", 0o0033, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DMP", 0o0171, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DMP*", 0o0173, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DMPR", 0o0101, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DMPR*", 0o0103, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DOT", 0o0135, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DOT*", 0o0137, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DSQ", 0o0060, 0 ), 
    ( "DSU", 0o0151, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "DSU*", 0o0153, 1, 0, 0o000000, ( 1, 0 ) ), 
    ( "EXIT", 0o0000, 0 ),
    ( "GOTO", 0o0126, 1 ), 
    ( "INCR,1", 0o0066, 1 ), 
    ( "INCR,2", 0o0062, 1 ),
    ( "INVERT", 0o0162, 1, 1, 0o000161 ), 
    ( "INVGO", 0o0162, 2, 1, 0o000121 ),
    #( "ITA", 0o0156, 1 ), 
    #( "ITCQ", 0o0160, 0 ), 
    ( "LXA,1", 0o0026, 1 ),
    ( "LXA,2", 0o0022, 1 ), 
    ( "LXC,1", 0o0036, 1 ), 
    ( "LXC,2", 0o0032, 1 ),
    ( "MXV", 0o0055, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "MXV*", 0o0057, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "NORM", 0o0075, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "NORM*", 0o0077, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "PDDL", 0o0051, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "PDDL*", 0o0053, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "PDVL", 0o0061, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "PDVL*", 0o0063, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "PUSH", 0o0170, 0 ), ( "ROUND", 0o0070, 0 ),
    ( "RTB", 0o0142, 1 ), 
    ( "RVQ", 0o0160, 0 ),
    ( "SET", 0o0162, 1, 1, 0o000061 ), 
    ( "SETGO", 0o0162, 2, 1, 0o000021 ),
    ( "SETPD", 0o0175, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "SIGN", 0o0011, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "SIGN*", 0o0013, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "SIN", 0o0020, 0 ), ( "SINE", 0o0020, 0 ),
    ( "SL", 0o0115, 1, 2, 0o020202, ( 1, 0 ) ),
    ( "SL*", 0o0117, 1, 2, 0o020202, ( 1, 0 ) ),
    ( "SLOAD", 0o0041, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "SLOAD*", 0o0043, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "SL1", 0o0024, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SL1R", 0o0004, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SL2", 0o0064, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SL2R", 0o0044, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SL3", 0o0124, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SL3R", 0o0104, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SL4", 0o0164, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SL4R", 0o0144, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SLR", 0o0115, 1, 2, 0o021202, ( 1, 0 ) ),
    ( "SLR*", 0o0117, 1, 2, 0o021202, ( 1, 0 ) ),
    ( "SQRT", 0o0010, 0 ), 
    ( "SR", 0o0115, 1, 2, 0o020602, ( 1, 0 ) ),
    ( "SR*", 0o0117, 1, 2, 0o020602, ( 1, 0 ) ),
    ( "SR1", 0o0034, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SR1R", 0o0014, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SR2", 0o0074, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SR2R", 0o0054, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SR3", 0o0134, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SR3R", 0o0114, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SR4", 0o0174, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SR4R", 0o0154, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "SRR", 0o0115, 1, 2, 0o021602, ( 1, 0 ) ),
    ( "SRR*", 0o0117, 1, 2, 0o021602, ( 1, 0 ) ),
    ( "SSP", 0o0045, 2, 0, 0o000000, ( 1, 0 ) ),
    ( "SSP*", 0o0047, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "STADR", 0o0150, 0 ), 
    ( "STQ", 0o0156, 1 ), ( "SXA,1", 0o0046, 1 ),
    ( "SXA,2", 0o0042, 1 ), 
    ( "TAD", 0o0005, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "TAD*", 0o0007, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "TIX,1", 0o0076, 1 ), 
    ( "TIX,2", 0o0072, 1 ),
    ( "TLOAD", 0o0025, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "TLOAD*", 0o0027, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "UNIT", 0o0120, 0 ), 
    ( "V/SC", 0o0035, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "V/SC*", 0o0037, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VAD", 0o0121, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VAD*", 0o0123, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VCOMP", 0o0100, 0 ), 
    ( "VDEF", 0o0110, 0 ),
    ( "VLOAD", 0o0001, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VLOAD*", 0o0003, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VPROJ", 0o0145, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VPROJ*", 0o0147, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VSL", 0o0115, 1, 2, 0o020202, ( 1, 0 ) ),
    ( "VSL*", 0o0117, 1, 2, 0o020202, ( 1, 0 ) ),
    ( "VSL1", 0o0004, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSL2", 0o0024, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSL3", 0o0044, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSL4", 0o0064, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSL5", 0o0104, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSL6", 0o0124, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSL7", 0o0144, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSL8", 0o0164, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSQ", 0o0140, 0 ), 
    ( "VSR", 0o0115, 1, 2, 0o020602, ( 1, 0 ) ),
    ( "VSR*", 0o0117, 1, 2, 0o020602, ( 1, 0 ) ),
    ( "VSR1", 0o0014, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSR2", 0o0034, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSR3", 0o0054, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSR4", 0o0074, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSR5", 0o0114, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSR6", 0o0134, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSR7", 0o0154, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSR8", 0o0174, 0, 0, 0o000000, ( 1, 0 ) ),
    ( "VSU", 0o0125, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VSU*", 0o0127, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VXM", 0o0071, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VXM*", 0o0073, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VXSC", 0o0015, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VXSC*", 0o0017, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VXV", 0o0141, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "VXV*", 0o0143, 1, 0, 0o000000, ( 1, 0 ) ),
    ( "XAD,1", 0o0106, 1 ), 
    ( "XAD,2", 0o0102, 1 ), 
    ( "XCHX,1", 0o0056, 1 ),
    ( "XCHX,2", 0o0052, 1 ), 
    ( "XSU,1", 0o0116, 1 ), 
    ( "XSU,2", 0o0112, 1 ) )
# Convert the raw data above into a forms keyed by instruction name and by
# numerical code.
interpreterOpcodes = {}
interpreterCodes = {}
for entry in interpreterOpcodesRaw:
    interpreterOpcodes[entry[0]] = entry
    if entry[1] in interpreterCodes:
        interpreterCodes[entry[1]].append(entry)
    else:
        interpreterCodes[entry[1]] = [entry]
# Deduce the proper masks to use for switch and shift opcodes.
maskSwitch = 0
maskShift = 0
for entry in interpreterOpcodesRaw:
    if len(entry) >= 5:
        if entry[3] == 1:
            maskSwitch |= entry[4]
        elif entry[3] == 2:
            maskShift |= entry[4]
maskSwitch &= ~1
        
# Inverse function for e(X).  See
# http://www.ibiblio.org/apollo/assembly_language_manual.html#Interpreter_Instruction_Set   
def eInverse(X):
    return "E%o,%04o" % (X // 0o400, (X % 0o400) + 0o1400)

# Inverse function for f(X).  See
# http://www.ibiblio.org/apollo/assembly_language_manual.html#Interpreter_Instruction_Set   
def fInverse(X):
    return "%02o,%04o" % (X // 0o2000, (X % 0o2000) + 0o2000)

# Sometimes, information is encoded in the argument that alters the 
# symbol used for the opcode.  This happens when the opcode is for a
# switch or shift instruction.  Therefore, we need to analyze the 
# argument in those cases to determine what the opcode really is.
# The interpreterCodesField parameter comes from interpreterCodes[code],
# where the code comes from the packed opcode word.
def adjustOpcodePerArgument(core, bank, offset, interpreterCodesField, 
                            isLeft):

    def printInterpreterCodesField(ior):
        msg = "           %s %03o %d" % (ior[0], ior[1], ior[2])
        if len(ior) > 3:
            msg += " %d" % ior[3]
        if len(ior) > 4:
            msg += " %05o" % ior[4]
        if len(ior) > 5:
            msg += " (%d, %d)" % ior[5]
        print(msg)

    if offset < 0o2000:
        nCode = interpreterCodesField[0][1]
        canIndex = (nCode & 2) != 0
        argument = core[bank][offset]
        if canIndex and (argument & 0o40000) != 0:
            if isLeft:
                increment = 1
            else:
                increment = 2
            argument = (increment + ~argument) & 0o77777
            #print("%03o, inverted argument %05o" % (nCode, argument))
            #for ior in interpreterCodesField:
            #    printInterpreterCodesField(ior)
        for ior in interpreterCodesField:
            if len(ior) == 3:
                return ior[0], ior[2], ior
            elif len(ior) > 3:
                if ior[3] == 0:
                    return ior[0], ior[2], ior
                if ior[3] == 1:
                    mask = maskSwitch
                else:
                    mask = maskShift
                if (ior[4] & mask) == argument & mask:
                    return ior[0], ior[2], ior
            else:
                print("Internal error:", ior)
    #print("Not found: %05o %05o %05o" % (argument, maskSwitch, maskShift))
    #for ior in interpreterCodesField:
    #    printInterpreterCodesField(ior)
    return "??????", 0, ()

# Returns a list of triples and two booleans.  The first boolean indicates
# whether or not the final instruction was STADR.  The second boolean 
# indicates whether or not it was EXIT.  The list of triples contains the 
# disassembled word and all of its arguments.  The first triple in the list is
#   (LEFT, RIGHT, ADDRESS)
# LEFT and RIGHT are the interpreter instructions, where RIGHT may be ""
# if the word encodes a single instruction.  ADDRESS is the address if LEFT
# is STCALL, STODL, STORE, or STOVL, but is "" otherwise.  Subsequent 
# triples are simply
#   ("", "", ARGUMENT)
# The input arguments are self-explanatory, except stadr.  This is 
# True if the last instruction previously was STADR, and False otherwise.
def disassembleInterpretive(core, bank, offset, stadr):
    disassembly = []
    word = core[bank][offset]
    cword = ~word
    if stadr:
        sword = cword
    else:
        sword = word
    offset += 1
    exit = False

    if stadr or sword & 0o40000 == 0:
        stadr = False
        left = "??????"
        storeType = 0o74000 & sword
        if storeType == 0o34000:
            left = "STCALL"
        elif storeType == 0o14000:
            left = "STODL"
        elif storeType == 0o00000:
            left = "STORE"
        elif storeType == 0o24000:
            left = "STOVL"
        if left == "??????":
            disassembly.append((left, "", ""))
        else:
            #disassembly.append((left, "", eInverse(sword & 0o1776)))
            disassembly.append((left, "", "%05o" % (sword & 0o1776)))
            if left != "STORE" and offset < 0o2000:
                word = core[bank][offset]
                if left == "STCALL" or 0 == (0o40000 & word):  # Extra arg?
                    if left == "STCALL":
                        disassembly.append(("", "", fInverse(word)))
                    else:
                        disassembly.append(("", "", "%05o" % word))
    else:                       # Not STORE, STCALL, STODL, or STOVL
        canPushDown = False
        leftField = (0o177 & cword) - 1
        rightField = (0o177 & ((cword) >> 7)) - 1   # -1 if none.
        left = "??????"
        right = "??????"
        numLeftArgs = 0
        numRightArgs = 0
        leftInterpreterCodes = []
        rightInterpreterCodes = []
        if leftField in interpreterCodes:
            leftInterpreterCodes = interpreterCodes[leftField]
            left, numLeftArgs, leftInterpreterCodes \
                = adjustOpcodePerArgument(core, bank, offset, 
                                    leftInterpreterCodes, True)
            if numLeftArgs > 0:
                canPushDown = (leftField & 1) != 0 \
                            and leftField not in [0o115, 0o117]
        if rightField == -1:
            right = ""
        elif rightField in interpreterCodes:
            rightInterpreterCodes = interpreterCodes[rightField]
            right, numRightArgs, rightInterpreterCodes = \
                adjustOpcodePerArgument(core, bank, 
                offset + numLeftArgs, rightInterpreterCodes, False)
            if numRightArgs > 0:
                canPushDown = (rightField & 1) != 0 \
                            and rightField not in [0o115, 0o117]
        disassembly.append((left, right, ""))
        if left == "EXIT" or right == "EXIT":
            exit = True
        if left == "STADR":
            numLeftArgs -= 1
            stadr = True
        if right == "STADR":
            numRightArgs -= 1
            stadr = True
        rawNumArgs = numLeftArgs + numRightArgs
        for i in range(rawNumArgs):
            if offset+i >= 0o2000:
                break
            word = core[bank][offset + i]
            if word == 0o77626: # STADR
                break
            if i == rawNumArgs - 1 and (word & 0o40000) != 0 and canPushDown:
                break
            disassembly.append(("", "", "%05o" % word))
    return disassembly, stadr, exit

