#!/usr/bin/env python
'''
License:        The author (Donald Schmidt) declares that this program
                is in the Public Domain (U.S. law) and may be used or
                modified for any purpose whatever without licensing.
Filename:       ibmFloat.py (Translated from ibmFloat.c)
Purpose:        IBM hex floating-point arithmetic and conversions.
                Based on the floating point logic in the 
                Hyperion/Hercules IBM 390 & z/Series emulator.
Mod history:    2026-05-06 RSB  Initial conversion by CodeConvert, and changes
                                at will by me  In particular, this file is
                                intended to be a Python "module" for importation
                                but I've added a section for stand-alone 
                                execution too, adapted from my ibmHex.py,
                                for testing purposes.
                2026-05-10 RSB  Fleshed out the stand-alone executable.
                2026-05-12 RSB  Corrected behavior of `ibm_dp_addsub` when doing
                                unnormalized arithmetic on unnormalized 0.
                                Changed syntax of addition from NUMBER+NUMBER
                                to NUMBERaNUMBER.  Introduced --test-fixer.
                2026-05-15 RSB  Reverted change to `ibm_dp_addsub` that rounded
                                results of unnormalized addition/subtraction.
                2026-05-16 RSB  Added various conveniences such as 
                                `IBM_DP_FIXER`, `hfpJoin`, and so on.
'''

'''
This is intended to be an exact port of Don Schmidt's ibmFloat.c to Python.
I (RSB) began by letting CodeConvert (https://app.codeconvert.ai/code-converter)
product a trial version of it, and then proceeded to adapt that trial code as I 
thought necessary.  CodeConvert produced the following notes during its initial
conversion:

1. **Types and Overflow**: Python's `int` has arbitrary precision, so 
   `& U32_MASK` (0xFFFFFFFF) and `& U64_MASK` (0xFFFFFFFFFFFFFFFF) were used 
   to simulate the wrapping behavior of C's `uint32_t` and `uint64_t`.
2. **llround**: In `ibm_dp_from_double`, `llround(d)` was translated to 
   `int(d + 0.5)` because `d` is guaranteed to be positive at that point in 
   the logic. This correctly implements rounding to the nearest integer.
3. **Pointers**: C functions returning values via pointers (`*msw`, `*lsw`) 
   were converted to return a tuple `(msw, lsw)` in Python.
4. **Static Variables and Macros**: 
    - `IBM_DP_1E23` and `TENSTBL` were converted to module-level constants.
    - Macros like `IBM_DP_PACK`, `IBM_DP_EXP`, and `IBM_DP_RENORMALIZE_56` were
      converted to Python functions.
    - `IBM_DP_RENORMALIZE_56` is implemented to return the updated `(mantissa, 
      exponent)` pair.
5. **String Parsing**: In `ibm_dp_from_string`, pointer arithmetic `*s++` was 
   replaced by indexing into the string `s[p]`.
6. **Error Handling**: `assert` statements were omitted or replaced by logical 
   equivalents (e.g., `ZeroDivisionError` in `ibm_dp_div`). The C 
   `__attribute__ ((no_instrument_function))` is a compiler directive and has 
   no effect on logic, so it was omitted.
7. **IBM Float Zero**: `IBM_DP_IS_TRUE_ZERO` was implemented to check if the 
   mantissa is zero, which matches the behavior seen in `ibm_dp_to_hal_string` 
   and Hyperion's logic where numbers with zero mantissas are treated as zero 
   regardless of the exponent.
8. **Add/Subtract Logic**: The `goto` labels in `ibm_dp_addsub` were replaced 
   with structured `if/else` and early `return` blocks to maintain the exact 
   logic flow without using `goto`.
9. **Guard Digits**: The alignment and guard digit logic (60-bit mantissa 
   simulation) was preserved using bitwise shifts. `IBM_DP_OVERFLOW_60` 
   correctly identifies carry-out from the 60th bit.
10. **snprintf**: Python's f-strings were used to replicate `snprintf` 
   formatting (e.g., `f"{abs_E10:02d}"` for `%02d`).
'''

import math
import struct

# Returns IEEE 754 hex representation as a string.
def ieee754(f):
     return struct.pack('>d', f).hex().upper()

