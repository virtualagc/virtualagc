/*
 * License:     The author (Donald Schmidt) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    ibmFloat.h
 * Purpose:     Header for ibmFloat.c — IBM hex floating-point helpers
 *              Based on the floating point logic in the
 *              Hyperion/Hercules IBM 390 & z/Series emulator:
 *                  https://github.com/hercules-390/hyperion/blob/master/float.c
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 */

#ifndef IBM_FLOAT_H
#define IBM_FLOAT_H

#include <stddef.h>
#include <stdint.h>
#include <assert.h>

// NOTE:
//       IBM floating point exponents are base-16 (hex).  Standard IEEE754
//       implementations (like C's float/double types) use base-2.  Because
//       it's hex, you'll see a lot of 4-bit ops to handle hexadecimal digits.
//
//       IEEE754 double's have 53 mantissa bits, and IBM dp has 56.
//
// Format constants:
//
#define IBM_DP_MANT_BITS         56     // mantissa width in bits
#define IBM_DP_MANT_HEXDIGITS    14     // = MANT_BITS / 4
#define IBM_DP_EXP_BIAS          64     // characteristic bias
#define IBM_DP_EXP_MAX           0x7F   // max biased exponent

// Bit masks on the 64-bit packed form:
//
#define IBM_DP_SIGN_BIT          0x8000000000000000ULL
#define IBM_DP_MAGNITUDE_MASK    0x7FFFFFFFFFFFFFFFULL  // ~SIGN_BIT
#define IBM_DP_MANT_MASK         0x00FFFFFFFFFFFFFFULL  // bits 0..55
#define IBM_DP_EXP_FIELD_MASK    0x7F00000000000000ULL  // bits 56..62

// During add/sub, mantissas are temporarily widened to 60 bits with a
// 4-bit guard digit at the bottom.  These masks identify the top hex
// digit of the 56-bit and 60-bit forms (used to detect normalization
// status), and the overflow region above the 60-bit field.
#define IBM_DP_TOP_HEX_56        0x00F0000000000000ULL  // bits 52..55
#define IBM_DP_TOP_HEX_60        0x0F00000000000000ULL  // bits 56..59
#define IBM_DP_OVERFLOW_60       0xF000000000000000ULL  // bits 60..63

// Overflow sentinel returned when a result exceeds the representable
// range: as a packed uint64 with sign=1, exp=0x7F, mant=0.  The (msw,
// lsw) form has msw = 0xff000000 and lsw = 0.
#define IBM_DP_OVERFLOW_PACKED   0xFF00000000000000ULL
#define IBM_DP_OVERFLOW_MSW      0xff000000U

// Field accessors
//
#define IBM_DP_SIGN(packed)  ((uint8_t)(((packed) >> 63) & 1u))
#define IBM_DP_EXP(packed)   ((int)(((packed) >> IBM_DP_MANT_BITS) \
                                    & IBM_DP_EXP_MAX))
#define IBM_DP_MANT(packed)  ((packed) & IBM_DP_MANT_MASK)

// True zero per S/360 semantics: BOTH mantissa AND biased exponent are
// zero.  An operand like FIXER (mant=0, exp=0x4E) is NOT zero — it has a
// nonzero exponent and participates in alignment.  Sign bit is ignored
// (0x8000000000000000 is "negative zero" but still numerically zero).
#define IBM_DP_IS_TRUE_ZERO(packed) (((packed) & IBM_DP_MAGNITUDE_MASK) == 0)

#define IBM_DP_PACK(sign, exp, mant)                              \
    (((uint64_t)((sign) & 1u) << 63)                              \
   | ((uint64_t)((exp) & IBM_DP_EXP_MAX) << IBM_DP_MANT_BITS)     \
   | ((mant) & IBM_DP_MANT_MASK))

#define IBM_DP_RENORMALIZE_56(mant, exp) do {                     \
    assert(mant !=0 && "IBM_DP_RENORMALIZE_56: mant == 0");       \
    while (((mant) & IBM_DP_TOP_HEX_56) == 0) {                   \
        (mant) <<= 4;                                             \
        (exp)  -= 1;                                              \
    }                                                             \
} while (0)

// Conversion to/from C double:
//  prefer ibm_dp_from_string for decimal literals to preserve all 56 bits.
void   ibm_dp_from_double(uint32_t *msw, uint32_t *lsw, double d);
double ibm_dp_to_double(uint32_t msw, uint32_t lsw);

// Conversion from decimal string:
//  based on XXXTOD.bal
void ibm_dp_from_string(const char *s, uint32_t *msw, uint32_t *lsw);

// Conversion to decimal string, direct from the IBM hex DP without
// going through IEEE754:
void ibm_dp_to_string(uint32_t msw, uint32_t lsw,
                      int sig_digits, int pad_to_digits,
                      char *out, size_t out_len);

// HAL/S MONITOR(12)-style formatting:
//   zero (mantissa==0, including IBM overflow sentinel) -> " 0.0"
//   positive -> " D.DDD...DDE±NN"   (leading space)
//   negative -> "-D.DDD...DDE±NN"
// precision==0 selects SP layout (7 sig digits, 6 frac).
// Anything else selects DP (16 sig digits, 15 frac).
void ibm_dp_to_hal_string(uint32_t msw, uint32_t lsw, int precision,
                          char *out, size_t out_len);

uint64_t ibm_dp_add(uint64_t a, uint64_t b);
uint64_t ibm_dp_sub(uint64_t a, uint64_t b);
uint64_t ibm_dp_mul(uint64_t a, uint64_t b);
uint64_t ibm_dp_div(uint64_t a, uint64_t b);
uint64_t ibm_dp_addsub(uint64_t a, uint64_t b,
                       int subtract_b, int normalize);

#endif // IBM_FLOAT_H
