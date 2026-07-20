#ifndef HALMAT_VALUE_H
#define HALMAT_VALUE_H

#include <stdbool.h>
#include <stddef.h>
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

/* Inverse of halmat_scalar_to_double: repeatedly rescales by 16 until the
 * magnitude is hex-normalized (in [1/16, 1)), then quantizes to a 56-bit
 * fraction. Not a primary-source algorithm (READ's ASCII-to-internal
 * conversion isn't covered in the extracted AP-101S material) -- used
 * for READ-statement input parsing, where the source value only exists
 * as decimal text to begin with, so double is an unavoidable intermediate
 * representation rather than a precision compromise on already-hex data. */
halmat_scalar_t halmat_scalar_from_double(double value, bool double_precision);

/* Genuine IBM System/360-style hex-float arithmetic (AP-101S Software
 * Model PDF Sec. 8: characteristic comparison and alignment, fraction
 * add/subtract, postnormalization) -- not a native-double approximation.
 * Result precision is double if either operand is double, else single.
 * Known limitations (documented, not silently wrong): no guard-digit
 * extra precision during alignment (real hardware keeps a few extra
 * bits before the final truncation; this truncates immediately), and
 * characteristic overflow/underflow clamps to [0,127] rather than
 * raising the real ERROR CONDITION interrupt. */
halmat_scalar_t halmat_scalar_add(halmat_scalar_t a, halmat_scalar_t b);
halmat_scalar_t halmat_scalar_sub(halmat_scalar_t a, halmat_scalar_t b);
halmat_scalar_t halmat_scalar_negate(halmat_scalar_t a);

/* Characteristic addition/subtraction + a genuine (portable, no
 * __uint128_t/compiler-extension dependency -- this needs to build under
 * MSVC too, per Plan.md's cross-platform requirement) wide fraction
 * multiply/divide, per the AP-101S Software Model PDF Sec. 8's
 * documented algorithm. Division by a zero divisor is a real ERROR
 * CONDITION on real hardware (floating point divide exception, dividend
 * left unchanged) -- returns false rather than silently producing a
 * result; the caller should fail() loudly, not substitute a default. */
halmat_scalar_t halmat_scalar_multiply(halmat_scalar_t a, halmat_scalar_t b);
bool halmat_scalar_divide(halmat_scalar_t a, halmat_scalar_t b, halmat_scalar_t *out);

/* WRITE-statement/STOC-conversion fixed-width field, per class-2/STOC.md
 * (USA00309 Sec. 6.1.3): "sd.ddddddddE+-dd" (single, 8 fractional
 * digits) or the 17-fractional-digit double form. `s` is blank for
 * non-negative values (including 0.0), '-' for negative -- no other
 * zero-specific case. Writes exactly the field width into buf (must be
 * at least 24 bytes) and returns it via strlen(buf). */
void halmat_scalar_format(halmat_scalar_t s, char *buf, size_t buf_size);

#endif
