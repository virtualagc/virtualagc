#include "value.h"

#include <math.h>
#include <stdio.h>

#include "literal.h"

halmat_scalar_t halmat_scalar_zero(bool double_precision) {
    halmat_scalar_t s = {0};
    s.double_precision = double_precision;
    return s; /* true zero: sign=0, characteristic=0, fraction=0 */
}

halmat_scalar_t halmat_scalar_from_ibm_words(uint32_t msw, uint32_t lsw, bool double_precision) {
    halmat_scalar_t s;
    s.double_precision = double_precision;
    s.msw = msw;
    s.lsw = double_precision ? lsw : 0;
    return s;
}

halmat_scalar_t halmat_scalar_from_integer(int32_t value, bool double_precision) {
    halmat_scalar_t s = halmat_scalar_zero(double_precision);
    if (value == 0) return s;

    uint32_t magnitude = (value < 0) ? (uint32_t)(-(int64_t)value) : (uint32_t)value;
    uint8_t sign = (value < 0) ? 1 : 0;

    /* Count hex digits k in magnitude (magnitude falls in [16^(k-1), 16^k)). */
    int k = 0;
    for (uint32_t t = magnitude; t != 0; t >>= 4) k++;

    int max_hex_digits = double_precision ? 14 : 6;
    uint64_t fraction;
    if (k <= max_hex_digits) {
        fraction = (uint64_t)magnitude << (4 * (max_hex_digits - k));
    } else {
        fraction = (uint64_t)magnitude >> (4 * (k - max_hex_digits)); /* drop low-order hex digits */
    }
    uint8_t characteristic = (uint8_t)(64 + k);

    if (double_precision) {
        s.msw = ((uint32_t)sign << 31) | ((uint32_t)characteristic << 24) | (uint32_t)((fraction >> 32) & 0x00FFFFFFu);
        s.lsw = (uint32_t)(fraction & 0xFFFFFFFFu);
    } else {
        s.msw = ((uint32_t)sign << 31) | ((uint32_t)characteristic << 24) | (uint32_t)(fraction & 0x00FFFFFFu);
        s.lsw = 0;
    }
    return s;
}

int32_t halmat_scalar_to_integer(halmat_scalar_t s) {
    return (int32_t)trunc(halmat_scalar_to_double(s));
}

double halmat_scalar_to_double(halmat_scalar_t s) {
    return ibm_hex_float_to_double(s.msw, s.lsw);
}

static int hex_digit_count64(uint64_t v) {
    int n = 0;
    while (v != 0) { n++; v >>= 4; }
    return n;
}

halmat_scalar_t halmat_scalar_add(halmat_scalar_t a, halmat_scalar_t b) {
    bool dbl = a.double_precision || b.double_precision;

    int sign_a = (int)((a.msw >> 31) & 1), sign_b = (int)((b.msw >> 31) & 1);
    int char_a = (int)((a.msw >> 24) & 0x7F), char_b = (int)((b.msw >> 24) & 0x7F);
    uint64_t frac_a = ((uint64_t)(a.msw & 0x00FFFFFFu) << 32) | a.lsw;
    uint64_t frac_b = ((uint64_t)(b.msw & 0x00FFFFFFu) << 32) | b.lsw;

    /* True zero: sign of a sum/difference with a zero fraction is
     * positive (AP-101S Software Model PDF Sec. 8.2's "true zero" rule);
     * an operand that's already true zero just yields the other,
     * re-cast to the result's precision. */
    if (frac_a == 0 && frac_b == 0) return halmat_scalar_zero(dbl);
    if (frac_a == 0) return halmat_scalar_from_ibm_words(b.msw, b.lsw, dbl);
    if (frac_b == 0) return halmat_scalar_from_ibm_words(a.msw, a.lsw, dbl);

    /* Align: right-shift the smaller-characteristic operand's fraction
     * until both characteristics match. */
    int char_r = (char_a > char_b) ? char_a : char_b;
    if (char_a < char_r) frac_a >>= (4 * (char_r - char_a));
    if (char_b < char_r) frac_b >>= (4 * (char_r - char_b));

    int64_t signed_a = sign_a ? -(int64_t)frac_a : (int64_t)frac_a;
    int64_t signed_b = sign_b ? -(int64_t)frac_b : (int64_t)frac_b;
    int64_t sum = signed_a + signed_b;

    int result_sign = (sum < 0) ? 1 : 0;
    uint64_t result_frac = (sum < 0) ? (uint64_t)(-sum) : (uint64_t)sum;

    if (result_frac == 0) return halmat_scalar_zero(dbl);

    /* Postnormalize in the wide (14-hex-digit/double) domain regardless
     * of the result's final precision; packing below truncates to 6 hex
     * digits for a single-precision result. */
    int max_hex_digits = 14;
    int k = hex_digit_count64(result_frac);
    if (k > max_hex_digits) {
        result_frac >>= (4 * (k - max_hex_digits));
        char_r += (k - max_hex_digits);
    } else if (k < max_hex_digits) {
        result_frac <<= (4 * (max_hex_digits - k));
        char_r -= (max_hex_digits - k);
    }
    if (char_r < 0) char_r = 0;
    if (char_r > 127) char_r = 127;

    halmat_scalar_t result;
    result.double_precision = dbl;
    if (dbl) {
        result.msw = ((uint32_t)result_sign << 31) | ((uint32_t)char_r << 24) | (uint32_t)((result_frac >> 32) & 0x00FFFFFFu);
        result.lsw = (uint32_t)(result_frac & 0xFFFFFFFFu);
    } else {
        uint64_t short_frac = result_frac >> 32; /* top 6 hex digits only */
        result.msw = ((uint32_t)result_sign << 31) | ((uint32_t)char_r << 24) | (uint32_t)(short_frac & 0x00FFFFFFu);
        result.lsw = 0;
    }
    return result;
}

