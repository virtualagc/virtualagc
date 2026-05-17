/*
 * License:     The author (Donald Schmidt) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    ibmFloat.c
 * Purpose:     IBM hex floating-point arithmetic and conversions.
 *              Based on the floating point logic in the
 *              Hyperion/Hercules IBM 390 & z/Series emulator:
 *                  https://github.com/hercules-390/hyperion/blob/master/float.c
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 * Mod history: 2026-05-01 DS   Initial version.
 *              2026-05-12 RSB  Corrected behavior of `ibm_dp_addsub` when doing
 *                              unnormalized arithmetic on unnormalized 0.
 *              2026-05-15 RSB  Reverted change to `ibm_dp_addsub` that rounded
 *                              results of unnormalized addition/subtraction.
 */

#include <assert.h>
#include <math.h>
#include <stddef.h>
#include <stdio.h>
#include "ibmFloat.h"

#define twoTo56 (1LL << IBM_DP_MANT_BITS)
#define twoTo52 (1LL << 52)

static uint64_t ibm_dp_from_uint(uint64_t v);

// Convert a C double to IBM double-precision float, returning the (msw, lsw)
// pair.  On overflow returns (IBM_DP_OVERFLOW_MSW, 0).
// NOTE: IBM float has 56 bit mantissa, IEEE754 double is 53 bits,
//       so this loses precision.
void __attribute__ ((no_instrument_function))
ibm_dp_from_double(uint32_t *msw, uint32_t *lsw, double d) {
    assert(msw != NULL && lsw != NULL);
    int s; // The sign: 1 if negative, 0 if non-negative.
    int e; // Exponent.
    uint64_t f;
    if (d == 0) {
        *msw = 0x00000000;
        *lsw = 0x00000000;
        return;
    }
    // Make x positive but preserve the sign as a bit flag.
    if (d < 0) {
        s = 1;
        d = -d;
    } else
        s = 0;
    // Shift left by 24 bits.
    //printf("A %s\n", ieee754(d));
    d *= twoTo56;
    //printf("B %s\n", ieee754(d));
    // Find the exponent (biased by IBM_DP_EXP_BIAS) as a power of 16:
    e = IBM_DP_EXP_BIAS;
    while (d < twoTo52) {
        e -= 1;
        d *= 16;
        //printf("C %s\n", ieee754(d));
    }
    while (d >= twoTo56) {
        e += 1;
        d /= 16;
        //printf("D %s\n", ieee754(d));
    }
    if (e < 0)
        e = 0;
    if (e > IBM_DP_EXP_MAX) {
        *msw = IBM_DP_OVERFLOW_MSW;
        *lsw = 0x00000000;
        return;
    }
    //f = llround(d);
    f = (long long)(d + 0.5);
    *msw = (s << 31) | (e << 24) | ((f >> 32) & 0xffffffff);
    *lsw = f & 0xffffffff;
}


double __attribute__ ((no_instrument_function))
ibm_dp_to_double(uint32_t msw, uint32_t lsw) {
    int s; // sign
    int e; // exponent
    long long int f;
    double x;
    s = (msw >> 31) & 1;
    e = ((msw >> 24) & IBM_DP_EXP_MAX) - IBM_DP_EXP_BIAS;
    f = ((msw & 0x00ffffffLL) << 32) | (lsw & 0xffffffff);
    x = f * pow(16, e) / twoTo56;
    if (s != 0)
        x = -x;
    return x;
}


// Convert a small unsigned integer to IBM DP packed format.
static uint64_t
ibm_dp_from_uint(uint64_t v) {
    if (v == 0) return 0;
    int exp = IBM_DP_EXP_BIAS + IBM_DP_MANT_HEXDIGITS;
    while (v >= ((uint64_t)1 << IBM_DP_MANT_BITS)) { v >>= 4; exp += 1; }
    IBM_DP_RENORMALIZE_56(v, exp);
    if (exp < 0) return 0;
    if (exp > IBM_DP_EXP_MAX) return IBM_DP_OVERFLOW_PACKED;
    return IBM_DP_PACK(0, exp, v);
}


