#!/usr/bin/env python
'''
The idea here to to try to parse BFS-type object code from members of 
a PDS output by HAL/S compiler PASS2.

Usage:
    coPILOT.py memberNames

Here are some acronyms I use, sometimes because PASS2 seems to use them, 
sometimes because I googled them, that may or may not be correct:

ESD - External Symbol Dictionary

CSECT - Control Section

SD - Segment Definition: metadata about a CSECT

ESDID - A numerical index of a CSECT within an ESD

RLD - Relocation and Linkage Directory (maybe Relocation Data)

LEC - Link Edit Control
'''

import sys
from asciiToEbcdic import *

# Names of CSECTs
sections = [None]

# Get an EBCDIC string from a `bytearray` and convert to ASCII.
def fetchString(bytes, offset, length):
    string = ""
    for i in range(offset, offset+length):
        string += ebcdicToAscii[bytes[i]]
    return string

def fetchHalfword(bytes, offset):
    return 256 * bytes[offset] + bytes[offset + 1]

def dumpRange(bytes, offset, length, reclen=32):
    for i in range(0, length, 2):
        if 0 == i % reclen:
            print("\n\t\t", end="")
        print("%04X " % fetchHalfword(bytes, offset + i), end="")
    print()
    return offset+length

def dumpRangeRaw(bytes, offset, length):
    for i in range(0, length, 2):
       print("%04X " % fetchHalfword(bytes, offset + i), end="")

