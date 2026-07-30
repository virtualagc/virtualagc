#ifndef HALMAT_HAL_TRANSCENDENTAL_H
#define HALMAT_HAL_TRANSCENDENTAL_H

#include "value.h"
#include "hal_fpu.h"

/* Bit-exact replication of the real AP-101S runtime library's own
 * RUNASM/EXP.asm -- HAL/S's EXP (single-precision base-e exponential)
 * built-in (class-0/BFNC.md selector 5) -- independently verified
 * instruction-by-instruction against yaGPC2's own real execution trace
 * (yagpc2-yahalmat2-issues.db id 51/task 100). Same porting discipline
 * as hal_random.c's own RANDOM.asm port: every register (R1-R6) and
 * floating pair (F0:F1) is threaded through in the source's own exact
 * program order, reusing hal_random.c's own already-verified extended-
 * precision add/subtract/multiply core (hrfp_addE/subE/mulQeE) for the
 * AED/SED/MED instructions.
 *
 * Confirmed via trace that HAL/S's `Y = EXP(X);` compiles to a call into
 * this single-precision entry point regardless of X's own declared
 * precision (EXP.asm's own header: "INPUT AND OUTPUT VIA F0", a single
 * 32-bit float register) -- DEXP.asm (the double-precision entry point)
 * was not observed reached by any traced call shape and is not ported
 * here.
 *
 * Domain/overflow bounds (X>174.673 / X<-180.218, EXP.asm's own MAX/MIN
 * constants) are the caller's responsibility (interp.c's own
 * arithmetic_error_should_apply_fixup machinery, matching every other
 * BFNC transcendental's existing convention) -- this function assumes X
 * is already within EXP.asm's own valid domain.
 *
 * `fpu` is the shared persistent AP-101S floating-register state
 * (hal_fpu.h) -- EXP's own MED/AED/SED steps write a genuine `f1` on
 * the way to computing their own result (though EXP's own algorithm
 * never needs to READ an incoming f1 -- MED's own extended product is a
 * pure function of X and LOG2E alone), and that final f1 is written
 * back here so it correctly leaks into whatever RTL call comes next. */
halmat_scalar_t hal_exp_single(halmat_scalar_t x, hal_fpu_state_t *fpu);

/* Bit-exact replication of RUNASM/LOG.asm -- HAL/S's LOG (single-
 * precision natural logarithm) built-in (class-0/BFNC.md selector 6).
 * Same verification discipline as hal_exp_single above. Internally uses
 * genuine extended-double (F0:F1) arithmetic for an accurately-rounded
 * result, but returns single precision only (lsw always 0) -- a real
 * trace confirms the compiled caller's own resumed code always zeroes
 * F1 right after the call returns, before the result is ever stored, so
 * F1's extra precision never actually reaches the caller on real
 * hardware either (see this function's own implementation comment).
 * Assumes X>0 (the real hardware's own ARG<=0 fixup -- ARGZERO returns
 * the most-negative representable value, ARG<0 retries on |ARG| -- is
 * the caller's own responsibility, matching interp.c's existing
 * arithmetic_error_should_apply_fixup convention; this function doesn't
 * special-case a non-positive input itself).
 *
 * `fpu` (hal_fpu.h) receives LOG's own genuine final `f1` (from its own
 * second, unconditional AEDR combining step) as a side effect -- this is
 * NOT the same thing as the single-precision RETURN VALUE (whose own
 * lsw is always 0, per this function's own header comment above): a
 * top-level `Y=LOG(X);` call's own compiled caller immediately zeroes
 * F1 again right after the call returns (before ever storing the
 * result), so interp.c's own top-level LOG dispatch must apply that
 * same reset itself (`fpu->f1 = 0`) right after calling this function --
 * but ATANH.asm's own internal `ACALL LOG` does NOT reset F1 before its
 * own next instruction, so hal_atanh_single's own call to this function
 * must NOT add that extra reset, letting LOG's real f1 propagate
 * through untouched instead. */
halmat_scalar_t hal_log_single(halmat_scalar_t x, hal_fpu_state_t *fpu);

