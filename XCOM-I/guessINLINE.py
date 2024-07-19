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
import datetime
from parseCommandLine import indentationQuantum, lines, ifdefs, traceInlines
from auxiliary import getAttributes, findParentProcedure

# The `guessFiles` dictionary has keys which are the starting patch numbers
# for each block of consecutive CALL INLINEs found.  The values of these
# keys are lists of the patches for each patch-number in the block.
# Any given one of these patches is also a list, with one string entry
# for each line of the C-code generated.  All of these guesses are output
# at the very end of compilation.  I don't create the files as they're 
# encountered, because while it's "easy" enough to start the files and 
# populate them, it's tricky to figure out when to close the files.
# There's so little patched material that it's just easier to accumulate it.
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

condition = "(CC == 0 && (mask360 & 8) != 0) || " + \
            "(CC == 1 && (mask360 & 4) != 0) || " + \
            "(CC == 2 && (mask360 & 2) != 0) || " + \
            "(CC == 3 && (mask360 & 1) != 0)"
condition1 = "if ((CC == 0 && (mask360 & 8) != 0) || " + \
            "(CC == 1 && (mask360 & 4) != 0) || "
condition2 = "    (CC == 2 && (mask360 & 2) != 0) || " + \
            "(CC == 3 && (mask360 & 1) != 0))"
