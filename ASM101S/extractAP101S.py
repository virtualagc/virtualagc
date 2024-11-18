#!/usr/bin/env python3
'''
The author (Ron Burkey) of this program declares that it is in the Public Domain
in the U.S., and may be freely used, modified, or distributed for any purpose
whatever.

The purpose of the program is to extract a pure AP-101S assembly-language
source-code file from a report produced by PASS2 of the HAL/S compiler HALSFC.

The usage is:
    extractAP101S.py <pass2.rpt >source.asm
'''

import sys

defaultEQUs ='''
* Default EQUs, not actually present in the PASS2 compiler report.
F0       EQU   0              FP 0 = FLOATING POINT REGISTER            
F1       EQU   1                 1                                      
F2       EQU   2                 2                                      
F3       EQU   3                 3                                      
F4       EQU   4                 4                                      
F5       EQU   5                 5                                      
F6       EQU   6                 6                                      
F7       EQU   7                 7                                      
R0       EQU   0   SET 2      GR 0 = GENERAL REGISTER                   
R1       EQU   1                 1                                      
R2       EQU   2                 2                                      
R3       EQU   3                 3                                      
R4       EQU   4                 4                                      
R5       EQU   5                 5                                      
R6       EQU   6                 6                                      
R7       EQU   7                 7
'''

print("* Extracted from HAL/S compiler's PASS2 report by extractAP101S.py")
print()

inTable = False
inSource = False
for line in sys.stdin:
    line = line.rstrip()
    if len(line) == 0:
        continue
    if not inTable:
        if line.startswith("SYMBOL   TYPE  ID"):
            inTable = True
            continue
    if inTable:
        print("* Default CSECT, not explicitly present in PASS2 compiler report")
        print("%-9sCSECT" % line.split()[0])
        inTable = False
        print(defaultEQUs)
        continue
    if not inSource:
        if line.startswith("  LOC    CODE"):
            inSource = True
            print("* Lines of code directly from PASS2 compiler report")
    else:
        if line.startswith("RLD INFORMATION"):
            break
        if line.strip() == "END":
            print("         END")
            break
        if len(line) < 37 or line[0] not in "0123456789ABCDEF":
            continue
        print(line[36:])