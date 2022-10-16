#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       disassemblerInterpretiveBlockI.py
Purpose:        Disassemble a word from an interpretive location, 
                Block I only.
History:        2022-10-13 RSB  Began.

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
interpreterOpcodes = {}
interpreterCodes = {}
for entry in interpreterOpcodesRaw:
    interpreterOpcodes[entry[0]] = entry
    if entry[1] in interpreterCodes:
        interpreterCodes[entry[1]].append(entry)
    else:
        interpreterCodes[entry[1]] = [entry]
        
# Inverse function for e(X).  See
# http://www.ibiblio.org/apollo/assembly_language_manual.html#Interpreter_Instruction_Set   
def eInverse(X):
    return "E%o,%04o" % (X // 0o400, (X % 0o400) + 0o1400)

# Inverse function for f(X).  See
# http://www.ibiblio.org/apollo/assembly_language_manual.html#Interpreter_Instruction_Set   
def fInverse(X):
    return "%02o,%04o" % (X // 0o2000, (X % 0o2000) + 0o2000)

# Returns a state structure corresponding to "beginning"; which has 
# different meanings for Block I vs Block II.  
def interpretiveStart():
    return { }

# Determines the number of arguments we expect an interpretive opcode
# to require.

# Assume all opcodes have 1 argument, except the following.
zeroArguments = { "DSQ", "SIN", "COS", "ASIN", "ACOS", "SQRT", "TP", "VDEF",
                  "ROUND", "ABS", "ABVAL", "COMP", "UNIT", "EXIT",
                  "ITCQ" }
twoArguments = { "TEST" }

def getNumArguments(opcode):
    if opcode in ["NOLOD", "LODON"]:
        return -1
    elif opcode in zeroArguments:
        return 0
    elif opcode in twoArguments:
        return 2
    else:
        return 1

# Returns a list of triples and a booleans.  The boolean 
# indicates whether or not it was EXIT.  The list of triples contains the 
# disassembled word and all of its arguments.  The first triple in the list is
#   (LEFT, RIGHT, ADDRESS)
# LEFT and RIGHT are the interpreter instructions, where RIGHT may be ""
# if the word encodes a single instruction.  ADDRESS is the address if LEFT
# is STCALL, STODL, STORE, or STOVL, but is "" otherwise.  Subsequent 
# triples are simply
#   ("", "", ARGUMENT)
# The state is used for tracking the progress of "equations".  We don't
# actually need it, and can assume that the function is always entered
# at the start of an "equation", and we're going to disassemble the 
# entire equation.

if False:  # My first crack at this.

    def disassembleInterpretive(core, bank, offset, state):
        disassembly = []
        numberOfArguments = 1  # Implied load to accumulator at equation start.
        
        # At start of "equation".
        word = core[bank][offset]
        offset += 1
        additionalOperatorWords = 0o177 & ((word + 1) ^ 0o177)
        nOpcode = 0o177 & ((word+1) >> 7) 
        opcode = "??????"
        if nOpcode in interpreterCodes:
            opcode = interpreterCodes[nOpcode][0][0]
        numberOfArguments += getNumArguments(opcode)
        disassembly.append((opcode, "%dD" % additionalOperatorWords, ""))
        #print("here", opcode, additionalOperatorWords, numberOfArguments)
        
        # Now get all of the additional opcodes.
        for i in range(additionalOperatorWords):
            word = core[bank][offset]
            offset += 1
            rightField = 0o177 & (word + 1)
            leftField = 0o177 & ((word+1) >> 7) 
            left = "??????"
            right = "??????"
            if leftField in interpreterCodes:
                left = interpreterCodes[leftField][0][0]
            numberOfArguments += getNumArguments(left)
            if rightField == 0o177:
                right = ""
            else:
                if rightField in interpreterCodes:
                    right = interpreterCodes[rightField][0][0]
                numberOfArguments += getNumArguments(right)
            disassembly.append((left, right, ""))
            
        # Now fetch all of the arguments.
        for i in range(numberOfArguments + 1):
            word = core[bank][offset]
            if i == numberOfArguments:
                if word >= 0o32000:
                    disassembly.append(("STORE", "", "%04o" % (word & 0o1777)))
                break
            offset += 1
            disassembly.append(("", "", "%05o" % word))
         
        return disassembly, False

else: # My hopefully-improved attempt.

    from dispatcherBlockI import dispatcher
    
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

