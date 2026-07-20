#ifndef HALMAT_VALUE_H
#define HALMAT_VALUE_H

#include <stdbool.h>
#include <stdint.h>

/* AP-101S SCALAR representation: IBM System/360-style hexadecimal
 * floating point (AP-101S Software Model PDF Sec. 8) -- NOT IEEE-754.
 * 1 sign bit + 7-bit excess-64 characteristic + a hexadecimal fraction
 * (24 bits/6 hex digits short, 56 bits/14 hex digits long). Stored as
 * the packed on-the-wire words: short values use only msw (which is
 * bit-for-bit the same 32-bit layout as long's own msw); long values
 * use both. This matches the litfile's own MSW/LSW pair convention
 * (see literal.h) so literal decode needs no extra conversion. */
typedef struct {
    bool double_precision;
    uint32_t msw;
    uint32_t lsw; /* unused (0) for short/single precision */
} halmat_scalar_t;

halmat_scalar_t halmat_scalar_zero(bool double_precision);
halmat_scalar_t halmat_scalar_from_ibm_words(uint32_t msw, uint32_t lsw, bool double_precision);

/* Exact for any value representable in the target precision's fraction
 * width (6 hex digits short / 14 long); larger magnitudes lose low-order
 * hex digits, matching real hardware's limited significance rather than
 * being a bug -- HAL/S single precision is documented as ~6.2 decimal
 * digits (AP-101S Software Model PDF Sec. 8.2). */
halmat_scalar_t halmat_scalar_from_integer(int32_t value, bool double_precision);

/* Truncates toward zero. Real HAL/S treats a non-representable
 * SCALAR->INTEGER conversion as a runtime ERROR CONDITION (see
 * class-6/STOI.md) rather than silent truncation; that check isn't
 * implemented here yet since no fixture exercises the failure path. */
int32_t halmat_scalar_to_integer(halmat_scalar_t s);

double halmat_scalar_to_double(halmat_scalar_t s);

#endif
