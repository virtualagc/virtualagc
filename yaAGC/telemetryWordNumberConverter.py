#!/usr/bin/env python3
# This is a little throw-away program that can be used with a 
# ddd-ID-AGCSOFTWARE.tsv (or similar) file to replace the entry-offset numbers
# in column 1 (like 0, 1, 2, ...) with word numbers that correspond to GSOP
# or HTML documentation (like 1a, 1b, 2, ...).  Note that files which have been
# converted in this way aren't useful for anything other than human inspection,
# and shouldn't be used to overwrite the original files!  I/O is on stdin and
# stdout.

import sys

for line in sys.stdin:
    fields = line.rstrip("\r\n").split("\t")
    if len(fields) != 6:
        continue
    offset = int(fields[0])
    dp = (fields[3] in ["FMT_DP", "FMT_2OCT", "FMT_2DEC"])
    if dp:
        suffix = ""
    elif (offset & 1) == 1:
        suffix = "b"
    else:
        suffix = "a"
    offset = (offset // 2) + 1
    fields[0] = ("%03d" % offset) + suffix
    print("\t".join(fields))