// ibm_dp_from_string():
// convert a HAL/S decimal-literal string to IBM DP hex.  Faithful
// reproduction of MONITOR.ASM/XXXTOD.bal — the routine the HAL/S-FC
// compiler invokes via MONITOR(10) at PASS1.PROCS/SCAN.xpl:690 to
// parse every numeric literal into the literal table.
//
// Final scaling follows XXXTOD.bal:1530-1700:
//   TIMES10A  while |dec_exp| >= 23: MD/DD F0,=D'1E23'
//   TIMES10B  build F4 = 10^(0..22 remainder) via repeated squaring
//   TIMES10C  MDR/DDR F0,F4
//
// =D'1E23' is IBM Assembler-H's evaluation of the literal `1E23`.
// True 10^23 × 16^14 / 16^20 = 5,960,464,477,539,062.5 — exactly
// halfway between two DP mantissas — and Assembler-H rounds half-up,
// so the constant lives at 0x54152D02C7E14AF7
//
static const uint64_t IBM_DP_1E23 = 0x54152D02C7E14AF7ULL;

void __attribute__ ((no_instrument_function))
ibm_dp_from_string(const char *s, uint32_t *msw, uint32_t *lsw) {
    assert(s != NULL && msw != NULL && lsw != NULL);
    uint8_t sign = 0;
    if (*s == '+') s++;
    else if (*s == '-') { sign = 1; s++; }

    uint64_t F0 = 0;
    uint64_t TEN = ibm_dp_from_uint(10);
    int frac_digits = 0, seen_dot = 0, ignore = 0;
    while (*s) {
        if (*s >= '0' && *s <= '9') {
            if (!ignore) {
                F0 = ibm_dp_mul(F0, TEN);
                if (*s != '0') {
                    F0 = ibm_dp_addsub(F0, ibm_dp_from_uint((uint64_t)(*s - '0')), 0, 1);
                }
                if (seen_dot) frac_digits++;
                // XXXTOD precision guard (MONITOR.ASM/XXXTOD.bal lines
                // 26-32): once F0 reaches the SP equivalent of ~7.2e15
                // (=X'4E19999A') and we're past the decimal point,
                // ignore all remaining digits.  Without this, every
                // additional digit costs another truncating *=10
                // multiply, accumulating LSB error past the 56-bit
                // mantissa's natural ~17-decimal-digit precision.  Note
                // pre-decimal digits never trigger ignore — they affect
                // magnitude and must always be processed.
                if (seen_dot
                    && ((uint32_t)(F0 >> 32)) >= 0x4E19999AU) {
                    ignore = 1;
                }
            }
            s++;
        } else if (*s == '.' && !seen_dot) {
            seen_dot = 1;
            s++;
        } else {
            break;
        }
    }

    int dec_exp = 0;
    if (*s == 'E' || *s == 'e') {
        s++;
        int es = 1;
        if (*s == '+') s++;
        else if (*s == '-') { es = -1; s++; }
        int v = 0;
        while (*s >= '0' && *s <= '9') { v = v * 10 + (*s - '0'); s++; }
        dec_exp = es * v;
    }
    dec_exp -= frac_digits;

    if (IBM_DP_MANT(F0) == 0) { *msw = 0; *lsw = 0; return; }
    if (sign) F0 |= IBM_DP_SIGN_BIT;

    if (dec_exp != 0) {
        int absexp = dec_exp < 0 ? -dec_exp : dec_exp;
        // TIMES10A: chunk by 23 using the Assembler-H 1E23 constant.
        while (absexp >= 23) {
            F0 = (dec_exp > 0)
                 ? ibm_dp_mul(F0, IBM_DP_1E23)
                 : ibm_dp_div(F0, IBM_DP_1E23);
            absexp -= 23;
        }
        // TIMES10B / TIMES10C: build F4 = 10^(0..22) via squaring,
        // then MDR/DDR.
        if (absexp > 0) {
            uint64_t F4 = ibm_dp_from_uint(1);
            uint64_t F2 = TEN;
            while (absexp > 0) {
                if (absexp & 1) F4 = ibm_dp_mul(F4, F2);
                absexp >>= 1;
                if (absexp) F2 = ibm_dp_mul(F2, F2);
            }
            F0 = (dec_exp > 0) ? ibm_dp_mul(F0, F4) : ibm_dp_div(F0, F4);
        }
    }

    if (F0 == IBM_DP_OVERFLOW_PACKED) { *msw = IBM_DP_OVERFLOW_MSW; *lsw = 0; return; }
    if (IBM_DP_MANT(F0) == 0) { *msw = 0; *lsw = 0; return; }
    *msw = (uint32_t)(F0 >> 32);
    *lsw = (uint32_t)F0;
}