def printableCSECT(bytes, offset):
    index = fetchHalfword(byteContents, offset)
    return '%d %-8s ' % (index, sections[index])

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
            print("\t%04X: Start" % offset)
            if type2 != 0x02:
                print("Corrupted card", file=sys.stderr)
                sys.exit(1)
            print("\t\torigin=%04X" % fetchHalfword(byteContents, offset + 2))
            offset += 4
        elif type == 0x02:
            print("\t%04X: CSD (CSECT Definition)" % offset)
            endOffset = offset + 2 * (7 + type2 - 7)
            s = "\t\t"
            name = fetchString(byteContents, offset + 2, 8).rstrip()
            index = len(sections)
            sections.append(name)
            s += 'esdid=%d %-8s ' % (index, name)
            s += 'length=%04X ' % fetchHalfword(byteContents, offset + 10)
            s += 'stacksize=%04X ' % fetchHalfword(byteContents, offset + 12)
            if offset + 14 < endOffset:
                s += "flags=%04X " % fetchHalfword(byteContents, offset + 14)
            if offset + 16 < endOffset:
                s += "HAL=%s" % fetchString(byteContents, offset + 16, endOffset - (offset + 16)).rstrip()
            print(s)
            offset = endOffset
        elif type == 0x03:
            print("\t%04X: ENT (Entry)" % offset)
            offset += 16
        elif type == 0x04:
            print("\t%04X: EXR (External Reference Definition)" % offset)
            endOffset = offset + 2 * (7 + type2 - 7)
            s = "\t\t"
            name = fetchString(byteContents, offset + 2, 8).rstrip()
            index = len(sections)
            sections.append(name)
            s += 'esdid=%d %-8s ' % (index, name)
            s += 'version=%04X ' % fetchHalfword(byteContents, offset + 10)
            s += 'tbd=%04X ' % fetchHalfword(byteContents, offset + 12)
            if offset + 14 < endOffset:
                s += "HAL=%s" % fetchString(byteContents, offset + 14, endOffset - (offset + 14)).rstrip()
            print(s)
            offset = endOffset
        elif type == 0x05:
            print("\t%04X: LEC (Link Edit Control)" % offset)
            offset += 2 * (1 + type2)
        elif type == 0x06:
            print("\t%04X: PTX (Protected text)" % (offset))
            s = "\t\t"
            s += "offset=%04X " % fetchHalfword(byteContents, offset + 2)
            s += 'csect=%s ' % printableCSECT(byteContents, offset + 4)
            offset += 6
            print(s, end="")
            offset = dumpRange(byteContents, offset, 2 * (type2 - 3))
        elif type == 0x07:
            print("\t%04X: UTX (Unprotected text)" % (offset))
            s = "\t\t"
            s += "offset=%04X " % fetchHalfword(byteContents, offset + 2)
            s += 'csect=%s ' % printableCSECT(byteContents, offset + 4)
            offset += 6
            print(s, end="")
            offset = dumpRange(byteContents, offset, 2 * (type2 - 3))
        elif type == 0x08:
            '''
            The notes in PASS2's output report provide the following information
            about the various fields in these RLD records:
            
            POS.ID is the ESDID of the SD for the control section that contains 
            the address constant.
            
            REL.ID is the ESDID of the ESD entry for the symbol being referred
            to.
            
            Flags (8 bits) has one of the following forms:
               V0101100 - CODE WITH ZCON SECTOR
               V0101000 - CODE WITH ZCON SECTOR AND ADDRESS
               V0001100 - DATA WITH ZCON SECTOR
               V0001000 - DATA WITH ZCON SECTOR AND ADDRESS
               V0XX0000 - 2 BYTE STANDARD ADDRESS TYPE
               V0XX0100 - 4 BYTE STANDARD ADDRESS TYPE
            Here:
                V is 1, then the address field needs to be negated.
                XX is 01 for ZCON CSECTs, 10 for LIBRARY CSECTs.
            '''
            print("\t%04X: RLD (Relocation data)" % offset)
            endOffset = offset + 2 * type2
            for i in range(offset + 2, endOffset, 8):
                print("\t\trel.id=%s pos.id=%s flags=%04X address=%04X" % \
                      (printableCSECT(byteContents, i),
                      printableCSECT(byteContents, i+2),
                      fetchHalfword(byteContents, i+4),
                      fetchHalfword(byteContents, i+6)))
            offset = endOffset
        elif type == 0x09:
            '''
            The END card is always exactly 20 halfwords, but the final 3 
            halfwords are not written to, and continue to contain whatever
            happened to be in memory from any other cards of sufficient length.  
            The layout is:
            
            HW 1: Count of the preceding cards. Okay!
            
            HW 2-6: 10-character HAL version name ("HAL/S BFS-ver").  FAILS, all 0!
            
            HW 7: HAL version ID. Becomes 1B58 (7000 decimal); is that okay?
            
            HW 8-10: Bytes are (year-1900), month (1-12), day (1-31), hour,
                    minutes, seconds.  Okay!
            
            HW 11-15: 10-character XPL version name (RSB-XCOM-I).  FAILS!
            
            HW 16: XPL compiler version.  Becomes 90; is that okay?
            '''
            print("\t%04X: END" % (offset))
            print("\t\tcards=%d" % fetchHalfword(byteContents, offset + 2))
            print('\t\thal compiler="%s"' % fetchString(byteContents, offset+4, 10))
            print("\t\thal version=***FIXME*** ", end="")
            dumpRangeRaw(byteContents, offset+14, 2)
            print()
            print("\t\ttimestamp=%04d-%02d-%02d %02d:%02d:%02d" % \
                  (byteContents[offset+16] + 1900,
                   byteContents[offset+17], byteContents[offset+18],
                   byteContents[offset+19], byteContents[offset+20],
                   byteContents[offset+21]))
            print('\t\txpl compiler="%s"' % fetchString(byteContents, offset+22, 10))
            print("\t\txpl version=%d.%02d" % (byteContents[offset+32], byteContents[offset+33]))
            #print("\t\txpl version=***FIXME*** ", end="")
            #dumpRangeRaw(byteContents, offset+32, 2)
            #print()
            offset = 2 * type2
            break
        elif type == 0x40:
            break
        else:
            print("%04X: Unsupported card type %02X in %s" % (offset, type, memberName), file=sys.stderr)
            sys.exit(1)
    
    