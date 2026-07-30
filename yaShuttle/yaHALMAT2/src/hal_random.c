#include "hal_random.h"

/* halmat_scalar_t's own {msw,lsw} pair IS the IBM hex-float wire format
 * (value.h's own header comment) -- these helpers manipulate it directly
 * (sign bit / 7-bit excess-64 characteristic / 56-bit hex fraction split
 * across msw's low 24 bits + all of lsw), the same field layout yaGPC2's
 * own floatIBM.c operates on via its `data8[8]` byte array. Ported
 * 1:1 from that file (fibm_gsign/ssign/gexp/sexp/gfracbits/sfrac/
 * normalize/addE/subE/mulQeE), scoped to exactly the operations RANDOM.asm's
 * own RANU/RANDG entry points use -- not a general-purpose port of
 * floatIBM.c's full API (no mulE/divE/cvfx/compE needed here). */

#define FRAC56_MASK (((uint64_t)1 << 56) - 1)
#define FRAC56_TOP_HEX_MASK ((uint64_t)0xF << 52) /* bits 52-55: top hex digit of a 56-bit fraction */

static int hrfp_gsign(const halmat_scalar_t *f) { return (f->msw & 0x80000000u) ? -1 : 1; }

static void hrfp_ssign(halmat_scalar_t *f, int x) {
    if (x <= 0) f->msw |= 0x80000000u;
    else f->msw &= 0x7FFFFFFFu;
}

static int hrfp_gexp(const halmat_scalar_t *f) { return (int)((f->msw >> 24) & 0x7Fu) - 64; }

static void hrfp_sexp(halmat_scalar_t *f, int x) {
    f->msw = (f->msw & 0x80FFFFFFu) | (((uint32_t)(x + 64) & 0x7Fu) << 24);
}

static uint64_t hrfp_gfracbits(const halmat_scalar_t *f) {
    return ((uint64_t)(f->msw & 0x00FFFFFFu) << 32) | f->lsw;
}

static void hrfp_sfrac(halmat_scalar_t *f, uint64_t v) {
    v &= FRAC56_MASK;
    f->msw = (f->msw & 0xFF000000u) | (uint32_t)((v >> 32) & 0x00FFFFFFu);
    f->lsw = (uint32_t)(v & 0xFFFFFFFFu);
}

static void hrfp_normalize(halmat_scalar_t *f) {
    uint64_t frac = hrfp_gfracbits(f);
    if (frac == 0) return;
    while (!(frac & FRAC56_TOP_HEX_MASK)) {
        frac <<= 4;
        hrfp_sexp(f, hrfp_gexp(f) - 1);
    }
    hrfp_sfrac(f, frac);
}

static halmat_scalar_t hrfp_zero(void) {
    halmat_scalar_t z;
    z.double_precision = true;
    z.msw = 0;
    z.lsw = 0;
    return z;
}

/* CVFL F0,R6 (32-bit integer to short IBM hex float) -- exposed (not
 * static) for reuse by hal_transcendental.c's own RUNASM ports (LOG.asm
 * etc., id 51/task 100), which use the exact same real CVFL instruction
 * this file already implements for RANDOM.asm's own RANU. */
halmat_scalar_t hrfp_cvfl(int32_t x) {
    if (x == 0) return hrfp_zero();
    halmat_scalar_t res = hrfp_zero();
    uint32_t mag;
    bool neg = (x < 0);
    if (neg) mag = ((uint32_t)x ^ 0xFFFFFFFFu) + 1u;
    else mag = (uint32_t)x;
    /* data8[1..3] = mag's top 3 bytes, data8[4] = mag's low byte --
     * i.e. msw's low 24 bits = mag>>8, lsw's top byte = mag's own low
     * byte, lsw's remaining 3 bytes stay zero. */
    res.msw = (mag >> 8) & 0x00FFFFFFu;
    res.lsw = (mag & 0xFFu) << 24;
    if (neg) hrfp_ssign(&res, -1);
    hrfp_sexp(&res, 4);
    hrfp_normalize(&res);
    return res;
}

/* Shared add/subtract core (ported from floatIBM.c's addsubE +
 * pack_addsub_result) -- exponent-align, add-or-subtract magnitudes,
 * renormalize. Exponent overflow/underflow (POO interrupt conditions on
 * real hardware) are not signaled here -- RANU/RANDG's own fixed value
 * ranges never approach either, matching the reference implementation's
 * own choice to only ever consult `.result`, never `.exc`, at its own
 * two call sites. */
