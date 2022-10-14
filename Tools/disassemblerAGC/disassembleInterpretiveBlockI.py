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

from engineering import endOfImplementation

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
# STXXX aren't included in interpretiveOpcodesRaw,
# as they must be handled differently.
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

# Returns a list of triples and two booleans.  The first boolean indicates
# whether or not the final instruction was STADR, but that's not needed in
# Block I, so it always returns False.  The second boolean 
# indicates whether or not it was EXIT.  The list of triples contains the 
# disassembled word and all of its arguments.  The first triple in the list is
#   (LEFT, RIGHT, ADDRESS)
# LEFT and RIGHT are the interpreter instructions, where RIGHT may be ""
# if the word encodes a single instruction.  ADDRESS is the address if LEFT
# is STCALL, STODL, STORE, or STOVL, but is "" otherwise.  Subsequent 
# triples are simply
#   ("", "", ARGUMENT)
# The input arguments are self-explanatory, except possibly stadr, which
# is simply ignored.  
def disassembleInterpretive(core, bank, offset, stadr):
    stadr = False
    disassembly = []
    word = core[bank][offset]
    cword = ~word
    sword = word
    offset += 1

    if sword >= 0o32000:
        left = "STORE"
        disassembly.append((left, "", "%05o" % ((sword - 1) & 0o1777)))
    else:                       # Not STORE, STCALL, STODL, or STOVL
        rightField = 0o177 & (sword + 1)
        leftField = 0o177 & ((sword+1) >> 7) 
        left = "??????"
        right = "??????"
        if leftField in interpreterCodes:
            left = interpreterCodes[leftField][0][0]
        if rightField == 0o177:
            right = ""
        elif rightField >= 0o170:
            right = "%o" % (rightField ^ 0o177)
        elif rightField in interpreterCodes:
            right = interpreterCodes[rightField][0][0]
        disassembly.append((left, right, ""))
        """
        There's a mystery associated with EXIT that I'm at a loss
        to understand:  Sometimes the locations following an EXIT
        are filled with interpretive arguments, before you get to 
        basic instructions.  Usually not.  But occasionally. On 
        rare occasions EXIT is the right-hand opcode, so it makes
        sense that the arguments must be for the left-hand opcode.
        Unfortunately, there's no list of how many arguments any
        given opcode takes, thought I guess maybe I could make one
        by going through Compleat in detail.  It's hard to deal with.
        *Usually*, however, EXIT is alone on a line by itself, or
        else as "EXIT   0", which encodes identically ... whatever
        that may mean.  The arguments are a complete mystery to me.  
        I see no alternative other than just to flip over to basic
        whenever an EXIT is encountered, parse the interpretive
        arguments as if they are basic instructions, and hope for
        the best.
        
        Note that Compleat says explicitly (p. 35) that "the EXIT
        order must be the last (or only) order in the equation in 
        which it appears".  Perhaps I just don't understand this
        "equation" gobbledygook.
        """
        if left == "EXIT" or right == "EXIT":
            return disassembly, stadr, True
        i = 0
        while True:
            if offset+i >= 0o2000:
                break
            word = core[bank][offset + i]
            i += 1
            if word == 0o77777:
                disassembly.append(("", "", "-"))
                continue
            if (word & 0o40000) != 0 or (word & 0o76000 == 0o32000):
                break
            disassembly.append(("", "", "%05o" % (word - 1)))
    return disassembly, stadr, False