/* Bit-exact replication of RUNASM/ATANH.asm -- HAL/S's ARCTANH (single-
 * precision inverse hyperbolic tangent) built-in (class-0/BFNC.md
 * selector 46). Same verification discipline as hal_exp_single/
 * hal_log_single above; internally calls hal_log_single itself for its
 * own "NORMAL" range (matching ATANH.asm's own genuine ACALL LOG).
 * Assumes |X|<1 (the real hardware's own AERROR-60 domain guard is the
 * caller's own responsibility, matching interp.c's existing
 * arithmetic_error_should_apply_fixup convention). `fpu` is threaded
 * straight through to the internal hal_log_single call (see that
 * function's own header comment on why ATANH's own resumed code, unlike
 * a top-level LOG call site, must NOT reset f1 afterward). */
halmat_scalar_t hal_atanh_single(halmat_scalar_t x, hal_fpu_state_t *fpu);

/* Bit-exact replication of RUNASM/SQRT.asm -- HAL/S's SQRT (single-
 * precision square root) built-in (class-0/BFNC.md selector 24): X's
 * own characteristic/mantissa split into Q/M, a hyperbolic-
 * approximation rational function for SQRT(M), then two Newton-Raphson
 * refinement passes. An earlier broad sweep this session found plain
 * top-level SQRT(x) calls already matched yaGPC2 bit-exact via a
 * native-double sqrt() for the specific inputs then tested, but that
 * turned out to be incomplete, not universal -- ASINH.asm's own
 * internal `ABAL SQRT` (SQRT(1.25), reached via ARCSINH(-0.5)) genuinely
 * diverged, which is why this exists as a real port rather than staying
 * a native-sqrt() shortcut. Assumes X>0 (the real hardware's own
 * ARG<=0 fixup -- error 5, `AERROR 5`, ARG=0 returns 0 unchanged, ARG<0
 * retries on |ARG| -- is the caller's own responsibility, matching
 * interp.c's existing arithmetic_error_should_apply_fixup convention;
 * this function doesn't special-case a non-positive input itself).
 *
 * `fpu` (id 71, yagpc2-yahalmat2-issues.db, corrected 2026-07-29): the
 * EARLIER version of this comment claimed no `fpu` parameter was needed
 * because SQRT.asm "never touches an odd companion register (no AEDR/
 * SEDR/MED/AED/SED anywhere in it)" -- that only checked whether SQRT.asm
 * READS an incoming leaked companion (it doesn't -- self-contained,
 * matching hal_fpu.h's "resets its own companion first" case), but
 * missed that it still WRITES one on the way out: `LFLR F1,R6` (twice --
 * the second one, right before the final Newton-Raphson correction, is
 * what survives to AEXIT) and `LE F3,FHALF` are both direct single-
 * precision loads that target F1/F3 as their OWN registers, not via an
 * extended op on F0/F2 -- but the CPU doesn't care how an odd register
 * got written, only that it did; any later routine reading F1/F3 as ITS
 * OWN companion via a genuine extended op (VX6S3/hal_random-style) sees
 * whatever SQRT.asm left there. Every caller (top-level SQRT(), UNIT,
 * ABVAL, and internally ASINH/ACOSH's own NORMAL branches) must thread
 * `state->fpu` through so this leaked pair propagates correctly to
 * whatever RTL call comes next -- confirmed concretely via 072-
 * EXAMPLE_2.hal (`RESULT1 = UNIT(V_PRIME); RESULT2 = V_PRIME * E;`),
 * where UNIT's own internal SQRT call is exactly what real hardware's
 * VX6S3-based VCRS reads back via F1/F3 on the very next line. */
halmat_scalar_t hal_sqrt_single(halmat_scalar_t x, hal_fpu_state_t *fpu);