// IBM hex dp add/subtract
// based on hyperion's add_lf:
// https://github.com/hercules-390/hyperion/blob/bec74e3a3dc26acb251eb820b3aeafcee0576b88/float.c#L1307
//
uint64_t
ibm_dp_addsub(uint64_t a_packed, uint64_t b_packed,
              int subtract_b, int normalize) {
    uint8_t  a_sign = IBM_DP_SIGN(a_packed);
    int      a_exp  = IBM_DP_EXP(a_packed);
    uint64_t a_mant = IBM_DP_MANT(a_packed);
    uint8_t  b_sign = IBM_DP_SIGN(b_packed);
    int      b_exp  = IBM_DP_EXP(b_packed);
    uint64_t b_mant = IBM_DP_MANT(b_packed);
    if (subtract_b) b_sign ^= 1;

    int a_iszero;
    int b_iszero;
    if (normalize) {
	a_iszero = (a_packed & IBM_DP_MANT_MASK) == 0;
	b_iszero = (b_packed & IBM_DP_MANT_MASK) == 0;
    } else {
        a_iszero = (a_packed & 0x7FFFFFFFFFFFFFFFULL) == 0;
        b_iszero = (b_packed & 0x7FFFFFFFFFFFFFFFULL) == 0;
    }

    if (!b_iszero && !a_iszero) {
        // Both not zero — align with guard digit, then signed add.
        if (a_exp == b_exp) {
            // Equal exponents: just introduce guard digit on both.
            a_mant <<= 4;
            b_mant <<= 4;
        } else if (a_exp < b_exp) {
            int shift = b_exp - a_exp - 1;  // minus guard digit
            a_exp = b_exp;
            if (shift > 0) {
                if (shift >= IBM_DP_MANT_HEXDIGITS
                    || ((a_mant >>= (shift * 4)) == 0)) {
                    // a effectively shifted to zero — copy b (no guard).
                    a_sign = b_sign;
                    a_mant = b_mant;
                    if (a_mant == 0 || !normalize) goto pack;
                    goto normalize_56bit;
                }
            }
            b_mant <<= 4;  // guard digit on b
        } else {
            int shift = a_exp - b_exp - 1;  // minus guard digit
            if (shift > 0) {
                if (shift >= IBM_DP_MANT_HEXDIGITS
                 || ((b_mant >>= (shift * 4)) == 0)) {
                    // b effectively shifted to zero — result is a (no guard).
                    if (a_mant == 0 || !normalize) goto pack;
                    goto normalize_56bit;
                }
            }
            a_mant <<= 4;  // guard digit on a
        }

        // Compute with guard digit (60-bit mantissas).
        uint64_t r_mant;
        uint8_t  r_sign;
        if (a_sign == b_sign) {
            r_sign = a_sign;
            r_mant = a_mant + b_mant;
        } else if (a_mant == b_mant) {
            // True cancellation — result is +0.
            a_sign = 0; a_exp = 0; a_mant = 0;
            goto pack;
        } else if (a_mant > b_mant) {
            r_sign = a_sign;
            r_mant = a_mant - b_mant;
        } else {
            r_sign = b_sign;
            r_mant = b_mant - a_mant;
        }

        // Post-add: handle overflow / drop guard / renormalize.
        if (r_mant & IBM_DP_OVERFLOW_60) {
            // Overflow into bit 60+: shift right 1 hex (cancels guard
            // and absorbs overflow), bump expo.
            r_mant >>= 8;
            a_exp += 1;
        } else if (!normalize) {
            // UNNORMAL: just drop guard.
            r_mant >>= 4;
        } else if (r_mant & IBM_DP_TOP_HEX_60) {
            // NORMAL, top guard-hex set: drop guard, already normalized.
            r_mant >>= 4;
        } else {
            // NORMAL, leading zero hex in 60-bit form: re-interpret as
            // 56-bit (decrement expo to compensate for the implicit
            // <<4 from the format change), then normalize.  High bits
            // beyond bit 55 will be truncated by the pack-time mask.
            a_exp -= 1;
            if (r_mant) IBM_DP_RENORMALIZE_56(r_mant, a_exp);
            else        { r_sign = 0; a_exp = 0; };
        }
        a_sign = r_sign;
        a_mant = r_mant;
        goto pack;
    }

    if (b_iszero && a_iszero) {
        // Both true zero.
        a_sign = 0; a_exp = 0; a_mant = 0;
        goto pack;
    }
    if (a_iszero) {
        // a true zero, b not — copy b.
        a_sign = b_sign;
        a_exp  = b_exp;
        a_mant = b_mant;
    }
    // (else: a not zero, b true zero — keep a as-is.)
    // For NORMAL we must always route through normalize_56bit so that
    // an `a` with mant=0 but exp!=0 (e.g., FIXER-format zero left by a
    // prior AW) canonicalizes to true zero — matches Hyperion's
    // significance_lf path in add_lf (float.c:1442-1452).
    if (normalize) goto normalize_56bit;
    goto pack;

normalize_56bit:
    if (a_mant == 0) { a_sign = 0; a_exp = 0; goto pack; }
    IBM_DP_RENORMALIZE_56(a_mant, a_exp);

pack:
    if (a_exp < 0) a_exp = 0;
    if (a_exp > IBM_DP_EXP_MAX) a_exp = IBM_DP_EXP_MAX;
    return IBM_DP_PACK(a_sign, a_exp, a_mant);
}

