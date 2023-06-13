#!/usr/bin/env python3
# The author, Ronald S. Burkey <info@sandroid.org>, declares this file to be in
# the Public Domain, and may be used for any desired purpose whatever, without
# restrictions.
#
# Filename:      leftSequence.py
# Purpose:       A lookup utility for finding page numbers in an LVDC program
#                listing, given a left-hand sequence number from a line of code
#                on that page.
# Reference:     http://www.ibibio.org/apollo
# Mods:          2023-06-13 RSB    Wrote

'''
The usage is
    leftSequence.py SEQUENCE [SEQUENCE2 [SEQUENCE3 ... ] ] <leftSequence.tsv
The program looks up each SEQUENCEx number given on the command line, and
prints page numbers for each.  The SEQUENCEx parameters are decimal integers.

The input file (leftSequence.tsv in the example above) is simply an ASCII file
in which line 1 gives the top line's sequence number from page 1 of the assembly
listing, line 2 gives the top-line sequence number from page 2, and so on.
Leading zeroes of sequence numbers can be omitted and are ignored if provided.
Optionally, the sequence number can be followed by a tab, and then by another
field giving a 2-character suffix for the sequence number.  (Left-hand sequence
numbers in AS-512 and AS-513 are six digits followed by a two-character suffix.)
Suffixes remain in effect until the next suffix is encountered.  They are, 
however, irrelevant for lookup, since the sequence numbers alone are adequate.

Note that while I've tailored this description for LVDC, it could be used for
any assembly listing with strictly increasing sequence numbers, whether on the
left-hand side or the right-hand side.  For example, AS-206RAM has no left-hand
sequence numbers, but the right-hand sequence numbers are strictly increasing
and are just as applicable, and have no suffixes.  Similarly, AGC assembly 
listings have left-hand sequence numbers but no suffixes.
'''

import sys

lines = sys.stdin.readlines()
suffix = ""
suffixes = set()
suffixes.add("")
for i in range(len(lines)):
    fields = lines[i].strip().split("\t")
    if len(fields) == 0 or fields[0].strip() == "":
        lines[i] = [None, suffix]
        continue
    sequence = int(fields[0].strip())
    if len(fields) > 1:
        suffix = fields[1].strip()
        if suffix not in suffixes:
            suffixes.add(suffix)
    lines[i] = [sequence, suffix]

if False:
    for i in range(len(lines)):
        fields = lines[i]
        if fields[0] == None:
            continue
        print("%03d: %06d%s" % (i, fields[0], fields[1]))
else:
    for argv in sys.argv[1:]:
        while len(argv) > 1 and argv[:1] == "0":
            argv = argv[1:]
        number = ""
        while argv[:1].isdigit():
            number = number + argv[:1]
            argv = argv[1:]
        number = int(number)
        msg = ""
        if argv not in suffixes:
            msg = " (illegal suffix \"%s\" given)" % argv
        page = 0
        for i in range(len(lines)):
            fields = lines[i]
            if fields[0] == None:
                page += 1
                continue
            if number < fields[0]:
                print("Sequence number %06d%s is on page %04d%s." % (number, fields[1], page, msg))
                break
            page += 1
        if i == range(len(lines)):
            print("Sequence number %06d%s is on page %04d%s." % (number, fields[1], page, msg))
            