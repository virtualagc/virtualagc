#!/usr/bin/env python
# Mike's test code for MPY/MPH, in Python

import sys

# v1 and v2 are the two factors, in the form they would appear in core-memory:
# i.e., 26-bit values, shifted to the left by 1 to allow leave room for parity
# in the least-significant position.  The return value is the product, in the
# same format.  b is some number of positions to shift the returned value.
# Positive b shifts to the right; negative b shifts to the left.
def lvdcMultiply(v1, v2, b):

    def delta1(a, m):
        b = (a >> 0) & 0o7
        if b in (0,7):
            return 0
        elif b in (1,2):
            return 2*m
        elif b == 3:
            return 4*m
        elif b == 4:
            return -4*m
        elif b in (5,6):
            return -2*m
    
    def delta2(a, m):
        b = (a >> 2) & 0o7
        if b in (0,7):
            return 0
        elif b in (1,2):
            return 8*m
        elif b == 3:
            return 16*m
        elif b == 4:
            return -16*m
        elif b in (5,6):
            return -8*m
    
    acc = (v1 >> 2) & (~1)
    mcd = (v2 >> 1)
    
    if mcd & 0o200000000:
        mcd ^= 0o377777777
        mcd = -(mcd + 1)
    mcd &= ~3

    p = 0
    
    for i in range(6):
        p += delta2(acc, mcd) + delta1(acc, mcd)
        p >>= 4
        acc >>= 4
    
    p = p & 0o377777777
    if b > 0:
        p = p >> b
    elif b < 0:
        p = p << (-b)
    return (0o777777776)

if "--test" in sys.argv[1:]:
    print("Input two 9-digit octals and a binary scale. Prints 9-digit octal product.")
    while True:
        print("> ", end="")
        sys.stdout.flush()
        line = sys.stdin.readline().strip()
        fields = line.split()
        try:
            v1 = int(fields[0], 8)
            v2 = int(fields[1], 8)
            b = int(fields[2])
            print("%09o" % lvdcMultiply(v1, v2, b))
        except:
            pass
        