uint64_t ibm_dp_add(uint64_t a, uint64_t b) {
    return ibm_dp_addsub(a, b, /*subtract_b=*/0, 1);
}


uint64_t ibm_dp_sub(uint64_t a, uint64_t b) {
    return ibm_dp_addsub(a, b, /*subtract_b=*/1, 1);
}

// IBM hex DP multiply
// based on Hyperion's mul_lf:
// https://github.com/hercules-390/hyperion/blob/bec74e3a3dc26acb251eb820b3aeafcee0576b88/float.c#L2082
//
uint64_t
ibm_dp_mul(uint64_t a, uint64_t b) {
    uint64_t a_mant = IBM_DP_MANT(a);
    uint64_t b_mant = IBM_DP_MANT(b);
    if (a_mant == 0 || b_mant == 0) return 0;

    int     a_exp  = IBM_DP_EXP(a);
    int     b_exp  = IBM_DP_EXP(b);
    uint8_t r_sign = IBM_DP_SIGN(a) ^ IBM_DP_SIGN(b);

    IBM_DP_RENORMALIZE_56(a_mant, a_exp);
    IBM_DP_RENORMALIZE_56(b_mant, b_exp);

    // 56x56 → 112-bit product via four 32x32 partial multiplications.
    // We compute the upper 96 bits (low 32 bits of product are always 0
    // for normalized 56-bit operands, since the smallest nonzero hex
    // digit lives at bit 0 and the lowest possible product bit is 0).
    uint64_t a_lo = a_mant & 0xFFFFFFFFULL, a_hi = a_mant >> 32;
    uint64_t b_lo = b_mant & 0xFFFFFFFFULL, b_hi = b_mant >> 32;
    uint64_t wk = (a_lo * b_lo) >> 32;
    wk += a_lo * b_hi;
    wk += a_hi * b_lo;
    uint32_t v  = (uint32_t)(wk & 0xFFFFFFFFULL);
    uint64_t hi = (wk >> 32) + (a_hi * b_hi);

    int      r_exp;
    uint64_t r_mant;
    if (hi & 0x0000F00000000000ULL) {
        // Top hex of result already at bit 44-47 of `hi` → shift left 8
        // to pack 56 bits into low part of U64.
        r_mant = (hi << 8) | (v >> 24);
        r_exp  = a_exp + b_exp - IBM_DP_EXP_BIAS;
    } else {
        // Top hex is one digit lower → shift left 12 and account via expo.
        r_mant = (hi << 12) | (v >> 20);
        r_exp  = a_exp + b_exp - (IBM_DP_EXP_BIAS + 1);
    }

    if (r_exp < 0) return 0;
    if (r_exp > IBM_DP_EXP_MAX) return IBM_DP_OVERFLOW_PACKED;  // overflow sentinel
    return IBM_DP_PACK(r_sign, r_exp, r_mant);
}