/* Bit-exact replication of RUNASM/DSQRT.asm -- HAL/S's SQRT built-in when
 * called on a genuinely DOUBLE-precision argument (id 63, yagpc2-
 * yahalmat2-issues.db): `RMS = SQRT(TOTAL/COUNT);` with TOTAL SCALAR
 * DOUBLE previously reused hal_sqrt_single on X's own narrowed msw and
 * just re-tagged the result double_precision=true -- correct bits, wrong
 * ALGORITHM (an inherently single-precision, ~24-bit-mantissa Newton-
 * Raphson result mislabeled as double), which only surfaced once
 * narrowed back down to a SINGLE-precision receiver's own 7-significant-
 * digit formatting (RMS here), landing on a different last digit than
 * real hardware's genuinely double-precision DSQRT.asm. Ported
 * instruction-by-instruction from a real yaGPC2 --trace of this exact
 * repro (108-EXAMPLE_5.hal, TOTAL/COUNT=3383.5): a single-precision
 * hyperbolic-quadratic initial guess X1 (X's own narrowed msw only, a
 * DIFFERENT quadratic-fit table than SQRT.asm's own -- DSQRT.asm's own
 * A/B/C halfword DC constants), one single-precision Newton-Raphson pass
 * to X2 (DER/AER/ME, matching SQRT.asm's own single-precision-only
 * idiom), then ONE double-precision correction pass using the ORIGINAL,
 * still-full-double X (X2 + (X-X2**2)/(X2+X2), via a real SEDR/AEDR
 * against X's own untouched F0:F1) -- the double-precision refinement
 * step SQRT.asm itself never has, which is the actual accuracy gap this
 * fixes. Confirmed via the same trace that the DER computing the
 * correction TERM itself is genuinely single-register (only F0's own
 * msw, silently dropping the preceding SEDR's own lsw) while the
 * following AEDR still combines that new msw with F1's now-STALE lsw as
 * a coherent double pair regardless -- a real hardware quirk, faithfully
 * reproduced rather than "corrected." Final result's own lsw is
 * masked to its own top 10 bits only (DSQRT.asm's own "SAVE FIRST 10
 * BITS CLEAR REM" comment, matching its header's own claimed "31 BITS
 * ACCURACY", narrower than a full 56-bit double mantissa). Assumes X>0,
 * same caller-owns-the-domain-check convention as hal_sqrt_single. No
 * `fpu` parameter -- nothing in this specific call shape (a top-level
 * `X=SQRT(Y);` with Y DOUBLE) reads an incoming odd-companion leak, and
 * DSQRT's own final F1 write is a pure function of X and the freshly-
 * computed X2 alone, not of any pre-existing register state. */
halmat_scalar_t hal_sqrt_double(halmat_scalar_t x);

/* Bit-exact replication of RUNASM/TAN.asm -- HAL/S's TAN (single-
 * precision tangent) built-in (class-0/BFNC.md selector 15, errors 11/12).
 * id 66 (yagpc2-yahalmat2-issues.db, GOOGLE-PARALLAX.hal): id 51's own
 * closing summary of ported transcendentals never listed plain TAN
 * (only ATAN/TANH) -- confirmed a genuine gap, not just an
 * already-adequate libm shortcut like several others turned out to be.
 * Range-reduces |X|*4/PI into an octant + fractional part W (the octant
 * isolated via TAN.asm's own "add-a-huge-constant" bias trick, CHAR46 --
 * same technique as hal_exp_single's own CH47), then evaluates a
 * rational-polynomial approximation of TAN(W*PI/4) (or its reciprocal,
 * COT(W*PI/4), for octants 1/2 mod 4) and fixes the sign from the
 * octant and the original argument's own sign. Domain guard (error 11,
 * |X|>=PI*2**18) is the caller's own responsibility, matching every
 * other domain-guarded BFNC transcendental's convention -- this
 * function assumes X is already in-domain. `singular` (may be NULL) is
 * set true instead of returning a value when the argument is too close
 * to TAN's own singularity (error 12) -- the caller applies the
 * standard fixup (max representable value) itself, same division of
 * responsibility as the domain guard. No `fpu` parameter -- confirmed
 * via a real trace this routine never touches an odd companion
 * register meaningfully across calls (SER F1,F1/SER F3,F3 reset both
 * up front, and nothing downstream depends on any incoming value). */
