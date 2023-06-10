#!/usr/bin/env python3
# This file is declared by its author, Ronald S. Burkey <info@sandroid.org>,
# to be in the Public Domain and may be used or altered in any way you desire.
#
# Filename:        checkDuplex.py
# Purpose:         In a file of LVDC "octals", can be used to check for 
#                  discrepancies between two memory modules.
# Reference:       http://www.ibibio.org/apollo
# Mods:            2023-06-07 RSB  Wrote.

'''
After I had transcribed all of the octals for the LVDC flight programs AS-512 
and AS-513, and had moved on to transcription of the AS-512 source code, and 
from there to debugging/assembly of theat code, I belatedly made a discovery 
about the transcribed octals for AS-512.

The discovery is that while the transcribed octals for AS-512 cover memory 
modules 0, 1, 2, 4, and 6, there is no actual source code for module 1.
The apparent reason is that modules 0/1 are used in "duplex" mode (i.e., the
odd banks are mirrors of the even banks), while modules 2, 4, and 6 are used
in "simplex" mode (in which the odd banks don't duplicate the even banks, which
in this case means that they aren't used at all).

What this means is that at least as far as modules 0/1 are concerned, an 
additional check of the octal transcription can be made by comparing modules
0 and 1, word for word.

The transcribed-octal file is input on stdin, and a report is produced on 
stdout.

I think this can be easily turned into a reusable parser module for LVDC
octal transcriptions, but I haven't done that.
'''

import sys

#-----------------------------------------------------------------------------
# Read the input file and parse it into a memory array.  Syllable 2 is a data
# word.
memory = [[[[-1 for offset in range(256)] for syllable in range(3)] \
             for sector in range(16)] for module in range(8)]
lines = sys.stdin.readlines()
usedModules = {}
sector = -1
module = -1
lastLoc = -0o010
for line in lines:
    fields = line.strip("\n").split("\t")
    if len(fields) < 3 or line[0] == "#":
        continue
    if fields[0] == "SECTOR":
        module = int(fields[1], 8)
        sector = int(fields[2], 8)
        if module not in usedModules:
            usedModules[module] = []
        if sector not in usedModules[module]:
            usedModules[module].append(sector)
        lastLoc = -0o010
        continue
    loc = int(fields[0], 8)
    if len(fields) != 17:
        print("Corrupted line at %o-%02o-%03o:" % (module, sector, loc), \
              line.strip(), file=sys.stderr)
        sys.exit(1)
    if loc != lastLoc + 0o010:
        print("Bad address at %o-%02o-%03o:" % (module, sector, loc), \
              line.strip(), file=sys.stderr)
        sys.exit(1)
    lastLoc = loc
    for i in range(8):
        data = fields[1 + 2 * i]
        type = fields[2 + 2 * i]
        if len(data) != 11:
            print("Corrupted data at %o-%02o-%03o:" \
                  % (module, sector, loc+i), file=sys.stderr)
            sys.exit(1)
        if type not in ["D", " ", ""]:
            print("Corrupted type at %o-%02o-%03o:" \
                  % (module, sector, loc+i), file=sys.stderr)
            sys.exit(1)
        if type in [" ", ""]:
            if data == "           ":
                continue
            else:
                print("Corrupted data at %o-%02o-%03o:" \
                      % (module, sector, loc+i), file=sys.stderr)
                sys.exit(1)
        if type != "D":
            print("Unknown type field at %o-%02o-%03o:" \
                  % (module, sector, loc+i), file=sys.stderr)
            sys.exit(1)
        if data[0] == " " and data[10] and len(data.strip()) == 9:
            try:
                v = int(data.strip(), 8)
            except:
                print("Corrupted data at %o-%02o-%03o:" \
                      % (module, sector, loc+i), file=sys.stderr)
                sys.exit(1)
            memory[module][sector][2][loc+i] = v
            continue
        dfields = [data[:5].strip(), data[6:].strip()]
        if data[5] != " ":
            print("Corrupted data at %o-%02o-%03o:" \
                  % (module, sector, loc+i), file=sys.stderr)
            sys.exit(1)
        for j in range(2):
            if len(dfields[j]) == 0:
                continue
            if len(dfields[j]) != 5:
                print("Corrupted data at %o-%02o-%o-%03o:" \
                      % (module, sector, j, loc+i), file=sys.stderr)
                sys.exit(1)
            try:
                v = int(dfields[j], 8)
            except:
                print("Corrupted data at %o-%02o-%o-%03o:" \
                      % (module, sector, j, loc+i), file=sys.stderr)
                sys.exit(1)
            memory[module][sector][1-j][loc+i] = v

# Here's a test.  It just prints out the now-buffered data, in the same format
# used by the input file.
if False:
    print("Modules used:", usedModules, file=sys.stderr)
    for module in usedModules:
        for sector in usedModules[module]:
            print("SECTOR\t%o\t%02o" % (module, sector))
            for loc in range(0, 0o400, 0o10):
                line = "%03o" % loc
                for i in range(8):
                    v = memory[module][sector][2][loc+i]
                    if v != -1:
                        line = line + "\t %09o \tD" % v
                        continue
                    v1 = memory[module][sector][0][loc+i]
                    v2 = memory[module][sector][1][loc+i]
                    if v1 == -1 and v2 == -1:
                        line = line + "\t           \t "
                        continue
                    if v1 == -1:
                        line = line + "\t      "
                    else:
                        line = line + "\t%05o " % v1
                    if v2 == -1:
                        line = line + "     \tD"
                    else:
                        line = line + "%05o\tD" % v2
                print(line)
            print()

#-----------------------------------------------------------------------------
# The memory array is now loaded up.  Produce a report of simplex vs duplex.

for module in [0, 2, 4, 6]:
    if module not in usedModules:
        print("Module %o not used." % module)
        continue
    if (module+1) not in usedModules:
        print("Module %o is simplex." % module)
        continue
    print("Module %o/%o is duplex." % (module, module+1))
    usedSectorsEven = usedModules[module]
    usedSectorsOdd = usedModules[module+1]
    for sector in range(0o20):
        if sector not in usedSectorsEven and sector not in usedSectorsOdd:
            pass
        elif sector in usedSectorsEven and sector not in usedSectorsOdd:
            print("Sector %02o in module %o but not in module %o" \
                  % (sector, module, module+1))
        elif sector not in usedSectorsEven and sector in usedSectorsOdd:
            print("Sector %02o not in module %o but in module %o" \
                  % (sector, module, module+1))
        else:
            for loc in range(0o400):
                for s in range(3):
                    vEven = memory[module][sector][s][loc]
                    vOdd = memory[module+1][sector][s][loc]
                    if vEven != vOdd:
                        if s < 2:
                            print("Mismatch %05o vs %05o at %o-%02o-%o-%03o vs %o-%02o-%o-%03o" \
                                  % (vEven, vOdd, module, sector, s, loc, 
                                     module+1, sector, s, loc))
                        else:
                            print("Mismatch %09o vs %09o at %o-%02o-%03o vs %o-%02o-%03o" \
                                  % (vEven, vOdd, module, sector, loc, 
                                     module+1, sector, loc))

                        