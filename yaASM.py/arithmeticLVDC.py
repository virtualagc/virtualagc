#!/usr/bin/env python3
'''
The author if this program (Ronald S. Burkey) declares that it is in the 
Public Domain and may be used or modified for any purpose whatever.

Filename:   arithmeticLVDC.py
Purpose:    The intention here is to duplicate certain aspects of the internal
            arithmetic of the original IBM FSD LVDC assembler, so as to enable
            the modern LVDC assembler to correctly round values derived from
            valuations of expressions.  This relates to the fact that if 
            computations are done in a straightforward way, some small (but
            non-zero) number of them do not round to the correct octal value
            in the least-significant bit.
Contact:    Ron Burkey <info@sandroid.org>, The Virtual AGC Project
History:    2023-06-20 RSB   Began.

There is no available documentation for the original IBM FSD LVDC assembler
presently available, so there's no choice other than to try to reverse engineer
the assembler's internal arithmetic system from available LVDC source code.
At present, unfortunately, we are operating under the assumption that that 
most of that source code is restricted from export from the U.S. under ITAR,
so I'll have to simply present my own observations about it rather than
providing a link allowing you to view that source code yourself (unless you care
to personally apply to me with evidence that you are legally qualified to 
receive ITAR-restricted materials.

Here are some observations:

    1.  The LVDC itself had 26-bit data words (not including the 27th parity
        bit), so numeric quantities were represented as 1 sign bit plus 25
        significant bits, organized as 2's-complement.
    2.  The original IBM FSD LVDC assembler presumably ran on an IBM/360 style
        computer, whose single-precision data words were 32 bits.  According to
        online sources, single-precision floating-point format consisted of:
        *   1 sign bit, 7 exponent bits, 24 fraction bits
        *   The exponent is base 16, offset by 64.  In other words, the 
            exponent ranged from 0 to 127, representing factors of 16**-64
            through 16**+63.
        *   Because the exponent is base 16 (rather than base 2) it was possible
            for any/all of the 3 most-significant bits of the fraction to be 0,
            but not for all 4 of the most-significant bits at once.

I would infer (or at least guess) that the original LVDC assembler did its 
internal computations in IBM/360 floating-point, converting to octal only at 
the end of the process, and that reason for the incorrect rounding of the octal
values is due to the lack of precision of the floating-point format, i.e., 
24 bits vs the LVDC's 25.

With luck, therefore, all I should need to do is to mimic IBM/360 floating-point
arithmetic.  Only +, -, *, and / operations are used in LVDC arithmetical 
expressions, so those are the only operations I need to mimic.  At least at 
first, all of these will be implemented in the most mindless, foolproof method
rather than the most elegant or efficient.  It if actually ends up *working* 
for my purpose, then I can think about optimizing.

For example, I do *not* need to mimic the packing of the IBM fields (sign, 
exponent, fraction) into 32-bit quantities, and I will instead represent IBM 
single-precision numbers as Python dictionaries thusly:
    {
        "negative": boolean,
        "exponent": 7-bit signed integer (-64 to +63),
        "fraction": 24-bit unsigned integer
    }
'''

import sys

test = False
for parm in sys.argv[1:]:
    if parm == "--test":
        test = True

zero = { "negative": False, "exponent": 0, "fraction": 0}
maxFraction1 = 2**24
maxFraction = maxFraction1 - 1
floorFraction = 2**20

# Accepts a Python integer or floating-point value and returns an IBM
# single-precision floating-point value, or else the value None on error.
def toIBM(value):
    if value == "P.CSR":
        value = "4063.492"
    try:
        value = float(value)
    except:
        return None
    if value == 0:
        return zero
    negative = False
    if value < 0:
        negative = True
        value = -value
    exponent = 0
    while value >= 1:
        exponent += 1
        value /= 16.0
    while True:
        bigger = value * 16.0
        if bigger >= 1:
            break
        value = bigger
        exponent -= 1
    if exponent > 63:
        return None
    if exponent < -64:
        return zero
    # At this point, 1/16 <= value < 1.0, and we have to convert it to a
    # properly-rounded 24-bit unsigned integer.
    fraction = int(0.5 + value * 2**24)
    return {"negative": negative, "exponent": exponent, "fraction": fraction}

# Packs one of our IBM dictionaries into an actual IBM 32-bit value, or None on
# error.
def pack(valueIBM):
    if valueIBM == None:
        return None
    value = 0
    if valueIBM["negative"]:
        value = 0x80000000
    value |= (64 + valueIBM["exponent"]) << 24
    value |= valueIBM["fraction"]
    return value

