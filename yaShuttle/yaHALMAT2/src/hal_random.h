#ifndef HALMAT_HAL_RANDOM_H
#define HALMAT_HAL_RANDOM_H

#include "value.h"
#include "hal_fpu.h"

/* Bit-exact replication of the real AP-101S runtime library's
 * RUNASM/RANDOM.asm -- HAL/S's RANDOM (rectangular [0,1) deviate) and
 * RANDOMG (Irwin-Hall-approximated Gaussian) built-ins (class-0/BFNC.md
 * selectors 42/51, USA003088.txt Sec. 9397/9399) -- confirmed
 * deterministic (fixed SEED=1435 baked into the object code, no wall-
 * clock/hardware entropy) and independently verified bit-for-bit against
 * yaGPC2's own real execution trace (yahalmat2_random_not_deterministic,
 * yagpc2-yahalmat2-issues.db). Ported from yaGPC2's own reference-impls/
 * hal_random.c (itself built on yaGPC2's floatIBM.c), adapted to
 * construct a halmat_scalar_t directly rather than round-tripping
 * through a native IEEE double the way that standalone reference does --
 * halmat_scalar_t's own {msw,lsw} pair is already bit-for-bit the same
 * IBM hex-float wire layout RANDOM.asm's own floating-point registers
 * use, so this avoids an extra (lossy) double-precision conversion step
 * the reference's own public double-returning API needed only because it
 * had no equivalent hex-float-native output type to hand back instead.
 *
 * Both functions share one persistent generator state (hal_random_state_t,
 * threaded explicitly rather than a hidden static, since halmat_state_t
 * itself owns it -- see interp.c's own use) -- the exact value sequence
 * either one returns depends on the exact sequence of calls made to
 * both, bit-for-bit, exactly as it does on real hardware.
 *
 * RANU's own CVFL instruction leaves a second, less obvious piece of
 * persistent state behind: CVFL only ever stores into the paired
 * register's high half, never its low half, so the immediately
 * following extended-precision multiply reads whatever the low half
 * was already holding from some earlier floating-point op. This is no
 * longer this struct's own private concern -- it's exactly the same
 * odd-register-companion leakage every OTHER ported RTL routine shares
 * out of the one real CPU register file, so it's modeled via the
 * caller-supplied hal_fpu_state_t (hal_fpu.h) instead of a field here;
 * hal_random_next/hal_randomg_next both read/write its own `f1`. */
typedef struct {
    int32_t seed; /* SEED DC F'1435' -- RANDOM.asm's own persistent LCG state. */
} hal_random_state_t;

/* Resets to a fresh process's own initial state (SEED=1435) --
 * interp_init's own equivalent of RANDOM.asm's object-code-baked
 * initial SEED constant. */
void hal_random_init(hal_random_state_t *rng);

/* HAL/S `X = RANDOM;` -- one RANU draw, returned as a double-precision
 * SCALAR (USA003088.txt's own "OUTPUT F0 SCALAR DP" declaration for both
 * built-ins). `fpu` is the shared persistent floating-register state
 * (hal_fpu.h) -- RANU reads/writes its own `f1` exactly as real
 * hardware's own F1 register would. */
halmat_scalar_t hal_random_next(hal_random_state_t *rng, hal_fpu_state_t *fpu);

/* HAL/S `X = RANDOMG;` -- twelve independent RANU draws summed and
 * recentered by -6.0 (Irwin-Hall approximation to a standard Gaussian),
 * per RANDOM.asm's own RANDG entry point. Also double-precision SCALAR. */
halmat_scalar_t hal_randomg_next(hal_random_state_t *rng, hal_fpu_state_t *fpu);

/* AED/SED/MED (Add/Subtract/Multiply Extended [rounded] Double) -- the
 * three real AP-101S extended-precision hex-float primitives this file
 * already implements for RANDOM.asm's own RANU (see hal_random.c's own
 * header comment on hrfp_mulQeE). Exposed here so hal_transcendental.c's
 * RUNASM ports (EXP.asm etc.) can reuse the exact same, already-verified
 * core rather than re-deriving it -- both files operate on the same
 * halmat_scalar_t {msw,lsw} IBM hex-float wire layout. */
halmat_scalar_t hrfp_addE(const halmat_scalar_t *x, const halmat_scalar_t *y);
halmat_scalar_t hrfp_subE(const halmat_scalar_t *x, const halmat_scalar_t *y);
halmat_scalar_t hrfp_mulQeE(const halmat_scalar_t *x, const halmat_scalar_t *y);
halmat_scalar_t hrfp_mulE(const halmat_scalar_t *x, const halmat_scalar_t *y);
halmat_scalar_t hrfp_divE(const halmat_scalar_t *x, const halmat_scalar_t *y);
halmat_scalar_t hrfp_cvfl(int32_t x);

#endif
