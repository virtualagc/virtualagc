/* AP-101S Q31/Q15 fixed-point fractional arithmetic, ported from
 * gpc/q31.coffee. See that file for the fractional-representation
 * background (IBM-75-C67-001 §2.2.2) — S.FFF...F with the binary point
 * immediately after the sign bit. */
#ifndef YAGPC_Q31_H
#define YAGPC_Q31_H

#include <stdbool.h>
#include <stdint.h>

typedef struct {
    uint32_t hi;
    uint32_t lo;
    bool overflow;
} Q31MulResult;

typedef struct {
    int32_t result;
    bool overflow;
} Q15MulResult;

typedef struct {
    int32_t quotient;
    bool overflow;
} Q31DivResult;

/* Q31 fullword multiply: two signed 32-bit fractions -> 64-bit fraction. */
Q31MulResult q31_mul32(int32_t a, int32_t b);

/* Q15 halfword multiply: two signed 16-bit fractions -> 32-bit fraction. */
Q15MulResult q15_mul(int32_t a, int32_t b);

/* Q31 fullword divide: 64-bit fraction (hi:lo) / 32-bit fraction. */
Q31DivResult q31_div(int32_t hi, int32_t lo, int32_t divisor);

#endif