# Constants and Masks (derived from the original logic)
IBM_DP_MANT_BITS = 56
IBM_DP_EXP_BIAS = 64
IBM_DP_EXP_MAX = 0x7F
IBM_DP_MANT_HEXDIGITS = 14
IBM_DP_MANT_MASK = 0x00FFFFFFFFFFFFFF
IBM_DP_SIGN_BIT = 0x8000000000000000
IBM_SP_SIGN_BIT = 0x80000000
IBM_DP_ROUNDER = 0x407FFFFFFFFFFFFF # 0.5-
IBM_DP_FIXED_LIMIT = 0x487FFFFFFFFFFFFF # 2**31-1
IBM_DP_FIXER = 0x4E00000000000000 # 0E+56, unnormalized
IBM_DP_OVERFLOW_PACKED = 0x7FFFFFFFFFFFFFFF
IBM_DP_OVERFLOW_MSW = 0x7FFFFFFF
IBM_SP_MANT_MASK = 0x00FFFFFF

TWO_TO_56 = 1 << 56
TWO_TO_52 = 1 << 52

# Arithmetic constants for addsub logic
IBM_DP_OVERFLOW_60 = 0x1000000000000000  # Bit 60
IBM_DP_TOP_HEX_60 = 0x0F00000000000000   # Bits 56-59

# Simulation masks
U32_MASK = 0xFFFFFFFF
U64_MASK = 0xFFFFFFFFFFFFFFFF

def hfpSplit(hfpDP):
    return (hfpDP >> 32) & 0xFFFFFFFF, hfpDP & 0xFFFFFFFF

def hfpJoin(msw, lsw):
    return (msw << 32) | lsw

# Internal helper "Macros"
def IBM_DP_SIGN(v):
    return (v >> 63) & 1

def IBM_DP_EXP(v):
    return (v >> 56) & IBM_DP_EXP_MAX

def IBM_DP_MANT(v):
    return v & IBM_DP_MANT_MASK

def IBM_DP_PACK(s, e, m):
    return (((s & 1) << 63) | ((e & IBM_DP_EXP_MAX) << 56) | (m & IBM_DP_MANT_MASK)) & U64_MASK

def IBM_DP_IS_TRUE_ZERO(v):
    # In IBM floating point logic used here, zero mantissa is treated as zero.
    return (v & IBM_DP_MANT_MASK) == 0

def IBM_DP_RENORMALIZE_56(mant, exp):
    while mant != 0 and (mant < TWO_TO_52):
        mant <<= 4
        exp -= 1
    return mant & U64_MASK, exp

# Convert a C double to IBM double-precision float, returning the (msw, lsw)
# pair. On overflow returns (IBM_DP_OVERFLOW_MSW, 0).
def ibm_dp_from_double(d):
    if d == 0:
        return 0x00000000, 0x00000000
    
    # Make x positive but preserve the sign as a bit flag.
    if d < 0:
        s = 1
        d = -d
    else:
        s = 0
        
    # Shift left by 56 bits.
    #print("A", ieee754(d))
    d *= TWO_TO_56
    #print("B", ieee754(d))
    
    # Find the exponent (biased by IBM_DP_EXP_BIAS) as a power of 16:
    e = IBM_DP_EXP_BIAS
    while d < TWO_TO_52:
        e -= 1
        d *= 16
        #print("C", ieee754(d))
    while d >= TWO_TO_56:
        e += 1
        d /= 16
        #print("D", ieee754(d))
        
    if e < 0:
        e = 0
    if e > IBM_DP_EXP_MAX:
        return IBM_DP_OVERFLOW_MSW, 0x00000000
        
    f = int(d + 0.5) # llround equivalent for positive d
    msw = ((s << 31) | (e << 24) | ((f >> 32) & 0xffffffff)) & U32_MASK
    lsw = f & 0xffffffff
    return msw, lsw

# Convert IBM double-precision float (msw, lsw) to Python float (C double).
def ibm_dp_to_double(msw, lsw):
    s = (msw >> 31) & 1
    e = ((msw >> 24) & IBM_DP_EXP_MAX) - IBM_DP_EXP_BIAS
    f = ((msw & 0x00ffffff) << 32) | (lsw & U32_MASK)
    x = f * math.pow(16, e) / TWO_TO_56
    if s != 0:
        x = -x
    return x

