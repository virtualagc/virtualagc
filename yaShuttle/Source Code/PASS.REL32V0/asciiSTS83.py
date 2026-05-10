#!/usr/bin/env python
# Convert a file created by extractSTS83.sh/extractSTS83.py into a 26 row by
# 51 column UTF-8 array.

import sys
import os

image = []
for i in range(26):
    image.append([' ']*52)
for line in sys.stdin:
    if line.startswith("#"):
        continue
    fields = line.rstrip().split("\t")
    if len(fields) != 3:
        continue
    c = fields[0]
    y = int(fields[1]) - 1
    x = int(fields[2]) - 1
    try:
        image[y][x] = c
    except:
        print(f"Out of range, row={y+1}, col={x+1}", file=sys.stderr)
        os._exit(1)
for row in image:
    print("".join(row))