static halmat_scalar_t hrfp_addsub(const halmat_scalar_t *x_in, const halmat_scalar_t *y_in, bool subtract_b) {
    bool a_sign = hrfp_gsign(x_in) < 0;
    int a_exp = hrfp_gexp(x_in) + 64;
    uint64_t a_mant = hrfp_gfracbits(x_in);
    bool b_sign = hrfp_gsign(y_in) < 0;
    int b_exp = hrfp_gexp(y_in) + 64;
    uint64_t b_mant = hrfp_gfracbits(y_in);
    if (subtract_b) b_sign = !b_sign;

    bool a_zero = (a_mant == 0);
    bool b_zero = (b_mant == 0);

    if (!b_zero && !a_zero) {
        if (a_exp == b_exp) {
            a_mant <<= 4;
            b_mant <<= 4;
        } else if (a_exp < b_exp) {
            int shift = b_exp - a_exp - 1;
            a_exp = b_exp;
            if (shift > 0) {
                a_mant = (shift >= 14) ? 0 : (a_mant >> (shift * 4));
                if (a_mant == 0) {
                    a_sign = b_sign;
                    a_mant = b_mant;
                    halmat_scalar_t r = hrfp_zero();
                    if (a_sign) hrfp_ssign(&r, -1);
                    hrfp_sexp(&r, a_exp - 64);
                    hrfp_sfrac(&r, a_mant);
                    return r;
                }
            }
            b_mant <<= 4;
        } else {
            int shift = a_exp - b_exp - 1;
            if (shift > 0) {
                b_mant = (shift >= 14) ? 0 : (b_mant >> (shift * 4));
                if (b_mant == 0) {
                    halmat_scalar_t r = hrfp_zero();
                    if (a_sign) hrfp_ssign(&r, -1);
                    hrfp_sexp(&r, a_exp - 64);
                    hrfp_sfrac(&r, a_mant);
                    return r;
                }
            }
            a_mant <<= 4;
        }

        uint64_t r_mant;
        bool r_sign;
        if (a_sign == b_sign) {
            r_sign = a_sign;
            r_mant = a_mant + b_mant;
        } else if (a_mant == b_mant) {
            return hrfp_zero();
        } else if (a_mant > b_mant) {
            r_sign = a_sign;
            r_mant = a_mant - b_mant;
        } else {
            r_sign = b_sign;
            r_mant = b_mant - a_mant;
        }

        if (r_mant & ((uint64_t)0xF << 60)) {
            r_mant >>= 8;
            a_exp += 1;
        } else if (r_mant & ((uint64_t)0xF << 56)) {
            r_mant >>= 4;
        } else {
            a_exp -= 1;
            if (r_mant == 0) return hrfp_zero();
            while (!(r_mant & FRAC56_TOP_HEX_MASK)) {
                r_mant <<= 4;
                a_exp -= 1;
            }
        }

        halmat_scalar_t r = hrfp_zero();
        if (r_sign) hrfp_ssign(&r, -1);
        hrfp_sexp(&r, a_exp - 64);
        hrfp_sfrac(&r, r_mant);
        return r;
    }

    if (b_zero && a_zero) return hrfp_zero();
    if (a_zero) {
        a_sign = b_sign;
        a_exp = b_exp;
        a_mant = b_mant;
    }
    /* needsRenorm path (pack_addsub_result's own second branch): one
     * operand was zero, so the other passes through unrenormalized
     * (already normalized on entry, by construction). */
    halmat_scalar_t r = hrfp_zero();
    if (a_sign) hrfp_ssign(&r, -1);
    hrfp_sexp(&r, a_exp - 64);
    hrfp_sfrac(&r, a_mant);
    return r;
}

/* AED/SED (Add/Subtract Extended Double) -- exposed (not static) for reuse
 * by hal_transcendental.c's own RUNASM ports (EXP.asm etc., id 51/100),
 * which need the exact same guard-digit-free extended-precision add/
 * subtract core real AP-101S hardware uses for these two instructions. */
