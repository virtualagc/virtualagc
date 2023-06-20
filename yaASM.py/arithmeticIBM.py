#!/usr/bin/env python3
'''
The author if this program (Ronald S. Burkey) declares that it is in the 
Public Domain and may be used or modified for any purpose whatever.

Filename:   arithmeticIBM.py
Purpose:    The intention here is to imitate several floating-point 
            (IBM 360 and IBM 7090/7094 single-precision)
            arithmetic types, to see if they can be used to solve 
            certain anomalies in arithmetic peformed by the original LVDC
            assembler by IBM FSD.
Contact:    Ron Burkey <info@sandroid.org>, The Virtual AGC Project
History:    2023-06-20 RSB   Began.

See the comments in arithmetic360.py for more explanation.  This program differs
only in that it models the internal floating-point format of the IBM 7090/7094
rather than the IBM 360.  The differences are:

                              360                7090
                            -------            -------
    Single-precision word   32 bits            36 bits
    Sign                     1 bit              1 bit
    Exponent                 7 bits             8 bits
    Exponent base             16                  2
    Mantissa                24 bits            27 bits
'''

import sys

test = False
check = False
systemType = 7090 # The other choice is 360
for parm in sys.argv[1:]:
    if parm == "--test":
        test = True
    elif parm == "--check":
        check = True
    elif parm.startswith("--system="):
        systemType = int(parm[9:])

if systemType == 7090:
    exponentBaseBits = 1
    biasExponent = 128
    numMantissaBits = 27
elif systemType == 360:
    exponentBaseBits = 4
    biasExponent = 64
    numMantissaBits = 24
else:
    print("Unknown system type")
    sys.exit(1)
print("System type IBM %d.  Exponent base bits %d, bias %d.  Mantissa bits %d." % \
      (systemType, exponentBaseBits, biasExponent, numMantissaBits))
exponentBase = 2**exponentBaseBits
maxExponent = biasExponent - 1
minExponent = -biasExponent
maxFraction1 = 2**numMantissaBits
maxFraction = maxFraction1 - 1
floorFraction = 2**(numMantissaBits-exponentBaseBits)
zero = { "negative": False, "exponent": 0, "fraction": 0}

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
        value /= exponentBase
    while True:
        bigger = value * exponentBase
        if bigger >= 1:
            break
        value = bigger
        exponent -= 1
    if exponent > maxExponent:
        return None
    if exponent < minExponent:
        return zero
    fraction = int(0.5 + value * maxFraction1)
    return {"negative": negative, "exponent": exponent, "fraction": fraction}

# Accepts an IBM single-precision floating-point value and returns a Python
# float, or None on error.
def fromIBM(valueIBM):
    try:
        value = valueIBM["fraction"] / maxFraction1
        value *= exponentBase ** valueIBM["exponent"]
        if valueIBM["negative"]:
            value = -value
        return value
    except:
        return None

# Adds two IBM SD values.
def addIBM(value1, value2, subtract=False):
    negative1 = value1["negative"]
    exponent1 = value1["exponent"]
    fraction1 = value1["fraction"]
    negative2 = value2["negative"]
    exponent2 = value2["exponent"]
    fraction2 = value2["fraction"]
    if exponent1 > exponent2:
        shift = exponent1 - exponent2
        fraction2 = fraction2 >> (exponentBaseBits * shift)
        exponent2 += shift
    elif exponent2 > exponent1:
        shift = exponent2 - exponent1
        fraction1 = fraction1 >> (exponentBaseBits * shift)
        exponent1 += shift
    if negative1:
        fraction1 = -fraction1
    if negative2 != subtract:
        fraction2 = -fraction2
    exponent = exponent1
    fraction = fraction1 + fraction2
    negative = (fraction < 0)
    if negative:
        fraction = -fraction
    while fraction > maxFraction:
        fraction = fraction >> exponentBaseBits
        exponent += 1
    if fraction == 0:
        return zero
    while fraction < floorFraction:
        fraction = fraction << exponentBaseBits
        exponent -= 1
    if exponent < minExponent:
        return zero
    if exponent > maxExponent:
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
        fraction /= exponentBase
        exponent += 1
    while fraction < floorFraction:
        fraction *= exponentBase
        exponent -= 1
    fraction = int(fraction + 0.5)
    if exponent < minExponent:
        return zero
    if exponent > maxExponent:
        return None
    return { "negative": negative, "exponent": exponent, "fraction": fraction}

def ibmToOctal(value, scale=26):
    if value == None:
        return None
    else:
        v = value["fraction"]
        shift = exponentBaseBits * value["exponent"] - scale + (25 - numMantissaBits) + 1
        if shift > 0:
            v = v << shift
        elif shift < 0:
            v = v >> (-shift)
        if v & 1:
            v += 1
        if value["negative"]:
            v = v ^ 0o777777776
        return "%09o" % v

# *** Note: --check is only partially implemented and not fully working. ***
# For checking values from assembly listings.  It reads an assembly listing
# and attempts to reproduce the assembler's computations, to the extent that
# its feeble parsing can manage.
if check:
    lines = sys.stdin.readlines()
    for line in lines:
        if len(line) < 70:
            continue
        if line[0] != " ":
            continue
        if line[38] != " " or line[48] != " ":
            continue
        constantString = line[39:48]
        isOctal = True
        for c in constantString:
            if c not in ["0", "1", "2", "3", "4", "5", "6","7"]:
                isOctal = False
                break
        if not isOctal:
            continue
        fields = line[58:].strip().split()
        if len(fields) < 2:
            continue
        operator = fields[0]
        if operator == "OCT":
            continue
        operand = fields[1]
        scale = 26
        fields = operand.split("B")
        if len(fields) > 1:
            scale = int(fields[1])
        value = fields[0]
        try:
            f = float(value)
            octal = ibmToOctal(toIBM(value))
            if octal == constantString:
                print("Match:   ", octal, line)
            else:
                print("Mismatch:", octal, line)
        except:
            pass

# For testing purposes:
if test:
    
    print("Numbers can include E-exponents but not B-scales.")
    print("B-scales can optionally appear at the end of a line.")
    print("Accepts line inputs in any of the following formats:")
    print("\tnumber [Bn]")
    print("\tnumber + number [Bn]")
    print("\tnumber - number [Bn]")
    print("\tnumber * number [Bn]")
    print("The default B-scale, affecting only outputs, is B26.")
    print("Notice the whitespaces delimiting operators and B-scales.")
    print("Also, in place of a number you can use the literal")
    print("string P.CSR, which is hard-coded as 4063.492.")
    print("Any of these line formats prints out the result of")
    print("the desired operation in 3 forms:  my representation")
    print("of an IBM single-precision floating-point number,")
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
            elif operator == "-":
                value = addIBM(value1, value2, True)
            elif operator == "*":
                value = multiplyIBM(value1, value2)
            else:
                continue
            print(value)
            print(fromIBM(value))
            print(ibmToOctal(value, scale))
            