# Convert a small unsigned integer to IBM DP packed format.
def ibm_dp_from_uint(v):
    if v == 0:
        return 0
    exp = IBM_DP_EXP_BIAS + IBM_DP_MANT_HEXDIGITS
    while v >= (1 << IBM_DP_MANT_BITS):
        v >>= 4
        exp += 1
    v, exp = IBM_DP_RENORMALIZE_56(v, exp)
    if exp < 0:
        return 0
    if exp > IBM_DP_EXP_MAX:
        return IBM_DP_OVERFLOW_PACKED
    return IBM_DP_PACK(0, exp, v)

# Static constant for string conversion
IBM_DP_1E23 = 0x54152D02C7E14AF7

# Convert a HAL/S decimal-literal string to IBM DP hex.
def ibm_dp_from_string(s):
    # sign handling
    p = 0
    sign = 0
    if p < len(s):
        if s[p] == '+':
            p += 1
        elif s[p] == '-':
            sign = 1
            p += 1

    F0 = 0
    TEN = ibm_dp_from_uint(10)
    frac_digits = 0
    seen_dot = 0
    ignore = 0
    
    while p < len(s):
        c = s[p]
        if '0' <= c <= '9':
            if not ignore:
                F0 = ibm_dp_mul(F0, TEN)
                if c != '0':
                    F0 = ibm_dp_addsub(F0, ibm_dp_from_uint(ord(c) - ord('0')), 0, 1)
                if seen_dot:
                    frac_digits += 1
                # XXXTOD precision guard
                if seen_dot and ((F0 >> 32) & U32_MASK) >= 0x4E19999A:
                    ignore = 1
            p += 1
        elif c == '.' and not seen_dot:
            seen_dot = 1
            p += 1
        else:
            break

    dec_exp = 0
    if p < len(s) and (s[p] == 'E' or s[p] == 'e'):
        p += 1
        es = 1
        if p < len(s):
            if s[p] == '+':
                p += 1
            elif s[p] == '-':
                es = -1
                p += 1
        v = 0
        while p < len(s) and '0' <= s[p] <= '9':
            v = v * 10 + (ord(s[p]) - ord('0'))
            p += 1
        dec_exp = es * v
    
    dec_exp -= frac_digits

    if IBM_DP_MANT(F0) == 0:
        return 0, 0
    
    if sign:
        F0 |= IBM_DP_SIGN_BIT

    if dec_exp != 0:
        absexp = abs(dec_exp)
        # TIMES10A: chunk by 23
        while absexp >= 23:
            F0 = ibm_dp_mul(F0, IBM_DP_1E23) if dec_exp > 0 else ibm_dp_div(F0, IBM_DP_1E23)
            absexp -= 23
        # TIMES10B / TIMES10C
        if absexp > 0:
            F4 = ibm_dp_from_uint(1)
            F2 = TEN
            while absexp > 0:
                if absexp & 1:
                    F4 = ibm_dp_mul(F4, F2)
                absexp >>= 1
                if absexp:
                    F2 = ibm_dp_mul(F2, F2)
            F0 = ibm_dp_mul(F0, F4) if dec_exp > 0 else ibm_dp_div(F0, F4)

    if F0 == IBM_DP_OVERFLOW_PACKED:
        return IBM_DP_OVERFLOW_MSW, 0
    
    if IBM_DP_MANT(F0) == 0:
        return 0, 0
    
    msw = (F0 >> 32) & U32_MASK
    lsw = F0 & U32_MASK
    return msw, lsw

