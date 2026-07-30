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

/* Fidelity scope note (DB id 51, yagpc2-yahalmat2-issues.db, corrected
 * 2026-07-28 after an earlier pass wrongly characterized the project as
 * "using native IEEE double throughout"): that claim didn't survive
 * contact with the actual code. halmat_scalar_add/sub/multiply/divide
 * below ARE genuine IBM hex-float arithmetic (characteristic/fraction,
 * hex postnormalization) -- confirmed via direct call-site inspection,
 * not just this header comment -- and are wired into every core SCALAR/
 * MATRIX/VECTOR opcode. The real, narrower situation: roughly 50 call
 * sites across the interpreter (transcendental/special functions --
 * SIN/LOG/SQRT/ARCTAN/etc. before their own real RUNASM ports landed,
 * MATRIX inversion's own N>4 general path, RANDOM, DFOR/CFOR loop
 * control, READ decimal parsing) go through a native-double
 * intermediate instead -- a reasonable choice absent a primary-source
 * hex-float RTL algorithm for most of these, and shrinking over time as
 * more RTL routines get ported bit-exactly (see hal_transcendental.c/
 * hal_matrix.c). Keep this distinction in mind when characterizing the
 * project's own floating-point fidelity: "hex-float vs. IEEE double" is
 * not an all-or-nothing property of the interpreter as a whole. */
halmat_scalar_t halmat_scalar_zero(bool double_precision);
halmat_scalar_t halmat_scalar_from_ibm_words(uint32_t msw, uint32_t lsw, bool double_precision);

/* Exact for any value representable in the target precision's fraction
 * width (6 hex digits short / 14 long); larger magnitudes lose low-order
 * hex digits, matching real hardware's limited significance rather than
 * being a bug -- HAL/S single precision is documented as ~6.2 decimal
 * digits (AP-101S Software Model PDF Sec. 8.2). */
halmat_scalar_t halmat_scalar_from_integer(int32_t value, bool double_precision);

/* Rounds to nearest, ties away from zero (confirmed against the
 * reference yaHALMAT emulator, class-6/STOI.md -- NOT truncation).
 * Real HAL/S treats a non-representable SCALAR->INTEGER conversion as a
 * runtime ERROR CONDITION (see class-6/STOI.md) rather than silently
 * producing an out-of-range result; that check isn't implemented here
 * yet since no fixture exercises the failure path. */
int32_t halmat_scalar_to_integer(halmat_scalar_t s);

/* Same rounding/tie-breaking rule as halmat_scalar_to_integer, but
 * WITHOUT its CVFX-interrupt 32767/-32767 clamp -- clamps only at true
 * int32_t bounds (to keep the cast defined), the full range a genuine
 * 32-bit register value can hold. For WRITE-argument INTEGER-format
 * display of a value the *compiler itself* already routed through a
 * wide (32-bit #QIOUT-equivalent `L`) load rather than a real runtime
 * CVFX conversion -- confirmed via a real HALSFC Pass 2 listing
 * (integer_exponentiation_overflow_needs_fcos; 052-TABLE.hal's
 * `WRITE(6) N, 2**(N-1), ...`, N a compile-time constant so `2**(N-1)`
 * is entirely constant-folded): every literal that doesn't fit 16 bits
 * loads via a full-word `L` into #QIOUT, never a CVFX at all, so there
 * is no real interrupt for halmat_scalar_to_integer's own clamp to be
 * modeling here -- applying it anyway silently truncated every such
 * WRITE argument to 32767 regardless of the compiler's own intent. */
int32_t halmat_scalar_to_integer_wide(halmat_scalar_t s);

/* Same rounding/clamping as halmat_scalar_to_integer_wide, but for an
 * already-decoded double rather than a halmat_scalar_t -- needed for a
 * QUAL_LIT literal's own full-precision value (halmat_literal_t's own
 * `numeric` field, decoded from msw+lsw unconditionally regardless of
 * LIT_FIXED/LIT_DOUBLE), which is NOT the same value as resolve_
 * operand's own a.scalar for that same literal (halmat_scalar_from_
 * ibm_words zeroes lsw whenever the litfile's type byte isn't literally
 * LIT_DOUBLE -- correct for ordinary SCALAR-context resolution, but not
 * a reliable single-vs-double signal for INTEGER-context display; see
 * OP_XXAR's own `integer_class_scalar` comment). */
int32_t halmat_double_to_integer_wide(double raw);

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
 * Alignment genuinely retains one extra hex digit of the smaller
 * operand's own fraction through the add/subtract itself (id 40,
 * yagpc2-yahalmat2-issues.db -- ported from hal_random.c's own
 * hrfp_addsub/floatIBM.c's addsubE, matching real hardware's own AE/AED
 * algorithm exactly), NOT a same-pass immediate truncating shift the
 * way an earlier version of this function used -- confirmed via id 40's
 * own recorded repro that this specific gap, not F1-chain state-
 * plumbing, was the actual source of a real (if narrow) divergence from
 * yaGPC2 for scalar arithmetic sandwiched between RANDOM/RANDOMG calls.
 * Known remaining limitation (documented, not silently wrong):
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