// IBM hex DP divide
// based on Hyperion's div_lf:
// https://github.com/hercules-390/hyperion/blob/bec74e3a3dc26acb251eb820b3aeafcee0576b88/float.c#L2298
//
uint64_t
ibm_dp_div(uint64_t a, uint64_t b) {
    uint64_t a_mant = IBM_DP_MANT(a);
    uint64_t b_mant = IBM_DP_MANT(b);
    assert(b_mant != 0 && "ibm_dp_div: divisor mantissa is zero");
    if (a_mant == 0) return 0;

    int     a_exp  = IBM_DP_EXP(a);
    int     b_exp  = IBM_DP_EXP(b);
    uint8_t r_sign = IBM_DP_SIGN(a) ^ IBM_DP_SIGN(b);

    IBM_DP_RENORMALIZE_56(a_mant, a_exp);
    IBM_DP_RENORMALIZE_56(b_mant, b_exp);

    int r_exp;
    if (a_mant < b_mant) {
        r_exp = a_exp - b_exp + IBM_DP_EXP_BIAS;
    } else {
        r_exp = a_exp - b_exp + (IBM_DP_EXP_BIAS + 1);
        b_mant <<= 4;  // shift divisor up so first quotient digit fits
    }

    // Long division: produce 14 hex digits (= 56 bits) of quotient.
    uint64_t wk2 = a_mant / b_mant;
    uint64_t wk  = (a_mant % b_mant) << 4;
    int i = IBM_DP_MANT_HEXDIGITS - 1;
    while (i--) {
        wk2 = (wk2 << 4) | (wk / b_mant);
        wk  = (wk % b_mant) << 4;
    }
    uint64_t r_mant = (wk2 << 4) | (wk / b_mant);

    if (r_exp < 0) return 0;
    if (r_exp > IBM_DP_EXP_MAX) return IBM_DP_OVERFLOW_PACKED;
    return IBM_DP_PACK(r_sign, r_exp, r_mant);
}

// data from TENSTBL.bal, used by XXDTOC.
//
// Each entry is the IBM Assemblerevaluation of the literal `=D'10^N'`
//  NOTE: `=D` literals use a round-up rule, not the truncate rule
//        used elsewhere in this code.
//
static const uint64_t TENSTBL[17] = {
    /* 10^0  */  0x4110000000000000ULL,
    /* 10^1  */  0x41A0000000000000ULL,
    /* 10^2  */  0x4264000000000000ULL,
    /* 10^3  */  0x433E800000000000ULL,
    /* 10^4  */  0x4427100000000000ULL,
    /* 10^5  */  0x45186A0000000000ULL,
    /* 10^6  */  0x45F4240000000000ULL,
    /* 10^7  */  0x4698968000000000ULL,
    /* 10^8  */  0x475F5E1000000000ULL,
    /* 10^9  */  0x483B9ACA00000000ULL,
    /* 10^10 */  0x492540BE40000000ULL,
    /* 10^20 */  0x5156BC75E2D63100ULL,
    /* 10^30 */  0x59C9F2C9CD04674FULL,
    /* 10^40 */  0x621D6329F1C35CA5ULL,
    /* 10^50 */  0x6A446C3B15F99267ULL,
    /* 10^60 */  0x729F4F2726179A22ULL,
    /* 10^70 */  0x7B172EBAD6DDC73DULL,
};