halmat_scalar_t halmat_scalar_negate(halmat_scalar_t a) {
    halmat_scalar_t r = a;
    if (r.msw != 0 || r.lsw != 0) r.msw ^= 0x80000000u; /* true zero's sign stays positive */
    return r;
}

halmat_scalar_t halmat_scalar_sub(halmat_scalar_t a, halmat_scalar_t b) {
    return halmat_scalar_add(a, halmat_scalar_negate(b));
}

void halmat_scalar_format(halmat_scalar_t s, char *buf, size_t buf_size) {
    /* Standard normalized scientific notation (leading digit 1-9 for any
     * nonzero value): 7 fractional digits single-precision, 16 double --
     * confirmed against the reference yaHALMAT emulator's own WRITE
     * output for a genuine nonzero value (1.5+2.25=3.75 -> " 3.7500000E+00"),
     * and self-consistent with class-2/STOC.md's stated total field
     * width (14/23 characters); that file's prose "8/17 fractional
     * digits" claim and its zero-value worked example both appear to be
     * off by one relative to its own total-width claim -- see the
     * Phase 3 follow-up note added there. */
    int frac_digits = s.double_precision ? 16 : 7;
    double value = halmat_scalar_to_double(s);
    char sign = (value < 0.0) ? '-' : ' ';
    double mag = (value < 0.0) ? -value : value;
    int exponent = 0;

    if (mag != 0.0) {
        exponent = (int)floor(log10(mag));
        mag = mag / pow(10.0, exponent);
        if (mag >= 10.0) { mag /= 10.0; exponent++; }  /* guard rounding at the boundary */
        if (mag < 1.0) { mag *= 10.0; exponent--; }
    }

    snprintf(buf, buf_size, "%c%.*fE%c%02d", sign, frac_digits, mag, (exponent < 0) ? '-' : '+',
             (exponent < 0) ? -exponent : exponent);
}

/* Shared postnormalize step (see halmat_scalar_add's identical logic):
 * bring `frac` (any nonzero width) to exactly 14 hex digits (56 bits),
 * adjusting `*characteristic` for whichever direction it shifts. */
static void postnormalize(uint64_t *frac, int *characteristic) {
    int k = hex_digit_count64(*frac);
    const int max_hex_digits = 14;
    if (k > max_hex_digits) {
        *frac >>= (4 * (k - max_hex_digits));
        *characteristic += (k - max_hex_digits);
    } else if (k < max_hex_digits) {
        *frac <<= (4 * (max_hex_digits - k));
        *characteristic -= (max_hex_digits - k);
    }
    if (*characteristic < 0) *characteristic = 0;
    if (*characteristic > 127) *characteristic = 127;
}

static void pack_scalar(int sign, int characteristic, uint64_t frac, bool dbl, halmat_scalar_t *out) {
    out->double_precision = dbl;
    if (dbl) {
        out->msw = ((uint32_t)sign << 31) | ((uint32_t)characteristic << 24) | (uint32_t)((frac >> 32) & 0x00FFFFFFu);
        out->lsw = (uint32_t)(frac & 0xFFFFFFFFu);
    } else {
        uint64_t short_frac = frac >> 32; /* top 6 hex digits only */
        out->msw = ((uint32_t)sign << 31) | ((uint32_t)characteristic << 24) | (uint32_t)(short_frac & 0x00FFFFFFu);
        out->lsw = 0;
    }
}

/* Portable (no __uint128_t) 64x64->128 unsigned multiply, schoolbook
 * 32-bit-limb technique -- needed for a genuinely correct 56-bit x
 * 56-bit fraction product without relying on a compiler extension that
 * MSVC doesn't provide (Plan.md's cross-platform requirement). */
static void mul64x64(uint64_t a, uint64_t b, uint64_t *hi, uint64_t *lo) {
    uint64_t a_lo = a & 0xFFFFFFFFu, a_hi = a >> 32;
    uint64_t b_lo = b & 0xFFFFFFFFu, b_hi = b >> 32;

    uint64_t lo_lo = a_lo * b_lo;
    uint64_t hi_lo = a_hi * b_lo;
    uint64_t lo_hi = a_lo * b_hi;
    uint64_t hi_hi = a_hi * b_hi;

    uint64_t cross = (lo_lo >> 32) + (hi_lo & 0xFFFFFFFFu) + (lo_hi & 0xFFFFFFFFu);
    *lo = (cross << 32) | (lo_lo & 0xFFFFFFFFu);
    *hi = hi_hi + (hi_lo >> 32) + (lo_hi >> 32) + (cross >> 32);
}