# IBM hex dp add/subtract
def ibm_dp_addsub(a_packed, b_packed, subtract_b, normalize):
    a_sign = IBM_DP_SIGN(a_packed)
    a_exp = IBM_DP_EXP(a_packed)
    a_mant = IBM_DP_MANT(a_packed)
    b_sign = IBM_DP_SIGN(b_packed)
    b_exp = IBM_DP_EXP(b_packed)
    b_mant = IBM_DP_MANT(b_packed)
    
    if subtract_b:
        b_sign ^= 1

    if normalize:
        a_iszero = IBM_DP_IS_TRUE_ZERO(a_packed)
        b_iszero = IBM_DP_IS_TRUE_ZERO(b_packed)
    else:
        a_iszero = (a_packed & 0x7FFFFFFFFFFFFFFF) == 0
        b_iszero = (b_packed & 0x7FFFFFFFFFFFFFFF) == 0

    if not b_iszero and not a_iszero:
        # Both not zero - align with guard digit, then signed add.
        if a_exp == b_exp:
            a_mant <<= 4
            b_mant <<= 4
        elif a_exp < b_exp:
            shift = b_exp - a_exp - 1
            a_exp = b_exp
            if shift > 0:
                a_mant >>= (shift * 4)
                if shift >= IBM_DP_MANT_HEXDIGITS or a_mant == 0:
                    a_sign = b_sign
                    a_mant = b_mant
                    if a_mant == 0 or not normalize:
                        return IBM_DP_PACK(a_sign, a_exp, a_mant)
                    a_mant, a_exp = IBM_DP_RENORMALIZE_56(a_mant, a_exp)
                    if a_exp < 0: a_exp = 0
                    if a_exp > IBM_DP_EXP_MAX: a_exp = IBM_DP_EXP_MAX
                    return IBM_DP_PACK(a_sign, a_exp, a_mant)
            b_mant <<= 4
        else:
            shift = a_exp - b_exp - 1
            if shift > 0:
                b_mant >>= (shift * 4)
                if shift >= IBM_DP_MANT_HEXDIGITS or b_mant == 0:
                    if a_mant == 0 or not normalize:
                        return IBM_DP_PACK(a_sign, a_exp, a_mant)
                    a_mant, a_exp = IBM_DP_RENORMALIZE_56(a_mant, a_exp)
                    if a_exp < 0: a_exp = 0
                    if a_exp > IBM_DP_EXP_MAX: a_exp = IBM_DP_EXP_MAX
                    return IBM_DP_PACK(a_sign, a_exp, a_mant)
            a_mant <<= 4

        # Compute with guard digit (60-bit mantissas).
        if a_sign == b_sign:
            r_sign = a_sign
            r_mant = a_mant + b_mant
        elif a_mant == b_mant:
            return IBM_DP_PACK(0, 0, 0)
        elif a_mant > b_mant:
            r_sign = a_sign
            r_mant = a_mant - b_mant
        else:
            r_sign = b_sign
            r_mant = b_mant - a_mant

        # Post-add
        if r_mant & IBM_DP_OVERFLOW_60:
            r_mant >>= 8
            a_exp += 1
        elif not normalize:
            r_mant >>= 4
        elif r_mant & IBM_DP_TOP_HEX_60:
            r_mant >>= 4
        else:
            a_exp -= 1
            if r_mant != 0:
                r_mant, a_exp = IBM_DP_RENORMALIZE_56(r_mant, a_exp)
            else:
                r_sign = 0
                a_exp = 0
        a_sign = r_sign
        a_mant = r_mant
    elif b_iszero and a_iszero:
        a_sign = 0; a_exp = 0; a_mant = 0
    elif a_iszero:
        a_sign = b_sign
        a_exp = b_exp
        a_mant = b_mant
        if normalize:
            a_mant, a_exp = IBM_DP_RENORMALIZE_56(a_mant, a_exp)
    else:
        # a is not zero, b is zero
        if normalize:
            a_mant, a_exp = IBM_DP_RENORMALIZE_56(a_mant, a_exp)

    if a_exp < 0: a_exp = 0
    if a_exp > IBM_DP_EXP_MAX: a_exp = IBM_DP_EXP_MAX
    return IBM_DP_PACK(a_sign, a_exp, a_mant)

def ibm_dp_add(a, b):
    return ibm_dp_addsub(a, b, 0, 1)

def ibm_dp_sub(a, b):
    return ibm_dp_addsub(a, b, 1, 1)

# IBM hex DP multiply
def ibm_dp_mul(a, b):
    a_mant = IBM_DP_MANT(a)
    b_mant = IBM_DP_MANT(b)
    if a_mant == 0 or b_mant == 0:
        return 0

    a_exp = IBM_DP_EXP(a)
    b_exp = IBM_DP_EXP(b)
    r_sign = IBM_DP_SIGN(a) ^ IBM_DP_SIGN(b)

    a_mant, a_exp = IBM_DP_RENORMALIZE_56(a_mant, a_exp)
    b_mant, b_exp = IBM_DP_RENORMALIZE_56(b_mant, b_exp)

    a_lo = a_mant & 0xFFFFFFFF
    a_hi = a_mant >> 32
    b_lo = b_mant & 0xFFFFFFFF
    b_hi = b_mant >> 32
    
    wk = (a_lo * b_lo) >> 32
    wk += a_lo * b_hi
    wk += a_hi * b_lo
    v = wk & 0xFFFFFFFF
    hi = (wk >> 32) + (a_hi * b_hi)

    if hi & 0x0000F00000000000:
        r_mant = (hi << 8) | (v >> 24)
        r_exp = a_exp + b_exp - IBM_DP_EXP_BIAS
    else:
        r_mant = (hi << 12) | (v >> 20)
        r_exp = a_exp + b_exp - (IBM_DP_EXP_BIAS + 1)

    if r_exp < 0:
        return 0
    if r_exp > IBM_DP_EXP_MAX:
        return IBM_DP_OVERFLOW_PACKED
    return IBM_DP_PACK(r_sign, r_exp, r_mant)