halmat_scalar_t hrfp_addE(const halmat_scalar_t *x, const halmat_scalar_t *y) { return hrfp_addsub(x, y, false); }
halmat_scalar_t hrfp_subE(const halmat_scalar_t *x, const halmat_scalar_t *y) { return hrfp_addsub(x, y, true); }

static void hrfp_round_once(uint64_t *mant, int *biased_exp) {
    uint64_t rounded = *mant + ((uint64_t)1 << 24);
    if (rounded & ((uint64_t)1 << 56)) {
        rounded >>= 4;
        *biased_exp += 1;
    }
    *mant = rounded & ~(((uint64_t)1 << 25) - 1);
}

/* MED (Multiply Extended, rounded) -- ported from floatIBM.c's own
 * fibm_mulQeE. Unlike a plain fibm_mulE (exact 56x56 product), this
 * rounds each operand's own fraction to 31 significant bits first (the
 * real MED instruction's own documented behavior), which is what
 * RANDOM.asm's own RANU actually uses (`MED F0,=X'3D20...'`) -- using
 * the exact-product mulE here instead would NOT reproduce real
 * hardware's own rounding error, breaking bit-exactness. */
halmat_scalar_t hrfp_mulQeE(const halmat_scalar_t *x, const halmat_scalar_t *y) {
    uint64_t x_frac = hrfp_gfracbits(x);
    uint64_t y_frac = hrfp_gfracbits(y);
    if (x_frac == 0 || y_frac == 0) return hrfp_zero();

    int result_sign = hrfp_gsign(x) * hrfp_gsign(y);
    int x_exp = hrfp_gexp(x) + 64;
    int y_exp = hrfp_gexp(y) + 64;
    while (!(x_frac & FRAC56_TOP_HEX_MASK)) { x_frac <<= 4; x_exp -= 1; }
    while (!(y_frac & FRAC56_TOP_HEX_MASK)) { y_frac <<= 4; y_exp -= 1; }

    hrfp_round_once(&x_frac, &x_exp);
    hrfp_round_once(&y_frac, &y_exp);

    /* x_exp/y_exp > 127 (real exponent overflow) is not reachable for
     * RANU's own fixed inputs -- not specially handled here, matching
     * the "no exception signaling needed" scope note above. */

    uint64_t a31 = x_frac >> 25;
    uint64_t b31 = y_frac >> 25;
    uint64_t prod = a31 * b31;
    uint64_t target = prod >> 6;

    if (target == 0) return hrfp_zero();

    uint64_t r_mant;
    int r_exp;
    if (target & FRAC56_TOP_HEX_MASK) {
        r_mant = target & FRAC56_MASK;
        r_exp = x_exp + y_exp - 64;
    } else {
        r_mant = (prod >> 2) & FRAC56_MASK;
        r_exp = x_exp + y_exp - 65;
    }

    halmat_scalar_t result = hrfp_zero();
    if (result_sign < 0) hrfp_ssign(&result, -1);
    hrfp_sexp(&result, r_exp - 64);
    hrfp_sfrac(&result, r_mant);
    return result;
}

/* ME/MER (Multiply Extended, exact -- unrounded, unlike MED's own
 * round-to-31-bits-per-operand behavior) -- ported from floatIBM.c's own
 * fibm_mulE. LOG.asm's own trace (task 100/id 51) confirms this is an
 * EXACT product truncated to 56 bits with no guard digit (same "no
 * guard digit" convention this project's own value.c scalar add/sub
 * already documents for AED/SED) -- verified via `ME F2,LOGE2` with F2
 * holding exactly 1.0, which reproduces LOGE2's own bit pattern exactly,
 * something MulQeE's own operand-rounding would NOT do. */
