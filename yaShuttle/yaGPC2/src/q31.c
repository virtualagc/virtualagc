#include "q31.h"

/* Ported to mirror gpc/q31.coffee's use of JS BigInt (arbitrary
 * precision through the multiply/shift/divide, with the final
 * truncation-to-32-bits done explicitly at the end, matching BigInt's
 * `& 0xFFFFFFFFn` reading as "low 32 bits of the two's complement
 * representation") using only standard `int64_t`/`uint64_t` — no
 * `__int128` (a GCC/Clang extension MSVC doesn't have; this file used to
 * rely on it, kept portable now that yaGPC targets MSVC too).
 *
 * Every intermediate here is provably representable in 64 bits (worked
 * out per call site below), *except* q31_div's dividend/divisor hitting
 * INT64_MIN / -1 — the one place plain int64_t division is UB in C
 * (BigInt handles it fine, yielding a finite 2^63). That single case is
 * special-cased explicitly instead of reaching for a wider type. */

Q31MulResult q31_mul32(int32_t a, int32_t b) {
    /* |a*b| <= 2^62, always fits in int64_t; the left shift is done on
     * the unsigned reinterpretation so it's well-defined (mod 2^64) even
     * for the a=b=INT32_MIN corner where the shifted value would
     * otherwise not be representable as a signed int64_t. */
    int64_t productSigned = (int64_t)a * (int64_t)b;
    uint64_t bits = ((uint64_t)productSigned) << 1;
    Q31MulResult r;
    r.hi = (uint32_t)(bits >> 32);
    r.lo = (uint32_t)(bits & 0xFFFFFFFFu);
    r.overflow = (a == INT32_MIN) && (b == INT32_MIN);
    return r;
}

Q15MulResult q15_mul(int32_t a, int32_t b) {
    int64_t product = (int64_t)a * (int64_t)b;
    int64_t shifted = product << 1;
    Q15MulResult r;
    r.result = (int32_t)(uint32_t)((uint64_t)shifted & 0xFFFFFFFFu);
    r.overflow = (a == -32768) && (b == -32768);
    return r;
}

Q31DivResult q31_div(int32_t hi, int32_t lo, int32_t divisor) {
    Q31DivResult r;
    if (divisor == 0) {
        r.quotient = 0;
        r.overflow = true;
        return r;
    }

    /* hi:lo concatenation always fits exactly in 64 bits; build it via
     * the unsigned reinterpretation (shifting a possibly-negative signed
     * value left is UB) then reinterpret as signed for the division. */
    uint64_t dividendBits = ((uint64_t)(uint32_t)hi << 32) | (uint32_t)lo;
    int64_t dividend = (int64_t)dividendBits;

    int64_t raw;
    if (divisor == -1) {
        /* dividend/-1 == -dividend; negating INT64_MIN overflows signed
         * int64_t (UB), so negate via unsigned wraparound instead. The
         * true mathematical quotient (2^63, when dividend==INT64_MIN) is
         * always > 0x7FFFFFFF regardless of how it wraps once
         * reinterpreted as int64_t, so the overflow check below still
         * comes out correct even though `raw` itself isn't the literal
         * (unrepresentable) mathematical value in that one corner case. */
        raw = (int64_t)(0ULL - (uint64_t)dividend);
    } else {
        raw = dividend / (int64_t)divisor; /* truncates toward zero */
    }
    int64_t shifted = raw >> 1;

    r.quotient = (int32_t)(uint32_t)shifted;
    r.overflow = (raw > (int64_t)0x7FFFFFFF) || (raw < -(int64_t)0x80000000);
    return r;
}