# IBM hex DP divide
def ibm_dp_div(a, b):
    a_mant = IBM_DP_MANT(a)
    b_mant = IBM_DP_MANT(b)
    if b_mant == 0:
        raise ZeroDivisionError("ibm_dp_div: divisor mantissa is zero")
    if a_mant == 0:
        return 0

    a_exp = IBM_DP_EXP(a)
    b_exp = IBM_DP_EXP(b)
    r_sign = IBM_DP_SIGN(a) ^ IBM_DP_SIGN(b)

    a_mant, a_exp = IBM_DP_RENORMALIZE_56(a_mant, a_exp)
    b_mant, b_exp = IBM_DP_RENORMALIZE_56(b_mant, b_exp)

    if a_mant < b_mant:
        r_exp = a_exp - b_exp + IBM_DP_EXP_BIAS
    else:
        r_exp = a_exp - b_exp + (IBM_DP_EXP_BIAS + 1)
        b_mant <<= 4

    # Long division: produce 14 hex digits
    wk2 = a_mant // b_mant
    wk = (a_mant % b_mant) << 4
    for _ in range(IBM_DP_MANT_HEXDIGITS - 1):
        wk2 = (wk2 << 4) | (wk // b_mant)
        wk = (wk % b_mant) << 4
    r_mant = (wk2 << 4) | (wk // b_mant)

    if r_exp < 0:
        return 0
    if r_exp > IBM_DP_EXP_MAX:
        return IBM_DP_OVERFLOW_PACKED
    return IBM_DP_PACK(r_sign, r_exp, r_mant)

# TENSTBL used by ibm_dp_to_string
TENSTBL = [
    0x4110000000000000, # 10^0
    0x41A0000000000000, # 10^1
    0x4264000000000000, # 10^2
    0x433E800000000000, # 10^3
    0x4427100000000000, # 10^4
    0x45186A0000000000, # 10^5
    0x45F4240000000000, # 10^6
    0x4698968000000000, # 10^7
    0x475F5E1000000000, # 10^8
    0x483B9ACA00000000, # 10^9
    0x492540BE40000000, # 10^10
    0x5156BC75E2D63100, # 10^20
    0x59C9F2C9CD04674F, # 10^30
    0x621D6329F1C35CA5, # 10^40
    0x6A446C3B15F99267, # 10^50
    0x729F4F2726179A22, # 10^60
    0x7B172EBAD6DDC73D, # 10^70
]

# direct IBM hex DP -> decimal string
def ibm_dp_to_string(msw, lsw, sig_digits, pad_to_digits):
    if ((msw & 0x7FFFFFFF) | lsw) == 0:
        return "0.0"

    sign = (msw >> 31) & 1
    value = (((msw & 0x7FFFFFFF) << 32) | (lsw & U32_MASK)) & U64_MASK

    E10 = 0
    for _ in range(8):
        char_field = (value >> 56) & IBM_DP_EXP_MAX
        diff = char_field - 78
        if diff == 0:
            break
        
        abs_diff = abs(diff)
        log10_diff = ((abs_diff * 19728) + 8192) >> 14
        if log10_diff > 78: log10_diff = 78
        if log10_diff <= 0: break

        ones = log10_diff % 10
        tens = log10_diff // 10

        if ones > 0:
            f = TENSTBL[ones]
            value = ibm_dp_div(value, f) if diff > 0 else ibm_dp_mul(value, f)
        if tens > 0:
            f = TENSTBL[9 + tens]
            value = ibm_dp_div(value, f) if diff > 0 else ibm_dp_mul(value, f)

        if diff > 0:
            E10 += log10_diff
        else:
            E10 -= log10_diff

    mantissa = value & IBM_DP_MANT_MASK
    m = f"{mantissa:017d}"
    
    start = 0
    while start < 16 and m[start] == '0':
        start += 1
    
    E10_display = E10 + (16 - start)
    avail = 17 - start
    take = min(sig_digits, avail)
    display = m[start : start + take]
    if len(display) < pad_to_digits:
        display += '0' * (pad_to_digits - len(display))
    
    abs_E10 = abs(E10_display)
    sign_str = "-" if sign else ""
    exp_sign = "+" if E10_display >= 0 else "-"
    
    return f"{sign_str}{display[0]}.{display[1:]}E{exp_sign}{abs_E10:02d}"

# ibm_dp_to_hal_string - HAL/S MONITOR(12)-style formatting.
def ibm_dp_to_hal_string(msw, lsw, precision):
    if (msw & 0x00FFFFFF) == 0 and lsw == 0:
        if precision:
            return " 0.0                  "
        else:
            return " 0.0         "
    
    sig = 7 if precision == 0 else 16
    body = ibm_dp_to_string(msw, lsw, sig, sig)
    if body.startswith('-'):
        return body
    else:
        return " " + body

#----------------------------------------------------------------------------
# The stuff below is executed only if this file is run as a program, and is
# not executed if the file is imported as a module.

if __name__ == "__main__":
    import sys
    import os
    
    # Perform unnormalized addition of an HFP value with 4E000000,00000000.
    # The algorithm slavishly follows that on pp. 18-8 and -9 of the ESA/390 
    # Principles of Operation for normalized addition, and then extending to
    # the discusson on p. 18-10 for unnormalized.  The attempt is intended to 
    # be verifiable and idiot-proof, *not* to be efficient.  We depart only
    # at the very end, when I believe the published description to be in error.
    def addUnnormalizedToFixer(operand):
        signMask = 0x8000000000000000
        expMask =  0x7F00000000000000
        expInc =   0x0100000000000000
        mantMask = 0x00FFFFFFFFFFFFFF
        fixer =    0x4E00000000000000
        sign = operand & signMask
        exp = operand & expMask
        mant = operand & mantMask
        if exp > fixer:
            return operand
        # Shift the operand rightward as necessary.
        guard = 0
        while exp < fixer:
            guard = mant & 0xF
            mant = mant >> 4
            exp += expInc
        # This is the part I think is missing from the published description
        # and from `ibm_dp_addsub`: Round according to the guard digit, rather 
        # than truncate.
        if guard >= 8:
            mant += 1
        return sign | exp | mant
    
    def printHuman(msw, lsw, parm):
        print(f"{'%08X'%msw},{'%08X'%lsw}   <->   DP='{ibm_dp_to_hal_string(msw,lsw,1)}'   SP='{ibm_dp_to_hal_string(msw,lsw,0)}'   ({parm})")
    
    def dpFromString(s):
        if s == "FIXER":
            return 0x4E000000, 0x00000000
        elif "," in s:
            fields = s.split(",")
            if len(fields) != 2 or len(fields[0]) != 8 or len(fields[1]) != 8:
                printf(f"Illegal IBM Hex   ({s})")
                os._exit(1)
            try:
                return int(fields[0], 16), int(fields[1], 16)
            except:
                printf(f"Illegal IBM Hex   ({s})")
                os._exit(1)
        return ibm_dp_from_string(s)
    
    # Apply the operation FLOATpFIXER to a native Python floating-point number.
    def fix(d):
        msw, lsw = ibm_dp_from_double(d)
        result = ibm_dp_addsub((msw << 32) | lsw, 0x4E00000000000000, 0, 0)
        mant = IBM_DP_MANT_MASK & result
        sign = IBM_DP_SIGN_BIT & result
        if sign:
            return -mant
        return mant
    
    for parm in sys.argv[1:]:
        parm = parm.replace(" ", "")
        if "--help" == parm:
            print()
            print("Utility for exercising the ibmFloat Python module.")
            print()
            print("Usage:")
            print()
            print("\tibmFloat.py arg1 arg2 arg3 ...")
            print()
            print("In what follows, NUMBER can be any of the following:")
            print()
            print("\tAn integer such as 1, -23, 1061, etc.")
            print()
            print("\tA floating-point number such as .6, 1., -1.2345,") 
            print("\t4.67E-52, etc.")
            print()
            print("\tA comma-delimited pair of 8-digit hexadecimals,")
            print("\trepresenting a already-encoded double-precision IBM ")
            print("\thexadecimal floating-point number.")
            print()
            print("\tThe literal FIXER, shorthand for 4E000000,00000000.")
            print();
            print("The arguments can take any of the forms listed below:")
            print()
            print("NUMBER")
            print("NUMBERaNUMBER")
            print("NUMBERsNUMBER")
            print("NUMBER*NUMBER")
            print("NUMBER/NUMBER")
            print("\tAny integer or floating-point number or simple expression")
            print("\tis converted to an IBM DP floating-point number.  Note")
            print("\tthat NUMBERaNUMBER and NUMBERsNUMBER are used in place of")
            print("\tNUMBER+NUMBER and NUMBER-NUMBER to simplify parsing the")
            print("\targuments, and because + and - are not allowed as leading")
            print("\tcharacters in HAL/S literals but are allowed here.")
            print("NUMBERpNUMBER")
            print("NUMBERmNUMBER")
            print("\tSame as NUMBERaNUMBER and NUMBERsNUMBER, except that the")
            print("\tresult is not normalized.")
            print("hcNUMBER")
            print("chNUMBER")
            print("\tConvert HAL/S floating-point to native C/Python floating")
            print("\tpoint or vice versa, respectively.")
            print("iNUMBER")
            print("\tPrints the IEEE 754 hexadecimal representation of a ")
            print("\tnumber.  This is not directly relevant to ibmFloat")
            print("\tfunctionality but can be used for diagnosis of cross-test")
            print("\tdiscrepancies.")
            print("--help")
            print("\tPrints this message and exits.")
            print("--test-fixer")
            print("\tPerforms tests of the NpFIXER operation.")
            print("--make-test")
            print("\tOutputs a large test dataset that can be used with ")
            print("\tibmFloat.py and ibmFloat.c+ibmFloatRig.c in parallel")
            print("\tto cross-check that they produce the same results.")
            print("\tRecommended usage (in Linux) would be:")
            print("\t    ibmFloat.py --make-test >ibmFloat.tst")
            print("\t    while read -r line ; do ibmFloat.py $line ; done <ibmFloat.tst >resultsPy.txt")
            print("\t    while read -r line ; do  ibmFloat $line ; done <ibmFloat.tst >resultsC.txt")
            print("\t    diff resultsPy.txt resultsC.txt")
            print("")
            break
        elif parm == "--test-fixer":
            tests = 100000
            errors = 0
            offsets = (0, 0.94, 0.76, 0.49, 0.21, 0.1, 0.01, 0.001, 0.0001, 0.00001)
            for n in range(tests):
                for offset in offsets:
                    result = fix(n + offset)
                    if result != n:
                        if errors < 10:
                            print(f"Error: {n+offset}pFIXER gave {result}, wanted {n}")
                        errors += 1
                        if errors == 10:
                            print("Additional errors will not be listed individually.")
            print(f"{errors} total errors out of {tests*len(offsets)} tests.")
        elif parm == "--make-test":
            print(f"0 0.0")
            for i in range(-11, 11):
                if i == -11:
                    x = "FIXER"
                    print(x)
                else:
                    x = 10.0 ** i
                    print(f"{x} {-x} hc{x} hc{-x} ch{x} ch{-x}")
                for j in range(-11, 11):
                    if j == -11:
                        y = "FIXER"
                        print(f"{x}a{y} {x}s{y} {x}*{y} {x}p{y} {x}m{y}")
                    else:
                        y = 10.0 ** j
                        print(f"{x}a{y} {x}s{y} {x}*{y} {x}/{y} {x}p{y} {x}m{y}")
            f1 = 1
            f2 = 1
            for i in range(1000):
                print(f"{'%08X'%f1},{'%08X'%f2}")
                f1, f2 = (f1+f2) & 0xFFFFFFFF, f1
            break
        elif "a" in parm:
            fields = parm.split("a")
            if len(fields) != 2:
                print(f"Cannot interpret number(s)   ({parm}):")
                continue
            try:
                msw0, lsw0 = dpFromString(fields[0])
                msw1, lsw1 = dpFromString(fields[1])
                result = ibm_dp_add((msw0 << 32) | lsw0, (msw1 << 32) | lsw1)
                printHuman((result >> 32) & 0xFFFFFFFF, result & 0xFFFFFFFF, parm)
            except:
                print(f"Cannot interpret number(s)   ({parm})")
        elif "s" in parm:
            fields = parm.split("s")
            if len(fields) != 2:
                print(f"Cannot interpret number(s)   ({parm})")
                continue
            try:
                msw0, lsw0 = dpFromString(fields[0])
                msw1, lsw1 = dpFromString(fields[1])
                result = ibm_dp_sub((msw0 << 32) | lsw0, (msw1 << 32) | lsw1)
                printHuman((result >> 32) & 0xFFFFFFFF, result & 0xFFFFFFFF, parm)
            except:
                print(f"Cannot interpret number(s)   ({parm})")
        elif "*" in parm:
            fields = parm.split("*")
            if len(fields) != 2:
                print(f"Cannot interpret number(s)   ({parm})")
                continue
            try:
                msw0, lsw0 = dpFromString(fields[0])
                msw1, lsw1 = dpFromString(fields[1])
                result = ibm_dp_mul((msw0 << 32) | lsw0, (msw1 << 32) | lsw1)
                printHuman((result >> 32) & 0xFFFFFFFF, result & 0xFFFFFFFF, parm)
            except:
                print(f"Cannot interpret number(s)   ({parm})")
        elif "/" in parm:
            fields = parm.split("/")
            if len(fields) != 2:
                print(f"Cannot interpret number(s)   ({parm})")
                continue
            try:
                msw0, lsw0 = dpFromString(fields[0])
                msw1, lsw1 = dpFromString(fields[1])
                result = ibm_dp_div((msw0 << 32) | lsw0, (msw1 << 32) | lsw1)
                printHuman((result >> 32) & 0xFFFFFFFF, result & 0xFFFFFFFF, parm)
            except:
                print(f"Cannot interpret number(s)   ({parm})")
        elif "p" in parm:
            fields = parm.split("p")
            if len(fields) != 2:
                print(f"Cannot interpret number(s)   ({parm})")
                continue
            try:
                msw0, lsw0 = dpFromString(fields[0])
                msw1, lsw1 = dpFromString(fields[1])
                result = ibm_dp_addsub((msw0 << 32) | lsw0, (msw1 << 32) | lsw1, 0, 0)
                printHuman((result >> 32) & 0xFFFFFFFF, result & 0xFFFFFFFF, parm)
            except:
                print(f"Cannot interpret number(s)   ({parm})")
        elif "m" in parm:
            fields = parm.split("m")
            if len(fields) != 2:
                print(f"Cannot interpret number(s)   ({parm})")
                continue
            try:
                msw0, lsw0 = dpFromString(fields[0])
                msw1, lsw1 = dpFromString(fields[1])
                result = ibm_dp_addsub((msw0 << 32) | lsw0, (msw1 << 32) | lsw1, 1, 0)
                printHuman((result >> 32) & 0xFFFFFFFF, result & 0xFFFFFFFF, parm)
            except:
                print(f"Cannot interpret number(s)   ({parm})")
        elif parm.startswith("hc"):
            msw, lsw = dpFromString(parm[2:])
            f = ibm_dp_to_double(msw, lsw)
            print(f"{'%.14E'%f}   ({parm})")
        elif parm.startswith("ch"):
            try:
                f = float(parm[2:])
                msw, lsw = ibm_dp_from_double(f)
                if msw == IBM_DP_OVERFLOW_MSW:
                    print(f"Overflow   ({parm})")
                else:
                    printHuman(msw, lsw, parm)
            except:
                print(f"Not a valid Python floating-point number   ({parm})")
        elif parm.startswith("t"):
            try:
                msw, lsw = dpFromString(parm[1:])
                result = addUnnormalizedToFixer((msw << 32) | lsw)
                printHuman(result >> 32, result & 0xFFFFFFFF, parm)
            except:
                print(f"Not a valid Python floating-point number   ({parm})")
        elif parm.startswith("i"):
            try:
                f = float(parm[1:])
                rep = ieee754(f)
                print(f"{rep}   ({parm})")
            except:
                print(f"Not a valid Python floating-point number   ({parm})")
        else:
            try:
                msw, lsw = dpFromString(parm)
                printHuman(msw, lsw, parm)
            except:
                print(f"Cannot interpret number   ({parm})")

