#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       pieceworkAGC.py
Purpose:        Combine bits and pieces of AGC .bin files, to produce a
                single AGC .bin file in --hardware format.
History:        2022-10-10 RSB  Created.
                2022-10-26 RSB  Began adapting for --block1 and --blk2.
                2022-10-27 RSB  Fully corrected now to proper mapping of banks
                                and modules.
                2022-11-17 RSB  Added --bin option.
"""

import sys

additions = []
block1 = False
blk2 = False
binary = False
for param in sys.argv[1:]:
    if param == "--help":
        print('''
        Usage:
            pieceworkAGC.py [OPTIONS] >OUTPUT.bin
            
        A core dump (by default in disassemblerAGC.py --hardware --parity
        format) is produced on stdout. Without OPTIONS, with all locations
        will be marked as unused.  The following option can be used as 
        many times as desired:
        
            --add=F,P,H,M[,B1[,B2[,B3[...]]]]
            
        This option says to add data to the rope image from a file:
        
            F           Filename of an input .bin file.  These files 
                        contain an entire rope if they're non-hardware
                        .bin files.  If they're hardware .bin files,
                        they may contain either an entire rope or else
                        a single module.
            P           0 if F has no parity bits, 1 if it does.
            H           1 if F is a hardware dump, 0 if a non-hardware
                        .bin file.
            M           Always should be 0 if F is a non-hardware .bin
                        file.  If F is a hardware .bin file, then M=0
                        if F contains an entire rope, or some other number
                        if F contains a single rope-memory module.  For
                        example, for module B29, then use M=29.  
            B1,B2,...   A list of the banks (octals) which are to be
                        extracted from F and added to the output.  If the
                        list is empty, then all banks are extracted.
                        
        The following mutually-exclusive options affect the size and 
        ordering of banks in the input and output files as well:
        
            --agc       (the default)
            --block1
            --blk2
        
        The option following option changes the output format to match 
        that of disassemblerAGC.py --bin --parity:
        
            --bin
        ''')
        sys.exit(0)
    elif param[:6] == "--add=":
        additions.append(param[6:])
    elif param == "--block1":
        block1 = True
        blk2 = False
    elif param == "--blk2":
        blk2 = True
        block1 = False
    elif param == "--agc":
        block1 = False
        blk2 = False
    elif param == "--bin":
        binary = True
    else:
        print("Unrecognized switch: ", param, file=sys.stderr)
        sys.exit(1)

if block1:
    from auxiliaryBlockI import *
elif blk2:
    from auxiliaryBLK2 import *
else:
    from auxiliary import *
        
# Create core with all "unused".
core = []
for bank in range(numCoreBanks):
    core.append([0]*0o2000)

for addition in additions:
    fields = addition.split(",")
    F = fields[0]
    P = (fields[1] != "0")
    H = (fields[2] != "0")
    M = int(fields[3])
    B = fields[4:]
    print("Processing:", F, P, H, M, B, file=sys.stderr)
    if H:
        bankList = bankListHardware
        if M != 0:
            if block1:
                module = -1
                if M in [21, 22, 23, 24]:
                    module = M - 19
                elif M in [28, 29]:
                    module = M - 28
            else:
                module = M - 1
            bankList = bankList[banksPerModule * module : banksPerModule * (module + 1)]
    else:
        bankList = bankListBin
    if len(B) == 0:
        B = bankListHardware
    else:
        for i in range(len(B)):
            B[i] = int(B[i], 8)
    f = open(F, "r")
    data = f.buffer.read()
    f.close()
    for destBank in B:
        if destBank not in bankList:
            continue
        tBank = bankList.index(destBank)
        offset = tBank * 0o4000
        if offset + 0o4000 > len(data):
            continue
        for address in range(0o2000):
            value = (data[2 * address + offset] << 8) \
                    | data[2 * address + offset + 1]
            if P and value == 0: # Unused?
                continue
            if not H: # Convert value to --hardware format.
                value = (value & 0o100000) | ((value >> 1) & 0o37777) \
                        | ((value & 1) << 14)
            if not P: # If input file had no parity, add it.
                parity = value & 0o137777
                parity ^= parity >> 8
                parity ^= parity >> 4
                parity ^= parity >> 2
                parity ^= parity >> 1
                parity ^= 1
                parity &= 1
                value = (value & 0o137777) | (parity << 14)
            core[destBank][address] = value
        
# Output the result.
data = []
if binary:
    bankListOutput = bankListBin
else:
    bankListOutput = bankListHardware
for bank in bankListOutput:
    for offset in range(0o2000):
        value = core[bank][offset]
        if binary: # Convert word from --hardware to --bin.
            value = (value & 0o100000) | ((value << 1) & 0o77776) \
                        | ((value & 0o40000) >> 14)
        data.append((value >> 8) & 0xFF)
        data.append(value & 0xFF)
sys.stdout.buffer.write(bytes(data))