halmat_scalar_t hal_tan_single(halmat_scalar_t x, bool *singular);

/* Bit-exact replication of RUNASM/DTAN.asm -- HAL/S's TAN built-in when
 * called on a genuinely DOUBLE-precision argument (id 66's own actual
 * repro, GOOGLE-PARALLAX.hal's `TAN(ANGULAR_SHIFT 2**(-1))`, both
 * operands DOUBLE). Same overall shape as hal_tan_single (range-reduce
 * via a bias trick -- CH4E here, a wider double-precision analog of
 * CHAR46 -- into octant + fraction, evaluate a rational polynomial,
 * fix sign), but with two genuine double-precision-only differences
 * confirmed via a real yaGPC2 --trace of this exact repro: (1) the
 * polynomial itself is CUBIC (A2/A1/A0 over B3/B2/B1/B0), not
 * quadratic, computed via genuinely-extended (both-halves-written)
 * AED/MEDR double arithmetic throughout, not the single-register-
 * truncating ME/MER family single precision uses; (2) the final
 * TAN(W)=P/Q or COT(W)=Q/P divide is DTAN.asm's own "QDEDR" macro, a
 * Newton-refined extended-precision divide already ported once for
 * DATAN2/MM14 (this file's own datan2_qdedr, reused verbatim here --
 * same real hardware idiom, confirmed via this trace to expand to the
 * exact same DER-then-extended-correction instruction sequence).
 * Same `singular`-output-parameter convention as hal_tan_single (may
 * be NULL); same caller-owns-the-domain-guard convention (error 11,
 * |X|>=PI*2**50). No `fpu` parameter -- same rationale as
 * hal_tan_single (this routine's own odd companions are always freshly
 * established internally before any use, never read incoming). */
halmat_scalar_t hal_tan_double(halmat_scalar_t x, bool *singular);

/* QDEDR -- a Newton-refined extended-precision divide (a narrow msw-
 * only approximate divide, one genuinely-extended correction pass),
 * confirmed via real yaGPC2 traces to be exactly what real hardware's
 * own compiled code uses for EVERY plain double-precision "/" (id 69,
 * yagpc2-yahalmat2-issues.db) -- not a genuinely exact division the
 * way value.c's own halmat_scalar_divide (still correct for SINGLE
 * precision, confirmed via its own separate trace) computes. Exposed
 * for interp.c's own OP_SSDV; the underlying implementation
 * (hal_transcendental.c's own datan2_qdedr, originally written for
 * DATAN2's own final divide, also reused by DTAN) is unchanged --
 * this is the same routine under a name that doesn't imply an
 * ATAN2-specific scope now that it's used well beyond that. Caller's
 * own responsibility to check for a zero divisor first (this function
 * has no such guard, matching real hardware's own assumption that
 * QDEDR is never reached with one). */
halmat_scalar_t hal_qdedr_double(halmat_scalar_t dividend, halmat_scalar_t divisor);

/* Bit-exact replication of RUNASM/EATAN2.asm's own ATAN entry point --
 * HAL/S's ARCTAN (single-precision arctangent) built-in (class-0/
 * BFNC.md selector 37). EATAN2.asm implements BOTH ARCTAN and ARCTAN2
 * (see hal_atan2_single below) as two entry points sharing one
 * fractional-approximation core with three range-reduction paths
 * (tiny-X passthrough, 1/X inversion for X>1, and a SQRT3-based
 * reduction for X>TAN(PI/12)) -- discovered via real-hardware testing
 * that plain ARCTAN and ARCTAN2(X,1.0), despite being mathematically
 * identical, are NOT always bit-identical on real hardware (ARCTAN2's
 * own extra COSARG-handling code, even when a no-op for COSARG=1,
 * genuinely changes which register state feeds the shared core), so
 * this needed its own real port rather than assuming ARCTAN2's already-
 * confirmed match extended to plain ARCTAN too. No `fpu` parameter --
 * confirmed via trace this routine never touches an odd companion
 * register. */
halmat_scalar_t hal_atan_single(halmat_scalar_t x);

