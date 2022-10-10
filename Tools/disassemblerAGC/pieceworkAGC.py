#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       pieceworkAGC.py
Purpose:        Combine bits and pieces of AGC .bin files, to produce a
                single AGC .bin file in --hardware format.
History:        2022-10-10 RSB  Created.
"""

import sys

# Create core with all "unused".
core = []
for bank in range(0o44):
    core.append([0]*0o2000)

additions = []
for param in sys.argv[1:]:
    if param == "--help":
        print('''
        Usage:
            pieceworkAGC.py [OPTIONS] >OUTPUT.bin
            
        Without OPTIONS, a core dump (in disassemblerAGC.py --hardware
        --parity format) is produced on stdout, with all locations marked
        as unused.  There's only one OPTION, which can be used as many
        times as desired:
        
            --add=F,P,H,S,B1[,B2[,B3[...]]]
            
        This option says to add data to the rope image from a file:
        
            F           The filename.
            P           0 if the file has no parity bits, 1 if it does.
            H           0 if it's a --bin file, 1 for a --hardware file.
            S           The lowest bank number (octal) in file F,
                        which is expected to contain contiguous banks
                        in the order appropriate to whether it's a
                        --bin or a --hardware file.  Thus the lowest
                        bank number in F is not necessarily at the 
                        smallest offset in F.
            B1,B2,...   A list of the banks (octal) which are to be
                        extracted from F and added to the output core.
        ''')
        sys.exit(0)
    elif param[:6] == "--add=":
        additions.append(param[6:])
    else:
        print("Unrecognized switch: ", param, file=sys.stderr)
        sys.exit(1)
        
for addition in additions:
    fields = addition.split(",")
    F = fields[0]
    P = (fields[1] != "0")
    H = (fields[2] != "0")
    S = int(fields[3], 8)
    B = fields[4:]
    print(F, P, H, S, B, file=sys.stderr)
    for i in range(len(B)):
        B[i] = int(B[i], 8)
    f = open(F, "r")
    data = f.buffer.read()
    f.close()
    for destBank in B:
        if destBank < S:
            print("Desired bank %02o is before start of %s" % \
                    (destBank, F), file=sys.stderr)
            continue
        # Translate the bank numbers for --bin vs --hardware,
        # since bank 0, 1, 2, and 3 are in a different order.
        tBank = destBank
        if not H and destBank < 4:
            if destBank < 2:
                tBank += 2
            else:
                tBank -= 2
        tBank -= S
        offset = tBank * 0o4000
        if offset + 0o4000 > len(data):
            print("Desired bank %02o is past end of %s" % \
                    (destBank, F), file=sys.stderr)
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
for bank in range(0o44):
    for offset in range(0o2000):
        data.append((core[bank][offset] >> 8) & 0xFF)
        data.append(core[bank][offset] & 0xFF)
sys.stdout.buffer.write(bytes(data))

