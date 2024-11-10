#!/usr/bin/env python3
# The author (Ron Burkey) declares that this program is in the Public Domain,
# and may be used or modified in any desired manner.
#
# The program is used for creating double-precision IBM hexadecimal floating-
# point from native floating-point numbers, or vice versa.

import sys
from decimal import *

getcontext().prec = 20

# Python's native round() function uses a silly method (in the sense that it is
# unlike the expectation of every programmer who ever lived) called 'banker's
# rounding', wherein half-integers sometimes round up and sometimes
# round down.  Good for bankers, I suppose, because rounding errors tend to
# sum to zero, but no help whatever for us.  Instead, hround() rounds
# half-integers upward.  Returns None on error.
def hround(x):
    try:
        i = int(x.to_integral_value(rounding=ROUND_HALF_UP))
    except:
        # x wasn't a number.
        return None
    return i

'''
The following stuff is for converting back and forth from Python
numerical values to System/360 double-precision (64-bit) floating 
point.

The IBM documentation I've seen for the floating-point format
is pure garbage.  Fortunately, wikipedia ("IBM hexadecimal 
floating-point") explains it very simply.  Here's what it looks 
like in terms of 8 groups of 8 bits each:
    SEEEEEEE FFFFFFFF FFFFFFFF ... FFFFFFFF
where S is the sign, E is the exponent, and F is the fraction.
Single precision (32-bit) is the same, but with only 3 F-groups. 
The exponent is a power of 16, biased by 64, and thus represents
16**-64 through 16**63. The fraction is an unsigned number, of
which the leftmost bit represents 1/2, the next bit represents
1/4, and so on. 

As a special case, 0 is encoded as all zeroes.

E.g., the 64-bit hexadecimal pair 0x42640000 0x00000000 parses as:
    S = 0 (i.e., positive)
    Exponent = 16**(0x42-0x40) = 16**2 = 2**8.
    Fraction = 0.0110 0100 ...
or in total, 1100100 (binary), or 100 decimal.
'''
twoTo56 = Decimal(2 ** 56)
twoTo52 = Decimal(2 ** 52)
sixteen = Decimal(16)

# Convert a Python integer or float to IBM double-precision float.  
# Returns as a pair (msw,lsw), each of which are 32-bit integers,
# or (0xff000000,0x00000000) on error.  Note that `x` and `scale` can
# be either numbers or string representations of numbers.  But the 
# string representation is better, because if the value has already been
# converted to a Python `float`, it may no longer be able to correctly match 
# all significant digits.
def toFloatIBM(x, scale=1):
    d = Decimal(x) * Decimal(scale)
    if d == 0:
        return 0x00000000, 0x00000000
    # Make x positive but preserve the sign as a bit flag.
    if d < 0:
        s = 1
        d = -d
    else:
        s = 0
    # Shift left by 24 bits.
    d *= twoTo56
    # Find the exponent (biased by 64) as a power of 16:
    e = 64
    while d < twoTo52:
        e -= 1
        d *= sixteen
    while d >= twoTo56:
        e += 1
        d /= sixteen
    if e < 0:
        e = 0
    if e > 127:
        return 0xff000000, 0x00000000
    # x should now be in the right range, so lets just turn it into an integer.
    f = hround(d)
    # Convert to a more-significant and less-significant 32-word:
    msw = (s << 31) | (e << 24) | (f >> 32)
    lsw = f & 0xffffffff
    return msw, lsw


# Inverse of toFloatIBM(): Converts more-significant and less-significant 
# 32-bit words of an IBM DP float to a Python float.
def fromFloatIBM(msw, lsw):
    s = (msw >> 31) & 1
    e = ((msw >> 24) & 0x7f) - 64
    f = ((msw & 0x00ffffff) << 32) | (lsw & 0xffffffff)
    x = f * (16 ** e) / (2 ** 56)
    if s != 0:
        x = -x
    return x


#----------------------------------------------------------------------------
# The stuff below is executed only if this file is run as a program, and is
# not executed if the file is imported as a module.  I wish I had known about
# this mechanism years ago ....

if __name__ == "__main__":
    for parm in sys.argv[1:]:
        if "--help" == parm:
            print()
            print("Utility for converting human floating-point numbers to IBM")
            print("hexadecimal floating-point format and vice-versa. Usage:")
            print()
            print("\tibmHex.py arg1 arg2 arg3 ...")
            print()
            print("The arguments can take any of the forms listed below.")
            print();
            print("--help")
            print("\tPrints this message.")
            print("--test")
            print("\tPrints several examples of conversions")
            print("number")
            print("\tConverts a single floating-point from human-readable form")
            print("\tto IBM hexadecimal floating-point.")
            print("hex1,hex2")
            print("\tConverts an IBM hexadecimal floating-point number, expressed")
            print("\tas a pair of 32-bit hexadecimal numbers, to human-readable")
            print("\tfloating-point number.")
            print("--test")
            print("\tPrints seveveral examples of conversions")
            print("")
        elif "--test" == parm:
            # Test of the IBM float conversions.  Note that aside from showing that
            # toFloatIBM() and fromFloatIBM() are inverses, it also reproduces the 
            # known value 100 -> 0x42640000,0x00000000.
            for s in range(-1, 2, 2):
                for e in range(-10, 11):
                    x = s * 10 ** e
                    msw, lsw = toFloatIBM(x)
                    y = fromFloatIBM(msw, lsw)
                    print("%15s" % str(x), "-> %08X,%08X ->" % (msw, lsw), y)
        elif "," in parm:
            fields = parm.split(",")
            if len(fields) != 2:
                print("Too many commas in %s." % parm)
                continue
            try:
                hex1 = int(fields[0], 16)
            except:
                print("Not hexadecimal: %s" % fields[0])
            try:
                hex2 = int(fields[1], 16)
            except:
                print("Not hexadecimal: %s" % fields[1])
            f = fromFloatIBM(hex1, hex2)
            print("->", f, "->", "%08X,%08X" % toFloatIBM(f))
        else:
            try:
                f = parm
            except:
                print("Not a floating-point numbmer: %s" % parm)
            hex1, hex2 = toFloatIBM(f)
            if hex1 == 0xFF000000:
                print("Cannot be converted to IBM hexadecimal floating-point")
            else:
                print("->", "%08X,%08X" % (hex1, hex2), "->", fromFloatIBM(hex1, hex2))
    