/* Bit-exact replication of RUNASM/EATAN2.asm's own EATAN2 entry point --
 * HAL/S's ARCTAN2(α,β) built-in (class-0/BFNC.md selector 47),
 * α=SINARG, β=COSARG. Shares its core with hal_atan_single above (see
 * that function's own header comment); independently verified against
 * yaGPC2 already matching bit-exact via the prior libm-based
 * implementation across 10 diverse quadrant/magnitude combinations
 * before this port even existed -- ported anyway for genuine
 * authenticity (not just "close enough"), and to share one real
 * implementation with ARCTAN rather than maintaining two divergent
 * approximations of the same real hardware routine. Domain guard
 * (SINARG=COSARG=0, error 62) is the caller's own responsibility,
 * matching every other domain-guarded BFNC transcendental's existing
 * convention. */
halmat_scalar_t hal_atan2_single(halmat_scalar_t sinarg, halmat_scalar_t cosarg);

/* Bit-exact replication of RUNASM/DATAN2.asm's own DATAN2 entry point --
 * the genuine DOUBLE-precision counterpart of hal_atan2_single above.
 * Confirmed via a real trace that DOUBLE-declared SINARG/COSARG operands
 * to ARCTAN2 compile to a call into this ENTIRELY SEPARATE routine, not
 * a "double-tagged" call into EATAN2 -- unlike every other transcendental
 * in this file, where a DOUBLE-declared operand is silently narrowed to
 * single before the call (EXP.asm's own "INPUT AND OUTPUT VIA F0"
 * convention). DATAN2.asm shares EATAN2.asm's own overall three-path
 * range-reduction structure (tiny-X passthrough, 1/X inversion, SQRT3
 * reduction) but operates on genuine extended F0:F1/F2:F3 register pairs
 * throughout, plus an extra CHKHI/CHKLO/SCALE exponent-rescaling step
 * EATAN2.asm doesn't need. Plain ARCTAN(X), even with X DOUBLE, was
 * independently confirmed via the SAME trace to still enter EATAN2 (this
 * file's own DATAN2.asm also defines a "DATAN" single-arg double-
 * precision entry point, but no real compiled call into it was ever
 * observed) -- so hal_atan_single remains correct regardless of X's own
 * declared precision, and no double-precision ARCTAN port exists here. */
halmat_scalar_t hal_atan2_double(halmat_scalar_t sinarg, halmat_scalar_t cosarg);

/* Bit-exact replication of RUNASM/ASINH.asm -- HAL/S's ARCSINH (single-
 * precision inverse hyperbolic sine) built-in (class-0/BFNC.md selector
 * 45). Same verification discipline as hal_exp_single/hal_log_single/
 * hal_atanh_single above. ASINH has no restricted domain (unlike
 * ATANH), so there's no caller-side guard to match -- this function
 * handles the full real line itself, including ASINH.asm's own three-
 * way dispatch (tiny-X passthrough, Taylor series, and the general
 * LOG(X+SQRT(X**2+1)) path, with a LOG(X)+LN2 shortcut for very large
 * X to avoid a pointless/overflow-prone X**2). The general path's own
 * internal SQRT calls hal_sqrt_single (the real RUNASM/SQRT.asm port,
 * see that function's own header comment for why a native-sqrt()
 * shortcut wasn't good enough here). `fpu` is threaded through to the
 * two internal hal_log_single calls, same no-extra-reset rationale as
 * hal_atanh_single's own ACALL LOG. */
halmat_scalar_t hal_asinh_single(halmat_scalar_t x, hal_fpu_state_t *fpu);

