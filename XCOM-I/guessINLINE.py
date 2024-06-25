#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   instructionsIBM360.py
Purpose:    This is a module that I hope will be useful to somebody (me!)
            writing C-language equivalents for blocks of CALL INLINE statements
            consisting of IBM 360 machine code in XPL source files.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-06-24 RSB  Began.
'''

import sys
from parseCommandLine import indentationQuantum, lines
from auxiliary import getAttributes

# The `guessFiles` dictionary has keys which are the starting patch numbers
# for each block of consecutive CALL INLINEs found.  The values of these
# keys are lists of the patches for each patch-number in the block.
# Any given one of these patches is also a list, with one string entry
# for each line of the C-code generated.  All of these guesses are output
# at the very end of compilation.  I don't create the files as they're 
# encountered, because while it's "easy" enough to start the files and 
# populate them, it's tricky to figure out when to close the files.
# There's so little patched material that it's just easier to accumulate it
guessFiles = { }

# `instructionTypes` is a dictionary that gives characteristics of different
# instruction types (such as "RR", "RX", ...), such as the number of bytes of
# memory the instruction type takes.
instructionTypes = {
    "E": { "length": 2 },
    "I": { "length": 2 },
    "RR": { "length": 2 },
    "RRE": { "length": 4 },
    "RRF": { "length": 4 },
    "RX": { "length": 4 },
    "RXE": { "length": 6 },
    "RXF": { "length": 6 },
    "RS": { "length": 4 },
    "RSE": { "length": 6 },
    "RSL": { "length": 6 },
    "RSI": { "length": 4 },
    "RI": { "length": 4 },
    "RIL": { "length": 6 },
    "SI": { "length": 4 },
    "S": { "length": 4 },
    "SS": { "length": 6 },
    "SSE": { "length": 6 }
    }

'''
`instructions360` is a dictionary that can be used for lookup of IBM 360 
instructions either by mnemonic or opcode.  The properties included in the
dictionary are:
    "mnemonic"    
    "opcode"      
    "type"        "RR", "RX", "SI", etc.
    "page"        Page number in the ESA/390 Principles of Operation
