#!/usr/bin/env python
'''
The author (Ron Burkey) declares that this program is in the Public Domain
in the U.S., and may be copied, modified, or distributed for any purpose
whatever free of charge.

The purpose of this program is to decode so-called "LIT files" produced/modified
by various passes of the HALSFC HAL/S compiler into human-readable form.

Usage:
    unLitFile.py LITFILE.bin MEMORY.gz
    
Two files are necessary for the decoding process: the litfile itself and an
image of the memory space of the program that produced the litfile.  The latter
is needed because the litfile only provides pointers into memory for the 
textual data of string literals.  Numeric literals are provided directly in
the litfile.  When compiling a HAL/S file, after each compiler pass, and 
specifically those passes capable of modifying the litfile, HALSFC
produces the files you need for LITFILE.bin and MEMORY.gz:

    After PASS1: litfile0.bin COMMON0.out.bin.gz
    After OPT:   litfile2.bin COMMON2.out.bin.gz
    After PASS2: litfile4.bin COMMON4.out.bin.gz

The litfile data is packed into records of 1560 bytes each.  Each of those 
records is formatted identically, as 3 pages of 130 4-byte records each.
Each 1560-byte record contains data for 130 literals.  

The 4-byte records on the first 520-byte page are "types" of the literals: 
big-endian integers with the values 
    0 (for character-string literals)
    1 (for numeric literals)
    2 (for BIT(1) through BIT(32) literals).  
(I believe there may be other types as well, such as 5, but I've never seen 
them and don't know what they represent.)

As for the other 2 520-byte pages, the data format in their 4-byte fields 
depends on the type of literal:
    Type 0: The 2nd page contains "string descriptors".  I.e., the first byte
            is the string length minus 1, while the other three bytes are 
            a 24-bit pointer into the memory image.  If all 4 bytes are 0, it
            represents an empty string.  The 3rd page is simply zeroes.
    Type 1: Numbers are represented as double-precision IBM hexadecimal 
            floating point.  The more-significant word (i.e., the 
            single-precision value) is on the 2nd page, while the 
            less-significant word is on the 3rd page.
    Type 2: BIT data is represented as big-endian unsigned integers on the 2nd
            page.  The 3rd page is zeroes.
'''

import sys
import gzip
from asciiToEbcdic import *
from ibmHex import *

# Read the litfile.
f = open(sys.argv[1], "rb")
litfile = f.read()
f.close()

# Read the memory image.
f = gzip.open(sys.argv[2], "rb")
memory = f.read()
f.close()

#print(len(litfile))
#print(len(memory))

def formWord(page, offset):
    return (page[offset] << 24) + (page[offset+1] << 16) + \
        (page[offset+2] << 8) + page[offset+3]

# Loop on 130-literal (1560-byte)  records of the litfile.
literalNumber = -1
recordOffset = 0
while recordOffset < len(litfile):
    # Yes, the following isn't very efficient.  Who cares?  Shut up!
    page1 = litfile[recordOffset : recordOffset+520]
    page2 = litfile[recordOffset+520 : recordOffset + 1040]
    page3 = litfile[recordOffset+1040 : recordOffset + 1560]
    # Loop on the literals in the record.
    for offset in range(0, 520, 4):
        literalNumber += 1
        type = page1[offset+3]
        if type == 0:
            length = page2[offset]
            pointer = (page2[offset+1] << 16) + (page2[offset+2] << 8) + page2[offset+3]
            value = ""
            if length > 0 or pointer > 0:
                length += 1
                for i in range(pointer, pointer+length):
                    value += ebcdicToAscii[memory[i]]
            if value != "":
                print("Literal %d: STRING '%s'" % (literalNumber, value))
        elif type == 1:
            value = fromFloatIBM(formWord(page2, offset), formWord(page3, offset))
            print("Literal %d: FIXED  %lf" % (literalNumber, value))
        elif type == 2:
            value = formWord(page2, offset)
            print("Literal %d: BIT    %d" % (literalNumber, value))
    recordOffset += 1560
