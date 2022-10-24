#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       disassemblerInterpretiveBlockI-Compleat.py
Purpose:        Disassemble a word from an interpretive location, 
                Block I only.  It works pretty well, but sometimes
                fails to correctly determine the number of arguments,
                in which case the failure is pretty severe.
History:        2022-10-13 RSB  Began.
                2022-10-22 RSB  Renamed from disassembleInterpretiveBlockI.py
                                as preparation for replacement using
                                flowchart 6-3 from AGCIS #6B.
                2022-10-24 RSB  Now obsoleted by disassembleInterpretiveBlockI.py,
                                I hope.

Note that info on the Block I interpreter is scarce to come by.  The best
thing I've found so far is "The Compleat Sunrise"
(http://www.ibiblio.org/apollo/hrst/archive/1721.pdf), which if I need
to do so I'll refer to below simply as "Compleat".

"""

import sys

# Disassemble a word for an interpretive location. 
# I got interpreterOpcodes from yaYUL/Pass.c, and just simple-mindedly 
# converted braces to parentheses.
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
# STORE isn't included in interpretiveOpcodesRaw,
# as it must be handled differently.
interpreterOpcodesRaw = (
    ( "ABS", 0o124 ),
    ( "ABS*", 0o120 ),
    ( "ABVAL", 0o144 ),
    ( "ARCCOS", 0o104 ),
    ( "ACOS", 0o104 ),
    ( "ARCSIN", 0o114 ),
    ( "ASIN", 0o114 ),
    ( "AST,1", 0o066 ),
    ( "AST,2", 0o062 ),
    ( "AXC,1", 0o056 ),
    ( "AXC,2", 0o052 ),
    ( "AXT,1", 0o166 ),
    ( "AXT,2", 0o162 ),
    ( "BDDV", 0o107 ),
    ( "BDSU", 0o127 ),
    ( "BDSU*", 0o125 ),
    ( "BHIZ", 0o137 ),
    ( "BMN", 0o157 ),
    ( "BOV", 0o147 ),
    ( "BPL", 0o017 ),
    ( "BVSU", 0o033 ),
    ( "BZE", 0o037 ),
    ( "COMP", 0o034 ),
    ( "COMP*", 0o030 ),
    ( "COS", 0o064 ),
    ( "COS*", 0o060 ),
    ( "COSINE", 0o064 ),
    ( "DAD", 0o143 ),
    ( "DAD*", 0o141 ),
    ( "DDV", 0o113 ),
    ( "DDV*", 0o111 ),
    ( "DMOVE", 0o024 ),
    ( "DMOVE*", 0o020 ),
    ( "DMP", 0o123 ),
    ( "DMP*", 0o121 ),
    ( "DMPR", 0o067 ),
    ( "DOT", 0o013 ),
    ( "DSQ", 0o044 ),
    ( "DSU", 0o133 ),
    ( "DSU*", 0o131 ),
    ( "EXIT", 0o176 ),
    ( "INCR,1", 0o116 ),
    ( "INCR,2", 0o112 ),
    ( "ITA", 0o026 ),
    ( "ITC", 0o173 ),
    ( "ITC*", 0o171 ),
    ( "ITCI", 0o022 ),
    ( "ITCQ", 0o002 ),
    ( "LODON", 0o006 ),
    ( "LXA,1", 0o156 ),
    ( "LXA,2", 0o152 ),
    ( "LXC,1", 0o146 ),
    ( "LXC,2", 0o142 ),
    ( "MXV", 0o053 ),
    ( "NOLOD", 0o036 ),
    ( "ROUND", 0o032 ),
    ( "RTB", 0o172 ),
    ( "SIGN", 0o057 ),
    ( "SIN", 0o074 ),
    ( "SINE", 0o074 ),
    ( "SMOVE", 0o014 ),
    ( "SMOVE*", 0o010 ),
    ( "SQRT", 0o054 ),
    ( "STZ", 0o153 ),
    ( "SWITCH", 0o012 ),
    ( "SXA,1", 0o136 ),
    ( "SXA,2", 0o132 ),
    ( "TAD", 0o103 ),
    ( "TEST", 0o016 ),
    ( "TIX,1", 0o046 ),
    ( "TIX,2", 0o042 ),
    ( "TMOVE", 0o174 ),
    ( "TP", 0o174 ),
    ( "TSLC", 0o077 ),
    ( "TSLT", 0o117 ),
    ( "TSLT*", 0o115 ),
    ( "TSRT", 0o073 ),
    ( "TSRT*", 0o071 ),
    ( "TSU", 0o063 ),
    ( "UNIT", 0o154 ),
    ( "UNIT*", 0o150 ),
    ( "VAD", 0o043 ),
    ( "VAD*", 0o041 ),
    ( "VDEF", 0o004 ),
    ( "VMOVE", 0o164 ),
    ( "VMOVE*", 0o160 ),
    ( "VPROJ", 0o003 ),
    ( "VSLT", 0o023 ),
    ( "VSLT*", 0o021 ),
    ( "VSQ", 0o134 ),
    ( "VSRT", 0o027 ),
    ( "VSRT*", 0o025 ),
    ( "VSU", 0o163 ),
    ( "VXM", 0o047 ),
    ( "VXSC", 0o167 ),
    ( "VXSC*", 0o165 ),
    ( "VXV", 0o007 ),
    ( "VXV*", 0o005 ),
    ( "XAD,1", 0o106 ),
    ( "XAD,2", 0o102 ),
    ( "XCHX,1", 0o126 ),
    ( "XCHX,2", 0o122 ),
    ( "XSU,1", 0o076 ),
    ( "XSU,2", 0o072 ) 
)

# Convert the raw data above into a forms keyed by instruction name and by
# numerical code.
interpreterOpcodes = {} # By opcode name.
interpreterCodes = {}   # By numerical code.
for entry in interpreterOpcodesRaw:
    interpreterOpcodes[entry[0]] = entry
    if entry[1] in interpreterCodes:
        interpreterCodes[entry[1]].append(entry)
    else:
        interpreterCodes[entry[1]] = [entry]

'''
print("===========================", file=sys.stderr)
for i in sorted(interpreterCodes):
    if (i & 3) != 0:
        continue
    print("%02o" % (i >> 2), end="", file=sys.stderr)
    for entry in interpreterCodes[i]:
        print(" %s" % entry[0], end="", file=sys.stderr)
    print(file=sys.stderr)
sys.exit(1)
'''
     
# By assumption, "unary" operators have no input arguments, and "binary" 
# operators have one input argument. "Miscellaneous" operators are also
# assumed to have one input argument, but with the following exceptions.
miscellaneous0 = { "EXIT", "NOLOD", "LODON", "ITCQ" }
miscellaneous2 = { "TEST" }

# This is an attempt to implement the state machine from Compleat p. 42.
# The input (words) is a list of 15-bit octals representing the area of
# memory being disassembled, and locationCounter is the initial index
# into that list, which is assumed to be also the start of an "equation". 

debugOpcode = "none"

def dispatcher(words, locationCounter, singleEquation=False):
    disassembly = []
    firstEquation = True
    wasExit = False
    
    while locationCounter < len(words):  # "New equation."
        if singleEquation and not firstEquation:
            break
        firstEquation = False
        
        wasExit = False
        
        # "Set location counters, load indicator on."
        loadIndicator = True
        pendingOperators = []
        
        # Get leading opcode of the equation.
        word = words[locationCounter]
        locationCounter += 1
        if (word & 0o40000) == 0:
            # Cannot be the start of an equation.  Perhaps it is
            # data or basic.
            wasExit = True
            break
        numericalOpcode = 0o177 & ((word + 1) >> 7)
        if numericalOpcode in interpreterCodes:
            symbolicOpcode = interpreterCodes[numericalOpcode][0][0]
        else:
            symbolicOpcode = "?%03o" % numericalOpcode
        pendingOperators.append(numericalOpcode)
        # And get all of the equation's other opcodes as well.
        additionalOperatorWords = 0o177 & ~(word + 1) #0o176 - (word & 0o177)
        disassembly.append(( symbolicOpcode, "", "%o" \
            % additionalOperatorWords ))
        for i in range(additionalOperatorWords):
            if locationCounter >= len(words):
                return disassembly, wasExit
            word = words[locationCounter]
            locationCounter += 1
            leftNumericOpcode = 0o177 & ((word + 1) >> 7)
            if leftNumericOpcode in interpreterCodes:
                leftSymbolicOpcode = \
                    interpreterCodes[leftNumericOpcode][0][0]
            else:
                leftSymbolicOpcode = "?%03o" % numericalOpcode
            pendingOperators.append(leftNumericOpcode)
            rightNumericOpcode = 0o177 & (word + 1)
            if rightNumericOpcode == 0o177:
                rightSymbolicOpcode = ""
            elif rightNumericOpcode in interpreterCodes:
                rightSymbolicOpcode = \
                    interpreterCodes[rightNumericOpcode][0][0]
                pendingOperators.append(rightNumericOpcode)
            else:
                rightSymbolicOpcode = "?%03o" % rightNumericOpcode
                pendingOperators.append(rightNumericOpcode)   
            disassembly.append(( leftSymbolicOpcode, rightSymbolicOpcode, ""))
        wasExit = (pendingOperators[-1] == 0o176)
        
        # "Is there an operator to execute?"
        while len(pendingOperators) > 0:  # Yes.
            operator = pendingOperators[0]
            operatorName = operator
            if operator in interpreterCodes:
                operatorName = interpreterCodes[operator][0][0]
            pendingOperators = pendingOperators[1:]
            if operatorName == debugOpcode : 
                print("Is there an operator to execute (%05o, %05o)" % (locationCounter, word))
            # Compleat p. 40 describes how the selection codes and
            # prefix bits appear within the memory word, but doesn't
            # indicate the complementation I use.  However, Compleat
            # also indicates that bit 15 is 0, which is always false,
            # so I believe its lack of complementation is inadvertent.
            selectionCode = (~operator >> 2) & 0o37
            prefixBits = ~operator & 0o3
            binaryOperationDirect = (prefixBits == 0)
            binaryOperationIndexed = (prefixBits == 2)
            binaryOperation = binaryOperationDirect or binaryOperationIndexed
            miscellaneousOperation = (prefixBits == 1)
            unaryOperation = (prefixBits == 3)
            # "Is this a miscellaneous operator?
            if miscellaneousOperation:  # Yes
                if operatorName == debugOpcode : 
                    print("Is this a miscellaneous operator (%05o, %05o)" % (locationCounter, word))
                # "Execute"
                if operatorName in miscellaneous0:      # No arguments.
                    if operatorName == "NOLOD":
                        loadIndicator = False
                    elif operatorName == "LODON":
                        loadIndicator = True
                elif operatorName in miscellaneous2:    # 2 arguments. 
                    if locationCounter >= len(words):
                        return disassembly, wasExit
                    word = words[locationCounter]
                    locationCounter += 1
                    disassembly.append(( "", "", "%05o" % (word - 1) ))
                    if locationCounter >= len(words):
                        return disassembly, wasExit
                    word = words[locationCounter]
                    locationCounter += 1
                    disassembly.append(( "", "", "%05o" % (word - 1) ))
                else:                                   # 1 argument.
                    if locationCounter >= len(words):
                        return disassembly, wasExit
                    word = words[locationCounter]
                    locationCounter += 1
                    disassembly.append(( "", "", "%05o" % (word - 1) ))
                continue # Next operator.
            else:                       # No
                if operatorName == debugOpcode : 
                    print("Is the load indicator on (%05o, %05o)" % (locationCounter, word))
                # "Is load indicator on?"
                if loadIndicator:       # Yes
                    if operatorName == debugOpcode : 
                        print("Yes (%05o, %05o)" % (locationCounter, word))
                    if locationCounter >= len(words):
                        return disassembly, wasExit
                    word = words[locationCounter]
                    # The flowchart indicates that this load always occurs.  However, on 
                    # p. 18 of Compleat, it says that ITC, BOV, and STZ "do not load
                    # an accumulator if the load indicator is on".  I'd ignore that if
                    # ITC weren't giving me problems otherwise, and if this hadn't made
                    # those problems seem to disappear.
                    if operatorName not in ["ITC", "BOV", "STZ"]:
                        locationCounter += 1
                        disassembly.append(( "", "", "%05o" % (word - 1) ))
                    loadIndicator = False
                # "Is this a unary op?"
                if unaryOperation:      # Yes
                    if operatorName == debugOpcode : 
                        print("Is this a unary op - Yes (%05o, %05o)" % (locationCounter, word))
                    # "Execute" - but we don't care what this operation does.
                    continue
                else:                   # No
                    if operatorName == debugOpcode : 
                        print("Is there an address (%05o, %05o)" % (locationCounter, word))
                    # "Is there an address?"
                    if locationCounter >= len(words):
                        return disassembly, wasExit
                    word = words[locationCounter]
                    locationCounter += 1 # Note: May undo this in a moment.
                    if word == 0o77777: # Inactive
                        disassembly.append(( "", "", "-" ))
                    elif word >= 0o32000 and word <= 0o37777:  # STORE address
                        disassembly.append(( "STORE", "", 
                            "%04o" % (0o1777 & (word - 1)) ))
                        return disassembly, wasExit
                    elif binaryOperation:
                        disassembly.append(( "", "", "%05o" % (word - 1) ))
                        continue
                    else:               # No address
                        locationCounter -= 1
                    # "PUSH-UP"
                    continue   
            
        # "Is there a STORE address?"
        if locationCounter >= len(words):
            return disassembly, wasExit
        word = words[locationCounter]
        if operatorName == debugOpcode : 
            print("Is there a STORE address (%05o, %05o)" % (locationCounter, word))
        locationCounter += 1
        # The flowchart doesn't mention any exceptions for EXIT, but I've 
        # observed that if I do nothing to prevent it, there will sometimes
        # be an extraneous STORE after an EXIT, which cause the first
        # basic instruction to be missed.
        if word >= 0o32000 and word <= 0o37777 and \
                operatorName not in ["EXIT"]:             # Yes
            if operatorName == debugOpcode : 
                print("Yes (%05o, %05o)" % (locationCounter, word))
            disassembly.append(( "STORE", "", "%04o" % (0o1777 & (word-1))))
            return disassembly, wasExit
        else:                           # No
            if operatorName == debugOpcode : 
                print("No (%05o, %05o)" % (locationCounter, word))
            # "Was the last operation miscellaneous or a branch?
            locationCounter -= 1
            continue
            
    return disassembly, wasExit
            
if False:
    # A test of the encoding scheme (i.e., PREFIX BITS and 
    # SELECTION CODES).  It seems to work, except that
    # ROUND shows up as "miscellaneous" rather than "unary".
    for symbol in interpreterOpcodes:
        entry = interpreterOpcodes[symbol]
        code = ((~entry[1]) >> 2) & 0o37
        prefixBits = (~entry[1]) & 0o3
        binaryOperationDirect = (prefixBits == 0)
        binaryOperationIndexed = (prefixBits == 2)
        miscellaneousOperation = (prefixBits == 1)
        unaryOperation = (prefixBits == 3)
        if binaryOperationDirect:
            print(symbol, "binary")
        if binaryOperationIndexed:
            print(symbol, "binary")
        if miscellaneousOperation:
            print(symbol, "miscellaneous")
        if unaryOperation:
            print(symbol, "unary")

if False:
    # For test purposes, here are lists of words comprising various 
    # subroutines from Solarium 55.
    LOECC = [
        0o64776, 0o00017, 0o00013, 0o66776, 0o06304, 0o00005, 0o64775, 0o53176, 
        0o00013, 0o22307, 0o42774, 0o63722, 0o76576, 0o00766, 0o00774, 0o00002,
        0o77777, 0o22143, 0o32011, 0o64774, 0o66771, 0o70776, 0o77777, 0o77777,
        0o77777, 0o22155, 0o00011, 0o32011, 0o66775, 0o76522, 0o00007, 0o77777,
        0o22213, 0o00015, 0o33457, 0o40576                                     
    ]
    PITCH1 = [
	    0o47573,0o66756,0o41423,0o42576,0o01567,0o24124,0o01567,0o00033,
	    0o33571,0o45174,0o76516,0o76516,0o01571,0o20404,0o00017,0o24246,
	    0o00005,0o32025,0o57176,0o00025,0o45176,0o07227,0o55175,
	    0o41176,0o00025,0o32027,0o47576,0o33411,0o45176,0o01415,0o32027,
	    0o47176,0o01411,0o32033,
    ]

    disassembly = []
    #disassembly += dispatcher(PITCH1, 0)
    disassembly += dispatcher(LOECC, 0)
    for entry in disassembly:
        print("\t%s\t%s" % (entry[0], entry[1] + entry[2]))
    
# Returns a state structure corresponding to "beginning".  
def interpretiveStart():
    return { }

def disassembleInterpretive(core, bank, offset, state):
    return dispatcher(core[bank], offset, True)

#==========================================================================
# This is stuck at the end because it isn't actually used by the
# code above.  But it is interpreter-related data that may be imported
# from other code.

# Here's a list of opcodes and pseudo-ops I pasted in from 
# yaYUL/Pass.c (ParsersBlock1) and then massaged a bit.
# Pseudo-ops which allocate no rope are commented out.
parsers = {
    #"=": 'd',
    "2DEC": 'd',
    "2DEC*": 'd',
    "2OCT": 'd',
    "AD": 'b',
    "ADRES": 'd',
    #"BANK": 'd',
    "CAF": 'b',
    "CADR": 'd',
    "CCS": 'b',
    "COM": 'b',
    "CS": 'b',
    "DEC": 'd',
    "DOUBLE": 'b',
    "DV": 'b',
    #"EQUALS": 'd',
    #"ERASE": 'd',
    "EXTEND": 'b',
    "INDEX": 'b',
    "INHINT": 'b',
    "MASK": 'b',
    "MP": 'b',
    "NDX": 'b',
    "NOOP": 'b',
    "OCT": 'd',
    "OCTAL": 'd',
    "OVIND": 'b',
    "OVSK": 'b',
    "RELINT": 'b',
    "RESUME": 'b',
    "RETURN": 'b',
    #"SECSIZ": 'd',
    #"SETLOC": 'd',
    "SQUARE": 'b',
    "STORE": 'i',
    "SU": 'b',
    "TC": 'b',
    "TCR": 'b',
    "TCAA": 'b',
    "TS": 'b',
    "XAQ": 'b',
    "XCADR": 'd',
    "XCH": 'b'
}