/* Bit-exact replication of RUNASM/SINH.asm's own SINH entry point --
 * HAL/S's SINH (single-precision hyperbolic sine) built-in (class-0/
 * BFNC.md selector 22). Newly confirmed divergent from yaGPC2's own
 * real output (task 100/id 51's own bfnc_hyperbolic fixture re-
 * verification), unlike the earlier-ported EXP/LOG/ATANH/ASINH/SQRT/
 * ATAN/ATAN2. For |X|<1, uses a direct polynomial approximation; for
 * |X|>=1, computes via EXP(|X|+LN(V)) (V a rounding-control constant),
 * sharing its own "JOIN"/"ROUND" code with hal_cosh_single below (one
 * real RTL file, two entry points, same idea as EATAN2.asm's own ATAN/
 * ARCTAN2 pair). `fpu` is threaded to the internal ACALL EXP with NO
 * extra reset afterward (SINH.asm's own resumed code right after is
 * "LE F2,VSQ", a plain single op that doesn't touch F1 -- same no-
 * reset rationale as ATANH.asm's/ASINH.asm's own internal ACALL LOG),
 * and IS read again directly a few steps later at the routine's own
 * "ROUND" rounding-correction step (a genuine extended add, F1 still
 * holding EXP's own leftover companion register). Domain/overflow
 * guard (error 9, |X|>175.366) is the caller's own responsibility,
 * matching every other App.-C-guarded transcendental's existing
 * interp.c convention -- this function assumes |X|<=175.366 already. */
halmat_scalar_t hal_sinh_single(halmat_scalar_t x, hal_fpu_state_t *fpu);

/* Bit-exact replication of RUNASM/SINH.asm's own COSH entry point --
 * HAL/S's COSH (single-precision hyperbolic cosine) built-in (class-0/
 * BFNC.md selector 17). Shares hal_sinh_single's own JOIN/ROUND code
 * (see that function's own header comment) but always takes |X| first
 * (no small-X polynomial shortcut -- COSH.asm's own AENTRY code has
 * none) and always ADDS rather than SUBTRACTS at the E**X +/- E**(-X)
 * step, with no final sign-restore (COSH is even). Same `fpu`/domain-
 * guard conventions as hal_sinh_single. */
halmat_scalar_t hal_cosh_single(halmat_scalar_t x, hal_fpu_state_t *fpu);

/* Bit-exact replication of RUNASM/TANH.asm -- HAL/S's TANH (single-
 * precision hyperbolic tangent) built-in (class-0/BFNC.md selector
 * 25). Newly confirmed divergent, same discovery as hal_sinh_single
 * above. For |X|<=16**-3, TANH(X)=X; for |X|<=0.7, a rational-function
 * approximation; for |X|>=9.011, exactly +/-1 (TANH's own bounded
 * range means no App. C overflow entry is needed, unlike SINH/COSH);
 * otherwise TANH(|X|)=1-2/(EXP(2|X|)+1), computed as EXP(|X|)**2 (via
 * an internal ACALL EXP) to avoid a separate doubling step. `fpu`
 * threaded through to that internal call, though TANH.asm's own
 * resumed code never reads a genuine extended companion afterward (no
 * AEDR/SEDR/MEDR anywhere in this routine) -- purely for EXP's own
 * side effect of leaking into whatever RTL call comes next. */
halmat_scalar_t hal_tanh_single(halmat_scalar_t x, hal_fpu_state_t *fpu);

/* Bit-exact replication of RUNASM/ACOSH.asm -- HAL/S's ARCCOSH (single-
 * precision inverse hyperbolic cosine) built-in (class-0/BFNC.md
 * selector 44). Newly confirmed divergent, same discovery as
 * hal_sinh_single above. ARCCOSH(X)=LOG(X+SQRT(X**2-1)), with X**2-1
 * computed as (X+1)*(X-1) to avoid accuracy loss (the routine's own
 * comment) and a LOG(X)+LN(2) shortcut for very large X (avoiding a
 * pointless, overflow-prone X**2), via genuine internal calls into
 * hal_log_single and hal_sqrt_single (ACALL LOG / ABAL SQRT). Domain
 * guard (X<1, error 59) is the caller's own responsibility, matching
 * hal_atanh_single's own convention -- this function assumes X>=1
 * already. `fpu` threaded to both internal ACALL LOG sites with no
 * extra reset (same no-reset rationale as every other internal-ACALL-
 * LOG site in this file). */
halmat_scalar_t hal_arccosh_single(halmat_scalar_t x, hal_fpu_state_t *fpu);

#endif