pc = 0 # Program counter.  Reset to 0 at the start of each procedure.
patchBase = ""
offsetsInBlock = []
# Return True on success, False on failure
def guessINLINE(scope, functionName, parameters, inlineCounter, errxitRef,
                indexInScope):
    global pc, patchBase, offsetsInBlock
    returnValue = False
    
    guessFile = guessFiles[list(guessFiles)[-1]]
    if len(guessFile) == 0:
        pc = 0
        patchBase = "p%d_" % inlineCounter
        # To generate jump-tables for branch instructions to numerical addresses
        # rather than to XPL labels, we have to know the byte offsets of each
        # instruction in this block of inlines, and we have to know them all
        # in advance.  So let's do some look-ahead here to find them.
        offsetsInBlock = [0]
        code = scope["code"]
        for i in range(indexInScope, len(code)):
            line = code[i]
            if "CALL" in line and line["CALL"] == "INLINE":
                p = line["parameters"]
                token = p[0]["token"]
                length = 0
                if "number" in token:
                    opcode = token["number"]
                    if opcode in instructions360:
                        instructionType = instructions360[opcode]["type"]
                        if instructionType in instructionTypes:
                            length = instructionTypes[instructionType]["length"]
                if length > 0:
                    offsetsInBlock.append(offsetsInBlock[-1] + length)
    nextLabel = patchBase + "%d: ;" % pc
    
    # The parameter is the index of the *expected* B in the `parameters` 
    # array.  If `anyX` is true, B is immediately preceded in `parameters`
    # by the index register (X).  The return value is an ordered pair:
    #    The number of entries in `parameters` actually used.
    #    A string of C code that's an expression for X(B,D), or None on failure.
    X = 0
    B = 0
    D = 0
    sD = "0"
    identifierD = None
    def getXBD(iBD, anyX = False):
        nonlocal X, B, D, identifierD, sD
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
            X = regX
        else:
            X = 0
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
            B = regB
            D = tokenD["number"]
            sD = "%d" % D
            identifierD = None
        elif "identifier" in tokenB:
            count += 1
            identifier = tokenB["identifier"]
            attributes = getAttributes(scope, identifier)
            if attributes == None:
                return count, None
            B = 0
            D = attributes["address"]
            if False:
                sD = "%d" % D
            else:
                sD = "m" + attributes["mangled"]
            identifierD = identifier
        else:
            return count, None
        if False:
            if isinstance(D, str):
                address += D
            else:
                address = address + ("%d" % D)
        else:
            address += sD
        return count, "(" + address + ") & 0xFFFFFF"
    
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

    # Instead of `return True` or `return False`, use `return endOfInstruction()`.
    def endOfInstruction(msg = None):
        global pc
        if msg != None:
            thisLine.append(indent + msg)
        thisLine.append("")
        thisLine.append(nextLabel)
        pc = nextPc
        return returnValue
    
    # Generate a jump-table for a branch instruction.  The `address` parameter
    # is a string for a C expression.  There are two cases:
    #    1. Negative addresses, by convention, represent the XPL labels within
    #       the procedure.
    #    2. Positive addresses, again by convention, are the byte offset of an
    #       instruction within the current block.
    # We know which is which at compile-time because the former come only from
    # RR-type instructions, and the other come from RX-type instructions.
    # However, I think that's a false economy, and each jump table is generated
    # with all known reachable local addresses.
    # Returns False on success, True on error
    def generateJumpTable(indent, address):
        indent1 = indent + indentationQuantum
        parentProcedure = findParentProcedure(scope)
        labels = parentProcedure["allLabels"]
        if len(labels) == 0 and len(offsetsInBlock) == 0:
            thisLine.append(indent + "// " + str(labels))
            thisLine.append(indent + ";" + FIXME + \
                "No available targets for jump-table generation")
            return True # Error!
        thisLine.append(indent + "switch (%s) {" % address)
        for i in range(len(labels)):
            thisLine.append(indent1 + "case -%d: goto %s;" % (i+1, labels[i]))
        for i in range(len(offsetsInBlock)):
            thisLine.append(indent1 + "case %d: goto %s%d;" % \
                            (offsetsInBlock[i], patchBase, offsetsInBlock[i]))
        thisLine.append(indent1 + \
            'default: abend("Unsupported target address in jump table");')
        thisLine.append(indent + "}")
        return False
    
    indent = indentationQuantum
    FIXME = indent + "// ***FIXME*** "
    thisLine = []  # Add C lines to this list.
    if len(guessFile) == 0:
        if "P" in ifdefs:
            suffix = "p"
        elif "B" in ifdefs:
            suffix = "b"
        else:
            suffix = ""
        guessFile.append([
            "{",
            indent + "/*",
            indent + \
            " * File:      patch%d.c" % (inlineCounter),
            indent + \
            " * For:       %s.c" % functionName,
            indent + \
            ' * Notes:     1. Page references are from IBM "ESA/390 Principles of',
            indent + \
            ' *               Operation", SA22-7201-08, Ninth Edition, June 2003.',
            indent + \
            ' *            2. Labels are of the form p%d_%d, where the 1st number',
            indent + \
            ' *               indicates the leading patch number of the block, and',
            indent + \
            ' *               the 2nd is the byte offset of the instruction within',
            indent + \
            ' *               within the block.',
            indent + \
            ' *            3. Known-problematic translations are marked with the',
            indent + \
            ' *               string  "* * * F I X M E * * *" (without spaces).',
            indent + \
            ' * History:   %s RSB  Auto-generated by XCOM-I --guess=....' % \
                    datetime.datetime.now().strftime("%Y-%m-%d"),
            indent + " */",
            "",
            nextLabel
            ])
        guessFile.append(["}"])
    guessFile.insert(-1, thisLine)
    
    indent1 = indent + indentationQuantum
    indent2 = indent1 + indentationQuantum
    indent3 = indent2 + indentationQuantum
    
    thisLine.append(indent + "// (%d) %s" % (inlineCounter, lines[errxitRef]))
    length = len(parameters)
    if length == 0:
        return endOfInstruction(FIXME + "INLINE with no parameters")
    if "number" in parameters[0]["token"]:
        opcode = parameters[0]["token"]["number"]
    else:
        return endOfInstruction(FIXME + "Opcode not a number")
    if opcode not in instructions360:
        return endOfInstruction(FIXME + "Not a supported opcode")
    instruction = instructions360[opcode]
    mnemonic = instruction["mnemonic"]
    typeName = instruction["type"]
    typeData = instructionTypes[typeName]
    pageNumber = instruction["page"]
    instructionLength = typeData["length"]
    
    # At the end of this instruction, use the following two items to update
    # the program counter and to print the label for the next instruction.
    nextPc = pc + instructionLength
    nextLabel = patchBase + "%d: ;" % nextPc
    
    # Convert all of the parameters of CALL(...) inline to appropriate addresses,
    # either integers Rn (used as indices for GR[n] or FR[n]) or as assignments
    # for the C global variables address360A or address360B.
    if typeName == "RR":
        R1 = getR(1)
        R2 = getR(2)
        if (R1 == None or R2 == None):
            return endOfInstruction(FIXME + "R1 or R2 in RR type not a number")
        stringified = mnemonic + "\t" + "%d,%d" % (R1, R2)
    elif typeName == "RX":
        R1 = getR(1)
        if R1 == None:
            return endOfInstruction(FIXME + "R1 in RX type not a number")
        count, address360B = getXBD(3, True)
        if address360B != None:
            thisLine.append(indent + "address360B = %s;" % address360B)
        else:
            return endOfInstruction(FIXME + "Cannot compute address in RX type")
        stringified = mnemonic + "\t" + "%d,%s(%d,%d)" % \
                                 (R1, sD, X, B)
    elif typeName == "SS":
        msNibble = parameters[1]["token"]["number"]
        lsNibble = parameters[2]["token"]["number"]
        L = (msNibble << 4) + lsNibble
        count, address360A = getXBD(3, False)
        if address360A != None:
            thisLine.append(indent + "address360A = %s;" % address360A)
        else:
            return endOfInstruction(FIXME + "Cannot compute first address in SS type")
        X1 = X
        B1 = B
        D1 = D
        sD1 = "" + sD
        count, address360B = getXBD(3 + count, False)
        if address360B != None:
            thisLine.append(indent + "address360B = %s;" % address360B)
        else:
            return endOfInstruction(FIXME + "Cannot compute second address in SS type")
        X2 = X
        B2 = B
        D2 = D
        sD2 = sD
        stringified = mnemonic + "\t" + "%s(%d,%d),%s(%d)" %\
                                 (sD1, L, B1, sD2, B2)
    elif typeName == "RS":
        R1 = getR(1)
        R3 = getR(2)
        count, address360B = getXBD(3, False)
        if R1 == None or R3 == None or address360B == None:
            return endOfInstruction(FIXME + "Cannot get R1, R3, or address in RS type")
        stringified = mnemonic + "\t" + "%d,%d,%s(%d)" % (R1, R3, sD, B)
    elif typeName == "SI":
        msNibble = parameters[1]["token"]["number"]
        lsNibble = parameters[2]["token"]["number"]
        I2 = (msNibble << 4) + lsNibble
        count, address360A = getXBD(3, False)
        if address360A != None:
            thisLine.append(indent + "address360A = %s;" % address360A)
        else:
            return endOfInstruction(FIXME + "Cannot compute address in SI type")
        if I2 == None:
            return endOfInstruction(FIXME + "Immediate value not a number in SI type")
        stringified = mnemonic + "\t" + "%s(%d),%d" % (sD, B, I2)
    else:
        return endOfInstruction(FIXME + "Unsupported instruction type %s" % typeName)
    
    thisLine.append(indent + "// Type %s, " % typeName \
                    + "p. %s:\t\t%s" % (pageNumber, stringified))
    
    if traceInlines:
        thisLine.append(indent + 'detailedInlineBefore(%d, "%s");' % \
                        (inlineCounter, stringified))
    # Generated proposed code.
    if opcode == 0x05: # BALR p. 7-14
        thisLine.append(indent + "GR[%d] = %d;" % (R1, nextPc))
        if R2 != 0:
            generateJumpTable(indent, "GR[%d]" % R2)
    elif opcode == 0x06: # BCTR p. 7-18
        thisLine.append(indent + "GR[%d] = GR[%d] - 1;" % (R1, R1))
        if R2 != 0:
            thisLine.append(indent + "if (GR[%d] != 0)" % R1)
            if generateJumpTable(indent1, "GR[%d]" % R2):
                return endOfInstruction()
    elif opcode == 0x07: # BCR p. 7-17
        thisLine.append(indent + "mask360 = %d;" % R1)
        if R2 != 0:
            #thisLine.append(indent + "if (%s)" % condition)
            thisLine.append(indent + condition1)
            thisLine.append(indent + condition2)
            if generateJumpTable(indent1, "GR[%d]" % R2):
                return endOfInstruction()
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
        thisLine.append(indent + "GR[%d] = address360B & 0xFFFFFF;" % R1)
    elif opcode == 0x43: # IC p. 7-76
        thisLine.append(indent + \
              "GR[%d] = memory[address360B] | (GR[%d] & 0xFFFFFF00);" \
              % (R1, R1))
    elif opcode == 0x44: # EX p. 7-74
        return endOfInstruction(FIXME + "Unsupported opcode %s" % mnemonic)
    elif opcode == 0x47: # BC p. 7-17
        if B == 0 and X == 0:
            thisLine.append(indent + "mask360 = %d;" % R1)
            #thisLine.append(indent + "if (%s)" % condition)
            thisLine.append(indent + condition1)
            thisLine.append(indent + condition2)
            thisLine.append(indent1 + "goto %s;" % identifier)
        elif X == 0:
            thisLine.append(indent + "mask360 = %d;" % R1)
            #thisLine.append(indent + "if (%s)" % condition)
            thisLine.append(indent + condition1)
            thisLine.append(indent + condition2)
            if generateJumpTable(indent1, "address360B"):
                return endOfInstruction()
        else:
            return endOfInstruction(FIXME + 
                                    "BC not supported for this operand combination")
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
        thisLine.append(indent + "scratchd = GR[%d] + COREWORD(address360B);" % R1)
        thisLine.append(indent + "setCC();")
        thisLine.append(indent + "GR[%d] = scratch;" % R1)
    elif opcode == 0x60: # STD p. 9-11
        thisLine.append(indent + "std(%d, address360B);" % R1)
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
        thisLine.append(indent + "aw(%d, address360B);" % R1)
    elif opcode == 0x70: # STE p. 9-11
        thisLine.append(indent + "toFloatIBM(&msw360, &lsw360, FR[%d]);" % R1)
        thisLine.append(indent + "COREWORD2(address360B, msw360);")
    elif opcode == 0x78: # LE p. 9-10
        thisLine.append(indent + "FR[%d] = fromFloatIBM(COREWORD(address360B), 0);" % R1)
    elif opcode == 0xD2: # MVC p. 7-83
        thisLine.append(indent + "mvc(address360A, address360B, %d);" % L)
    elif opcode == 0xDC: # TR p. 7-131
        # I'm sure there's some standard C library function to do this, but
        # I couldn't find it.
        thisLine.append(indent + "for (i360 = 0; i360 <= %d; i360++)" % L)
        thisLine.append(indent1 + 
              "memory[address360A + i360] = memory[address360B + memory[address360A + i360]];")
    elif opcode == 0xDD: # TRT p. 7-132
        thisLine.append(indent + "trt(address360A, address360B, length;")
    elif opcode == 0x88: # SRL p. 7-121
        thisLine.append(indent + "scratch = (%s) & 0x3f;" % address360B);
        thisLine.append(indent + "if (scratch < 32)");
        thisLine.append(indent1 + "GR[%d] = GR[%d] >> scratch;" % (R1, R1))
        thisLine.append(indent + "else");
        thisLine.append(indent1 + "GR[%d] = 0;" % R1);
    elif opcode == 0x8D: # SLDL p. 7-119
        thisLine.append(indent + 
              "scratch = (((int64_t) GR[%d]) << 32) | GR[%d];" % (R1, R1 + 1))
        thisLine.append(indent + "scratch = scratch << ((%s) & 0x3F);" % address360B)
        thisLine.append(indent + "GR[%d] = scratch >> 32;" % R1)
        thisLine.append(indent + "GR[%d] = scratch & 0xFFFFFFFF;" % (R1 + 1))
    elif opcode == 0x92: # MVI p. 7-83
        thisLine.append(indent + "memory[address360A] = %d;" % I2)
    elif opcode == 0x97: # XI p. 7-74
        thisLine.append(indent + "scratch = %d ^ memory[address360A];" % I2)
        thisLine.append(indent + "CC = (scratch != 0);")
        thisLine.append(indent + "memory[address360A] = scratch;")
    else:
        return endOfInstruction(FIXME + "Implementation error %d,%s" % \
                                (opcode, mnemonic))
    returnValue = True
    if traceInlines:
        thisLine.append(indent + "detailedInlineAfter();")
    return endOfInstruction()

