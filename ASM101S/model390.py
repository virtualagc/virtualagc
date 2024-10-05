'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   model390.py
Purpose:    This is object-code generation stuff for ASM101S, specific to the 
            assembly language of the IBM System/390 computer.  I don't expect
            to every implement this, so it's basically just a stub.
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-09-05 RSB  Began.

At the moment, this is just a place-holder, since System/390 support for ASM101S
is pure speculation for some far-future time.  Refer to model101.py to see 
how a more-fleshed-out version of this file might be created.
'''

#=============================================================================
# instruction set.

ap101 = False
system390 = True

# First, the CPU instructions, categorized by instruction types
argsE = set()
argsRR = set()
argsI = set()
argsRRE = set()
argsRRF = set()
argsRX = set()
argsRXE = set()
argsRXF = set()
argsRS = set()
argsRSE = set()
argsRSL = set()
argsRSI = set()
argsRI = set()
argsRIL = set()
argsSRS = set()
argsSI = set()
argsS = set()
argsSS = set()
argsSSE = set()

# Now, the MSC instructions.
argsMSC = set()

# And BCE instructions.
argsBCE = set()

knownInstruction = set.union(argsE, argsRR, argsI, argsRRE, argsRRF, argsRX, 
                             argxRXE, argsRXF, argsRS, argsRSE, argsRSL, 
                             argsRSI, argsRI, argsRIL, argsSRS, 
                             argsSI, argsS, argsSS, argsSSE, argsMSC, argsBCE)
instructionsWithoutOperands = set.union(argsE, argsBCE)
instructionsWithOperands = knownInstructions - instructionsWithoutOperands
                                                        