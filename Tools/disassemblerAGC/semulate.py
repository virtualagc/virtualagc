#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       semulate.py
Purpose:        Track what effects of on erasable and in particular on
                memory-bank settings which can be easily tracked at 
                assembly time.
History:        2022-09-28 RSB  Split off from disassemblerAGC.py.

I've invented the term "semulate" to embody the idea of semi-emulation.
The idea is this:  erasable (and register) locations for which we don't
know the value (or perhaps just don't know it easily) at assembly time
are assign the value -1.  Those for which we can (easily) know the value at
assembly time, since perhaps they arise from instruction sequences like
    CA  FIXED
    TS  ERASABLE
instead have the correct value stored in them.  And this is adjusted every
time there's some kind of write to erasable/registers.

This is imperfect not only in the sense of being incomplete, but also in 
the sense that it's not always possible to determine if a given memory
location contains a basic instruction vs data (or vs an interpretive
opcode).  This decision is made by the calling program, rather than by
semulate() itself, however.
"""

from registers import *

# Get the value stored at a 12-bit address, if possible.  If impossible
# at assembly-time, -1 is returned.  The addresses are as follows:
#   0000-0377   erasable bank 0
#   0400-0777   erasable bank 1
#   1000-1377   erasable bank 2
#   1400-1777   erasable bank pointed to by EB
#   2000-3777   fixed bank pointed to by FB/FEB
#   4000-5777   fixed bank 2
#   6000-7777   fixed bank 3
def get12bit(erasable, core, EB, FB, FEB, address):
    if address < 0:
        return -1
    elif address < 0o1400:
        return erasable[address // 0o400][address % 0o400]
    elif address < 0o2000:
        if EB != -1:
            return erasable[(EB >> 8) & 7][address % 0o400]
    elif address < 0o4000:
        if FB != -1:
            fixedBank = (FB >> 10) & 0o37
            if fixedBank < 0o30:
                return core[fixedBank][address % 0o2000]
            if FEB != -1:
                if FEB & 0o1000000 != 0:
                    fixedBank += 0o10
                return core[fixedBank][address % 0o2000]    
    else:
        return core[address // 0o2000][address % 0o2000]
    return -1

# Write a value to a 10-bit address, if possible.  If impossible
# at assembly-time, -1 is written to all of the erasable locations
# that *might* have been the ones desired.  The addresses are as follows:
#   0000-0377   erasable bank 0
#   0400-0777   erasable bank 1
#   1000-1377   erasable bank 2
#   1400-1777   erasable bank pointed to by EB
def put10bit(erasable, iochannels, EB, address, value):
    if address < 0:
        return
    offset = address % 0o400
    if address >= 0o1400:
        if EB == 0:
            # This step is to make sure that special registers
            # in bank E0 are treated correctly below.
            address = offset
        elif EB == -1:
            value = -1
            for i in range(1, 8):
                erasable[i][offset] = value
            EB = 0
            address = offset
            # Pass through to treat special registers properly.
    if address in [1, 2]:       # L or Q
        erasable[0][address] = value
        iochannels[address] = value
    elif address == 6: # BB
        if value == -1:
            erasable[0][6] = -1 # BB
            erasable[0][3] = -1 # EB
            erasable[0][4] = -1 # FB
        else:
            erasable[0][6] = value & 0o76007    # BB
            erasable[0][3] = (value & 0o7) << 8 # EB
            erasable[0][4] = value & 0o76000    # FB
    elif address in [3, 4]: # EB or FB
        if value == -1:
            erasable[0][address] = -1
            erasable[0][6] = -1 # BB
        else:
            if address == 3:
                value &= 0o03400
            else:
                value &= 0o76000
            erasable[0][address] = value
            if erasable[0][3] != -1 and erasable[0][4] != -1:
                erasable[0][6] = (erasable[0][4] & 0o76000) \
                    | ((erasable[0][3] >> 8) & 0o7)
            else:
                erasable[0][6] = -1
    elif address == 0o20:       # CYR
        if value != -1:
            b = value & 1
            value = (value >> 1) | (b << 14)
        erasable[0][address] = value
    elif address == 0o21:       # SR
        if value != -1:
            value = (value >> 1) | (value & 0o40000)
        erasable[0][address] = value
    elif address == 0o22:       # CYL
        if value != -1:
            b = value & 0o40000
            value = ((value << 1) & 0o77777) | (b >> 14)
        erasable[0][address] = value
    elif address == 0o23:       # EDOP
        if value != -1:
            value = (value >> 7) & 0o177
        erasable[0][address] = value
    elif address < 0o1400:
        erasable[address // 0o400][offset] = value
    else: # address >= 0o1400
        erasable[(EB >> 8) & 7][offset] = value

# Add two 1's-complement 15-bit values.  I don't try to account for
# a 16th bit in (say) the accumulator or for overflow, because I don't
# see how these things can work their way into EB or FB register 
# emulations at assembly-time.
def addOnesComplement(value1, value2):
    sum = value1 + value2
    if sum & 0o100000 != 0:
        sum += 1
        sum &= 0o77777
    return sum

# The function operates directly on erasable and iochannels, 
# and does not return any value.
def semulate(core, erasable, iochannels, opcode, operand):
    A = erasable[0][0]
    L = erasable[0][1]
    Q = erasable[0][2]
    EB = erasable[0][3]
    FB = erasable[0][4]
    Z = erasable[0][5]
    BB = erasable[0][6]
    FEB = iochannels[7]
    if not operand.isdigit():
        try:
            if opcode in ["WRITE", "WOR", "WAND", "READ", 
                          "ROR", "RAND", "RXOR"]: 
                operand = iochannelsByName[operand]
            else:
                operand = registersByName[operand]
        except:
            pass
    try:
        address12 = int(operand, 8)
        address10 = address12 & 0o1777
    except:
        address12 = -1
        address10 = -1
    
    if opcode == "AD":
        value = get12bit(erasable, core, EB, FB, FEB, address12)
        if A == -1 or value == -1:
            A = -1
        else:
            A = addOnesComplement(A, value)
        put10bit(erasable, iochannels, 0, 0, A)
        
    elif opcode == "ADS":
        value = get12bit(erasable, core, EB, FB, FEB, address10)
        if A == -1 or value == -1:
            A = -1
        else:
            A = addOnesComplement(A, value)
        put10bit(erasable, iochannels, 0, 0, A)
        put10bit(erasable, iochannels, EB, address10, A)
        
    elif opcode == "AUG":
        value = get12bit(erasable, core, EB, FB, FEB, address10)
        if value != -1:
            if value & 0o40000 != 0:
                value = addOnesComplement(value, 0o77776)
            else:
                value = addOnesComplement(value, 0o00001)
            put10bit(erasable, iochannels, EB, address10, value)
        
    elif opcode in ["BZF", "BZMF"]:
        pass
        
    elif opcode == "CA":
        A = get12bit(erasable, core, EB, FB, FEB, address12)
        put10bit(erasable, iochannels, 0, 0, A)
    
    elif opcode == "CCS":
        value = get12bit(erasable, core, EB, FB, FEB, address10)
        if value == -1:
            A = -1
        else:
            if 0o40000 & value != 0:
                value = 0o77777 & ~value
            if value > 1:
                A = value - 1
            else:
                A = 0
        put10bit(erasable, iochannels, 0, 0, A)
    
    elif opcode == "COM":
        if A != -1:
            A = 0o77777 & ~A
            put10bit(erasable, iochannels, 0, 0, A)
     
    elif opcode == "CS":
        A = get12bit(erasable, core, EB, FB, FEB, address12)
        if A != -1:
            A = 0o77777 & ~A
        put10bit(erasable, iochannels, 0, 0, A)
    
    elif opcode == "DAS":
        # TBD ... I'll figure this one out later.
        put10bit(erasable, iochannels, EB, address10, -1)
        put10bit(erasable, iochannels, EB, address10+1, -1)
        pass
        
    elif opcode == "DCA":
        A = get12bit(erasable, core, EB, FB, FEB, address12)
        L = get12bit(erasable, core, EB, FB, FEB, address12+1)
        put10bit(erasable, iochannels, 0, 0, A)
        put10bit(erasable, iochannels, 0, 1, L)
    
    elif opcode == "DCOM":
        if A != -1:
            A = 0o77777 & ~A
        if L != -1:
            L = 0o77777 & ~L
        put10bit(erasable, iochannels, 0, 0, A)
        put10bit(erasable, iochannels, 0, 1, L)
    
    elif opcode == "DCS":
        A = get12bit(erasable, core, EB, FB, FEB, address12)
        L = get12bit(erasable, core, EB, FB, FEB, address12+1)
        if A != -1:
            put10bit(erasable, iochannels, 0, 0, 0o77777 & ~A)        
        if L != -1:
            put10bit(erasable, iochannels, 0, 1, 0o77777 & ~L)
                
    elif opcode == "DDOUBL":
        # TBD ... use DAS code, once I figure that out.
        pass
    
    elif opcode == "DIM":
        value = get12bit(erasable, core, EB, FB, FEB, address10)
        if value in [-1, 0, 0o77777]:
            pass
        elif 0o40000 & value == 0:
            value -= 1
        else:
            value += 1
        put10bit(erasable, iochannels, EB, address10, value)
    
    elif opcode == "DOUBLE":
        if A != -1:
            A = addOnesComplement(A, A)
            put10bit(erasable, iochannels, 0, 0, A)        

    elif opcode == "DTCB":
        put10bit(erasable, iochannels, 0, 0, Z)        
        put10bit(erasable, iochannels, 0, 1, BB)        
        put10bit(erasable, iochannels, 0, 5, A)        
        put10bit(erasable, iochannels, 0, 6, L)        
    
    elif opcode == "DTCF":
        put10bit(erasable, iochannels, 0, 0, FB)        
        put10bit(erasable, iochannels, 0, 1, Z)        
        put10bit(erasable, iochannels, 0, 4, A)        
        put10bit(erasable, iochannels, 0, 5, L)        
    
    elif opcode == "DV":
        # Deliberately not implementing.
        put10bit(erasable, iochannels, 0, 0, -1)
        put10bit(erasable, iochannels, 0, 1, -1)
    
    elif opcode == "DXCH":
        valueA = get12bit(erasable, core, EB, FB, FEB, address10)
        valueL = get12bit(erasable, core, EB, FB, FEB, address10+1)
        put10bit(erasable, iochannels, EB, address10, A)
        put10bit(erasable, iochannels, EB, address10+1, L)
        put10bit(erasable, iochannels, 0, 0, valueA)
        put10bit(erasable, iochannels, 0, 1, valueL)

    elif opcode in ["EDRUPT", "EXTEND"]:
        pass
    
    elif opcode == "INCR":
        value = get12bit(erasable, core, EB, FB, FEB, address10)
        if value != -1:
            value = addOnesComplement(value, 1)
            put10bit(erasable, iochannels, EB, address10, value)
    
    elif opcode in ["INDEX", "INHINT"]:
        pass
    
    elif opcode == "LXCH":
        value = get12bit(erasable, core, EB, FB, FEB, address10)
        put10bit(erasable, iochannels, EB, address10, L)
        put10bit(erasable, iochannels, 0, 0, value)
    
    elif opcode == "MASK":
        value = get12bit(erasable, core, EB, FB, FEB, address10)
        if A != -1 and value != -1:
            put10bit(erasable, iochannels, EB, address10, value & A)
    
    elif opcode == "MP":
        put10bit(erasable, iochannels, 0, 0, -1)
        put10bit(erasable, iochannels, 0, 1, -1)
    
    elif opcode == "MSU":
        value = get12bit(erasable, core, EB, FB, FEB, address10)
        if A == -1 or value == -1:
            A = -1
        else:
            A = (A + value) & 0o77777
            if A & 0o40000 != 0:
                A = addOnesComplement(A, 0o77776)
        put10bit(erasable, iochannels, 0, 0, A)
    
    elif opcode in ["NOOP", "OVSK"]:
        pass
    
    elif opcode == "QXCH":
        value = get12bit(erasable, core, EB, FB, FEB, address10)
        put10bit(erasable, iochannels, EB, address10, Q)
        put10bit(erasable, iochannels, 0, 2, value)

    
    elif opcode == "RAND":
        if A == -1 or address10 >= len(iochannels) \
                or iochannels[address10] == -1:
            A = -1
        else:
            A = A & iochannels[address10]
        put10bit(erasable, iochannels, 0, 0, A)

    
    elif opcode == "READ":
        if address10 >= len(iochannels):
            A = -1
        else:
            A = iochannels[address10]
        put10bit(erasable, iochannels, 0, 0, A)

    
    elif opcode in ["RELINT", "RESUME", "RETURN"]:
        pass
        
    elif opcode == "ROR":
        if A == -1 or address10 >= len(iochannels) \
                or iochannels[address10] == -1:
            A = -1
        else:
            A = A | iochannels[address10]
        put10bit(erasable, iochannels, 0, 0, A)

    elif opcode == "RXOR":
        if A == -1 or address10 >= len(iochannels) \
                or iochannels[address10] == -1:
            A = -1
        else:
            A = A ^ iochannels[address10]
        put10bit(erasable, iochannels, 0, 0, A)
    
    elif opcode == "SQUARE":
        put10bit(erasable, iochannels, 0, 0, -1)
        put10bit(erasable, iochannels, 0, 1, -1)
    
    elif opcode == "SU":
        value = get12bit(erasable, core, EB, FB, FEB, address12)
        if A == -1 or value == -1:
            A = -1
        else:
            A = addOnesComplement(A, 0o77777 & ~value)
        put10bit(erasable, iochannels, 0, 0, A)

    elif opcode in ["TC", "TCF", "TCAA", "TCF"]:
        pass

    elif opcode == "TS":
        put10bit(erasable, iochannels, EB, address10, A)
    
    elif opcode == "WAND":
        if address10 >= 0 and address10 < len(iochannels):
            if A == -1 or iochannels[address10] == -1:
                value = -1
            else:
                value = A & iochannels[address10]
            iochannels[address10] = value
            if address10 in [1, 2]:
                put10bit(erasable, iochannels, 0, address10, value)

    elif opcode == "WOR":
        if address10 >= 0 and address10 < len(iochannels):
            if A == -1 or iochannels[address10] == -1:
                value = -1
            else:
                value = A | iochannels[address10]
            iochannels[address10] = value
            if address10 in [1, 2]:
                put10bit(erasable, iochannels, 0, address10, value)

    elif opcode == "WRITE":
        if address10 >= 0 and address10 < len(iochannels):
            iochannels[address10] = A
            if address10 in [1, 2]:
                put10bit(erasable, iochannels, 0, address10, A)
    
    elif opcode == "XCH":
        value = get12bit(erasable, core, EB, FB, FEB, address10)
        put10bit(erasable, iochannels, EB, address10, A)
        put10bit(erasable, iochannels, 0, 0, value)
    
    elif opcode in ["XLQ", "XXALQ"]:
        pass
      
    elif opcode == "ZL":
        put10bit(erasable, iochannels, 0, 1, 0)


    elif opcode == "ZQ":
        put10bit(erasable, iochannels, 0, 2, 0)



