#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       disassemblerInterpretiveBlockI.py
Purpose:        Disassemble a word from an interpretive location, 
                Block I only.
History:        2022-10-22 RSB  Began.

This is my attempt to implement the Dispatcher from Figure 6-3 of AGCIS issue
#6B:  http://www.ibiblio.org/apollo/Documents/agcis_6b_interpreter.pdf#page=47.
If it ends up working, it will replace the Dispatcher flowchart from "The
Compleat Sunrise" (http://www.ibiblio.org/apollo/hrst/archive/1721.pdf#page=56), 
which I had implemented in disassemblerInterpretiveBlockI-Compleat.py.  From
time to time, I'll also refer to an earlier version, namely Figure 6-3 of AGCIS #6:
http://www.ibiblio.org/apollo/Documents/agcis_6_interpreter.pdf#page=24.

I'll refer to Figure 6-3 of AGCIS #6B (and its associated descriptive text)
simply as "the flowchart" below, if I have occasion to refer to it.

In order to help document how I've implemented the state machine defined in the
flowchart, I've separated out just Figure 6-3 from the complete PDF, and annotated
it so that each box in the flowchart has a distinct name.  The annotated PDF is
agcis_6b_Figure-6.3.pdf in the same folder of the source tree as this Python
file.
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
interpreterCodes = {}   # By code.
for entry in interpreterOpcodesRaw:
    interpreterOpcodes[entry[0]] = entry
    if entry[1] in interpreterCodes:
        interpreterCodes[entry[1]].append(entry)
    else:
        interpreterCodes[entry[1]] = [entry]

# For whatever reason (I haven't been able to see it), the flowchart
# isn't good at detecting which arguments should have a STORE and which
# should not.  This function can be used to correct for spurious STOREs in
# the middle of a batch of arguments.
def adjustSTORE(arguments):
    for i in range(len(arguments)):
        entry = arguments[i]
        if entry[0] == "STORE":
            entry[0] = ""
            entry[2] = "%05o" % entry[3]