/* Portable 128-by-64-bit unsigned restoring division, producing a 64-bit
 * quotient (bits beyond bit 63, if the true quotient were ever wider,
 * are silently dropped -- doesn't happen for normalized 56-bit fraction
 * inputs scaled by exactly 56 bits, per halmat_scalar_divide's own
 * range analysis). O(128) per call; not performance-critical for an
 * interpreter. */
static uint64_t div128by64(uint64_t dividend_hi, uint64_t dividend_lo, uint64_t divisor) {
    uint64_t remainder = 0;
    uint64_t quotient = 0;
    for (int i = 127; i >= 0; i--) {
        uint64_t bit = (i >= 64) ? ((dividend_hi >> (i - 64)) & 1u) : ((dividend_lo >> i) & 1u);
        remainder = (remainder << 1) | bit;
        if (remainder >= divisor) {
            remainder -= divisor;
            if (i < 64) quotient |= ((uint64_t)1 << i);
        }
    }
    return quotient;
}

halmat_scalar_t halmat_scalar_multiply(halmat_scalar_t a, halmat_scalar_t b) {
    bool dbl = a.double_precision || b.double_precision;
    int sign_a = (int)((a.msw >> 31) & 1), sign_b = (int)((b.msw >> 31) & 1);
    int char_a = (int)((a.msw >> 24) & 0x7F), char_b = (int)((b.msw >> 24) & 0x7F);
    uint64_t frac_a = ((uint64_t)(a.msw & 0x00FFFFFFu) << 32) | a.lsw;
    uint64_t frac_b = ((uint64_t)(b.msw & 0x00FFFFFFu) << 32) | b.lsw;

    /* "When either the multiplicand or multiplier is a true zero, the
     * result is normally forced to a true zero" (AP-101S Software Model
     * PDF Sec. 8.24). */
    if (frac_a == 0 || frac_b == 0) return halmat_scalar_zero(dbl);

    uint64_t prod_hi, prod_lo;
    mul64x64(frac_a, frac_b, &prod_hi, &prod_lo);
    /* "The sum of the characteristics less 64 is used as the
     * characteristic of an intermediate product" (Sec. 8.24). Taking the
     * product's top 56 bits (dropping the low 56, i.e. >>56) is exactly
     * the fraction value at that characteristic's scale -- see the
     * derivation in this file's Phase 3 commit message; no further
     * digit-count correction is needed before postnormalize(). */
    int char_r = char_a + char_b - 64;
    uint64_t result_frac = (prod_hi << 8) | (prod_lo >> 56);
    int result_sign = sign_a ^ sign_b;

    if (result_frac == 0) return halmat_scalar_zero(dbl);
    postnormalize(&result_frac, &char_r);

    halmat_scalar_t result;
    pack_scalar(result_sign, char_r, result_frac, dbl, &result);
    return result;
}

bool halmat_scalar_divide(halmat_scalar_t a, halmat_scalar_t b, halmat_scalar_t *out) {
    bool dbl = a.double_precision || b.double_precision;
    int sign_a = (int)((a.msw >> 31) & 1), sign_b = (int)((b.msw >> 31) & 1);
    int char_a = (int)((a.msw >> 24) & 0x7F), char_b = (int)((b.msw >> 24) & 0x7F);
    uint64_t frac_a = ((uint64_t)(a.msw & 0x00FFFFFFu) << 32) | a.lsw;
    uint64_t frac_b = ((uint64_t)(b.msw & 0x00FFFFFFu) << 32) | b.lsw;

    if (frac_b == 0) {
        /* "When division by a zero divisor is attempted, the operation
         * is suppressed... a program interruption for floating point
         * divide exception occurs" (Sec. 8.16) -- a real ERROR
         * CONDITION, not a value to silently substitute. */
        return false;
    }
    if (frac_a == 0) {
        /* "When the dividend is a true zero, the quotient fraction will
         * be zero... yielding a true zero result" (Sec. 8.16). */
        *out = halmat_scalar_zero(dbl);
        return true;
    }

    /* Scale the dividend left by exactly 14 hex digits (56 bits) before
     * dividing, so the integer quotient itself directly represents the
     * result fraction at characteristic (char_a - char_b + 64) -- see
     * this file's Phase 3 commit message for the full derivation
     * (mirrors halmat_scalar_multiply's approach in reverse). Normalized
     * 56-bit operands keep the true quotient within 64 bits. */
    uint64_t dividend_hi = frac_a >> 8;         /* frac_a << 56, split into hi/lo of a 128-bit value */
    uint64_t dividend_lo = frac_a << 56;
    uint64_t quotient = div128by64(dividend_hi, dividend_lo, frac_b);

    int char_r = char_a - char_b + 64;
    int result_sign = sign_a ^ sign_b;

    if (quotient == 0) { *out = halmat_scalar_zero(dbl); return true; }
    postnormalize(&quotient, &char_r);
    pack_scalar(result_sign, char_r, quotient, dbl, out);
    return true;
}
