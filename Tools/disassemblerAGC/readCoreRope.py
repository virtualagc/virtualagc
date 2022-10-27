#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       readCoreRope.py
Purpose:        Reads the core rope input file (binsource or bin)
History:        2022-09-25 RSB  Created.
                2022-10-10 RSB  Added --parity.
"""

import sys

'''
Read the input file (.bin or .binsource) into the core[] list.
The cli structure contains the cli.binFile and cli.hardwareFile
command-line parameters.  The file parameter is an open file,
such as sys.stdin.

For --bin or --hardware input files, we are also given a list 
(bankList) of the order in which the memory banks appear in the 
input file.

For the cli input parameter, it is a structure with only 3 fields 
used:
    cli.hardwareFile        A boolean
    cli.binFile             A boolean
    cli.parity              A boolean
'''
def readCoreRope(file, core, cli, numCoreBanks, sizeCoreBank, bankList):
    if cli.hardwareFile or cli.binFile: # .bin file.
        data = file.buffer.read()
        bankIndex = 0
        bank = bankList[bankIndex]
        offset = 0
        for i in range(0, len(data), 2):
            value = (data[i] << 8) | data[i + 1]
            if cli.parity:
                parity = value
                parity ^= parity >> 8
                parity ^= parity >> 4
                parity ^= parity >> 2
                parity ^= parity >> 1
                parity &= 1
            else:
                parity = 1
            if cli.binFile:
                value = value >> 1
            else: # cli.hardwareFile
                value = ((value & 0o100000) >> 1) | (value & 0o37777)
            if cli.parity and value == 0 and parity == 0:
                pass # Unused location, don't change it.
            else:
                value &= 0o77777
                core[bank][offset] = value
                if cli.parity and parity == 0:
                    print("Parity error:  %02o,%04o %05o %o" %\
                        (bank, offset + 0o2000, value, parity), \
                        file = sys.stderr)
            offset += 1
            if offset >= sizeCoreBank:
                offset = 0
                bankIndex += 1
                if bankIndex >= len(bankList):
                    break
                bank = bankList[bankIndex]
    else:
        # For binsource files, we simply use the markings BANK=N
        # within the file to tell us what to read, so we needn't
        # worry about any other factors like "--bin" or "--block1"
        # etc.
        bank = 2
        offset = 0
        for line in file:
            fields = line.split(";")    # Eliminate comments.
            line = " ".join(fields[0].strip().split())   # Simplify pesky whitespace.
            if line == "":       # Eliminate empty lines.
                continue
            line = line.upper()
            if line[:5] == "BANK=":
                bankField = line[5:].split(',')[0]
                bank = int(bankField, 8)
                offset = 0
                if bank < 0 or bank >= numCoreBanks:
                    print("Illegal bank:  %02o" % bank)
                    sys.exit(1)
                continue
            if line[:7] == "PARITY=" or line[:9] == "NUMBANKS=" \
                    or line[:11] == "CHECKWORDS=":
                continue
            line = line.replace(",", "")
            # If we've gotten to here, we should now have just pure octals,
            # either 5 digits per field (if no parity) or 6 digits (if parity),
            # or "@" for unused positions.
            fields = line.split()
            if len(fields) != 8:
                print("Malformed line:", line)
                sys.exit(1)
            for field in fields:
                if field != "@":
                    o = field
                    if len(field) == 6:
                        o = field[:5]
                    if len(o) != 5:
                        print("Malformed octal:", field)
                        sys.exit(1)
                    if offset >= 1024:
                        print("Bank", bank, "overflow")
                        sys.exit(1)
                    core[bank][offset] = int(o, 8)
                offset += 1


