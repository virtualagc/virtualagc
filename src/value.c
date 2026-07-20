#include "value.h"

#include <math.h>

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
