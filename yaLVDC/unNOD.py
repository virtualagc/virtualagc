#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public 
            Domain and to be modifiable or usable in any way desired.
Filename:   unNOD.py
Purpose:    This program decodes the LVDC/LVDA DCS data listed on pp. 55-22 
            through 55-39 of the document "AS-506 Mission Supplements to 
            Network Operatives Directive" into the LVDC/LVDA-relevant values 
            described in Table 10-1 (p. I-10-2) of the Saturn IB EDD document.
History:    2023-08-18 RSB  Created.

Ignores comments (any line containing a "#" anywhere) and blank lines.  
All other lines must consist of 4 3-digit octal fields, followed by a 
description.  This data expected to be taken from the NOD document.
It is checked for validity, on the assumption that it corresponds to the DCS
word format described in Table 10-1 of the Saturn IB EDD, shifted leftward
by one bit position (since Table 10-1 describes 35-bit data but NOD lists
36-bit data with the rightmost bit always being 0.

If valid, the output list all of the information that Table 10-1 claims is 
"of interest to the LVDA/LVDC":
    The 2 OM/D bits (always 11 for LVDC)
    The 2 interrupt bits (always 11 for LVDC)
    The 6-bit DCS mode value
    ... plus the textual description
If invalid, some details about the invalidity are printed.
'''

import sys

# Each input line is assumed to have 4 3-digit octal fields, followed by textual
# descriptor.
sequenceBit = 0
for line in sys.stdin:
    if "#" in line:
        continue
    fields = line.strip().split(None, 4)
    if len(fields) == 0:
        continue
    words = []
    corrupted = False
    msg = ""
    if len(fields) != 5:
        corrupted = True
        msg = "Wrong number of fields"
    else:
        description = fields[-1]
        for field in fields[:-1]:
            if len(field) != 3:
                corrupted = True
                msg = "Wrong length field (%s, %d)" % (field, len(field))
                break
            try:
                value = int(field, 8)
            except:
                msg = "Non-octal field (%s)" % field
                corrupted = True
                break
            words.append(value)
    if corrupted:
        print("Corrupted input line: %s: " % msg, fields, words, file=sys.stderr)
        continue
    ibit14 = (words[0] >> 2) & 1
    intA = (words[0] >> 1) & 1
    intB = (words[0] >> 0) & 1
    omdA = (words[1] >> 8) & 1
    omdB = (words[1] >> 6) & 1
    ibit13_12 = (words[1] >> 4) & 3
    ibit11_6 = (words[2] >> 3) & 0o77
    ibit5_4 = (words[2] >> 0) & 3
    ibit3_1 = (words[3] >> 6) & 7
    
    omd = omdA & omdB
    if omd:
        sequenceBit = 0
    else:
        sequenceBit ^= 1
    interrupt = intA & intB
    ibits = (ibit14 << 13) | (ibit13_12 << 11) | (ibit11_6 << 5) | \
            (ibit5_4 << 3) | ibit3_1
    
    # At this point, both omd and interrupt should be 1, and ibit should contain 
    # the 14 bits of the command, with the upper 7 bits being the command in 
    # true form and the lower 7 bits being the command in complemented form.
    upper = ibits >> 7
    lower = ibits & 0o177
    if omd == 1:
        print("OM/D: %d%d   Int: %d%d   Mode: %02o   Description: %s" % \
              (omdA, omdB, intA, intB, upper >> 1, description))
    else:
        print("OM/D: %d%d   Int: %d%d   Data: %02o   Description: %s" % \
              (omdA, omdB, intA, intB, upper >> 1, description))
    if (upper & 1) != sequenceBit:
        print("Sequence bit is wrong", file=sys.stderr)
    if False and omd != 1:
        print("OM/D bits wrong (%o, %o)" % (omdA, omdB), file = sys.stderr)
    if False and interrupt != 1:
        print("Interrupt bits wrong (%o, %o)" % (intA, intB), file = sys.stderr)
    if upper != lower ^ 0o177:
        print("Complementarity wrong (%s, %s" % \
                    ('{0:07b}'.format(upper), '{0:07b}'.format(lower)), \
              file=sys.stderr)
        print("ibit14    %d" % ibit14, file=sys.stderr)
        print("ibit13_12 %s" % '{0:02b}'.format(ibit13_12), file=sys.stderr)
        print("ibit11_6  %s" % '{0:06b}'.format(ibit11_6), file=sys.stderr)
        print("ibit5_4  %s" % '{0:02b}'.format(ibit5_4), file=sys.stderr)
        print("ibit3_1   %s" % '{0:03b}'.format(ibit3_1), file=sys.stderr)
        
    
    