halmat_scalar_t hrfp_mulE(const halmat_scalar_t *x, const halmat_scalar_t *y) {
    uint64_t x_frac = hrfp_gfracbits(x);
    uint64_t y_frac = hrfp_gfracbits(y);
    if (x_frac == 0 || y_frac == 0) return hrfp_zero();

    int result_sign = hrfp_gsign(x) * hrfp_gsign(y);
    int x_exp = hrfp_gexp(x) + 64;
    int y_exp = hrfp_gexp(y) + 64;
    while (!(x_frac & FRAC56_TOP_HEX_MASK)) { x_frac <<= 4; x_exp -= 1; }
    while (!(y_frac & FRAC56_TOP_HEX_MASK)) { y_frac <<= 4; y_exp -= 1; }

    /* x_frac/y_frac each occupy [2**52,2**56) once normalized -- their
     * exact product occupies [2**104,2**112), i.e. either 27 or 28 hex
     * digits, one nibble-alignment away from mulQeE's own analogous
     * two-branch normalization check, just scaled up to the full
     * 112-bit exact product instead of mulQeE's own reduced 62-bit
     * rounded one. */
    unsigned __int128 prod = (unsigned __int128)x_frac * (unsigned __int128)y_frac;

    uint64_t r_mant;
    int r_exp;
    if (prod & (((unsigned __int128)0xF) << 108)) {
        r_mant = (uint64_t)(prod >> 56) & FRAC56_MASK;
        r_exp = x_exp + y_exp - 64;
    } else {
        r_mant = (uint64_t)(prod >> 52) & FRAC56_MASK;
        r_exp = x_exp + y_exp - 65;
    }
    if (r_mant == 0) return hrfp_zero();

    halmat_scalar_t result = hrfp_zero();
    if (result_sign < 0) hrfp_ssign(&result, -1);
    hrfp_sexp(&result, r_exp - 64);
    hrfp_sfrac(&result, r_mant);
    return result;
}

/* DER/DE (Divide Extended) -- ported from floatIBM.c's own fibm_divE.
 * Same "no guard digit" truncating convention as hrfp_mulE above,
 * mirroring the real hardware's own documented behavior (this project's
 * value.c scalar add/sub comment). Divide-by-zero is not handled (not
 * reachable by any of this file's own callers, whose fixed algorithms
 * never divide by a value that can legitimately be zero). */
halmat_scalar_t hrfp_divE(const halmat_scalar_t *x, const halmat_scalar_t *y) {
    uint64_t x_frac = hrfp_gfracbits(x);
    uint64_t y_frac = hrfp_gfracbits(y);
    if (x_frac == 0) return hrfp_zero();

    int result_sign = hrfp_gsign(x) * hrfp_gsign(y);
    int x_exp = hrfp_gexp(x) + 64;
    int y_exp = hrfp_gexp(y) + 64;
    while (!(x_frac & FRAC56_TOP_HEX_MASK)) { x_frac <<= 4; x_exp -= 1; }
    while (!(y_frac & FRAC56_TOP_HEX_MASK)) { y_frac <<= 4; y_exp -= 1; }

    /* Scale the dividend up by 56 bits before dividing so the quotient
     * itself retains 56 bits of significance (x_frac/y_frac alone would
     * be < 16, losing almost all precision to integer truncation). Since
     * each of x_frac/y_frac's own leading hex digit can independently be
     * anywhere in [1,16), the raw quotient can land up to a couple of
     * nibbles away from properly normalized in either direction -- renor-
     * malize with the same kind of nibble-at-a-time loop hrfp_normalize
     * itself uses, rather than assuming a single fixed-size adjustment
     * the way hrfp_mulE's own two-branch check can (multiply's operand
     * ranges are tighter). */
    unsigned __int128 dividend = (unsigned __int128)x_frac << 56;
    uint64_t quot = (uint64_t)(dividend / y_frac);
    int r_exp = x_exp - y_exp + 64;
    while (quot >> 56) { quot >>= 4; r_exp += 1; }
    while (quot != 0 && !(quot & FRAC56_TOP_HEX_MASK)) { quot <<= 4; r_exp -= 1; }
    uint64_t r_mant = quot & FRAC56_MASK;
    if (r_mant == 0) return hrfp_zero();

    halmat_scalar_t result = hrfp_zero();
    if (result_sign < 0) hrfp_ssign(&result, -1);
    hrfp_sexp(&result, r_exp - 64);
    hrfp_sfrac(&result, r_mant);
    return result;
}