# Accepts an IBM single-precision floating-point value and returns a Python
# float, or None on error.
def fromIBM(valueIBM):
    try:
        value = valueIBM["fraction"] / (2.0 ** 24)
        value *= 16 ** valueIBM["exponent"]
        if valueIBM["negative"]:
            value = -value
        return value
    except:
        return None

# Adds two IBM SD values.
def addIBM(value1, value2):
    negative1 = value1["negative"]
    exponent1 = value1["exponent"]
    fraction1 = value1["fraction"]
    negative2 = value2["negative"]
    exponent2 = value2["exponent"]
    fraction2 = value2["fraction"]
    if exponent1 > exponent2:
        shift = exponent1 - exponent2
        fraction2 = fraction2 >> (4 * shift)
        exponent2 += shift
    elif exponent2 > exponent1:
        shift = exponent2 - exponent1
        fraction1 = fraction1 >> (4 * shift)
        exponent1 += shift
    if negative1:
        fraction1 = -fraction1
    if negative2:
        fraction2 = -fraction2
    exponent = exponent1
    fraction = fraction1 + fraction2
    negative = (fraction < 0)
    if negative:
        fraction = -fraction
    while fraction > maxFraction:
        fraction = fraction >> 4
        exponent += 1
    if fraction == 0:
        return zero
    while fraction < floorFraction:
        fraction = fraction << 4
        exponent -= 1
    if exponent < -64:
        return zero
    if exponent > 63:
        return None
    return { "negative": negative, "exponent": exponent, "fraction": fraction}

# Multiplies two IBM SD values.
def multiplyIBM(value1, value2):
    negative1 = value1["negative"]
    exponent1 = value1["exponent"]
    fraction1 = value1["fraction"]
    negative2 = value2["negative"]
    exponent2 = value2["exponent"]
    fraction2 = value2["fraction"]
    if fraction1 == 0 or fraction2 == 0:
        return zero
    negative = (negative1 != negative2)
    exponent = exponent1 + exponent2
    fraction = fraction1 * fraction2 / maxFraction1
    while fraction > maxFraction:
        fraction /= 16.0
        exponent += 1
    while fraction < floorFraction:
        fraction *= 16.0
        exponent -= 1
    fraction = int(fraction + 0.5)
    if exponent < -64:
        return zero
    if exponent > 63:
        return None
    return { "negative": negative, "exponent": exponent, "fraction": fraction}

def ibmToOctal(value, scale=26):
    if value == None:
        return None
    else:
        v = value["fraction"]
        shift = 4 * value["exponent"] - scale + 2
        if shift > 0:
            v = v << shift
        elif shift < 0:
            v = v >> (-shift)
        if v & 1:
            v += 1
        return "%09o" % v

# For testing purposes:
if test:
    
    print("Numbers can include E-exponents but not B-scales.")
    print("B-scales can optionally appear at the end of a line.")
    print("Accepts line inputs in any of the following formats:")
    print("\tnumber [Bn]")
    print("\tnumber + number [Bn]")
    print("\tnumber * number [Bn]")
    print("The default B-scale, affecting only outputs, is B26.")
    print("Notice the whitespaces delimiting operators and B-scales.")
    print("Also, in place of a number you can use the literal")
    print("string P.CSR, which is hard-coded as 4063.492.")
    print("Any of these line formats prints out the result of")
    print("the desired operation in 3 forms:  my representation")
    print("of an IBM 360 single-precision floating-point number,")
    print("a normal fixed-point representation, and a 9-octal-digit")
    print("LVDC literal. The example, from p. 190 of AS-512, of")
    print("\t31440.2 * P.CSR B27")
    print("results in")
    print("\t{'negative': False, 'exponent': 7, 'fraction': 7984812}")
    print("\t127756992.0")
    print("\t363532540")
    while True:
        print("> ", end="")
        sys.stdout.flush()
        fields = sys.stdin.readline().strip().split()
        scale = 26
        if len(fields) > 1 and fields[-1][0] == "B":
            try:
                scale = int(fields[-1][1:])
                fields.pop()
            except:
                continue
        if len(fields) == 1:
            value = toIBM(fields[0])
            print(value)
            print(fromIBM(value))
            print(ibmToOctal(value, scale))
        elif len(fields) == 3:
            value1 = toIBM(fields[0])
            operator = fields[1]
            value2 = toIBM(fields[2])
            if operator == "+":
                value = addIBM(value1, value2)
            elif operator == "*":
                value = multiplyIBM(value1, value2)
            else:
                continue
            print(value)
            print(fromIBM(value))
            print(ibmToOctal(value, scale))
            