'''
Some terminology.  Alas, the flowchart uses different names for everything 
than Solarium source code does, which unfortunately needs to be consulted to
fill in details that the flowchart omits: FIXED-FIXED_INTERPRETER_SECTION.agc
I'll use flowchart symbolism in the code below, but here are a few notes 
about differences:
                    Compleat, 
Flowchart           Solarium            Note
---------           --------            ----
String              Equation
IIW                 Instruction         Interpretive Instruction Word
IAW                 Address             Interpretive Address Word
Dual-quantity       Binary
Single-quantity     Unary

The behavior of some quantities mentioned in the flowchart is merely to be
saved, but never to be tested again, and thus not to affect anything (of
interest to us).  Thus we can ignore them entirely rather than trying to
reproduce them.  Here's the list of those, as I understand them.

BNK         Fixed bank in use
MODE        DP vs TP vs VEC - This quantity is "tested" in box ANON20, 
            but either branch of the decision box goes to ANON21 anyway.
'''
bankDebug = 0 # just a couple of quantities for printing debugging messages.
offsetDebug = 0
def dispatcher(words, locationCounter, singleEquation=False):
    disassembly = []
    arguments = []
    wasExit = False
    
    # Here are variables used to track the state of the state machine
    # described by the flowchart.  Note that "CYR" doesn't do any 
    # editing; I just use it to hold the current instruction code
    # being processed.
    flowchartBox = "INTPRET" # Start here.
    LOADIND = 0
    IWLOC = 0
    endIIW = 0
    ORDER = 0
    AWLOC = 0
    A = 0
    AWORD = 0
    CYR = 0
    debug = False
    
    while True:
    
        if False and flowchartBox == "(never)":
            debug = True
        if debug:
            print("BOX=%-12s LOADIND=%d IWLOC=%o endIIW=%o AWLOC=%o AWORD=%o ORDER=%o A=%o CYR=%o wasExit=%r" \
                    % (flowchartBox, LOADIND, IWLOC, endIIW, AWLOC, AWORD, ORDER, A, CYR, wasExit))
            for entry in disassembly + arguments:
                print("\t%-12s %-12s %-12s" % tuple(entry[:3]))
            #pause = input("# ")
    
        ##################################################################
        # First page of the flowchart.
    
        if flowchartBox == "INTPRET":
            AWLOC = locationCounter - 1 # Address of TC INTPRET
            flowchartBox = "ANON1"
            
        elif flowchartBox == "NEWSTRNG":
            # Start of a new string, but we don't actually have to do
            # anything except set up the next state.
            disassembly += arguments
            arguments = []
            if singleEquation:
                break
            flowchartBox = "ANON1"
        
        elif flowchartBox == "ANON1":
            # For some stuff that the flowchart doesn't describe in detail,
            # like the "true form" of the IIW or the "address of the last
            # IIW of string", it's necessary to consult Solarium's source
            # code of the interpreter, in FIXED-FIXED_INTERPRETER_SECTION.agc.
            LOADIND = 0o00001
            IWLOC = AWLOC + 1   # Address of first IIW of the string.
            ORDER = words[IWLOC] + 1  # The "true form" of the IIW.
            extraIIW = (ORDER ^ 0o177) & 0o177
            endIIW = IWLOC + extraIIW # Address of last IIW of the string.
            AWLOC = endIIW
            A = 0o00000
            CYR = (ORDER >> 7) & 0o177
            if CYR in interpreterCodes:
                left = interpreterCodes[CYR][0][0]
            else:
                left = "A!%03o" % CYR
            right = "%o" % extraIIW
            disassembly.append((left, right, ""))            
            flowchartBox = "IPROC2"
        
        elif flowchartBox == "IPROC2":
            dummy = ORDER
            ORDER = A
            A = (dummy >> 7) & 0o177
            CYR = A
            flowchartBox = "A"
            
        elif flowchartBox == "NEWORDER":
            # This is for swapping jobs, which is something we don't need.
            flowchartBox = "ANON2"
            
        elif flowchartBox == "ANON2":
            # We don't actually need to do anything.
            flowchartBox = "ANON3"
            
        elif flowchartBox == "ANON3":
            if ORDER == 0o00000:
                flowchartBox = "ANON5"
            else:
                flowchartBox = "ANON4"
                
        elif flowchartBox == "ANON4":
            A = ORDER & 0o177
            CYR = A
            ORDER = 0o00000
            flowchartBox = "A"
        
        elif flowchartBox == "ANON5":
            if wasExit:
                flowchartBox = "NEWSTRNG"
            elif IWLOC >= endIIW:
                flowchartBox = "B"
            else:
                flowchartBox = "ANON6"
                
        elif flowchartBox == "ANON6":
            IWLOC += 1
            ORDER = words[IWLOC] + 1 # "True form" of the IIW
            A = ORDER & 0o177
            if A == 0o177:
                A = 0
            CYR = A
            leftCode = (ORDER >> 7) & 0o177
            if leftCode in interpreterCodes:
                left = interpreterCodes[leftCode][0][0]
            else:
                left = "B!%03o" % leftCode
            right = ""
            if A > 0:
                if A in interpreterCodes:
                    right = interpreterCodes[A][0][0]
                else:
                    right = "C!%03o" % A
            disassembly.append((left, right, ""))
            flowchartBox = "IPROC2"
                
        ##################################################################
        # Second page of the flowchart.
    
        elif flowchartBox in ["A", "JUMPIT"]:
            # We're supposed to test whether the order code (opcode) is
            # "binary" or not, which is determined by the least-significant
            # bit.  Unfortunately, what with all of the complementation and
            # CCS operations floating around, the Solarium code is maximally
            # obtuse as to whether that means the bit is supposed to be 0 or
            # 1.  We can get at it by taking a binary operator like DAD
            # as an example.  As stored in ORDER, it will have the code 0o143.
            # Thus the least-significant bit is 1 for binary operations.
            if (A & 1) != 0:
                flowchartBox = "ADDRESS"
            else:
                flowchartBox = "ANON10" 
       
        elif flowchartBox == "ANON10":
            # We're now supposed to test whether the operation is
            # Unary vs Miscellaneous, which is the next-to-least significant
            # bit of the order code.  Take the unary operation SQRT as an
            # example.  This has code 0o054, so we expect unary operations to
            # have a 2nd bit of 0.  Similarly, a miscellaneous code like
            # NOLOD has code 0o036 in which the 2nd bit is 1.
            if CYR == 0o176:
                wasExit = True
            if (CYR & 2) == 0:
                flowchartBox = "UNAPROC"
            else:
                flowchartBox = "ANON11" 
                
        elif flowchartBox == "UNAPROC":
            if LOADIND != 0o00000:
                flowchartBox = "UNALOAD"
            else:
                flowchartBox = "ANON12" 
                
        elif flowchartBox == "ANON12":
            # What we're supposed to do now is execute the unary instruction.
            # What happens *after* the instruction executes is that it's 
            # supposed to go to ANON54.
            flowchartBox = "ANON54"
            
        elif flowchartBox == "UNALOAD":
            '''
            The flowchart is rather opaque here about what it expects.  
            
            First, we must "Test order code and enter 77776, 77775, or 77777
            into MODE".  With some external digging, we find that this is to
            set up the DP vs TP vs VEC data, and seemingly is to detect
            TMOVE/TP vs DMOVE/DMOVE* vs VMOVE/VMOVE* (and somehow, vs 
            everything else).  What Solarium does for UNALOAD is quite 
            convoluted and difficult to decipher.  As I mentioned above, 
            however, MODE is never again needed by the flowchart, except
            in some manner that is of no consequence in ANON20, so can just
            ignore it entirely.
            
            Second, we must "Store 00043 or 40043 instead of order code in
            CYR".  This is apparently done by the MODESET subroutine, which
            is separate in Solarium or a separate box in the AGCIS #6 (vs #6B)
            flowchart, the latter of which tells us "Set up order code in a 
            form to permit test for direct or indexed addressing".  For unary
            operators, the bit for indexed addressing is apparently the 
            least-significant bit of the 5-bit "selection code" (which would
            currently be in CYR) rather than the more-significant bit of the 
            2 "prefix bits" (which are always 00 for unary operators).  I think
            the value of 40043 vs 00043 is a distinction between indexing
            vs non-indexing.  Again, however, this is transparent at the 
            flowchart level since it affects no decisions, so I ignore it.
            
            Finally, we must "Store bits 7 through 4 of order code in SL".
            These are the 4 remaining LS bits of the order code (currently in 
            CYR, now that CYR has rotated out the 2 prefix bits and the LS bit
            of the 5-bit selection code).  The purpose appears to be to preserve
            it while additional processing occurs, and I think we can ignore it.
            '''
            flowchartBox = "ADDRESS"
            
        elif flowchartBox == "ADDRESS":
            dummy = AWLOC + 1
            if dummy >= len(words):
                break
            A = words[dummy]
            flowchartBox = "ANON17"
            
        elif flowchartBox == "ANON17":
            if A == 0o77777:
                flowchartBox = "PUSHUP2"
            elif (A & 0o40000) != 0:
                flowchartBox = "PUSHUP"
            else:
                flowchartBox = "ANON18"
                
        elif flowchartBox == "ANON18":
            # A and dummy are from box "ADDRESS".
            AWORD = A - 1
            AWLOC = dummy
            adjustSTORE(arguments)
            if A < 0o32000:
                arguments.append(["", "", "%05o" % AWORD])
            else:
                arguments.append(["STORE", "", "%04o" % (AWORD & 0o1777), AWORD])
            flowchartBox = "ANON28"
        
        elif flowchartBox == "PUSHUP2":
            AWLOC = dummy   # from box ADDRESS.
            value = words[dummy]-1
            adjustSTORE(arguments)
            if value == 0o77776:
                arguments.append(["", "", "-"])
            elif value < 0o32000:
                arguments.append(["", "", "%05o" % (value)])
            else:
                arguments.append(["STORE", "", "%04o" % (value & 0o1777), value])
            flowchartBox = "PUSHUP"
            
        elif flowchartBox == "PUSHUP":
            # Notice that in the end, the result is to go to
            # box C, with no other interesting consequences,
            # so the test could be bypassed without problems.
            if ORDER in [0o165, 0o167]: # VXSC* or VXSC
                flowchartBox = "ANON20"
            else:
                flowchartBox = "ANON19"
                
        elif flowchartBox in ["ANON19", "ANON20", "ANON21"]:
            # I don't think there's real difference between
            # these states from our perspective, nor anything
            # to do for them.
            flowchartBox = "C"        
        
        elif flowchartBox == "ANON28":
            # We're supposed to "Test bit 2 of order code contained in CYR".
            # The purpose is to detect indexing.  Recall that we're just
            # using CYR to hold the current order code, without simulating
            # its editing behavior.
            indexed = False
            if (CYR & 3) == 0:        # Unary
                indexed = ((CYR & 4) == 0)
            elif (CYR & 3) == 2:      # Binary with indexed operand address.
                indexed = True
            if indexed:
                flowchartBox = "INDEX"
            else:
                flowchartBox = "NONINDEX"
        
        elif flowchartBox == "NONINDEX":
            if AWORD < 0o20000: # 0o17777:
                flowchartBox = "ANON22"
            elif AWORD >= 0o20000: # > 0o20000:
                flowchartBox = "ANON25"
            else:
                print("%02o %04o %04o" % (bankDebug, offsetDebug + 0o6000, 
                        locationCounter + 0o6000), file=sys.stderr)
                print(disassembly, file=sys.stderr)
                print(arguments, file=sys.stderr)
                print("Implementation error: AWORD==%05o at NONINDEX" % AWORD, 
                    file=sys.stderr)
                sys.exit(1)
        
        elif flowchartBox == "ANON22":
            if AWORD < 0o60: # <= 0o56:
                flowchartBox = "ANON23"
            elif AWORD >= 0o60:
                flowchartBox = "ANON24"
            else:
                print("Implementation error: AWORD==%05o at ANON22" % AWORD,
                    file=sys.stderr)
                sys.exit(1)
        
        elif flowchartBox in ["ANON23", "ANON24"]:
            flowchartBox = "C"
        
        elif flowchartBox == "ANON25":
            # We're assured at this point that AWORD > 20000.
            # On the flowchart, one exit from this decision box reads
            # "Address word > 34000, represents STORE Code Address Word".
            # The other reads "20000 - address < 31776, refers to F
            # memory". The latter description is literally nonsense, 
            # since obviously 20000-address is < 0, so it's certainly
            # less than 31776 as well.  I think the test relates to the
            # fact that (from Compleat, p. 13):  "Addresses in the range
            # 32000 - 37777 are recognized to be store addresses ... the
            # lower 10 bits are used as an erasable address ....  If the 
            # address is in the range 34000 - 37777 the low-order 11 bits
            # are interpreted as a 10 bit erasable address and a 1 bit
            # index register tag."  Thus:
            #   20000 - 31777 :     Fixed memory (upper half)
            #   32000 - 33777 :     Non-indexed erasable.
            #   34000 - 37777 :     Indexed erasable.
            # So the gobbledygook exit, it appears, should read
            # "20000 <= address <= 31776", which actually makes sense,
            # even if redundant.  (Recall that 31777, which would be the
            # last address in erasable memory, isn't accessible to
            # interpretive code.)  Similarly, the first exit seems as
            # though it should read "Address word >= 34000, ...".
            if AWORD >= 0o34000:
                flowchartBox = "ANON26"
            else:
                flowchartBox = "ANON27"
                
        elif flowchartBox == "ANON26":
            # At this point we're supposed to "Compute 12-bit address of
            # STORE Code Address Word location and store it in AWLOC",
            # but it appears to me that whatever route we took to get
            # here (from boxes ANON18 or STORADR), the address will 
            # already be stored there. 
            flowchartBox = "PUSHUP"
            
        elif flowchartBox == "ANON27":
            flowchartBox = "SWADDR"
            
        elif flowchartBox == "SWADDR":
            flowchartBox = "C"
            
        elif flowchartBox == "ANON11":
            #AWLOC += 1
            flowchartBox = "MISCPROC"
        
        elif flowchartBox in ["MISCPROC", "ANON13", "ANON14", "ANON15", "ANON16"]:
            flowchartBox = "NEWORDER"
        
        elif flowchartBox in ["B", "ANON29"]:
            dummy = words[AWLOC + 1]
            if dummy >= 0o77700:
                flowchartBox = "STORADR"
            elif (dummy & 0o40000) == 0:
                flowchartBox = "STORADR"
            else:
                flowchartBox = "PUSHDOWN"
                
        elif flowchartBox == "PUSHDOWN":
            flowchartBox = "NEWSTRNG"
            
        elif flowchartBox == "STORADR":
            AWORD = (dummy - 1) & 0o1777 # from ANON29.
            AWLOC += 1
            adjustSTORE(arguments)
            if dummy == 0o77777:
                arguments.append(["", "", "-"])
            elif dummy >= 0o77700:
                dummy = 0o77777 & (~dummy + 1)
                arguments.append(["", "", "%dD" % -dummy])
            elif dummy >= 0o32000:
                arguments.append(["STORE", "", "%04o" % (AWORD & 0o1777), AWORD])
            else:
                arguments.append(["", "", "%05o" % AWORD])
            flowchartBox = "ANON30"
            
        elif flowchartBox == "ANON30":
            if dummy < 0o34000:
                flowchartBox = "ANON31"
            else:
                flowchartBox = "INDEX"
          
        elif flowchartBox == "ANON31":
            AWORD &= 0o1777
            flowchartBox = "NONINDEX"
        
        elif flowchartBox in ["INDEX", "ANON32", "ANON33", 
                              "ANON34", "ANON35", "ANON36"]:
            # Okay, we run into confusion here, because what
            # happens next in boxes INDEX and ANON32 - ANON36
            # depends on the value of the address after indexing,
            # which of course we know nothing about at assembly
            # (or disassembly) time.  There are three ways out 
            # of this collection of boxes:
            #       To NONINDEX
            #       To SWADDR
            #       To ANON23
            # But it appears to me that all of *those* eventually
            # arrive somehow at C without additionally incrementing
            # AWLOC.  So it appears that we can just go right to C
            # ourselves.
            flowchartBox = "C"
        
        elif flowchartBox == "D":
            flowchartBox = "ADDRESS"
          
        elif flowchartBox == "E":
            flowchartBox = "ANON12"          
          
        ##################################################################
        # Third page of the flowchart.
    
        elif flowchartBox in ["C", "JUMP"]: # ANON50 - ANON53.
            # This all appears rather complex, but it seems to me
            # that the only significant thing that happens from our
            # standpoint is that we go to ANON51, ANON52, or ANON53, *all*
            # of which (from our standpoint) have identical behavior:
            if LOADIND == 0:
                flowchartBox = "NEWORDER"
            else:
                flowchartBox = "LOAD"
                
        elif flowchartBox == "LOAD":
            LOADIND = 0
            flowchartBox = "ANON54"
            
        elif flowchartBox in ["ANON54", "LOADRET"]:
            if LOADIND == 0:
                flowchartBox = "ANON55"
            else:
                flowchartBox = "ULRET"
                
        elif flowchartBox == "ANON55":
            flowchartBox = "D" 
            
        elif flowchartBox == "ULRET":
            LOADIND = 0
            flowchartBox = "E"    
          
        else:
            print("Incomplete implementation:", flowchartBox, file=sys.stderr)
            sys.exit(1)
       
    return disassembly, wasExit

# Returns a state structure corresponding to "beginning".  
def interpretiveStart():
    return { }

def disassembleInterpretive(core, bank, offset, state):
    global bankDebug, offsetDebug
    bankDebug = bank
    offsetDebug = offset
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