// ibm_dp_to_string — direct IBM hex DP -> decimal string
//
// Based on MONITOR.ASM/XXDTOC.bal
//
//   1. Iteratively scale |value| by powers of 10 until
//      the characteristic field equals 0x4E (= 78), at which point
//      the 56-bit mantissa is the leading 16-17 decimal digits of the
//      original value as an integer.  Each iteration's log10 step is
//      computed the same way the assembly did:
//          (|char-78| * 19728 + 8192) >> 14
//      ≈ |char-78| * log10(16), rounded.
//   2. Format the mantissa as a 17-digit string.  XXDTOC's WINT
//      assembly is just a packed-decimal representation of this
//      integer; the leading digit may be a real digit (17-digit
//      mantissa) or an implicit leading '0' (16-digit mantissa).
//      Take sig_digits chars starting from the first non-zero, and
//      pad on the right with '0' if pad_to_digits > sig_digits.
//   3. The decimal exponent for the displayed "D.DDD...DD" is
//      E10 + 16 - (leading zeros skipped), matching XXDTOC's
//      `AH R1,H15` (and conditional `AH R1,ONE` for 17-digit case).
//
void
ibm_dp_to_string(uint32_t msw, uint32_t lsw, int sig_digits,
                 int pad_to_digits, char *out, size_t out_len)
{
    assert(out != NULL && out_len > 0);
    assert(sig_digits > 0 && sig_digits <= 30);
    assert(pad_to_digits >= sig_digits && pad_to_digits <= 30);

    if (((msw & 0x7FFFFFFFu) | lsw) == 0) {
        snprintf(out, out_len, "0.0");
        return;
    }

    int sign = (msw >> 31) & 1u;
    uint64_t value = ((uint64_t)(msw & 0x7FFFFFFFu) << 32) | lsw; // unsigned

    int E10 = 0;

    for (int iter = 0; iter < 8; iter++) {
        int char_field = (int)((value >> 56) & IBM_DP_EXP_MAX);
        int diff = char_field - 78;
        if (diff == 0) break;

        int abs_diff = diff < 0 ? -diff : diff;
        int log10_diff = ((abs_diff * 19728) + 8192) >> 14;
        if (log10_diff > 78) log10_diff = 78;
        if (log10_diff <= 0) break;

        int ones = log10_diff % 10;
        int tens = log10_diff / 10;

        if (ones > 0) {
            uint64_t f = TENSTBL[ones];
            value = (diff > 0) ? ibm_dp_div(value, f)
                               : ibm_dp_mul(value, f);
        }
        if (tens > 0) {
            uint64_t f = TENSTBL[9 + tens];
            value = (diff > 0) ? ibm_dp_div(value, f)
                               : ibm_dp_mul(value, f);
        }

        if (diff > 0) E10 += log10_diff;
        else          E10 -= log10_diff;
    }

    uint64_t mantissa = value & IBM_DP_MANT_MASK;

    // Render mantissa as 17 chars (leading zero if 16-digit)
    char m[20];
    snprintf(m, sizeof(m), "%017llu", (unsigned long long)mantissa);

    // Skip leading zeros to find the first significant digit.
    int start = 0;
    while (start < 16 && m[start] == '0') start++;

    int E10_display = E10 + (16 - start);

    char display[40];
    int avail = 17 - start;
    int take  = sig_digits < avail ? sig_digits : avail;
    int pos = 0;
    for (int i = 0; i < take; i++) display[pos++] = m[start + i];
    for (int i = take; i < pad_to_digits; i++) display[pos++] = '0';
    display[pos] = '\0';

    int abs_E10 = E10_display < 0 ? -E10_display : E10_display;
    snprintf(out, out_len, "%s%c.%sE%c%02d", sign ? "-" : "",
                                             display[0],
                                             display + 1,
                                             E10_display < 0 ? '-' : '+',
                                             abs_E10);
}

// ibm_dp_to_hal_string — HAL/S MONITOR(12)-style formatting.
//
//     0.0:        Printed as " 0.0"   (notice the leading space)
//     Positive:   Printed as " d.ddd...E±ee"
//     Negative:   Printed as "-d.ddd...E±ee"
// SP gets 7 sig digits (6 fractional); DP gets 16 (15 fractional);
// precision==0 selects SP, anything else selects DP.
//
// Zero detection treats any all-zero-mantissa packed value as zero,
// which also folds the IBM overflow sentinel (0xFF000000_00000000)
// into "0.0" the same way the previous IEEE-roundtrip path did.
void
ibm_dp_to_hal_string(uint32_t msw, uint32_t lsw, int precision,
                     char *out, size_t out_len)
{
    if ((msw & 0x00FFFFFFu) == 0 && lsw == 0) {
	if (precision)
	  snprintf(out, out_len, " 0.0                  ");
	else
	  snprintf(out, out_len, " 0.0         ");
        return;
    }
    int sig = (precision == 0) ? 7 : 16;
    char body[64];
    ibm_dp_to_string(msw, lsw, sig, sig, body, sizeof(body));
    if (body[0] == '-')
        snprintf(out, out_len, "%s", body);
    else
        snprintf(out, out_len, " %s", body);
}