'''
instructions360 = {
    }

def makeInstruction(mnemonic, opcode, tipe, page):
    if mnemonic in instructions360 or opcode in instructions360:
        print("Duplicated IBM 360 mnemonic or opcode %s,%d" % \
              (mnemonic, opcode), file=sys.stderr)
    instructions360[opcode] = {
        "mnemonic": mnemonic,
        "opcode": opcode,
        "type": tipe,
        "page": page
        }
    instructions360[mnemonic] = instructions360[opcode]

makeInstruction("BALR", 0x05, "RR", "7-14")
makeInstruction("BCTR", 0x06, "RR", "7-18")
makeInstruction("BCR", 0x07, "RR", "7-17")
makeInstruction("LR", 0x18, "RR", "7-77")
makeInstruction("CR", 0x19, "RR", "7-35")
makeInstruction("AR", 0x1A, "RR", "7-12")
makeInstruction("SR", 0x1B, "RR", "7-127")
makeInstruction("LPDR", 0x20, "RR", "18-17")
makeInstruction("LDR", 0x28, "RR", "9-10")
makeInstruction("CDR", 0x29, "RR", "18-10")
makeInstruction("ADR", 0x2A, "RR", "18-8")
makeInstruction("SDR", 0x2B, "RR", "18-23")

makeInstruction("LA", 0x41, "RX", "7-78")
makeInstruction("IC", 0x43, "RX", "7-76")
makeInstruction("EX", 0x44, "RX", "7-74")
makeInstruction("BC", 0x47, "RX", "7-17")
makeInstruction("LH", 0x48, "RX", "7-80")
makeInstruction("AH", 0x4A, "RX", "7-12")
makeInstruction("ST", 0x50, "RX", "7-122")
makeInstruction("L", 0x58, "RX", "7-7")
makeInstruction("A", 0x5A, "RX", "7-12")
makeInstruction("STD", 0x60, "RX", "9-11")
makeInstruction("LD", 0x68, "RX", "9-10")
makeInstruction("CD", 0x69, "RX", "18-10")
makeInstruction("AD", 0x6A, "RX", "18-8")
makeInstruction("SD", 0x6B, "RX", "18-23")
makeInstruction("AW", 0x6E, "RX", "18-10")
makeInstruction("STE", 0x70, "RX", "9-11")
makeInstruction("LE", 0x78, "RX", "9-10")

makeInstruction("SRL", 0x88, "RS", "7-121")
makeInstruction("SLDL", 0x8D, "RS", "7-119")

makeInstruction("MVI", 0x92, "SI", "7-83")
makeInstruction("XI", 0x97, "SI", "7-74")

makeInstruction("MVC", 0xD2, "SS", "7-83")
makeInstruction("TR", 0xDC, "SS", "7-131")

pc = 0 # Program counter.  Reset to 0 at the start of each procedure.
# Return True on success, False on failure
def guessINLINE(scope, functionName, parameters, inlineCounter, errxitRef, \
                   reset = False):
    global pc
    returnValue = True
    
    if reset:
        pc = 0
    
    # The parameter is the index of the *expected* B in the `parameters` 
    # array.  If `anyX` is true, B is immediately preceded in `parameters`
    # by the index register (X).  The return value is an ordered pair:
    #    The number of entries in `parameters` actually used.
    #    A string of C code that's an expression for X(B,D), or None on failure.
    def getXBD(iBD, anyX = False):
        address = ""
        count = 0
        if iBD >= len(parameters):
            return count, None
        if anyX:
            count += 1
            if iBD < 1:
                return count, None
            tokenX = parameters[iBD - 1]["token"]
            if "number" not in tokenX:
                return count, None
            regX = tokenX["number"]
            if regX > 0:
                address = "GR[%d] + " % regX
        tokenB = parameters[iBD]["token"]
        if "number" in tokenB:
            count += 2
            regB = tokenB["number"]
            if regB > 0:
                address = address + ("GR[%d] + " % regB)
            if iBD + 1 >= len(parameters):
                return count, None
            tokenD = parameters[iBD + 1]["token"]
            if "number" not in tokenD:
                return count, None
            address = address + ("%d" % tokenD["number"])
        elif "identifier" in tokenB:
            count += 1
            identifier = tokenB["identifier"]
            attributes = getAttributes(scope, identifier)
            if attributes == None:
                return count, None
            else:
                address = address + ("%d" % attributes["address"])
        else:
            return count, None
        return count, address
    
    # Similar to getXBD(), but just for a single register.  Returns the register
    # number, or None on failure.  It returns a number rather than a string for
    # an expression, because we don't know whether it's a general-purpose 
    # register or a floating-point register.
    def getR(iR):
        if iR < 1 or iR >= len(parameters):
            return None
        token = parameters[iR]["token"]
        if "number" not in token:
            return None
        return token["number"]
    
    # Generate a jump-table for a branch instruction.  The `address` parameter
    # is a string with a negative address for the jump, typically something 
    # like "GR[n]".
    def generateJumpTable(indent, address):
        parentProcedure = findParentProcedure(scope)
        labels = parentProcedure["labels"]
        if len(labels) < 2:
            errxit("There are no labels in this PROCEDURE for INLINE branches")
        indent1 = indent + indentationQuantum
        print(indent + "switch (%s): {" % address)
        for i in range(1, len(labels)):
            print(indent1 + "case -%d: goto %s;" % (i, labels[i]))
        print(indent + "}")
    
    indent = indentationQuantum
    TBD = indent + "// ***FIXME***"
    guessFile = guessFiles[list(guessFiles)[-1]]
    thisLine = []  # Add C lines to this list.
    if len(guessFile) == 0:
        guessFile.append(["{"])
        guessFile.append([indent + "// File:\tguess%d.c" % inlineCounter])
        guessFile.append([indent + "// For:\t%s.c" % functionName])
        guessFile.append([indent + "// Note:\tPage references are from IBM ESA/390 Principles of Operation"])
        guessFile.append(["}"])
    guessFile.insert(-1, thisLine)
    
    thisLine.append("")
    thisLine.append(indent + "// (%d) %s" % (inlineCounter, lines[errxitRef]))
    length = len(parameters)
    if length == 0:
        thisLine.append(TBD)
        return False
    if "number" in parameters[0]["token"]:
        opcode = parameters[0]["token"]["number"]
    else:
        thisLIne.append(TBD)
        return False
    if opcode not in instructions360:
        thisLine.append(TBD)
        return False
    instruction = instructions360[opcode]
    mnemonic = instruction["mnemonic"]
    typeName = instruction["type"]
    typeData = instructionTypes[typeName]
    pageNumber = instruction["page"]
    instructionLength = typeData["length"]
    thisLine.append(indent + "// Mnemonic " + mnemonic + ", type %s, " % typeName \
                    + "p. %s" % pageNumber)
    
    # Convert all of the parameters of CALL(...) inline to appropriate addresses,
    # either integers Rn (used as indices for GR[n] or FR[n]) or as assignments
    # for the C global variables address360A or address360B.
    if typeName == "RR":
        R1 = getR(1)
        R2 = getR(2)
        if (R1 == None or R2 == None):
            thisLine.append(TBD)
            return False
    elif typeName == "RX":
        R1 = getR(1)
        if R1 == None:
            thisLine.append(TBD)
            return False
        count, address360B = getXBD(3, True)
        if address360B != None:
            thisLine.append(indent + "address360B = %s;" % address360B)
        if R1 == None or address360B == None:
            thisLine.append(TBD)
            return False
    elif typeName == "SS":
        msNibble = parameters[1]["token"]["number"]
        lsNibble = parameters[2]["token"]["number"]
        L = (msNibble << 4) + lsNibble
        count, address360A = getXBD(3, False)
        if address360A != None:
            thisLine.append(indent + "address360A = %s;" % address360A)
        count, address360B = getXBD(3 + count, False)
        if address360B != None:
            thisLine.append(indent + "address360B = %s;" % address360B)
        if address360A == None or address360B == None:
            thisLine.append(TBD)
            return False
    elif typeName == "RS":
        R1 = getR(1)
        R3 = getR(2)
        count, address360B = getXBD(3, False)
        if R1 == None or R3 == None or address360B == None:
            thisLine.append(TBD)
            return False
    elif typeName == "SI":
        I2 = getR(1)
        count, address360A = getXBD(2, False)
        if address360A != None:
            thisLine.append(indent + "address360A = %s;" % address360A)
        if I2 == None or address360A == None:
            thisLine.append(TBD)
            return False
    else:
        thisLine.append(TBD)
        return False
    
    # Generated proposed code.
    if opcode == 0x06: # BCTR p. 7-18
        thisLine.append(TBD)
    elif opcode == 0x07: # BCR p. 7-17
        thisLine.append(TBD)
    elif opcode == 0x18: # LR p. 7-77
        thisLine.append(indent + "GR[%d] = GR[%d];" % (R1, R2))
    elif opcode == 0x19: # CR p. 7-35
        thisLine.append(indent + "scratch = (int64_t) GR[%d] - (int64_t) GR[%d];" % (R1, R2))
        thisLine.append(indent + "setCC();")
    elif opcode == 0x1A: # AR p. 7-12
        thisLine.append(indent + "scratch = (int64_t) GR[%d] + (int64_t) GR[%d];" % (R1, R2))
        thisLine.append(indent + "setCC();")
    elif opcode == 0x1B: # SR p. 7-127
        thisLine.append(indent + "scratch = (int64_t) GR[%d] - (int64_t) GR[%d];" % (R1, R2))
        thisLine.append(indent + "setCC();")
        thisLine.append(indent + "GR[%d] = (int32_t) scratch;" % R1)
    elif opcode == 0x20: # LPDR p. 18-17
        thisLine.append(indent + "scratchd = fabs(FR[%d]);" % R2)
        thisLine.append(indent + "setCCd();")
        thisLine.append(indent + "FR[%d] = scratchd;" % R1)
    elif opcode == 0x28: # LDR p. 9-10
        thisLine.append(indent + "FR[%d] = FR[%d];" % (R1, R2))
        # Note: No CC effect.
    elif opcode == 0x29: # CDR p. 18-10
        thisLine.append(indent + "scratchd = FR[%d] - FR[%d];" % (R1, R2))
        thisLine.append(indent + "setCCd();")
    elif opcode == 0x2A: # ADR p. 18-8
        thisLine.append(indent + "scratchd = FR[%d] + FR[%d];" % (R1, R2))
        thisLine.append(indent + "setCCd();")
        thisLine.append(indent + "FR[%d] = scratchd;" % R1)
    elif opcode == 0x2B: # SDR p. 18-23
        thisLine.append(indent + "scratchd = FR[%d] - FR[%d];" % (R1, R2))
        thisLine.append(indent + "setCCd();")
        thisLine.append(indent + "FR[%d] = scratchd;" % R1)
    elif opcode == 0x41: # LA p. 7-78
        thisLine.append(indent + "GR[%d] = address360B;" % R1)
    elif opcode == 0x43: # IC p. 7-76
        thisLine.append(indent + \
              "GR[%d] = (memory[address360B] << 24) | (GR[%d] & 0xFFFFFF);" \
              % (R1, R1))
    elif opcode == 0x44: # EX p. 7-74
        thisLine.append(TBD)
        return False
    elif opcode == 0x47: # BC p. 7-17
        thisLine.append(TBD)
        return false
    elif opcode == 0x48: # LH p. 7-80
        thisLine.append(indent + "GR[%d] = COREHALFWORD(address360B);" % R1)
    elif opcode == 0x4A: # AH p. 7-12
        thisLine.append(indent + "scratch = GR[%d] + COREHALFWORD(address360B);" % R1)
        thisLine.append(indent + "setCC();")
        thisLine.append(indent + "GR[%d] = scratch;" % R1)
    elif opcode == 0x50: # ST p. 7-122
        thisLine.append(indent + "COREWORD2(address360B, GR[%d]);" % R1)
    elif opcode == 0x58: # L p. 7-77
        thisLine.append(indent + "GR[%d] = COREWORD(address360B);" % R1)
    elif opcode == 0x5A: # A p. 7-12
        thisLine.append(indent + "scratchd = GR[%d] + COREWORD[address360B];" % R1)
        thisLine.append(indent + "setCC();")
        thisLine.append(indent + "GR[%d] = scratch;" % R1)
    elif opcode == 0x60: # STD p. 9-11
        thisLine.append(indent + "toFloatIBM(&msw360, &lsw360, FR[%d]);" % R1)
        thisLine.append(indent + "COREWORD2(address360B, msw360);")
        thisLine.append(indent + "COREWORD2(address360B + 4, lsw360);")
    elif opcode == 0x68: # LD p. 9-10
        thisLine.append(indent + \
            "FR[%d] = fromFloatIBM(COREWORD(address360B), COREWORD(address360B + 4));"\
            % R1)
    elif opcode == 0x69: # CD p. 18-10
        thisLine.append(indent + "scratchd = FR[%d];" % R1)
        thisLine.append(indent + \
              "scratchd -= fromFloatIBM(COREWORD(address360B), COREWORD(address360B + 4));")
        thisLine.append(indent + "setCCd();")
    elif opcode == 0x6A: # AD p. 18-8
        thisLine.append(indent + "scratchd = FR[%d];" % R1)
        thisLine.append(indent + \
              "scratchd += fromFloatIBM(COREWORD(address360B), COREWORD(address360B + 4));")
        thisLine.append(indent + "setCCd();")
        thisLine.append(indent + "FR[%d] = scratchd;" % R1)
    elif opcode == 0x6B: # SD p. 18-23
        thisLine.append(indent + "scratchd = FR[%d];" % R1)
        thisLine.append(indent + \
              "scratchd -= fromFloatIBM(COREWORD(address360B), COREWORD(address360B + 4));")
        thisLine.append(indent + "setCCd();")
        thisLine.append(indent + "FR[%d] = scratchd;" % R1)
    elif opcode == 0x6E: # AW p. 18-10
        thisLine.append(indent + "scratchd = FR[%d];" % R1)
        thisLine.append(indent + \
              "scratchd += fromFloatIBM(COREWORD(address360B), COREWORD(address360B + 4));")
        thisLine.append(indent + "setCCd();")
        thisLine.append(indent + "FR[%d] = scratchd;" % R1)
    elif opcode == 0x70: # STE p. 9-11
        thisLine.append(indent + "toFloatIBM(&msw360, &lsw360, FR[%d]);" % R1)
        thisLine.append(indent + "COREWORD2(address360B, msw360);")
    elif opcode == 0x78: # LE p. 9-10
        thisLine.append(indent + "FR[%d] = fromFloatIBM(COREWORD(address360), 0);" % R1)
    elif opcode == 0xD2: # MVC p. 7-83
        thisLine.append(indent + \
              "memmove(&memory[address360A], &memory[address360B], %d);" % \
              (L + 1))
    elif opcode == 0xDC: # TR p. 7-131
        # I'm sure there's some standard C library function to do this, but
        # I couldn't find it.
        indent2 = indent + indentationQuantum
        thisLine.append(indent + "int i;")
        thisLine.append(indent + "for (i = 0; i < %d; i++)" % (L + 1))
        thisLine.append(indent2 + 
              "memory[address360A + i] = memory[memory[address360B + i]];")
    elif opcode == 0x88: # SRL p. 7-121
        thisLine.append(indent + "GR[%d] = GR[%d] >> ((%s) & 0x3F);" % \
              (R1, R1, address360B))
    elif opcode == 0x8D: # SLDL p. 7-119
        thisLine.append(indent + 
              "scratch = (((int64_t) GR[%d]) << 32) | GR[%d];" % (R1, R1 + 1))
        thisLine.append(indent + "scratch = scratch << ((%s) & 0x3F);" % address360B)
        thisLine.append(indent + "GR[%d] = scratch >> 32;" % R1)
        thisLine.append(indent + "GR[%d] = scratch & 0xFFFFFFFF;" % (R1 + 1))
    elif opcode == 0x92: # MVI p. 7-83
        thisLine.append(indent + "COREWORD2(address360A, %d);" % I2)
    elif opcode == 0x97: # XI p. 7-74
        thisLine.append(indent + "scratch = %d ^ COREWORD(address360A);" % I2)
        thisLine.append(indent + "CC = (scratch != 0);")
        thisLine.append(indent + "COREWORD2(address360A, (int32_t) scratch);")
    else:
        thisLine.append(TBD)
        return False
    return True