/* RUNASM/RANDOM.asm's RANU, shared by RANDOM and RANDOMG alike. */
static halmat_scalar_t ranu_raw(hal_random_state_t *rng, hal_fpu_state_t *fpu) {
    /* M R6,SEED ; SRDA R6,1 ; LR ... -- not a plain S/360 signed
     * multiply on this CPU (yaGPC2's own exec_M routes even-register
     * multiplies through a Q31 fixed-point path that left-shifts by 1
     * bit before the SRDA immediately undoes it) -- net effect across
     * all three real instructions is a plain truncating 32-bit multiply:
     * seed <- low 32 bits of the exact 65539*seed product (see this
     * project's own yagpc2-yahalmat2-issues.db writeup, id 36, for the
     * full derivation this comment summarizes). */
    int64_t product = (int64_t)65539 * (int64_t)rng->seed;
    int32_t r6 = (int32_t)((uint64_t)product & 0xFFFFFFFFu);
    if (r6 < 0) {
        /* S R6,NEGMAX ; NEGMAX=X'80000000' -- signed 32-bit subtract,
         * two's-complement wraparound fixup for a negative product. */
        r6 = (int32_t)((uint32_t)r6 - 0x80000000u);
    }
    rng->seed = r6; /* ST R6,SEED */

    halmat_scalar_t f0 = hrfp_cvfl(r6); /* CVFL F0,R6 -- only ever stores F0's own half */
    /* MED F0,=X'3D20000000000000' reads F0:F1 as one extended pair --
     * F0 freshly from CVFL above, F1 still whatever the shared FPU
     * state's own `f1` last left there (hal_fpu.h's own header comment).
     * X'3D200000' == 2^-15 in this same IBM hex-float encoding
     * (confirmed against yaGPC2's own floatIBM.c, not by hand-decoding
     * the source's own "2**-31" comment, which describes a different
     * conceptual framing than the literal bit pattern actually stored). */
    halmat_scalar_t v1;
    v1.double_precision = true;
    v1.msw = f0.msw;
    v1.lsw = fpu->f1;
    halmat_scalar_t v2;
    v2.double_precision = true;
    v2.msw = 0x3D200000u;
    v2.lsw = 0x00000000u;
    halmat_scalar_t result = hrfp_mulQeE(&v1, &v2);
    fpu->f1 = result.lsw; /* MED sets F1 too -- carries into the next draw */
    return result;
}

void hal_random_init(hal_random_state_t *rng) {
    rng->seed = 1435; /* SEED DC F'1435' */
}

halmat_scalar_t hal_random_next(hal_random_state_t *rng, hal_fpu_state_t *fpu) {
    return ranu_raw(rng, fpu);
}

halmat_scalar_t hal_randomg_next(hal_random_state_t *rng, hal_fpu_state_t *fpu) {
    /* SEDR F2,F2 -- zeroes the accumulator via self-subtraction (not a
     * literal 0.0 load; mathematically identical either way -- and,
     * being a self-subtract, this is exactly-zero regardless of
     * whatever F3 held coming in, so no shared-state read is needed
     * here). */
    halmat_scalar_t acc = hrfp_zero();
    for (int i = 0; i < 12; i++) {
        /* BAL R5,RANU ; AEDR F2,F0 -- "LOOP TWELVE TIMES". */
        halmat_scalar_t ru = ranu_raw(rng, fpu);
        acc = hrfp_addE(&acc, &ru);
    }
    /* SED F2,=D'6.0' -- Irwin-Hall recentering to mean 0, variance 1.
     * 6.0's own exact IBM-hex-float bit pattern (0x41600000/0x00000000
     * -- characteristic 65, fraction 0x6, same pattern this project's
     * own existing 3.0-literal fixture already confirms empirically for
     * the encoding convention) is hardcoded here rather than routed
     * through halmat_scalar_from_double(6.0, true), since that function
     * lives in value.c (a distinct translation unit this self-contained
     * module deliberately doesn't depend on) and 6.0's own bit pattern
     * is a fixed compile-time constant either way -- not a genuine
     * runtime conversion. */
    halmat_scalar_t six;
    six.double_precision = true;
    six.msw = 0x41600000u;
    six.lsw = 0x00000000u;
    halmat_scalar_t result = hrfp_subE(&acc, &six);
    /* LER F0,F2 ; LER F1,F3 -- the original source's own "FAKE D.P.
     * LOAD" comment: repackages the Gaussian result into F0:F1 as
     * RANDOMG's own declared return value, and as a side effect
     * overwrites the shared FPU state's own `f1` with this result's own
     * low word -- exactly the same leakage every other RTL routine
     * shares (hal_fpu.h's own header comment explains why this matters
     * for whatever RANDOM/RANDOMG/EXP/LOG/... call comes next). */
    fpu->f1 = result.lsw;
    return result;
}
