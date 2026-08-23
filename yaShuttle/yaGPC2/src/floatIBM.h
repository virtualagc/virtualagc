/* IBM hexadecimal floating-point (System/360-style), ported from
 * gpc/floatIBM.coffee. See that file's header comment for the format
 * background (excess-64 characteristic, base-16 fraction).
 *
 * The JS source represents the 56-bit fraction with the `Long` npm
 * package (two 32-bit halves) purely because JS numbers can't hold a
 * 56-64 bit integer exactly. C has a native 64-bit integer, so this port
 * uses a plain uint64_t for the fraction; the one place that needs a
 * genuine 112-bit product (mulE, a 56x56 multiply) uses a portable
 * 64x64->128 multiply built from four 32-bit partial products (the
 * "Hacker's Delight" mulhilo algorithm) instead of `__int128` — a GCC/
 * Clang extension MSVC doesn't have, and this port targets MSVC too —
 * see floatIBM.c's `mul64x64`. The bit-twiddling on the resulting
 * {hi,lo} pair is algebraically equivalent to the JS's 32-bit-split
 * arithmetic, verified fixture-by-fixture against the real
 * gpc/floatIBM.coffee rather than transcribed instruction-by-instruction,
 * since the two implementations necessarily take different paths to the
 * same bits.
 *
 * `unNormalizeToExp`, `obj32`, `obj64`, and the float-valued `gFrac()`
 * are defined in the source but never called from anywhere reachable by
 * `gpc run` (grep-verified) — omitted here.
 */
#ifndef YAGPC_FLOATIBM_H
#define YAGPC_FLOATIBM_H

#include <stdbool.h>
#include <stdint.h>

typedef struct {
    uint8_t data8[8]; /* big-endian; short-precision fits in data8[0..3] */
} FloatIBM;

typedef struct {
    FloatIBM result;
    int exc;
} FloatIBMResult;

typedef struct {
    int32_t result;
    int exc;
} FloatIBMCvfxResult;

/* POO 2.5.2 interrupt codes (same numeric values cpu.coffee's signal*
 * methods use). */
enum {
    FP_EXC_OK = 0,
    FP_EXC_SIGNIFICANCE = 0x0005,
    FP_EXC_EXP_UNDERFLOW = 0x0009,
    FP_EXC_CONVERT_OVERFLOW = 0x000A,
    FP_EXC_EXP_OVERFLOW = 0x000B,
    FP_EXC_DIVIDE = 0x000C,
};

FloatIBM fibm_zero(void);                       /* new FloatIBM() */
FloatIBM fibm_from32(uint32_t x);                /* FloatIBM.From32 */
FloatIBM fibm_from64(uint32_t x1, uint32_t x2);  /* FloatIBM.From64 */
FloatIBM fibm_from_float(double x);              /* new FloatIBM(x) */

uint32_t fibm_to32(const FloatIBM *f);
uint32_t fibm_to64x(const FloatIBM *f);
uint32_t fibm_to64y(const FloatIBM *f);
double fibm_to_float(const FloatIBM *f);

int fibm_gsign(const FloatIBM *f);          /* +1 or -1 */
void fibm_ssign(FloatIBM *f, int x);        /* x <= 0 -> negative */
int fibm_gexp(const FloatIBM *f);           /* unbiased characteristic */
void fibm_sexp(FloatIBM *f, int x);
uint64_t fibm_gfracbits(const FloatIBM *f); /* low 56 bits significant */
void fibm_sfrac(FloatIBM *f, uint64_t v);   /* stores low 56 bits of v */
void fibm_normalize(FloatIBM *f);

/* POO 8.11 hardware anomaly: false equality when the prealigned fraction
 * difference is exactly 0x8000000. Returns CC: 0=equal, 1=a>b, 3=a<b.
 * Used by CER/CE/CEDR/CED. */
int fibm_compe_anomalous(const FloatIBM *x, const FloatIBM *y);

FloatIBMResult fibm_addE(const FloatIBM *x, const FloatIBM *y);
FloatIBMResult fibm_subE(const FloatIBM *x, const FloatIBM *y);
FloatIBM fibm_compE(const FloatIBM *x, const FloatIBM *y); /* subE(...).result */

FloatIBMResult fibm_mulE(const FloatIBM *x, const FloatIBM *y);
FloatIBMResult fibm_mulQeE(const FloatIBM *x, const FloatIBM *y);
/* The AP-101S's own extended multiply, as distinct from fibm_mulQeE's
 * AP-101 C/M one.  gpc selects between them by machine model (fp:'S'
 * vs fp:'B'); yaGPC2 is an AP-101S, so this is the one MEDR/MED use. */
FloatIBMResult fibm_mulQeS(const FloatIBM *x, const FloatIBM *y);
FloatIBMResult fibm_divE(const FloatIBM *x, const FloatIBM *y);

FloatIBMCvfxResult fibm_cvfx(const FloatIBM *x);
FloatIBM fibm_cvfl(int32_t x);

#endif
