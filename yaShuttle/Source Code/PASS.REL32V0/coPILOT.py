#!/usr/bin/env python
# The idea here to to try to parse BFS-type object code from members of 
# a PDS output by HAL/S compiler PASS2.
#
# Usage:
#    coPILOT.py memberNames

import sys
from asciiToEbcdic import *

# Get an EBCDIC string from a `bytearray` and convert to ASCII.
def fetchString(bytes, offset, length):
    string = ""
    for i in range(offset, offset+length):
        string += ebcdicToAscii[bytes[i]]
    return string

def fetchHalfword(bytes, offset):
    return 256 * bytes[offset] + bytes[offset + 1]

sections = [None]

for memberName in sys.argv[1:]:
    # Read entire contents of file.
    try:
        f = open(memberName, "rb")
        byteContents = f.read()
        f.close()
    except:
        print("Cannot read file " + memberName, file=sys.stderr)
        sys.exit(1)
    if 0 != len(byteContents) % 2:
        print("Member " + memberName + " has odd length", file=sys.stderr)
        sys.exit(1)
    print("Member " + memberName)
    offset = 0
    while offset < len(byteContents):
        type = byteContents[offset]
        type2 = byteContents[offset + 1]
        if type == 0x01:
            print("\t%04X: Start card" % offset)
            if type2 != 0x02:
                print("Corrupted card", file=sys.stderr)
                sys.exit(1)
            print("\t\torigin=%04X" % fetchHalfword(byteContents, offset + 2))
            offset += 4
        elif type == 0x02:
            print("\t%04X: CSECT Definition (CSD) card" % offset)
            endOffset = offset + 2 * (7 + type2 - 7)
            s = "\t\t"
            name = fetchString(byteContents, offset + 2, 8).rstrip()
            sections.append(name)
            s += 'CSECT=%s ' % name
            s += 'length=%04X ' % fetchHalfword(byteContents, offset + 10)
            s += 'stacksize=%04X ' % fetchHalfword(byteContents, offset + 12)
            if offset + 14 < endOffset:
                s += "flags=%04X " % fetchHalfword(byteContents, offset + 14)
            if offset + 16 < endOffset:
                s += "HAL=%s" % fetchString(byteContents, offset + 16, 6).rstrip()
            print(s)
            offset = endOffset
        elif type == 0x03:
            print("\t%04X: ESD card" % offset)
            offset += 16
        elif type == 0x04:
            print("\t%04X: External Reference Definition (EXR) card" % offset)
            endOffset = offset + 2 * (7 + type2 - 7)
            s = "\t\t"
            name = fetchString(byteContents, offset + 2, 8).rstrip()
            sections.append(name)
            s += 'EXR=%s ' % name
            s += 'version=%04X ' % fetchHalfword(byteContents, offset + 10)
            s += 'TBD=%04X ' % fetchHalfword(byteContents, offset + 12)
            if offset + 14 < endOffset:
                s += "flags=%04X " % fetchHalfword(byteContents, offset + 14)
            if offset + 16 < endOffset:
                s += "HAL=%s" % fetchString(byteContents, offset + 16, 6).rstrip()
            print(s)
            offset = endOffset
        elif type == 0x05:
            print("\t%04X: Link Edit Control (LEC) card" % offset)
            offset += 2 * (1 + type2)
        elif type == 0x06:
            print("\t%04X: Code or Constants %02X %02X" % (offset, type, type2))
            s = "\t\t"
            length = type2 - 3
            s += "offset=%04X " % fetchHalfword(byteContents, offset + 2)
            s += 'CSECT=%s ' % sections[fetchHalfword(byteContents, offset + 4)]
            offset += 6
            s += "memory="
            for i in range(length):
                s += "%04X " % fetchHalfword(byteContents, offset)
                offset += 2
            print(s)
        elif type == 0x07:
            print("\t%04X: Code or Constants %02X %02X" % (offset, type, type2))
            s = "\t\t"
            length = type2 - 3
            s += "offset=%04X " % fetchHalfword(byteContents, offset + 2)
            s += 'CSECT=%s ' % sections[fetchHalfword(byteContents, offset + 4)]
            offset += 6
            s += "memory="
            for i in range(length):
                s += "%04X " % fetchHalfword(byteContents, offset)
                offset += 2
            print(s)
        elif type == 0x08:
            print("\t%04X: TBD %02X %02X" % (offset, type, type2))
            s = "\t\t"
            length = type2 - 1
            offset += 2
            s += "TBD="
            for i in range(length):
                s += "%04X " % fetchHalfword(byteContents, offset)
                offset += 2
            print(s)
        elif type == 0x09:
            print("\t%04X: TBD %02X %02X" % (offset, type, type2))
            s = "\t\t"
            length = type2 - 1
            offset += 2
            s += "TBD="
            for i in range(length):
                s += "%04X " % fetchHalfword(byteContents, offset)
                offset += 2
            print(s)
        elif type == 0x40:
            break
        else:
            print("%04X: Unsupported card type %02X in %s" % (offset, type, memberName), file=sys.stderr)
            sys.exit(1)
    
    