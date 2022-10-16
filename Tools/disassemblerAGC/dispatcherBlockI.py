#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       dispatcher.py
Purpose:        This is my attempt at implementing the dispatcher state
                machine from p. 42 of The Compleat Sunrise
                (http://www.ibiblio.org/apollo/hrst/archive/1721.pdf),
                but just insofar as it supports disassembly.
History:        2022-10-14 RSB  Wrote.

This really forms the meat of disassembleInterpretiveBlockI.py, so there's
really no point to have it separately.  At some point I'll undoubtedly 
merge them and get rid of this file entirely.
"""

from disassembleInterpretiveBlockI import interpreterOpcodes, interpreterCodes

# By assumption, "unary" operators have no input arguments, and "binary" 
# operators have one input argument. "Miscellaneous" operators are also
# assumed to have one input argument, but with the following exceptions.
miscellaneous0 = { "EXIT", "NOLOD", "LODON", "ITCQ" }
miscellaneous2 = { "TEST" }

# This is an attempt to implement the state machine from Compleat p. 42.
# The input (words) is a list of 15-bit octals representing the area of
# memory being disassembled, and locationCounter is the initial index
# into that list, which is assumed to be also the start of an "equation". 

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
                # "Is load indicator on?"
                if loadIndicator:       # Yes
                    if locationCounter >= len(words):
                        return disassembly, wasExit
                    word = words[locationCounter]
                    locationCounter += 1
                    disassembly.append(( "", "", "%05o" % (word - 1) ))
                    loadIndicator = False
                # "Is this a unary op?"
                if unaryOperation:      # Yes
                    # "Execute" - but we don't care what this operation does.
                    continue
                else:                   # No
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
        locationCounter += 1
        if word >= 0o32000 and word <= 0o37777:             # Yes
            disassembly.append(( "STORE", "", "%04o" % (0o1777 & (word-1))))
            continue
        else:                           # No
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

