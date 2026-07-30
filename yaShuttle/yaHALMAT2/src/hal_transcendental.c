#include "hal_transcendental.h"
#include "hal_random.h"

/* LECR -- negate, except real hardware's own documented LECR bug means
 * an exact-zero operand is deliberately left un-negated (defined once
 * here, forward-declared for use by every RUNASM port in this file --
 * MM14SN.asm's/EATAN2.asm's/SINH.asm's/TANH.asm's own identically-
 * described "WORKAROUND FOR BUG IN LECR INSTRUCTION" comments). Full
 * definition (with its own header comment) lives further down, next to
 * the ATAN/ATAN2 port that first needed it. */
static uint32_t atan2_negate_ws(uint32_t a);

/* EXP.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/EXP.asm) --
 * transcribed verbatim from the .asm source, not re-derived. MAX/MIN are
 * the caller's own domain-bound responsibility (see header comment) and
 * are not used here; LOG2E/CH47 are the extended-precision (F0:F1) pair
 * constants MED/AED/SED operate on, the rest are plain 32-bit register
 * constants the fixed-point rational-approximation core uses directly. */
#define EXP_LOG2E_MSW 0x415C551Du /* 4*LOG BASE 2 OF E, double */
#define EXP_LOG2E_LSW 0x94AE0BF8u
#define EXP_CH47_MSW 0x47100000u /* 16**7 -- integer/fraction separation trick */
#define EXP_CH47_LSW 0x00000000u
#define EXP_CONST_A 0x576AE119u /* 87.417497 (B7) */
#define EXP_CONST_B 0x269F8E6Bu /* 617.97227 (B11) */
#define EXP_CONST_C 0xB9059003u /* -0.03465736 (B-4) */
#define EXP_CONST_D 0xB05CFCE3u /* -9.95459578 (B4) */
#define EXP_CONST_FONE 0x02000000u
#define EXP_CONST_ONE 0x01100000u

/* MR/M (even-register multiply) -- Q31 fixed-point: exact 64-bit signed
 * product left-shifted by 1, split into hi:lo halves. Ported from
 * yaGPC2's own q31.c q31_mul32 (confirmed instruction-by-instruction
 * against a real execution trace, task 100's own derivation). */
static void exp_q31_mul(uint32_t a, uint32_t b, uint32_t *hi, uint32_t *lo) {
    int64_t product = (int64_t)(int32_t)a * (int64_t)(int32_t)b;
    uint64_t bits = ((uint64_t)product) << 1;
    *hi = (uint32_t)(bits >> 32);
    *lo = (uint32_t)(bits & 0xFFFFFFFFu);
}

/* DR (register-pair divide) -- Q31 fixed-point: hi:lo concatenated as a
 * 64-bit signed dividend, divided by divisor (truncating toward zero),
 * raw quotient right-shifted by 1 (the exact inverse of exp_q31_mul's
 * own <<1). Ported from yaGPC2's own q31.c q31_div. Matches the traced
 * hardware behavior of only ever writing the quotient back (the paired
 * remainder register is never observed changing in the real trace, and
 * EXP.asm's own algorithm never reads it afterward either). */
static uint32_t exp_q31_div(uint32_t hi, uint32_t lo, uint32_t divisor) {
    int32_t d = (int32_t)divisor;
    uint64_t dividend_bits = ((uint64_t)hi << 32) | lo;
    int64_t dividend = (int64_t)dividend_bits;
    int64_t raw = (d == -1) ? (int64_t)(0ULL - (uint64_t)dividend) : dividend / (int64_t)d;
    int64_t shifted = raw >> 1;
    return (uint32_t)(int32_t)shifted;
}

halmat_scalar_t hal_exp_single(halmat_scalar_t x_in, hal_fpu_state_t *fpu) {
    /* INPUT F0: real hardware only ever has a single 32-bit float
     * register to receive the argument in, so a DOUBLE-declared X is
     * already implicitly narrowed the moment it's loaded into F0 --
     * this is architectural, not a shortcut (EXP.asm's own header:
     * "INPUT AND OUTPUT VIA F0"). */
    uint32_t f0 = x_in.msw;

    /* LER F2,F0 -- keep the ORIGINAL sign of X (captured before MED
     * below overwrites F0) for the later "BNP NEG" branch. Zero counts
     * as "not positive" (BNP's own sense), matching a genuine IBM
     * hex-float zero test (sign bit clear is not sufficient by itself --
     * a zero magnitude with clear sign bit is still "not positive"). */
    bool x_positive = ((f0 & 0x80000000u) == 0u) && ((f0 & 0x00FFFFFFu) != 0u);

    /* SER F1,F1 ; MED F0,LOG2E -- F0:F1 <- X * (4 log2 e), rounded to 31
     * significant bits each operand first (real MED behavior, see
     * hal_random.c's own hrfp_mulQeE comment). */
    halmat_scalar_t log2e;
    log2e.double_precision = true;
    log2e.msw = EXP_LOG2E_MSW;
    log2e.lsw = EXP_LOG2E_LSW;
    halmat_scalar_t xf;
    xf.double_precision = true;
    xf.msw = f0;
    xf.lsw = 0;
    halmat_scalar_t med = hrfp_mulQeE(&xf, &log2e);
    uint32_t f1 = med.lsw;
    f0 = med.msw;

    /* BM MINUS -- sign of the MED result decides AED vs SED against
     * CH47 (=16**7), the classic "add a much larger constant to force
     * rounding at a fixed scale" trick that separates the integer part
     * (4R) from the fraction (S+T) into R1/R3 below. */
    bool med_negative = (f0 & 0x80000000u) != 0u;
    halmat_scalar_t ch47;
    ch47.double_precision = true;
    ch47.msw = EXP_CH47_MSW;
    ch47.lsw = EXP_CH47_LSW;
    halmat_scalar_t pair;
    pair.double_precision = true;
    pair.msw = f0;
    pair.lsw = f1;
    halmat_scalar_t adj = med_negative ? hrfp_subE(&pair, &ch47) : hrfp_addE(&pair, &ch47);
    f0 = adj.msw;
    f1 = adj.lsw;

    /* TOG: LFXR R1,F0 ; LFXR R3,F1 -- reinterpret the extended pair's own
     * raw bits directly as two plain integer registers (no numeric
     * conversion, a pure bit-copy, confirmed via trace). */
    uint32_t r1 = f0;
    uint32_t r3 = f1;

    /* LER F2,F2 ; BNP NEG -- if X was positive, one's-complement both
     * halves (X R1,ALLF / X R3,ALLF) to flip the "R-1"/"-S-1,-T" encoding
     * used for X>=0 into the "-R"/"S,T" encoding NEG's own code below
     * expects uniformly; if X<=0, the fall-through already has that
     * encoding and skips the complement (EXP.asm's own comment block
     * above the NEG label explains the two encodings). */
    if (x_positive) {
        r1 = ~r1;
        r3 = ~r3;
    }

    /* NEG: SLL R1,24 -- shift -R into the characteristic byte position. */
    r1 = r1 << 24;
    /* AHI R1,X'C000' -- add-halfword-immediate shifts its own immediate
     * into the HIGH halfword before adding (confirmed against a real
     * trace, task 100's own derivation -- NOT standard low-halfword
     * sign-extension). */
    r1 = r1 + (0xC000u << 16);

    /* SR R2,R2 ; SLDL R2,2 -- clear R2, then shift the (R2:R3) 64-bit
     * pair left by 2, moving S (originally R3's own top 2 bits) down
     * into R2 and T up into R3. */
    uint32_t r2 = 0;
    {
        uint64_t pair64 = (((uint64_t)r2) << 32) | r3;
        pair64 <<= 2;
        r2 = (uint32_t)(pair64 >> 32);
        r3 = (uint32_t)(pair64 & 0xFFFFFFFFu);
    }
    /* SLL R2,16 -- S parked in R2's top halfword; this is deliberately
     * left in place, not a scratch value -- the "SRL R4,58" step far
     * below reads S back out of it via the CPU's own register-indirect
     * shift-count addressing mode (see that step's own comment). */
    r2 = r2 << 16;
    /* SRL R3,4 -- give T a positive sign at bit 3 (EXP.asm's own
     * comment). */
    r3 = r3 >> 4;

    /* LR R6,R3 ; MR R6,R6 ; SRDL R6,1 -- R6:R7 <- T*T (Q31 fixed-point
     * self-multiply then a compensating 1-bit right shift of the
     * register pair). */
    uint32_t r6 = r3;
    uint32_t r7;
    exp_q31_mul(r6, r6, &r6, &r7);
    {
        uint64_t pair64 = (((uint64_t)r6) << 32) | r7;
        pair64 >>= 1;
        r6 = (uint32_t)(pair64 >> 32);
        r7 = (uint32_t)(pair64 & 0xFFFFFFFFu);
    }

    /* LR R4,R6 ; M R4,C ; SRA R4,1 -- R4 <- C*T*T (Q31 multiply by the
     * constant C, then an arithmetic right shift to rescale). */
    uint32_t r4 = r6;
    uint32_t r5;
    exp_q31_mul(r4, EXP_CONST_C, &r4, &r5);
    r4 = (uint32_t)((int32_t)r4 >> 1);

    /* A R6,A ; LR R5,R6 ; L R6,B ; DR R6,R5 -- R6 <- B/(A+T*T). */
    r6 = r6 + EXP_CONST_A;
    r5 = r6;
    r6 = EXP_CONST_B;
    r6 = exp_q31_div(r6, r7, r5);

    /* SRL R3,1 ; SR R6,R3 ; A R6,D ; AR R6,R4 --
     * R6 <- C*T*T - T + D + B/(A+T*T). */
    r3 = r3 >> 1;
    r6 = r6 - r3;
    r6 = r6 + EXP_CONST_D;
    r6 = r6 + r4;

    /* LR R4,R3 ; SRL R4,1 ; DR R4,R6 ; SRA R4,4 --
     * R4 <- 2T / (C*T*T - T + D + B/(A+T*T)), rescaled to bit 6. `r5`
     * here is deliberately NOT reset -- it still holds A+T*T, the stale
     * leftover from the earlier "LR R5,R6" above (the first DR's own
     * divisor), reused as this second DR's own dividend low half. This
     * intentional register-value carryover across unrelated-looking
     * instructions is confirmed via a real execution trace (see this
     * project's own RANDOM.asm port for precedent of the same idiom) --
     * not an oversight to "clean up". */
    r4 = r3;
    r4 = r4 >> 1;
    r4 = exp_q31_div(r4, r5, r6);
    r4 = (uint32_t)((int32_t)r4 >> 4);

    /* A R4,FONE -- 2**(-T) now ready at bit 6 of R4 (EXP.asm's own
     * comment). */
    r4 = r4 + EXP_CONST_FONE;

    /* SRL R4,58 -- the literal shift count 58 exceeds the CPU's own
     * 6-bit immediate-shift-count field's 55-value ceiling, which per
     * yaGPC2's own cpu_g_shift_cnt (cpu.c) means the REAL shift amount
     * is instead read from general register (58-56)=2's own bits 16-21
     * at execution time -- exactly S, still parked in R2's top halfword
     * since the "SLL R2,16" step above. This is a genuine hardware
     * register-indirect-shift-count idiom (confirmed via a real
     * execution trace showing an effective shift of 2 for S=2, not a
     * disassembly error), not an approximation -- so this reads S
     * straight out of r2 rather than hardcoding any particular count. */
    {
        uint32_t shift_count = (r2 >> 16) & 0x3Fu;
        r4 = (shift_count >= 32u) ? 0u : (r4 >> shift_count);
    }

    /* S R4,ALLF -- ALLF is X'FFFFFFFF' (=F'-1'); subtracting -1 adds 1
     * at bit 31 to round (EXP.asm's own comment). */
    r4 = r4 - 0xFFFFFFFFu;

    /* C R4,FONE -- compare only (sets the condition the BL below tests);
     * captured here since the SRL that follows doesn't disturb it (real
     * hardware logical shifts don't set the condition code) but this
     * port has no persistent CC to thread through. */
    bool carry_fixup_needed = !((int32_t)r4 < (int32_t)EXP_CONST_FONE);

    /* SRL R4,1 -- shift to mantissa position bit 7. */
    r4 = r4 >> 1;

    /* BL READY / L R4,ONE -- if the compare above found R4 already below
     * FONE, no carry occurred into the characteristic position and R4 is
     * used as-is; otherwise R4 is replaced outright with ONE's own fixed
     * bit pattern (EXP.asm's own "FIXUP OCCURS HERE" comment). */
    if (carry_fixup_needed) {
        r4 = EXP_CONST_ONE;
    }

    /* READY: SR R4,R1 -- multiply by 16**R (EXP.asm's own comment: R1
     * holds -R already shifted into the characteristic byte, so a plain
     * integer subtract here adjusts R4's own characteristic field by
     * +R). */
    r4 = r4 - r1;

    /* LFLR F0,R4 -- reinterpret R4's raw bits directly as the final
     * single-precision float result (again a pure bit-copy, no numeric
     * conversion). */
    fpu->f1 = f1; /* leaks into whatever RTL call comes next -- see header comment */
    halmat_scalar_t result;
    result.double_precision = false;
    result.msw = r4;
    result.lsw = 0;
    return result;
}

/* LOG.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/LOG.asm). */
#define LOG_CONST_LIMIT 0x5A8279D8u /* SQRT(2)/2 */
#define LOG_CONST_ROUND 0xF0000000u /* deliberately-crafted low word for AEDR's own rounding */
#define LOG_CONST_LOGE2 0x40B17219u /* LOG(BASE E)2 + FUDGE */
#define LOG_CONST_R 0x408D8BC7u /* 0.55291413 */
#define LOG_CONST_S 0x416A298Cu /* 6.6351437 */
#define LOG_CONST_HALF 0x40800000u /* 0.5 */
#define LOG_CONST_QUARTER 0x40400000u /* 0.25 */
#define LOG_CONST_ONE 0x41100000u /* 1.0 */

/* "Single" (msw-only, plain non-extended) versions of the four
 * arithmetic primitives -- real hardware's own single-precision F-
 * registers have no paired low word at all (unlike the extended F0:F1/
 * F2:F3 pairs AEDR operates on below), so every intermediate result is
 * genuinely truncated back to 32 bits after each of these, not merely
 * displayed that way. Implemented by feeding hal_random.h's own
 * extended-pair primitives a zero low word and discarding whatever low
 * word they produce, rather than re-deriving a separate 32-bit-only
 * arithmetic core. */
static uint32_t log_sub(uint32_t a, uint32_t b) {
    halmat_scalar_t x; x.double_precision = true; x.msw = a; x.lsw = 0;
    halmat_scalar_t y; y.double_precision = true; y.msw = b; y.lsw = 0;
    return hrfp_subE(&x, &y).msw;
}
static uint32_t log_mul(uint32_t a, uint32_t b) {
    halmat_scalar_t x; x.double_precision = true; x.msw = a; x.lsw = 0;
    halmat_scalar_t y; y.double_precision = true; y.msw = b; y.lsw = 0;
    return hrfp_mulE(&x, &y).msw;
}
static uint32_t log_add(uint32_t a, uint32_t b) {
    halmat_scalar_t x; x.double_precision = true; x.msw = a; x.lsw = 0;
    halmat_scalar_t y; y.double_precision = true; y.msw = b; y.lsw = 0;
    return hrfp_addE(&x, &y).msw;
}
static uint32_t log_div(uint32_t a, uint32_t b) {
    halmat_scalar_t x; x.double_precision = true; x.msw = a; x.lsw = 0;
    halmat_scalar_t y; y.double_precision = true; y.msw = b; y.lsw = 0;
    return hrfp_divE(&x, &y).msw;
}

halmat_scalar_t hal_log_single(halmat_scalar_t x_in, hal_fpu_state_t *fpu) {
    /* INPUT F0 -- same single-register narrowing as hal_exp_single
     * (real hardware has only one 32-bit register to receive the
     * argument in). SER F1,F1 clears F1, never touched again by any
     * "single" op below (only the two AEDR steps near the end use it). */
    uint32_t f0 = x_in.msw;
    uint32_t f1 = 0;

    /* LFXR R6,F0 ; SR R7,R7 ; SRDL R6,24 -- split the raw bits: R6
     * receives the biased exponent (P+64) in its own low byte, R7
     * receives the 24-bit mantissa shifted up into its own top byte. */
    uint32_t r6, r7;
    {
        uint64_t pair64 = ((uint64_t)f0 << 32);
        pair64 >>= 24;
        r6 = (uint32_t)(pair64 >> 32);
        r7 = (uint32_t)(pair64 & 0xFFFFFFFFu);
    }
    /* SRL R7,1 */
    r7 = r7 >> 1;

    /* NCT R5,R7 -- count leading duplicate-bit-pairs (renormalizing M
     * into a tighter range and extracting Q, 0<=Q<=3, at the same time)
     * -- a genuine hardware primitive confirmed via yaGPC2's own
     * cpu_instr.c exec_NCT (task 100/id 51's own derivation): while the
     * top two bits of R7 are equal, shift R7 left and increment the
     * count; R5 receives the final count in its own top halfword. */
    uint32_t r5;
    {
        uint32_t v2 = r7;
        uint32_t count = 0;
        if (v2 != 0) {
            while (count < 32) {
                uint32_t bit0 = (v2 >> 31) & 1u;
                uint32_t bit1 = (v2 >> 30) & 1u;
                if (bit0 != bit1) break;
                v2 = v2 << 1;
                count++;
            }
        }
        r7 = v2;
        r5 = count << 16;
    }

    /* SLL R6,18 ; SR R6,R5 -- (4P-Q)+offset in R6's own top halfword
     * (plain integer subtract, not Q31 -- no M/D instruction involved
     * here). */
    r6 = r6 << 18;
    r6 = r6 - r5;

    /* LFLI F2,1 ; LE F3,HALF -- default A=1,B=0 (M>SQRT(2)/2 case). */
    uint32_t f2 = LOG_CONST_ONE;
    uint32_t f3 = LOG_CONST_HALF;
    /* C R7,LIMIT ; BH POS -- LIMIT's own bit pattern compared as a
     * plain signed 32-bit integer; both operands are always positive
     * normalized hex-float patterns here, so ordinary integer ordering
     * agrees with real magnitude ordering (the same trick CVFL-adjacent
     * code elsewhere in this project's own primitives relies on). */
    bool m_above_limit = (int32_t)r7 > (int32_t)LOG_CONST_LIMIT;
    if (!m_above_limit) {
        /* LE F2,HALF ; LE F3,QUARTER ; AHI R6,X'FFFF' -- A=1/2,B=1. */
        f2 = LOG_CONST_HALF;
        f3 = LOG_CONST_QUARTER;
        r6 = r6 + (0xFFFFu << 16);
    }
    /* AHI R6,X'FF00' -- 4P-Q-B ready in R6's own top byte. */
    r6 = r6 + (0xFF00u << 16);

    /* SRL R7,7 ; AHI R7,X'4000' ; LFLR F0,R7 -- float M into F0. */
    r7 = r7 >> 7;
    r7 = r7 + (0x4000u << 16);
    f0 = r7;

    /* LER F4,F0 ; SER F0,F2 -- M-A in F0 (plain single subtract). */
    uint32_t f4 = f0;
    f0 = log_sub(f0, f2);

    /* BZ ELSPETH -- if Z=0, LOG((1+Z)/(1-Z))=0, skipping straight to
     * ELSPETH with F0:F1 left at 0:0 (both already are). */
    if (f0 != 0) {
        /* ME F4,HALF ; AER F4,F3 ; DER F0,F4 --
         * W = 2Z = 2(M-A)/(M+A). */
        f4 = log_mul(f4, LOG_CONST_HALF);
        f4 = log_add(f4, f3);
        f0 = log_div(f0, f4);

        /* LER F2,F0 ; MER F0,F0 -- W saved in F2, W**2 computed in F0
         * (the minimax rational approximation to LOG((1+Z)/(1-Z))). */
        f2 = f0;
        f0 = log_mul(f0, f0);

        /* LE F4,S ; SER F4,F0 -- S-W**2. */
        f4 = log_sub(LOG_CONST_S, f0);

        /* ME F0,R ; DER F0,F4 -- R*W**2/(S-W**2). */
        f0 = log_mul(f0, LOG_CONST_R);
        f0 = log_div(f0, f4);

        /* MER F0,F2 -- W*(R*W**2/(S-W**2)). */
        f0 = log_mul(f0, f2);

        /* LE F3,ROUND ; AEDR F0,F2 -- W+W*(R*W**2/(S-W**2)), computed
         * as a genuine extended-double add: F0:F1 (F1 still 0) plus
         * F2:F3, where F3 is ROUND's own deliberately-crafted low word
         * (not garbage -- a real hardware rounding-control idiom,
         * confirmed via trace) paired with F2's own saved copy of W. */
        f3 = LOG_CONST_ROUND;
        halmat_scalar_t pa; pa.double_precision = true; pa.msw = f0; pa.lsw = f1;
        halmat_scalar_t pb; pb.double_precision = true; pb.msw = f2; pb.lsw = f3;
        halmat_scalar_t sum = hrfp_addE(&pa, &pb);
        f0 = sum.msw;
        f1 = sum.lsw;
    }

    /* ELSPETH: CVFL F2,R6 -- (4P-Q-B) converted from integer to float. */
    halmat_scalar_t n = hrfp_cvfl((int32_t)r6);
    f2 = n.msw;

    /* ME F2,LOGE2 -- (4P-Q-B)*LOG(2) (plain multiply). */
    f2 = log_mul(f2, LOG_CONST_LOGE2);

    /* AEDR F0,F2 -- final extended-double add; F3 is still ROUND's own
     * bit pattern here, unchanged since the block above (confirmed via
     * trace -- reused for this second add too, not re-loaded). */
    {
        halmat_scalar_t pa; pa.double_precision = true; pa.msw = f0; pa.lsw = f1;
        halmat_scalar_t pb; pb.double_precision = true; pb.msw = f2; pb.lsw = f3;
        halmat_scalar_t sum = hrfp_addE(&pa, &pb);
        f0 = sum.msw;
        f1 = sum.lsw;
    }

    /* Despite the genuine extended-double (F0:F1) arithmetic above,
     * LOG.asm's own declared signature is "OUTPUT F0 SCALAR SP" -- and a
     * real execution trace confirms why: a TOP-LEVEL `Y=LOG(X);` call
     * site's own compiled caller, immediately after LOG's SRET, executes
     * SER F1,F1 (self-subtract, zeroing F1) BEFORE storing the result --
     * so F1's own extra precision is purely an internal accuracy aid for
     * computing a correctly-rounded SINGLE RETURN VALUE, and never
     * actually survives into what gets STORED. Matching that exactly
     * (rather than propagating F1 into the return value) is required for
     * bit-exactness -- confirmed via task 100/id 51's own trace, where
     * naively keeping F1 in the return value produced a value that
     * differed from the real WRITE output starting at the 8th
     * significant digit.
     *
     * The genuine f1 this routine itself computed is still written back
     * to `*fpu` below, though -- that's a separate concern from the
     * return value, since not every CALLER resets F1 the same way a
     * top-level BFNC dispatch's own resumed code does (ATANH.asm's own
     * internal `ACALL LOG` does not -- see this function's own header
     * comment). */
    fpu->f1 = f1;
    halmat_scalar_t result;
    result.double_precision = false;
    result.msw = f0;
    result.lsw = 0;
    return result;
}

/* ATANH.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/
 * ATANH.asm). */
#define ATANH_CONST_ONE 0x41100000u
#define ATANH_CONST_TWO 0x41200000u
#define ATANH_CONST_SMALL 0x40300000u /* 0.1875 */
#define ATANH_CONST_TINY 0x3D2B2329u /* 4.1138977E-05 */
#define ATANH_CONST_THIRD 0x40555555u
#define ATANH_CONST_FIFTH 0x40333333u

halmat_scalar_t hal_atanh_single(halmat_scalar_t x_in, hal_fpu_state_t *fpu) {
    /* INPUT F0 -- same single-register narrowing as hal_exp_single/
     * hal_log_single. */
    uint32_t f0 = x_in.msw;

    /* LER F2,F0 ; BNM POS ; LECR F2,F2 -- F2 = |X|. */
    uint32_t f2 = f0 & 0x7FFFFFFFu;

    /* CE F2,ONE ; BNL ERROR -- domain (|X|<1) is the caller's own
     * responsibility (matching interp.c's existing
     * arithmetic_error_should_apply_fixup convention for every other
     * transcendental), not replicated here. */

    /* CE F2,TINY ; BL EXIT -- |X| too small to change the Taylor
     * series' own leading term; return X unchanged. */
    if ((int32_t)f2 < (int32_t)ATANH_CONST_TINY) {
        halmat_scalar_t result;
        result.double_precision = false;
        result.msw = f0;
        result.lsw = 0;
        return result;
    }

    /* CE F2,SMALL ; BH NORMAL */
    if ((int32_t)f2 <= (int32_t)ATANH_CONST_SMALL) {
        /* Taylor series: X + X**3/3 + X**5/5 (using |X|**2/|X|**4 times
         * the ORIGINAL signed X, mathematically equivalent to X**3/X**5
         * directly since |X|**2==X**2 regardless of X's own sign). */
        f2 = log_mul(f2, f2); /* MER F2,F2 -- |X|**2 */
        uint32_t f4 = f2; /* LER F4,F2 */
        f4 = log_mul(f4, f4); /* MER F4,F4 -- |X|**4 */
        f2 = log_mul(f2, f0); /* MER F2,F0 -- |X|**2 * X */
        f4 = log_mul(f4, f0); /* MER F4,F0 -- |X|**4 * X */
        f2 = log_mul(f2, ATANH_CONST_THIRD); /* ME F2,THIRD */
        f4 = log_mul(f4, ATANH_CONST_FIFTH); /* ME F4,FIFTH */
        f2 = log_add(f2, f4); /* AER F2,F4 */
        f0 = log_add(f0, f2); /* AER F0,F2 */
        halmat_scalar_t result;
        result.double_precision = false;
        result.msw = f0;
        result.lsw = 0;
        return result;
    }

    /* NORMAL: ARCTANH(X) = sign(X) * (1/2)*LOG((1+|X|)/(1-|X|)), via a
     * genuine call into LOG.asm itself (ACALL LOG) -- reused here
     * directly as hal_log_single, since real hardware's own LOG entry
     * point uses the exact same single-precision-in/out calling
     * convention this port already replicates faithfully. */
    bool x_was_negative = (f0 & 0x80000000u) != 0u; /* LFXR R7,F0, tested via LR R7,R7/BNM further below -- captured now since F0 itself is about to be overwritten */
    f0 = ATANH_CONST_ONE; /* LE F0,ONE */
    uint32_t f4 = f0; /* LER F4,F0 */
    f0 = log_add(f0, f2); /* AER F0,F2 -- 1+|X| */
    f4 = log_sub(f4, f2); /* SER F4,F2 -- 1-|X| */
    f0 = log_div(f0, f4); /* DER F0,F4 -- (1+|X|)/(1-|X|) */
    {
        halmat_scalar_t arg;
        arg.double_precision = false;
        arg.msw = f0;
        arg.lsw = 0;
        /* fpu passed straight through, NOT reset afterward -- ATANH.asm's
         * own resumed code right after ACALL LOG is "DE F0,TWO", a plain
         * single op that doesn't touch F1 at all, so LOG's own genuine
         * f1 (just written to *fpu by hal_log_single above) propagates
         * onward untouched (see hal_log_single's own header comment on
         * why this must NOT match a top-level LOG call site's own reset). */
        f0 = hal_log_single(arg, fpu).msw; /* ACALL LOG */
    }
    f0 = log_div(f0, ATANH_CONST_TWO); /* DE F0,TWO */
    if (x_was_negative) f0 = f0 ^ 0x80000000u; /* LECR F0,F0 -- ARCTANH is odd */

    halmat_scalar_t result;
    result.double_precision = false;
    result.msw = f0;
    result.lsw = 0;
    return result;
}

/* ASINH.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/
 * ASINH.asm). Note LN2 here (X'40B17218') differs by one ULP from
 * LOG.asm's own LOGE2 (X'40B17219') -- a genuine, deliberate difference
 * between the two constants, not a transcription slip; each file's own
 * literal value is used as-is, never substituted for the other's. */
#define ASINH_CONST_ONE 0x41100000u
#define ASINH_CONST_XBEST 0x3E3A25DAu
#define ASINH_CONST_BIG 0x47100000u
#define ASINH_CONST_POLYBEST 0x4037614Eu
#define ASINH_CONST_A1 0xC02AAAABu
#define ASINH_CONST_A2 0x40133333u
#define ASINH_CONST_LN2 0x40B17218u

halmat_scalar_t hal_asinh_single(halmat_scalar_t x_in, hal_fpu_state_t *fpu) {
    /* INPUT F0 -- same single-register narrowing as hal_exp_single/
     * hal_log_single/hal_atanh_single. */
    uint32_t x_bits = x_in.msw; /* LFXR R2,F0 -- save the original (signed) bits for the later sign restore and the "tiny X" early-return */
    uint32_t f0 = (x_bits & 0x80000000u) ? (x_bits ^ 0x80000000u) : x_bits; /* LER F0,F0 ; BNM POS ; LECR F0,F0 -- F0 = |X| */

    /* CE F0,XBEST ; BNL HAUSDORF -- |X| too small to change the Taylor
     * series' own leading term; return X (not |X|) unchanged. */
    if ((int32_t)f0 < (int32_t)ASINH_CONST_XBEST) {
        halmat_scalar_t result;
        result.double_precision = false;
        result.msw = x_bits; /* LFLR F0,R2 */
        result.lsw = 0;
        return result;
    }

    if ((int32_t)f0 >= (int32_t)ASINH_CONST_BIG) {
        /* HAUSDORF: |X| so large that SQRT(X**2+1) is indistinguishable
         * from X at single precision -- LN(X)+LN2 avoids the pointless
         * (and overflow-prone) X**2 computation. fpu passed straight
         * through to the internal ACALL LOG, NOT reset afterward --
         * ASINH.asm's own resumed code right after is "AE F0,LN2", a
         * plain single op that doesn't touch F1 (same rationale as
         * hal_atanh_single's own ACALL LOG). */
        halmat_scalar_t arg; arg.double_precision = false; arg.msw = f0; arg.lsw = 0;
        f0 = hal_log_single(arg, fpu).msw;
        f0 = log_add(f0, ASINH_CONST_LN2);
    } else if ((int32_t)f0 <= (int32_t)ASINH_CONST_POLYBEST) {
        /* REGULAR (moderate range): Taylor series
         * |X|*(1 + A1*X**2 + A2*X**4). */
        uint32_t f2 = log_mul(f0, f0); /* MER F2,F2 (via LER F2,F0 first) -- X**2 */
        uint32_t f4 = log_mul(f2, ASINH_CONST_A2); /* LER F4,F2 ; ME F4,A2 */
        f4 = log_add(f4, ASINH_CONST_A1); /* AE F4,A1 */
        f4 = log_mul(f4, f2); /* MER F4,F2 */
        f4 = log_add(f4, ASINH_CONST_ONE); /* AE F4,ONE */
        f0 = log_mul(f0, f4); /* MER F0,F4 */
    } else {
        /* NORMAL: LOG(|X| + SQRT(X**2+1)), via a genuine call into
         * SQRT.asm itself (ABAL SQRT) -- reused here directly as
         * hal_sqrt_single (see that function's own header comment). */
        uint32_t buf = f0; /* STE F0,BUFF */
        f0 = log_mul(f0, f0); /* MER F0,F0 -- X**2 */
        f0 = log_add(f0, ASINH_CONST_ONE); /* AE F0,ONE -- X**2+1 */
        {
            halmat_scalar_t sqrt_in; sqrt_in.double_precision = false; sqrt_in.msw = f0; sqrt_in.lsw = 0;
            f0 = hal_sqrt_single(sqrt_in, fpu).msw; /* ABAL SQRT */
        }
        f0 = log_add(f0, buf); /* AE F0,BUFF -- SQRT(X**2+1) + |X| */
        halmat_scalar_t arg; arg.double_precision = false; arg.msw = f0; arg.lsw = 0;
        f0 = hal_log_single(arg, fpu).msw; /* ACALL LOG, same no-extra-reset rationale as HAUSDORF above */
    }

    /* SIGN: LR R2,R2 ; BNM FIN ; LECR F0,F0 -- ARCSINH is odd: restore
     * the original argument's own sign. */
    if (x_bits & 0x80000000u) f0 = f0 ^ 0x80000000u;

    halmat_scalar_t result;
    result.double_precision = false;
    result.msw = f0;
    result.lsw = 0;
    return result;
}

/* SINH.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/
 * SINH.asm) -- this one file implements BOTH SINH and COSH (see
 * hal_sinh_single's own header comment). UNFLO is a genuine EQU alias
 * for C3's own storage location (the source's own "UNFLO EQU *" line
 * immediately precedes C3's own DC line) -- not a separate constant,
 * transcribed here as literally the same bit pattern. */
#define SINHCOSH_MAX_MSW 0x42AF5DC0u /* 175.366 */
#define SINHCOSH_LIMIT_MSW 0x41100000u /* 1.0 */
#define SINHCOSH_VSQ_MSW 0x403FDF95u /* V**2 = 0.2495053 */
#define SINHCOSH_LNV_MSW 0xC0B1B300u /* LN(V) = -0.6941376 */
#define SINHCOSH_DELTA_MSW 0x3E40F043u /* 1/(2V)-1 */
#define SINHCOSH_C1_MSW 0x402AAAB8u
#define SINHCOSH_C2_MSW 0x3F221E8Cu
#define SINHCOSH_C3_MSW 0x3DD5D8B3u
#define SINHCOSH_UNFLO_MSW SINHCOSH_C3_MSW

/* Shared core for both of SINH.asm's own entry points -- SINH
 * (is_cosh=false) and COSH (is_cosh=true). MAX's own domain/overflow
 * guard (error 9) is the caller's own responsibility -- see
 * hal_sinh_single's own header comment -- so this assumes |X|<=MAX
 * already. */
static uint32_t sinhcosh_core(uint32_t f0_in, bool is_cosh, hal_fpu_state_t *fpu) {
    uint32_t f5 = f0_in; /* original signed X, saved for the final SIGN step (SINH only) */
    bool negative = (f5 & 0x80000000u) != 0u;
    uint32_t f0 = negative ? atan2_negate_ws(f5) : f5; /* LER F0,F0 ; BNM ... ; LECR F0,F0 -- F0=|X| */

    if (!is_cosh) {
        /* SINH's own small-X fast paths -- COSH.asm's own AENTRY code
         * has neither, it always falls straight through to JOIN. */
        if ((int32_t)f0 < (int32_t)SINHCOSH_LIMIT_MSW) {
            if ((int32_t)f0 < (int32_t)SINHCOSH_UNFLO_MSW) {
                /* |X| tiny: SINH(X)=X. Mathematically identical to
                 * taking the SIGN-label path on |X| (LECR-negating back
                 * for a negative original X, no-op for X>=0), just
                 * computed directly instead. */
                return f5;
            }
            /* Polynomial: X + C1*X**3 + C2*X**5 + C3*X**7. */
            uint32_t xsq = log_mul(f0, f0); /* MER F0,F0 */
            uint32_t f2 = xsq; /* LER F2,F0 */
            uint32_t p = log_mul(xsq, SINHCOSH_C3_MSW); /* ME F0,C3 */
            p = log_add(p, SINHCOSH_C2_MSW); /* AE F0,C2 */
            p = log_mul(p, f2); /* MER F0,F2 */
            p = log_add(p, SINHCOSH_C1_MSW); /* AE F0,C1 */
            p = log_mul(p, f2); /* MER F0,F2 */
            p = log_mul(p, f5); /* MER F0,F4 -- times ORIGINAL signed X */
            p = log_add(p, f5); /* AER F0,F4 -- plus ORIGINAL signed X */
            return p;
        }
    }

    /* JOIN: AE F0,LNV ; ACALL EXP -- F0 = EXP(|X|+LN(V)). `fpu`
     * threaded through with NO extra reset afterward (the resumed code
     * right after is "LE F2,VSQ", a plain single op that doesn't touch
     * F1 -- same no-reset rationale as ATANH.asm's/ASINH.asm's own
     * internal ACALL LOG). */
    f0 = log_add(f0, SINHCOSH_LNV_MSW);
    {
        halmat_scalar_t arg; arg.double_precision = false; arg.msw = f0; arg.lsw = 0;
        f0 = hal_exp_single(arg, fpu).msw;
    }

    uint32_t f2 = log_div(SINHCOSH_VSQ_MSW, f0); /* LE F2,VSQ ; DER F2,F0 */

    if (is_cosh) {
        f0 = log_add(f0, f2); /* AER F0,F2 -- V(E**X+E**(-X)) */
    } else {
        /* ESINH: SINH always subtracts here regardless of the ORIGINAL
         * sign of X (R5<=0 covers BOTH R5=0[X>=0] and R5=-1[X<0] --
         * we're working with |X| throughout, sign restored only at the
         * very end via SIGN below). */
        f0 = log_sub(f0, f2); /* SER F0,F2 */
    }

    /* ROUND: rounding correction via a genuine extended add. F1 is
     * still EXP's own leftover companion register (nothing between the
     * ACALL EXP above and here touches it); F3 is set to LNV's own bit
     * pattern as a deliberately-crafted low word -- the same "crafted
     * lsw" rounding idiom as LOG.asm's own ROUND constant
     * (hal_log_single's own header comment). */
    {
        uint32_t pre = f0; /* LER F2,F0 -- captured BEFORE the ME below */
        uint32_t muled = log_mul(f0, SINHCOSH_DELTA_MSW); /* ME F0,DELTA */
        halmat_scalar_t pa; pa.double_precision = true; pa.msw = muled; pa.lsw = fpu->f1;
        halmat_scalar_t pb; pb.double_precision = true; pb.msw = pre; pb.lsw = SINHCOSH_LNV_MSW;
        halmat_scalar_t sum = hrfp_addE(&pa, &pb);
        f0 = sum.msw;
    }

    if (!is_cosh && negative) f0 = atan2_negate_ws(f0); /* SIGN: LECR-bug-workaround negate, SINH only */

    return f0;
}

halmat_scalar_t hal_sinh_single(halmat_scalar_t x, hal_fpu_state_t *fpu) {
    halmat_scalar_t result; result.double_precision = false; result.msw = sinhcosh_core(x.msw, false, fpu); result.lsw = 0;
    return result;
}

halmat_scalar_t hal_cosh_single(halmat_scalar_t x, hal_fpu_state_t *fpu) {
    halmat_scalar_t result; result.double_precision = false; result.msw = sinhcosh_core(x.msw, true, fpu); result.lsw = 0;
    return result;
}

/* TANH.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/
 * TANH.asm). */
#define TANH_CONST_A 0xBEF7EA70u /* -0.003782895 */
#define TANH_CONST_B 0xC0D08756u /* -0.81456511 */
#define TANH_CONST_C 0x41278C49u /* 2.4717498 */
#define TANH_CONST_HILIM 0x41902D0Eu /* 9.011 */
#define TANH_CONST_LOLIM 0x3E100000u /* 16**-3 */
#define TANH_CONST_MLIM 0x40B33333u /* 0.7 */
#define TANH_CONST_FLONE 0x41100000u /* 1.0 */

halmat_scalar_t hal_tanh_single(halmat_scalar_t x_in, hal_fpu_state_t *fpu) {
    uint32_t f5 = x_in.msw; /* LER F5,F0 -- save ORIGINAL signed X */
    bool negative = (f5 & 0x80000000u) != 0u;
    uint32_t f0 = negative ? atan2_negate_ws(f5) : f5; /* BNM POSARG ; LECR F0,F0 -- F0=|X| */

    if ((int32_t)f0 <= (int32_t)TANH_CONST_MLIM) {
        /* SMALL */
        if ((int32_t)f0 <= (int32_t)TANH_CONST_LOLIM) {
            /* TANH(X)=X if X is small (mathematically identical to the
             * shared SIGN path on |X|, same reasoning as
             * sinhcosh_core's own tiny-X shortcut). */
            halmat_scalar_t result; result.double_precision = false; result.msw = f5; result.lsw = 0;
            return result;
        }
        uint32_t xsq = log_mul(f0, f0); /* MER F0,F0 */
        uint32_t f4 = log_add(TANH_CONST_C, xsq); /* LE F4,C ; AER F4,F0 */
        uint32_t f2 = log_div(TANH_CONST_B, f4); /* LE F2,B ; DER F2,F4 */
        f2 = log_add(f2, TANH_CONST_A); /* AE F2,A */
        uint32_t f0v = log_mul(xsq, f2); /* MER F0,F2 */
        f0v = log_mul(f0v, f5); /* MER F0,F5 -- times ORIGINAL signed X */
        f0v = log_add(f0v, f5); /* AER F0,F5 -- plus ORIGINAL signed X */
        halmat_scalar_t result; result.double_precision = false; result.msw = f0v; result.lsw = 0;
        return result;
    }

    if ((int32_t)f0 >= (int32_t)TANH_CONST_HILIM) {
        /* BIG: TANH(X) = +/-1 exactly. */
        uint32_t r = TANH_CONST_FLONE; /* LFLI F0,1 */
        if (negative) r = atan2_negate_ws(r); /* SIGN */
        halmat_scalar_t result; result.double_precision = false; result.msw = r; result.lsw = 0;
        return result;
    }

    /* NORMAL: TANH(|X|) = 1 - 2/(EXP(2|X|)+1), computed as EXP(|X|)**2
     * to avoid a separate doubling step. `fpu` threaded to the internal
     * ACALL EXP purely for its own side effect (this routine itself
     * never reads a genuine extended companion register afterward). */
    {
        halmat_scalar_t arg; arg.double_precision = false; arg.msw = f0; arg.lsw = 0;
        f0 = hal_exp_single(arg, fpu).msw; /* ACALL EXP */
    }
    uint32_t f4 = TANH_CONST_FLONE; /* LFLI F4,1 */
    f0 = log_mul(f0, f0); /* MER F0,F0 -- EXP(2|X|) */
    f0 = log_add(f0, f4); /* AER F0,F4 */
    uint32_t f2 = log_add(f4, f4); /* LER F2,F4 ; AER F2,F2 -- = 2 */
    f2 = log_div(f2, f0); /* DER F2,F0 */
    f0 = log_sub(f4, f2); /* LER F0,F4 ; SER F0,F2 */

    if (negative) f0 = atan2_negate_ws(f0); /* SIGN */
    halmat_scalar_t result; result.double_precision = false; result.msw = f0; result.lsw = 0;
    return result;
}

/* ACOSH.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/
 * ACOSH.asm). LN2 here matches ASINH.asm's own LN2 bit-for-bit (both
 * files happen to use the identical constant), transcribed separately
 * per this project's own "each file's own literal value used as-is"
 * convention (hal_asinh_single's own header comment). */
#define ACOSH_CONST_ONE 0x41100000u
#define ACOSH_CONST_LN2 0x40B17218u
#define ACOSH_CONST_BIG 0x47100000u

halmat_scalar_t hal_arccosh_single(halmat_scalar_t x_in, hal_fpu_state_t *fpu) {
    uint32_t f0 = x_in.msw;

    if ((int32_t)f0 >= (int32_t)ACOSH_CONST_BIG) {
        /* X so large SQRT(X**2-1) is indistinguishable from X --
         * LOG(X)+LN2 avoids the pointless (overflow-prone) X**2. `fpu`
         * threaded through with no extra reset (this routine's own
         * resumed code right after ACALL LOG is "AE F0,LN2", a plain
         * single op that doesn't touch F1 -- same rationale as every
         * other internal-ACALL-LOG site in this file). */
        halmat_scalar_t arg; arg.double_precision = false; arg.msw = f0; arg.lsw = 0;
        f0 = hal_log_single(arg, fpu).msw; /* ACALL LOG */
        f0 = log_add(f0, ACOSH_CONST_LN2); /* AE F0,LN2 */
        halmat_scalar_t result; result.double_precision = false; result.msw = f0; result.lsw = 0;
        return result;
    }

    /* NORMAL: ARCCOSH(X)=LOG(X+SQRT(X**2-1)), X**2-1 computed as
     * (X+1)*(X-1) to avoid accuracy loss (the routine's own comment).
     * Domain guard (X<1, error 59) is the caller's own responsibility,
     * matching hal_atanh_single's own convention -- this function
     * assumes X>=1 already. */
    uint32_t buf = f0; /* STE F0,BUFF */
    uint32_t f2 = ACOSH_CONST_ONE;
    f0 = log_sub(f0, f2); /* SER F0,F2 -- X-1 */
    f2 = log_add(f2, buf); /* AE F2,BUFF -- 1+X */
    f0 = log_mul(f0, f2); /* MER F0,F2 -- X**2-1 */
    {
        halmat_scalar_t sqrt_in; sqrt_in.double_precision = false; sqrt_in.msw = f0; sqrt_in.lsw = 0;
        f0 = hal_sqrt_single(sqrt_in, fpu).msw; /* ABAL SQRT */
    }
    f0 = log_add(f0, buf); /* AE F0,BUFF */
    {
        halmat_scalar_t arg; arg.double_precision = false; arg.msw = f0; arg.lsw = 0;
        f0 = hal_log_single(arg, fpu).msw; /* ACALL LOG */
    }
    halmat_scalar_t result; result.double_precision = false; result.msw = f0; result.lsw = 0;
    return result;
}

/* SQRT.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/
 * SQRT.asm) -- each has a distinct Q=1 variant (a second DC line right
 * after the first), selected by the same register-indirect-shift-style
 * bit test EXP.asm's own "SRL R4,58" idiom uses elsewhere: not a fuzzy
 * threshold, a genuine hardware Q/mantissa-extraction step (task 100/
 * id 51's own derivation, confirmed via a real trace of SQRT(1.25)). */
#define SQRT_CONST_A0 0x21AE7D00u
#define SQRT_CONST_A1 0x206B9F40u
#define SQRT_CONST_B0 0xFF5B02F1u
#define SQRT_CONST_B1 0xFFD6C0BDu
#define SQRT_CONST_C0 0x35CFC610u
#define SQRT_CONST_C1 0x75CFC610u
#define SQRT_CONST_ROUND 0x00000001u
#define SQRT_CONST_HALF 0x40800000u

/* SQRT.asm is a genuine RTL routine ASINH.asm's own "NORMAL" branch
 * calls internally (ABAL SQRT) -- an EARLIER broad sweep this same
 * session (task 100/id 51) found plain top-level SQRT(x) calls already
 * matched yaGPC2 bit-exact via a native-double sqrt(), which held for
 * every value tested THEN, but a real trace of ASINH(-0.5)'s own
 * internal SQRT(1.25) later showed a genuine, non-last-digit divergence
 * -- the earlier "SQRT already matches" finding was real but incomplete
 * (true for the specific inputs swept, not universally), so SQRT.asm's
 * own actual hyperbolic-approximation-plus-two-Newton-Raphson-passes
 * algorithm is ported here for real, not reused as a native-sqrt()
 * shortcut. */
halmat_scalar_t hal_sqrt_single(halmat_scalar_t x_in, hal_fpu_state_t *fpu) {
    uint32_t f0 = x_in.msw; /* INPUT F0 */
    uint32_t f2 = f0; /* LER F2,F0 -- saved original X, later overwritten by the first Newton pass' own DER F2,F0 */

    /* LFXR R7,F0 ; XR R6,R6 ; SLDL R6,7 ; SLL R6,24 -- extract Q (into
     * R7's own sign, per the routine's own comment "Q & MANTISSA IN
     * R7") and the raw characteristic (into R6's own top byte). */
    uint32_t r7 = f0;
    uint32_t r6 = 0;
    {
        uint64_t pair64 = ((uint64_t)r6 << 32) | r7;
        pair64 <<= 7;
        r6 = (uint32_t)(pair64 >> 32);
        r7 = (uint32_t)(pair64 & 0xFFFFFFFFu);
    }
    r6 = r6 << 24;

    /* LR R7,R7 ; BCF 5,GORP -- Q=1 iff the shifted R7 is negative
     * (confirmed via trace: R7=0x8a000000 for SQRT(1.25), which takes
     * the Q=1 path). */
    bool is_q1 = ((int32_t)r7) < 0;
    if (is_q1) {
        r6 = r6 + (0x0100u << 16); /* AHI R6,X'0100' -- ADD 1 TO CHAR FOR Q=1 */
    }

    /* GORP: LR R5,R6 ; SRA R7,1 ; A R7,C ; L R6,B ; DR R6,R7 ; A R6,A ;
     * AR R6,R5 -- (16**P)(4**(-Q))(hyperbolic approx of SQRT(M)),
     * bit 7 + restored characteristic. DR R6,R7's own divisor is R7
     * itself (the SAME register as the dividend's own low half) -- a
     * genuine self-referential register use confirmed via trace, not a
     * transcription slip. */
    uint32_t r5 = r6;
    r7 = (uint32_t)((int32_t)r7 >> 1);
    r7 = r7 + (is_q1 ? SQRT_CONST_C1 : SQRT_CONST_C0);
    r6 = is_q1 ? SQRT_CONST_B1 : SQRT_CONST_B0;
    r6 = exp_q31_div(r6, r7, r7);
    r6 = r6 + (is_q1 ? SQRT_CONST_A1 : SQRT_CONST_A0);
    r6 = r6 + r5;
    uint32_t f1 = r6; /* LFLR F1,R6 */

    /* TWO PASSES OF THE NEWTON-RAPHSON ITERATION (the routine's own
     * comment). */
    f0 = log_div(f0, f1); /* DER F0,F1 */
    f0 = log_add(f0, f1); /* AER F0,F1 */
    uint32_t f3 = SQRT_CONST_HALF; /* LE F3,FHALF */
    f0 = log_mul(f0, f3); /* MER F0,F3 */
    f2 = log_div(f2, f0); /* DER F2,F0 */

    /* NHI R6,X'FF00' ; A R6,ROUND ; LFLR F1,R6 ; AER F0,F1 -- R6 here is
     * still M_approx's own bits (nothing wrote R6 since the first LFLR
     * above, confirmed via trace), used to build a rounding ULP scaled
     * to the answer's own characteristic. */
    r6 = f1 & 0xFF000000u;
    r6 = r6 + SQRT_CONST_ROUND;
    f1 = r6;
    f0 = log_add(f0, f1);

    f0 = log_sub(f0, f2); /* SER F0,F2 */
    f0 = log_mul(f0, f3); /* MER F0,F3 */
    f0 = log_add(f0, f2); /* AER F0,F2 -- ANSWER IN F0 */

    /* id 71: F1/F3 are both direct single-precision loads (LFLR F1,R6 /
     * LE F3,FHALF) that leave these exact final values sitting in F1/F3
     * when SQRT.asm's own AEXIT returns -- see this function's own
     * header comment. */
    fpu->f1 = f1;
    fpu->f3 = f3;

    halmat_scalar_t result;
    result.double_precision = false;
    result.msw = f0;
    result.lsw = 0;
    return result;
}

/* DSQRT.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/
 * DSQRT.asm) -- a genuinely different quadratic-fit table than SQRT.asm's
 * own SQRT_CONST_* above (confirmed via trace: DSQRT's own initial guess
 * uses X*A+B, times X, +C via plain halfword MH/AH/MR/AH, not SQRT.asm's
 * own exp_q31_div-based hyperbolic approximation), selected by whether
 * the shifted mantissa is </>= 0x20000000 (the routine's own "MANTISSA
 * LT/GE 0.25" DC comment), not by a Q1 sign test. */
#define DSQRT_CONST_A0 ((int16_t)0xAF76) /* MANTISSA LT 0.25 */
#define DSQRT_CONST_A1 ((int16_t)0xF5EF) /* MANTISSA GE 0.25 */
#define DSQRT_CONST_B0 0x433Eu
#define DSQRT_CONST_B1 0x219Fu
#define DSQRT_CONST_C0 0x0427u
#define DSQRT_CONST_C1 0x084Du
#define DSQRT_CONST_HALF 0x40800000u /* 0.5 */
#define DSQRT_CONST_MSK 0xFFC00000u /* top 10 bits -- DSQRT.asm's own "SAVE FIRST 10 BITS CLEAR REM" */

/* AER/SER/MER/DER/ME's own shared shape confirmed via yaGPC2's own
 * cpu_instr.c (exec_AER/exec_DER/exec_MER/exec_ME): both operands read as
 * SINGLE 32-bit registers (lsw implicitly 0), computed through the exact
 * same extended-precision core hrfp_addE/subE/mulE/divE already provide,
 * then TRUNCATED (fibm_to32 -- top word only, no rounding) back to a
 * single 32-bit result -- unlike AEDR/SEDR (hrfp_addE/subE called
 * directly on a genuine msw:lsw pair), which keep the full double-
 * precision result. mulE (not mulQeE/MED's own round-to-31-bits-per-
 * operand variant) matches MER/ME's own confirmed exact-product
 * semantics (same distinction hal_random.c's own hrfp_mulE header
 * comment already documents). */
static uint32_t dsqrt_single_add(uint32_t a, uint32_t b) {
    halmat_scalar_t x = {true, a, 0}, y = {true, b, 0};
    return hrfp_addE(&x, &y).msw;
}
static uint32_t dsqrt_single_mul(uint32_t a, uint32_t b) {
    halmat_scalar_t x = {true, a, 0}, y = {true, b, 0};
    return hrfp_mulE(&x, &y).msw;
}
static uint32_t dsqrt_single_div(uint32_t a, uint32_t b) {
    halmat_scalar_t x = {true, a, 0}, y = {true, b, 0};
    return hrfp_divE(&x, &y).msw;
}

/* Q15-style fixed-point multiply MH/MR share (yaGPC2's own cpu_instr.c
 * exec_MH/exec_MR, both routing through q31.c's own q15_mul: each
 * operand is its OWN register's upper 16 bits, arithmetically shifted
 * out first -- the same "value lives in the upper halfword" convention
 * LHI/LA/AH/CHI's own <<16 placement already establishes -- multiplied,
 * then doubled (<<1) and truncated to 32 bits, matching real hardware's
 * own Q15 fixed-point rounding-free semantics exactly). */
static uint32_t dsqrt_q15_mul(int32_t a, int32_t b) {
    int64_t product = (int64_t)a * (int64_t)b;
    return (uint32_t)(uint64_t)(product << 1);
}

halmat_scalar_t hal_sqrt_double(halmat_scalar_t x_in) {
    /* AER F4,F0 -- extended add against a true zero is exact (hrfp_addsub's
     * own a_zero passthrough branch), so this is provably just X's own
     * msw, unchanged -- confirmed via trace (FP4 became X's own msw
     * exactly). */
    uint32_t f4 = x_in.msw;

    /* START: LFXR R7,F4 ; AHI R7,X'4100' -- AHI's own "add to the upper
     * halfword" convention confirmed via trace (R07: 43d37800->84d37800,
     * i.e. +0x41000000) and already established by hal_sqrt_single's own
     * identical-shaped port above. */
    uint32_t r7 = f4 + 0x41000000u;
    uint32_t r6 = 0;

    /* SLDL R6,7 -- shift the R6:R7 pair (64-bit) left 7, confirmed via
     * trace (R06: 0->0x42, R07: 0x84d37800->0x69bc0000). */
    { uint64_t pair = (((uint64_t)r6 << 32) | r7) << 7; r6 = (uint32_t)(pair >> 32); r7 = (uint32_t)pair; }
    r6 <<= 6; /* SLL R6,6 -- trace: 0x42->0x1080 */
    r7 ^= 0x80000000u; /* XHI R7,X'8000' -- trace: 0x69bc0000->0xe9bc0000 */
    /* SLDL R6,1 -- trace: R06 0x1080->0x2101, R07 0xe9bc0000->0xd3780000 */
    { uint64_t pair = (((uint64_t)r6 << 32) | r7) << 1; r6 = (uint32_t)(pair >> 32); r7 = (uint32_t)pair; }
    r6 <<= 17; /* SLL R6,17 -- trace: 0x2101->0x42020000 */
    r6 += 0x00050000u; /* AHI R6,X'0005' -- trace: 0x42020000->0x42070000 */
    r7 >>= 1; /* SRL R7,1 -- trace: 0xd3780000->0x69bc0000 */

    /* CHI R7,X'2000' ; BC 2,LESS -- selects the "GE 0.25" coefficient
     * row when R7 (as a plain 32-bit compare against 0x2000<<16, per
     * exec_CHI) is NOT less than the threshold; trace confirms our
     * specific repro takes the GE branch. */
    bool ge025 = (int32_t)r7 >= (int32_t)0x20000000;
    int32_t coef_a = ge025 ? DSQRT_CONST_A1 : DSQRT_CONST_A0;
    uint32_t coef_b = (ge025 ? DSQRT_CONST_B1 : DSQRT_CONST_B0) << 16;
    uint32_t coef_c = (ge025 ? DSQRT_CONST_C1 : DSQRT_CONST_C0) << 16;

    /* LESS: LR R5,R7 ; MH R5,A ; AH R5,B ; MR R5,R7 ; AH R5,C -- the
     * quadratic (AX+B)X+C, confirmed instruction-by-instruction via
     * trace (R05: 0x69bc0000 -> 0xf7af4508 -> 0x194e4508 -> 0x14e72690
     * -> 0x1d342690). */
    uint32_t r5 = r7;
    r5 = dsqrt_q15_mul((int32_t)r5 >> 16, coef_a);
    r5 += coef_b;
    r5 = dsqrt_q15_mul((int32_t)r5 >> 16, (int32_t)r7 >> 16);
    r5 += coef_c;

    /* SRL R5,62 -- encodes a REGISTER-INDIRECT shift count (yaGPC2's own
     * cpu_g_shift_cnt: an immediate field >55 means "shift by register
     * (field-56)'s own upper 16 bits, mod 64, clamped to 0 if >=32"),
     * confirmed by DSQRT.asm's own "SHIFT BY BITS IN R6" comment and by
     * trace (R6's upper halfword was 0x4207 at this point -> shift 7;
     * R05: 0x1d342690 -> 0x003a684d, matching 0x1d342690>>7 exactly). */
    { uint32_t shift = (r6 >> 16) & 0x3Fu; r5 = (shift >= 32) ? 0u : (r5 >> shift); }
    r6 &= 0xFF000000u; /* NHI R6,X'FF00' -- trace: 0x42070000->0x42000000 */
    r6 |= r5; /* OR R6,R5 -- trace: ->0x423a684d */
    uint32_t f2 = r6; /* LFLR F2,R6 -- X1, the initial guess */

    /* FIRST PASS THROUGH NEWTON-RAPHSON (single-precision, matching
     * SQRT.asm's own idiom exactly): DER F4,F2 ; AER F4,F2 ; ME F4,HALF
     * -- X2 = (X/X1 + X1) / 2. Trace: FP4 0x43d37800->0x4239ede5->
     * 0x42745632->0x423a2b19. */
    f4 = dsqrt_single_div(f4, f2);
    f4 = dsqrt_single_add(f4, f2);
    f4 = dsqrt_single_mul(f4, DSQRT_CONST_HALF); /* X2, still single-precision-accurate only */

    /* LER F2,F4 ; MER F2,F4 -- X2*X2, single (exact-product MER, per
     * ME/MER's own confirmed semantics above). Trace: FP2 0x423a2b19->
     * 0x43d378e9. */
    uint32_t x2sq_msw = dsqrt_single_mul(f4, f4);

    /* SEDR F0,F2 -- the routine's OWN double-precision correction step,
     * the entire reason this needs its own port rather than reusing
     * hal_sqrt_single: X (still the ORIGINAL, untouched, full-precision
     * F0:F1 double input) minus X2*X2 (single, lsw=0), computed as a
     * genuine extended-double subtract (hrfp_subE, full msw:lsw result)
     * -- NOT truncated to single like every DER/AER/MER above. */
    halmat_scalar_t x2sq = {true, x2sq_msw, 0};
    halmat_scalar_t diff = hrfp_subE(&x_in, &x2sq);

    /* LER F2,F4 ; AER F2,F2 -- X2+X2, single. */
    uint32_t two_x2 = dsqrt_single_add(f4, f4);

    /* DER F0,F2 -- confirmed via trace to be genuinely SINGLE-register
     * (exec_DER only ever reads/writes F(x) alone): only diff's own MSW
     * participates here, silently dropping the SEDR's own lsw -- a real
     * hardware quirk, not a bug to "fix". F1 (diff.lsw) is left
     * completely untouched by this step (matching exec_DER not touching
     * F(x+1) at all) and carries forward STALE into the next AEDR. */
    uint32_t correction_msw = dsqrt_single_div(diff.msw, two_x2);

    /* AEDR F0,F4 -- X2 + correction, genuinely double: F0:F1 is
     * (correction_msw, diff.lsw) -- the new msw paired with the OLD
     * (stale, pre-DER) lsw, per the comment above -- added against
     * F4:F5 (=X2, 0 -- F5 was explicitly zeroed by DSQRT.asm's own `XR
     * R7,R7 ; LFLR F5,R7`, confirmed via trace). */
    halmat_scalar_t pre_aedr = {true, correction_msw, diff.lsw};
    halmat_scalar_t x2_pair = {true, f4, 0};
    halmat_scalar_t result = hrfp_addE(&pre_aedr, &x2_pair);

    /* LFXR R6,F1 ; N R6,MSK ; LFLR F1,R6 -- the final result's own lsw is
     * masked down to just its top 10 bits (DSQRT.asm's own "SAVE FIRST
     * 10 BITS CLEAR REM" comment), matching its header's own claimed "31
     * BITS ACCURACY" (24 single-precision mantissa bits + 10 more, not a
     * full 56-bit double mantissa). */
    result.lsw &= DSQRT_CONST_MSK;
    return result;
}

/* EATAN2.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/
 * EATAN2.asm). DATA holds the four table-selected angle offsets --
 * 0, PI/6, -PI/2, -PI/3 -- indexed by which of the three range-
 * reduction paths (none / SQRT3-reduced / 1/X-inverted / both) ran. */
#define ATAN2_CONST_FLONE 0x41100000u
#define ATAN2_CONST_PI 0x413243F7u
#define ATAN2_CONST_PIOV2 0x411921FBu
#define ATAN2_CONST_LOWLIM 0x3B100000u
#define ATAN2_CONST_HIGHLIM 0x47100000u
#define ATAN2_CONST_A 0x41168A5Eu
#define ATAN2_CONST_B 0x408F239Cu
#define ATAN2_CONST_C 0xBFD35F49u
#define ATAN2_CONST_D 0x409A6524u
#define ATAN2_CONST_RT3M1 0x40BB67AFu
#define ATAN2_CONST_RT3 0x411BB67Bu
#define ATAN2_CONST_SMALL 0x3E100000u
#define ATAN2_CONST_TAN15 0x40449851u
#define ATAN2_DATA0 0x00000000u
#define ATAN2_DATA1 0x40860A92u /* PI/6 */
#define ATAN2_DATA2 0xC11921FBu /* -PI/2 */
#define ATAN2_DATA3 0xC110C152u /* -PI/3 */

/* LECR -- negate, except real hardware's own documented LECR bug means
 * an exact-zero operand is deliberately left un-negated at STEST
 * (EATAN2.asm's own "WORKAROUND FOR BUG IN LECR INSTRUCTION" comment,
 * matching MM14SN.asm's own identically-named workaround elsewhere). */
static uint32_t atan2_negate_ws(uint32_t a) { return (a == 0u) ? a : (a ^ 0x80000000u); }

/* Shared core for both of EATAN2.asm's own entry points -- ATAN
 * (is_atan2=false, cosarg_bits ignored) and ARCTAN2 (is_atan2=true).
 * No `fpu` parameter -- confirmed via trace that this routine never
 * touches an odd companion register (no AEDR/SEDR/MED/AED/SED anywhere
 * in it, single ops throughout). */
static halmat_scalar_t atan_or_atan2_single(uint32_t sinarg_bits, uint32_t cosarg_bits, bool is_atan2) {
    uint32_t r6 = sinarg_bits; /* LFXR R6,F0 -- original SINARG bits, incl. sign, saved for the final STEST */
    uint32_t f0 = (r6 & 0x80000000u) ? atan2_negate_ws(r6) : r6; /* LR R6,R6 ; BNM TEST1 ; LECR F0,F0 -- F0=|SINARG| */
    uint32_t r2_data = ATAN2_DATA0; /* table pointer, starts at index 0 */

    if (is_atan2) {
        uint32_t r7 = cosarg_bits; /* LFXR R7,F2 */
        if (r7 == 0u) {
            if (r6 == 0u) {
                /* ERROR: SINARG=COSARG=0 -- caller's own responsibility
                 * (error 62), matching every other domain-guarded BFNC
                 * transcendental's existing convention; this function
                 * assumes it's never called with both zero. */
                halmat_scalar_t z; z.double_precision = false; z.msw = 0; z.lsw = 0;
                return z;
            }
            /* VALUE: COSARG=0, SINARG!=0 -- exactly +/-PI/2. */
            f0 = ATAN2_CONST_PIOV2;
            goto stest;
        }
        /* Overflow-protection check: default to +/-PI/2 when
         * EXP(SINARG)-EXP(COSARG) >= 7, avoiding an exponent overflow
         * in the tangent divide that follows. */
        if (f0 != 0u) {
            uint32_t exp_sin = f0 & 0x7F000000u;
            uint32_t exp_cos = cosarg_bits & 0x7F000000u;
            int32_t delta = (int32_t)exp_sin - (int32_t)exp_cos;
            if (delta >= (int32_t)0x07000000) {
                f0 = ATAN2_CONST_PIOV2;
                goto stest;
            }
        }
        /* TANDIV: X = SINARG/COSARG (note: COSARG's OWN sign still
         * carried through this division at this point). */
        {
            halmat_scalar_t sx; sx.double_precision = true; sx.msw = f0; sx.lsw = 0;
            halmat_scalar_t cx; cx.double_precision = true; cx.msw = cosarg_bits; cx.lsw = 0;
            f0 = hrfp_divE(&sx, &cx).msw;
        }
        if ((int32_t)r7 >= 0) {
            /* NORM: COSARG>0, X already |SINARG|/|COSARG|. */
        } else {
            f0 = atan2_negate_ws(f0); /* LECR F0,F0 -- COSARG<0, make X positive */
            if ((int32_t)f0 <= (int32_t)ATAN2_CONST_LOWLIM) {
                f0 = ATAN2_CONST_PI;
                goto stest;
            }
        }
        if ((int32_t)f0 > (int32_t)ATAN2_CONST_HIGHLIM) {
            f0 = ATAN2_CONST_PIOV2;
            goto stest;
        }
    }

    /* ATAN1: main circuit, X=|SINARG| (ATAN entry) or the tangent ratio
     * just computed above (ATAN2 entry). */
    if ((int32_t)f0 > (int32_t)ATAN2_CONST_FLONE) {
        /* X>1: invert, ATAN(X) via ATAN(1/X)+table[2](=-PI/2). */
        uint32_t f2 = f0;
        halmat_scalar_t one; one.double_precision = true; one.msw = ATAN2_CONST_FLONE; one.lsw = 0;
        halmat_scalar_t f2s; f2s.double_precision = true; f2s.msw = f2; f2s.lsw = 0;
        f0 = hrfp_divE(&one, &f2s).msw;
        r2_data = ATAN2_DATA2;
    }

    if ((int32_t)f0 < (int32_t)ATAN2_CONST_SMALL) {
        /* REDUC: X<16**-3 -- ATAN(X)~=X, avoids a pointless (and
         * underflow-prone) polynomial evaluation. F0 already holds X
         * (or 1/X). */
    } else {
        if ((int32_t)f0 > (int32_t)ATAN2_CONST_TAN15) {
            /* SQRT3 reduction: ATAN(X)=PI/6+ATAN(Y),
             * Y=(X*SQRT3-1)/(X+SQRT3), computed as X(SQRT3-1)-1+X to
             * protect significant bits (the routine's own comment). */
            uint32_t f2 = f0;
            f0 = log_mul(f0, ATAN2_CONST_RT3M1);
            f0 = log_sub(f0, ATAN2_CONST_FLONE);
            f0 = log_add(f0, f2);
            f2 = log_add(f2, ATAN2_CONST_RT3);
            f0 = log_div(f0, f2);
            r2_data = (r2_data == ATAN2_DATA2) ? ATAN2_DATA3 : ATAN2_DATA1;
        }
        /* OK: ATAN(X)/X = D + C*X**2 + B/(X**2+A), then multiply back
         * by X (trace-verified against a real SQRT(1.25)-adjacent
         * ATAN(0.1) execution, task 100/id 51). */
        uint32_t f4 = f0;
        f0 = log_mul(f0, f0);
        uint32_t f2 = f0;
        f0 = log_mul(f0, ATAN2_CONST_C);
        f2 = log_add(f2, ATAN2_CONST_A);
        uint32_t f6 = ATAN2_CONST_B;
        f6 = log_div(f6, f2);
        f0 = log_add(f0, f6);
        f0 = log_add(f0, ATAN2_CONST_D);
        f0 = log_mul(f0, f4);
    }

    /* READY: apply the table-selected angle offset, then force the
     * result positive (STEST/POSOK below handle the real sign). */
    f0 = log_add(f0, r2_data);
    if ((int32_t)f0 < 0) f0 = atan2_negate_ws(f0);

    if (is_atan2) {
        /* POSOK: EATAN2 entry only -- if COSARG<0, reflect through
         * PI-F0 to place the answer in the correct half-plane. */
        if ((int32_t)cosarg_bits < 0) {
            f0 = log_sub(ATAN2_CONST_PI, f0);
            if ((int32_t)f0 < 0) f0 = atan2_negate_ws(f0);
        }
    }

stest:
    /* STEST: sign of the answer must agree with the ORIGINAL SINARG's
     * own sign (r6, saved at entry, before |SINARG| was ever taken). */
    if ((int32_t)r6 < 0 && f0 != 0u) f0 = atan2_negate_ws(f0);

    halmat_scalar_t result;
    result.double_precision = false;
    result.msw = f0;
    result.lsw = 0;
    return result;
}

halmat_scalar_t hal_atan_single(halmat_scalar_t x) {
    return atan_or_atan2_single(x.msw, 0u, false);
}

halmat_scalar_t hal_atan2_single(halmat_scalar_t sinarg, halmat_scalar_t cosarg) {
    return atan_or_atan2_single(sinarg.msw, cosarg.msw, true);
}

/* DATAN2.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/
 * DATAN2.asm) -- transcribed verbatim as {msw,lsw} pairs. DATA2/DATA3
 * are each biased by +1 relative to their "true" angle offset (-PI/2,
 * -PI/3) -- a real "protect significant bits" trick, the same idea as
 * the SQRT3-reduction's own X(SQRT3-1)-1+X rewrite: whenever the X>1
 * branch is taken, a separate ZERO/ONE-selected SED step below
 * subtracts exactly 1 back out, cancelling the bias (confirmed by
 * decoding DATA3's own bit pattern, which numerically equals -PI/3+1,
 * not -PI/3, and by DATAN2.asm's own literal "-PI/2+1" comment on the
 * DATA2 line). */
#define DATAN2_FLONE_MSW 0x41100000u
#define DATAN2_FLONE_LSW 0x00000000u
#define DATAN2_PI_MSW 0x413243F6u
#define DATAN2_PI_LSW 0xA8885A2Fu
#define DATAN2_PIOV2_MSW 0x411921FBu
#define DATAN2_PIOV2_LSW 0x54442D18u
#define DATAN2_LOWLIM_MSW 0x33100000u /* 16**-14 */
#define DATAN2_HIGHLIM_MSW 0x4F100000u /* 16**14 */
#define DATAN2_NEG3_SHIFTED 0xFD000000u /* -3, pre-shifted to the characteristic-byte position (real hardware's own L R2,NEG3 loads only NEG3's own top fullword) */
#define DATAN2_THIRTEEN_SHIFTED 0x0D000000u /* 13, same convention */
#define DATAN2_C1_MSW 0xBF1E31FFu
#define DATAN2_C1_LSW 0x1784B965u
#define DATAN2_C2_MSW 0xC0ACDB34u
#define DATAN2_C2_LSW 0xC0D1B35Du
#define DATAN2_C3_MSW 0x412B7CE4u
#define DATAN2_C3_LSW 0x5AF5C165u
#define DATAN2_C4_MSW 0xC11A8F92u
#define DATAN2_C4_LSW 0x3B178C78u
#define DATAN2_C5_MSW 0x412AB4FDu
#define DATAN2_C5_LSW 0x5D433FF6u
#define DATAN2_C6_MSW 0xC02298BBu
#define DATAN2_C6_LSW 0x68CFD869u
#define DATAN2_C7_MSW 0x41154CEEu
#define DATAN2_C7_LSW 0x8B70CA99u
#define DATAN2_RT3M1_MSW 0x40BB67AEu
#define DATAN2_RT3M1_LSW 0x8584CAA8u
#define DATAN2_RT3_MSW 0x411BB67Au
#define DATAN2_RT3_LSW 0xE8584CABu
#define DATAN2_SMALL_MSW 0x3A100000u /* 16**-7 */
#define DATAN2_TAN15_MSW 0x40449851u
#define DATAN2_TAN15_LSW 0xC5F064ACu
#define DATAN2_DATA1_MSW 0x40860A91u /* PI/6 */
#define DATAN2_DATA1_LSW 0xC16B9B2Cu
#define DATAN2_DATA2_MSW 0xC0921FB5u /* -PI/2, biased +1 -- see comment above */
#define DATAN2_DATA2_LSW 0x4442D184u
#define DATAN2_DATA3_MSW 0xBFC15238u /* -PI/3, biased +1 -- see comment above */
#define DATAN2_DATA3_LSW 0x2D736574u

static halmat_scalar_t dx_mk(uint32_t msw, uint32_t lsw) {
    halmat_scalar_t v; v.double_precision = true; v.msw = msw; v.lsw = lsw; return v;
}

/* QDEDR/QDED -- a Newton-refined extended-precision divide, expanded
 * literally from a real disassembly (DATAN2.lst/CTOE.lst's own shared
 * QDEDR macro): plain DER/DE are a NARROWING divide on real hardware
 * -- BOTH the dividend AND the divisor are used msw-only (their own
 * lsw ignored entirely for the division itself), and the result is
 * msw-only too, with the destination's own companion register left
 * completely untouched (still whatever the DIVIDEND's own original
 * lsw was, since the dividend register IS the divide's destination in
 * both DER/DE forms here). An initial attempt used hrfp_divE's own
 * full-precision (msw+lsw) inputs, reasoning the extra input
 * precision was needed for a correct msw -- this happened to not
 * change any of ATAN2's own test results (every dividend/divisor's
 * own lsw was apparently 0 at each of THIS routine's own QDEDR call
 * sites), but a real trace of RUNASM/MM14DN.asm's own QDEDR usage
 * (task 107/id 51, a case with a genuinely nonzero divisor lsw) proved
 * definitively that real DER/DE narrow the INPUT too -- feeding the
 * full-precision divisor into hrfp_divE there computed a measurably
 * wrong msw, while narrowing both operands to msw-only reproduced the
 * traced answer exactly. */
static halmat_scalar_t datan2_qdedr(halmat_scalar_t dividend, halmat_scalar_t divisor) {
    halmat_scalar_t dividend_narrow = dx_mk(dividend.msw, 0);
    halmat_scalar_t divisor_narrow = dx_mk(divisor.msw, 0);
    uint32_t approx_msw = hrfp_divE(&dividend_narrow, &divisor_narrow).msw; /* DER -- narrow msw-only divide */
    halmat_scalar_t approx = dx_mk(approx_msw, dividend.lsw); /* companion NOT written -- dividend's own original lsw */
    halmat_scalar_t err = hrfp_mulQeE(&approx, &divisor); /* MED -- genuinely extended, both halves written */
    err = hrfp_subE(&err, &dividend); /* SED -- genuinely extended */
    halmat_scalar_t err_narrow = dx_mk(err.msw, 0);
    uint32_t err_div_msw = hrfp_divE(&err_narrow, &divisor_narrow).msw; /* DE -- narrow msw-only divide */
    halmat_scalar_t err_div = dx_mk(err_div_msw, err.lsw); /* companion NOT written -- err's own lsw from SED */
    return hrfp_subE(&approx, &err_div); /* SEDR -- genuinely extended */
}

/* Exposed alias for interp.c's own OP_SSDV (id 69, yagpc2-yahalmat2-
 * issues.db): a real yaGPC2 --trace of a plain, unrelated `C=A/B;`
 * (both DOUBLE, no RTL call involved at all) showed real hardware's
 * own compiled "/" between two DOUBLE scalars expands to this EXACT
 * same QDEDR macro, instruction-for-instruction -- not scoped to
 * "dividing by a value that just came from an RTL call result" as
 * first suspected when this gap was found (GOOGLE-PARALLAX.hal's own
 * `EOR / TAN(...)`), it's how EVERY double SSDV compiles. A companion
 * trace of a plain SINGLE-precision `/` confirmed that one compiles to
 * a single plain DE instead -- genuinely different per precision, so
 * this is scoped to DOUBLE only, single continues to use value.c's own
 * halmat_scalar_divide. Given the exact same name (not "datan2_qdedr")
 * now that it's used well outside DATAN2's own scope. */
halmat_scalar_t hal_qdedr_double(halmat_scalar_t dividend, halmat_scalar_t divisor) {
    return datan2_qdedr(dividend, divisor);
}

/* TAN.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/TAN.asm). */
#define TAN_CONST_FOVPI_MSW 0x41145F30u
#define TAN_CONST_FOVPI_LSW 0x6DC9C883u
#define TAN_CONST_CHAR46_MSW 0x46100000u
#define TAN_CONST_ONE_MSW 0x41100000u
#define TAN_CONST_HALF_MSW 0x40800000u
#define TAN_CONST_UNFLO_MSW 0x3B100000u
#define TAN_CONST_B2_MSW 0xC028C93Fu
#define TAN_CONST_B1_MSW 0x415B40FDu
#define TAN_CONST_B0_MSW 0xC1AC5D33u
#define TAN_CONST_A0_MSW 0xC1875FDCu

/* LECR-bug workaround (see atan2_negate_ws's own identically-described
 * comment) -- redefined locally rather than exposed, matching this
 * file's own established per-routine-static convention (mxd_negate in
 * hal_matrix.c, etc). */
static uint32_t tan_negate_ws(uint32_t a) { return (a == 0u) ? a : (a ^ 0x80000000u); }

/* TAN: authentic AP-101S RUNASM/TAN.asm port (id 66, yagpc2-yahalmat2-
 * issues.db). Ported directly from the primary source's own documented
 * algorithm (range-reduce |X|*4/PI into octant+fraction via the CHAR46
 * bias trick, evaluate a rational polynomial in W=fraction or 1-
 * fraction, divide or reciprocal-divide depending on octant, fix
 * sign) -- every ME/MER/AE/DER step is genuinely EXACT (hrfp_mulE, not
 * the rounded hrfp_mulQeE MED/MEDR uses), matching TAN.asm's own
 * consistent use of the non-D-suffixed single-precision opcode family
 * throughout (confirmed instruction-by-instruction against the primary
 * source; DTAN.asm below is the one that needs the rounded family).
 * F0 itself is never sign-corrected mid-routine (only F4, the "W" copy,
 * gets the JOIN-label abs-value treatment) -- F0's own raw (possibly
 * negative, in the odd-octant case) value still feeds the later U=W**2
 * squaring step and the SKIP-shortcut's own linear term, both of which
 * are insensitive to that sign by construction (squaring, or a
 * magnitude far smaller than the additive constant it's combined
 * with) -- not a bug, a real hardware economy confirmed by reading
 * TAN.asm's own single unified JOIN/WPOS abs-value step rather than
 * duplicating sign-fix logic in each of the odd/even branches. */
halmat_scalar_t hal_tan_single(halmat_scalar_t x_in, bool *singular) {
    if (singular) *singular = false;
    bool was_negative = (x_in.msw & 0x80000000u) != 0u;
    uint32_t f0 = was_negative ? tan_negate_ws(x_in.msw) : x_in.msw; /* LER F0,F0 ; BNM POS ; LECR F0,F0 -- |X| */

    halmat_scalar_t xf = {true, f0, 0};
    halmat_scalar_t fovpi = {true, TAN_CONST_FOVPI_MSW, TAN_CONST_FOVPI_LSW};
    halmat_scalar_t red = hrfp_mulQeE(&xf, &fovpi); /* MED F0,FOVPI -- genuinely extended, rounded */

    uint32_t compr = (red.msw & 0xFF000000u) + 8u; /* LFXR R5,F0 ; N R5,MASK ; A R5,QTAN ; ST R5,COMPR */

    double red_msw_d = halmat_scalar_to_double((halmat_scalar_t){false, red.msw, 0});
    halmat_scalar_t frac;
    uint32_t octant;
    if (red_msw_d < 1.0) {
        /* CER F0,F4(=1.0) ; BNL NORMAL -- not taken: X*4/PI already <1,
         * so it's its own fraction with no reduction needed (ZB
         * OCTANT+3,X'00FF' forces octant=0 explicitly). */
        frac = red;
        octant = 0;
    } else {
        halmat_scalar_t char46 = {true, TAN_CONST_CHAR46_MSW, 0};
        halmat_scalar_t biased = hrfp_addE(&red, &char46); /* AED F0,CHAR46 */
        octant = biased.msw; /* LER F2,F0 -- also OCTANT's own bit-test source below */
        halmat_scalar_t int_part_narrow = {true, biased.msw, 0}; /* F2:F3, F3=0 (SER F3,F3 earlier) */
        frac = hrfp_subE(&red, &int_part_narrow); /* SEDR F0,F2 -- fraction = red(full) - biased(msw-narrowed) */
        if (octant & 1u) {
            halmat_scalar_t one_d = {true, TAN_CONST_ONE_MSW, 0};
            frac = hrfp_subE(&frac, &one_d); /* SED F0,ONE (fraction-1; JOIN's own abs-value step below yields the intended 1-fraction magnitude) */
        }
    }

    uint32_t f4 = (frac.msw & 0x80000000u) ? tan_negate_ws(frac.msw) : frac.msw; /* JOIN: LER F4,F0 ; BNM WPOS ; LECR F4,F4 -- W=|fraction| */

    double f4d = halmat_scalar_to_double((halmat_scalar_t){false, f4, 0});
    double unflo_d = halmat_scalar_to_double((halmat_scalar_t){false, TAN_CONST_UNFLO_MSW, 0});

    halmat_scalar_t p, q;
    if (f4d < unflo_d) {
        /* SKIP shortcut (avoid extraneous underflow, W tiny): F2 stays
         * the SER-F2,F2 zero from JOIN, so Q=B0 alone; F0 (=frac, its
         * own raw pre-abs sign) skips the U=W**2 squaring entirely. */
        halmat_scalar_t zero_s = {true, 0, 0};
        halmat_scalar_t b0 = {true, TAN_CONST_B0_MSW, 0};
        q = hrfp_addE(&zero_s, &b0); /* AE F2,B0 */
        halmat_scalar_t a0 = {true, TAN_CONST_A0_MSW, 0};
        halmat_scalar_t fracA0 = hrfp_addE(&frac, &a0); /* AE F0,A0 */
        halmat_scalar_t f4s = {true, f4, 0};
        p = hrfp_mulE(&fracA0, &f4s); /* MER F0,F4 */
    } else {
        halmat_scalar_t frac_s = {true, frac.msw, 0};
        halmat_scalar_t u = hrfp_mulE(&frac_s, &frac_s); /* MER F0,F0 -- U=W**2 (exact; sign-independent) */
        halmat_scalar_t half_s = {true, TAN_CONST_HALF_MSW, 0};
        u = hrfp_mulE(&u, &half_s); /* ME F0,HALF -- U=W**2/2 */
        halmat_scalar_t b2 = {true, TAN_CONST_B2_MSW, 0};
        halmat_scalar_t q2 = hrfp_mulE(&u, &b2); /* LER F2,F0 ; ME F2,B2 */
        halmat_scalar_t b1 = {true, TAN_CONST_B1_MSW, 0};
        q2 = hrfp_addE(&q2, &b1); /* AE F2,B1 */
        q2 = hrfp_mulE(&q2, &u); /* MER F2,F0 */
        halmat_scalar_t b0 = {true, TAN_CONST_B0_MSW, 0};
        q = hrfp_addE(&q2, &b0); /* SKIP: AE F2,B0 -- Q(U)=(B2*U+B1)*U+B0 */
        halmat_scalar_t a0 = {true, TAN_CONST_A0_MSW, 0};
        halmat_scalar_t p2 = hrfp_addE(&u, &a0); /* AE F0,A0 (F0=U here) */
        halmat_scalar_t f4s = {true, f4, 0};
        p = hrfp_mulE(&p2, &f4s); /* MER F0,F4 -- P(W)=W*(U+A0) */
    }

    bool use_cot = ((octant & 3u) == 1u) || ((octant & 3u) == 2u); /* TRB R7,X'0003' ; BM COTN */
    uint32_t result_msw;
    if (!use_cot) {
        result_msw = hrfp_divE(&p, &q).msw; /* DER F0,F2 -- TAN(W*PI/4)=P/Q */
    } else {
        double compr_d = halmat_scalar_to_double((halmat_scalar_t){false, compr, 0});
        if (f4d <= compr_d) {
            /* CE F4,COMPR ; BNH ERROR2 -- too close to a singularity;
             * caller applies the standard fixup. */
            if (singular) *singular = true;
            return (halmat_scalar_t){false, 0, 0};
        }
        result_msw = hrfp_divE(&q, &p).msw; /* DER F2,F0 -- COT(W*PI/4)=Q/P */
    }

    bool flip = (octant & 2u) != 0u; /* TRB R7,X'0002' */
    if (flip) result_msw = tan_negate_ws(result_msw);
    if (was_negative) result_msw = tan_negate_ws(result_msw);

    return (halmat_scalar_t){false, result_msw, 0};
}

/* DTAN.asm's own DC constants (Source Code/PASS.REL32V0/RUNASM/DTAN.asm)
 * -- FOUROVPI's own lsw genuinely differs from TAN.asm's own FOVPI
 * constant (...C882 here vs ...C883 there) -- confirmed by reading both
 * primary sources directly, not a transcription slip; each routine uses
 * its own distinct hand-tabulated constant, so they are NOT
 * interchangeable. */
#define DTAN_CONST_FOUROVPI_MSW 0x41145F30u
#define DTAN_CONST_FOUROVPI_LSW 0x6DC9C882u
#define DTAN_CONST_CH4E_MSW 0x4E100000u
#define DTAN_CONST_ONE_MSW 0x41100000u
#define DTAN_CONST_UNFLO_MSW 0x35400000u
#define DTAN_CONST_A2_MSW 0xC325FD4Au
#define DTAN_CONST_A2_LSW 0x87357CAFu
#define DTAN_CONST_A1_MSW 0x44AFFA63u
#define DTAN_CONST_A1_LSW 0x93159226u
#define DTAN_CONST_A0_MSW 0xC58AFDD0u
#define DTAN_CONST_A0_LSW 0xA41992D4u
#define DTAN_CONST_B3_MSW 0x422376F1u
#define DTAN_CONST_B3_LSW 0x71F72282u
#define DTAN_CONST_B2_MSW 0xC41926DBu
#define DTAN_CONST_B2_LSW 0xBB1F469Bu
#define DTAN_CONST_B1_MSW 0x4532644Bu
#define DTAN_CONST_B1_LSW 0x1E45A133u
#define DTAN_CONST_B0_MSW 0xC5B0F82Cu
#define DTAN_CONST_B0_LSW 0x871A3B68u

/* TAN built-in on a genuinely DOUBLE-precision argument: DTAN.asm's own
 * port (id 66's actual repro, GOOGLE-PARALLAX.hal). Same overall shape
 * as hal_tan_single above (see that function's own header comment for
 * the shared range-reduction/sign-fix structure), confirmed via a real
 * yaGPC2 --trace of the exact repro, but with genuine double-precision-
 * only differences: a CUBIC polynomial (not quadratic) evaluated via
 * genuinely-extended (both-halves-written) AED/MEDR arithmetic
 * throughout (hrfp_mulQeE/hrfp_addE, not the single-register-truncating
 * ME/MER family single precision uses), and QDEDR (datan2_qdedr, this
 * file's own already-verified Newton-refined extended divide) for the
 * final TAN/COT divide instead of a plain narrowing DER. F0(=`frac`)
 * itself is NEVER reassigned to its own abs value mid-routine (only a
 * SEPARATE copy, `w`, gets that treatment at JOIN) -- `frac`'s own raw
 * (possibly negative, odd-octant) value still feeds the later U=W**2
 * squaring (sign-independent) and the SKIP-shortcut's own B3*frac
 * linear term (whose magnitude is dominated by the additive B0/A0
 * constants regardless of frac's own sign there) -- same real-hardware
 * economy as hal_tan_single, not a bug. */
halmat_scalar_t hal_tan_double(halmat_scalar_t x_in, bool *singular) {
    if (singular) *singular = false;
    bool was_negative = (x_in.msw & 0x80000000u) != 0u;
    halmat_scalar_t xf = was_negative ? dx_mk(x_in.msw ^ 0x80000000u, x_in.lsw) : x_in; /* LER F0,F0 ; BNM POS ; LECR F0,F0 -- |X| (lsw has no sign of its own) */

    halmat_scalar_t fourovpi = dx_mk(DTAN_CONST_FOUROVPI_MSW, DTAN_CONST_FOUROVPI_LSW);
    halmat_scalar_t red = hrfp_mulQeE(&xf, &fourovpi); /* MED F0,FOUROVPI */

    /* LFXR R5,F0 ; NHI R5,X'FF00' ; STH R5,TEST -- TEST is an 8-byte
     * workarea first loaded whole with INIT (0x0000000000000008) at
     * DTAN's very start, then only its own TOP halfword overwritten
     * here -- net effect confirmed by tracing the byte splice: TEST's
     * own final msw is red's own masked top byte, its own lsw is
     * INIT's own untouched lsw (0x00000008). */
    halmat_scalar_t test_d = dx_mk(red.msw & 0xFF000000u, 0x00000008u);

    double red_msw_d = halmat_scalar_to_double(dx_mk(red.msw, 0)); /* CER F0,F4(=1.0) reads F0's own msw only */
    halmat_scalar_t frac;
    uint32_t octant;
    if (red_msw_d < 1.0) {
        frac = red; /* BNL NORMAL not taken -- ZB OCTANT+3,X'00FF' forces octant=0 */
        octant = 0;
    } else {
        halmat_scalar_t ch4e = dx_mk(DTAN_CONST_CH4E_MSW, 0);
        halmat_scalar_t biased = hrfp_addE(&red, &ch4e); /* LER F2,F0 ; LER F3,F1 ; AED F2,CH4E */
        octant = biased.msw; /* STED F2,OCTANT -- bit-test source, BEFORE subtracting CH4E back out */
        halmat_scalar_t int_part = hrfp_subE(&biased, &ch4e); /* SED F2,CH4E */
        frac = hrfp_subE(&red, &int_part); /* SEDR F0,F2 -- red itself was never biased, unlike single */
        if (octant & 1u) {
            halmat_scalar_t one_d = dx_mk(DTAN_CONST_ONE_MSW, 0);
            frac = hrfp_subE(&frac, &one_d); /* SEDR F0,F4(=1.0) */
        }
    }

    halmat_scalar_t w = (frac.msw & 0x80000000u) ? dx_mk(frac.msw ^ 0x80000000u, frac.lsw) : frac; /* JOIN: |W|, a genuinely separate copy (frac itself keeps its own raw sign) */

    double wd = halmat_scalar_to_double(w);
    double unflo_d = halmat_scalar_to_double(dx_mk(DTAN_CONST_UNFLO_MSW, 0));

    halmat_scalar_t p, q;
    if (wd < unflo_d) {
        /* SKIP shortcut: Q keeps a genuine (rounded) B3*frac linear
         * term (DOUBLE's own cubic polynomial has no all-zero shortcut
         * the way single's quadratic one does); P's own "*1.0" step is
         * NOT a no-op -- MEDR/mulQeE genuinely rounds its OTHER operand
         * to 31 bits regardless of the multiplier's own value, so it's
         * modeled explicitly rather than elided. */
        halmat_scalar_t b3 = dx_mk(DTAN_CONST_B3_MSW, DTAN_CONST_B3_LSW);
        halmat_scalar_t q2 = hrfp_mulQeE(&b3, &frac); /* MEDR F2,F0 */
        halmat_scalar_t b0 = dx_mk(DTAN_CONST_B0_MSW, DTAN_CONST_B0_LSW);
        q = hrfp_addE(&q2, &b0); /* AED F2,B0 */
        halmat_scalar_t one_d2 = dx_mk(DTAN_CONST_ONE_MSW, 0);
        halmat_scalar_t frac_x1 = hrfp_mulQeE(&frac, &one_d2); /* MEDR F0,F4(=1.0) */
        halmat_scalar_t a0 = dx_mk(DTAN_CONST_A0_MSW, DTAN_CONST_A0_LSW);
        halmat_scalar_t p2 = hrfp_addE(&frac_x1, &a0); /* AED F0,A0 */
        p = hrfp_mulQeE(&p2, &w); /* LED F4,TEMP ; MEDR F0,F4 */
    } else {
        halmat_scalar_t u = hrfp_mulQeE(&frac, &frac); /* MEDR F0,F0 -- U=W**2, rounded */
        halmat_scalar_t a2 = dx_mk(DTAN_CONST_A2_MSW, DTAN_CONST_A2_LSW);
        halmat_scalar_t inner = hrfp_addE(&u, &a2); /* AED F4,A2 */
        inner = hrfp_mulQeE(&inner, &u); /* MEDR F4,F0 */
        halmat_scalar_t a1 = dx_mk(DTAN_CONST_A1_MSW, DTAN_CONST_A1_LSW);
        inner = hrfp_addE(&inner, &a1); /* AED F4,A1 -- inner=(U+A2)*U+A1 */

        halmat_scalar_t b3 = dx_mk(DTAN_CONST_B3_MSW, DTAN_CONST_B3_LSW);
        halmat_scalar_t q2 = hrfp_mulQeE(&b3, &u); /* MEDR F2,F0 */
        halmat_scalar_t b2 = dx_mk(DTAN_CONST_B2_MSW, DTAN_CONST_B2_LSW);
        q2 = hrfp_addE(&q2, &b2); /* AED F2,B2 */
        q2 = hrfp_mulQeE(&q2, &u); /* MEDR F2,F0 */
        halmat_scalar_t b1 = dx_mk(DTAN_CONST_B1_MSW, DTAN_CONST_B1_LSW);
        q2 = hrfp_addE(&q2, &b1); /* AED F2,B1 */
        q2 = hrfp_mulQeE(&q2, &u); /* SKIP: MEDR F2,F0 */
        halmat_scalar_t b0 = dx_mk(DTAN_CONST_B0_MSW, DTAN_CONST_B0_LSW);
        q = hrfp_addE(&q2, &b0); /* AED F2,B0 -- Q(U)=((B3*U+B2)*U+B1)*U+B0 */

        halmat_scalar_t p2 = hrfp_mulQeE(&u, &inner); /* MEDR F0,F4 */
        halmat_scalar_t a0 = dx_mk(DTAN_CONST_A0_MSW, DTAN_CONST_A0_LSW);
        p2 = hrfp_addE(&p2, &a0); /* AED F0,A0 -- P_partial=U*inner+A0 */
        p = hrfp_mulQeE(&p2, &w); /* LED F4,TEMP ; MEDR F0,F4 -- P(W)=P_partial*W */
    }

    bool use_cot = ((octant & 3u) == 1u) || ((octant & 3u) == 2u); /* TB OCTANT+3,X'0003' ; BM COTN */
    halmat_scalar_t result;
    if (!use_cot) {
        result = datan2_qdedr(p, q); /* QDEDR F0,F2 -- TAN(W*PI/4)=P/Q */
    } else {
        double test_dv = halmat_scalar_to_double(test_d);
        if (wd <= test_dv) {
            /* CED F4,TEST ; BNH ERROR2 -- singularity, caller fixup. */
            if (singular) *singular = true;
            return dx_mk(0, 0);
        }
        result = datan2_qdedr(q, p); /* QDEDR F2,F0 -- COT(W*PI/4)=Q/P */
    }

    bool flip = (octant & 2u) != 0u; /* TB OCTANT+3,X'0002' */
    if (flip && result.msw != 0u) result.msw ^= 0x80000000u;
    if (was_negative && result.msw != 0u) result.msw ^= 0x80000000u;

    return result;
}

/* DATAN2.asm's own DATAN2 entry point (hal_atan2_single's own header
 * comment explains why DATAN, the single-arg double-precision sibling
 * entry, is never ported -- no real compiled call into it was ever
 * observed). Structurally mirrors atan_or_atan2_single above (same
 * three-way range reduction, same STEST/POSOK sign-fixup shape) but
 * every arithmetic step is a genuine extended (F0:F1) operation, and an
 * extra CHKHI/CHKLO/SCALE block (rarely exercised -- needs an extreme
 * SINARG/COSARG exponent ratio -- but translated faithfully rather than
 * skipped) rescales both exponents before the tangent divide to avoid
 * overflow/underflow that single precision's own narrower dynamic range
 * never risked in the same way. */
halmat_scalar_t hal_atan2_double(halmat_scalar_t sinarg, halmat_scalar_t cosarg) {
    uint32_t r6 = sinarg.msw; /* LFXR R6,F0 -- original SINARG sign, saved for STEST */
    uint32_t f0 = sinarg.msw, f1 = sinarg.lsw;
    if ((int32_t)f0 < 0) f0 = atan2_negate_ws(f0); /* LER F0,F0 ; BNM TEST1 ; LECR F0,F0 -- F0:F1 = |SINARG| (lsw has no sign of its own) */

    uint32_t r7 = cosarg.msw; /* LFXR R7,F2 */
    uint32_t f2 = cosarg.msw, f3 = cosarg.lsw;

    if (f2 == 0u) {
        if (r6 == 0u) {
            /* ERROR: SINARG=COSARG=0 -- caller's own responsibility
             * (error 62), matching hal_atan2_single's own convention;
             * interp.c's own case 47 already guards this before ever
             * calling here. */
            return dx_mk(0, 0);
        }
        /* VALUE: COSARG=0, SINARG!=0 -- exactly +/-PI/2. */
        f0 = DATAN2_PIOV2_MSW; f1 = DATAN2_PIOV2_LSW;
        goto stest;
    }

    if (f0 != 0u) {
        uint32_t exp_sin = f0 & 0x7F000000u;
        uint32_t exp_cos = f2 & 0x7F000000u;
        int32_t delta = (int32_t)exp_sin - (int32_t)exp_cos;
        if (delta >= (int32_t)0x0F000000) {
            /* IF DELTA >= 15*16**2, RETURN +/-PI/2. */
            f0 = DATAN2_PIOV2_MSW; f1 = DATAN2_PIOV2_LSW;
            goto stest;
        }
        if (delta < (int32_t)0xCD000000) {
            /* IF DELTA < -51*16**2, RETURN ARCTAN(0). */
            f0 = 0; f1 = 0;
            goto posok;
        }
        /* CHKHI/CHKLO/SCALE -- rescale both exponents by +13 or -3 to
         * avoid overflow/underflow in the tangent divide below, for
         * SINARG exponents (in raw excess-64 byte form) outside
         * [13,61). */
        if ((int32_t)exp_sin >= (int32_t)0x7D000000 || (int32_t)exp_sin < (int32_t)0x0D000000) {
            uint32_t scale = ((int32_t)exp_sin >= (int32_t)0x7D000000) ? DATAN2_NEG3_SHIFTED : DATAN2_THIRTEEN_SHIFTED;
            uint32_t r5 = (f2 & 0x7FFF0000u) + scale; /* NHI R5,X'7FFF' ; AR R5,R2 */
            uint32_t r4 = (f0 & 0x7FFF0000u) + scale; /* NHI R4,X'7FFF' ; AR R4,R2 */
            f0 = r4 | (f0 & 0x0000FFFFu); /* ZRB R2,X'FFFF' ; OR R4,R2 ; LFLR F0,R4 */
            f2 = r5 | (f2 & 0x00007FFFu); /* ZRB R2,X'7FFF' ; OR R5,R2 ; LFLR F2,R5 */
        }
    }

    /* TANDIV: X = |SINARG|/COSARG (COSARG's own sign still carried
     * through this divide at this point). */
    {
        halmat_scalar_t sx = dx_mk(f0, f1);
        halmat_scalar_t cx = dx_mk(f2, f3);
        halmat_scalar_t q = datan2_qdedr(sx, cx);
        f0 = q.msw; f1 = q.lsw;
    }
    if ((int32_t)r7 >= 0) {
        /* NORM: COSARG>0, X already |SINARG|/|COSARG|. */
    } else {
        f0 = atan2_negate_ws(f0); /* LECR F0,F0 -- COSARG<0, make X positive */
        if ((int32_t)f0 <= (int32_t)DATAN2_LOWLIM_MSW) {
            f0 = DATAN2_PI_MSW; f1 = DATAN2_PI_LSW;
            goto stest;
        }
    }
    if ((int32_t)f0 > (int32_t)DATAN2_HIGHLIM_MSW) {
        f0 = DATAN2_PIOV2_MSW; f1 = DATAN2_PIOV2_LSW;
        goto stest;
    }

    /* DATAN1: main circuit, X=tangent ratio just computed above. */
    {
        uint32_t data_msw = 0, data_lsw = 0; /* r2: DATA[0] by default */
        uint32_t zo_msw = 0, zo_lsw = 0; /* r3: ZERO by default */

        if ((int32_t)f0 > (int32_t)DATAN2_FLONE_MSW) {
            /* X>1: invert via 1/X, table offset -PI/2(+1), and remember
             * to subtract that +1 bias back out below (r3->ONE). */
            halmat_scalar_t xv = dx_mk(f0, f1);
            halmat_scalar_t one = dx_mk(DATAN2_FLONE_MSW, DATAN2_FLONE_LSW);
            halmat_scalar_t inv = datan2_qdedr(one, xv);
            f0 = inv.msw; f1 = inv.lsw;
            data_msw = DATAN2_DATA2_MSW; data_lsw = DATAN2_DATA2_LSW;
            zo_msw = DATAN2_FLONE_MSW; zo_lsw = DATAN2_FLONE_LSW;
        }

        if ((int32_t)f0 >= (int32_t)DATAN2_SMALL_MSW) {
            /* X>=16**-7 -- not small enough for the ATAN(X)~=X shortcut. */
            if ((int32_t)f0 > (int32_t)DATAN2_TAN15_MSW) {
                /* SQRT3 reduction: Y=(X*SQRT3-1)/(X+SQRT3), computed as
                 * X(SQRT3-1)-1+X to protect significant bits (the
                 * routine's own comment, same trick as EATAN2.asm's own
                 * SQRT3 branch). */
                halmat_scalar_t xsave = dx_mk(f0, f1);
                halmat_scalar_t rt3m1 = dx_mk(DATAN2_RT3M1_MSW, DATAN2_RT3M1_LSW);
                halmat_scalar_t one = dx_mk(DATAN2_FLONE_MSW, DATAN2_FLONE_LSW);
                halmat_scalar_t rt3 = dx_mk(DATAN2_RT3_MSW, DATAN2_RT3_LSW);
                halmat_scalar_t t = hrfp_mulQeE(&xsave, &rt3m1); /* MED F0,RT3M1 */
                t = hrfp_subE(&t, &one); /* SED F0,FLONE */
                t = hrfp_addE(&t, &xsave); /* AEDR F0,F2 */
                halmat_scalar_t denom = hrfp_addE(&xsave, &rt3); /* AED F2,RT3 */
                halmat_scalar_t q = datan2_qdedr(t, denom);
                f0 = q.msw; f1 = q.lsw;
                if (data_msw == DATAN2_DATA2_MSW && data_lsw == DATAN2_DATA2_LSW) {
                    data_msw = DATAN2_DATA3_MSW; data_lsw = DATAN2_DATA3_LSW;
                } else {
                    data_msw = DATAN2_DATA1_MSW; data_lsw = DATAN2_DATA1_LSW;
                }
            }
            /* OK: ATAN(X)/X = D + C*X**2 + B/(X**2+A) (Horner-nested via
             * QDEDR below), then multiply back by X. */
            halmat_scalar_t xv = dx_mk(f0, f1);
            halmat_scalar_t f6 = xv; /* LER F6,F0 ; LER F7,F1 */
            halmat_scalar_t xsq = hrfp_mulQeE(&xv, &xv); /* MEDR F0,F0 */
            halmat_scalar_t c7 = dx_mk(DATAN2_C7_MSW, DATAN2_C7_LSW);
            halmat_scalar_t f4 = hrfp_addE(&c7, &xsq); /* LED F4,C7 ; AEDR F4,F0 */
            halmat_scalar_t c6 = dx_mk(DATAN2_C6_MSW, DATAN2_C6_LSW);
            halmat_scalar_t f2v = datan2_qdedr(c6, f4); /* LED F2,C6 ; QDEDR F2,F4 */
            halmat_scalar_t c5 = dx_mk(DATAN2_C5_MSW, DATAN2_C5_LSW);
            f2v = hrfp_addE(&f2v, &c5); /* AED F2,C5 */
            f2v = hrfp_addE(&f2v, &xsq); /* AEDR F2,F0 */
            halmat_scalar_t c4 = dx_mk(DATAN2_C4_MSW, DATAN2_C4_LSW);
            f4 = datan2_qdedr(c4, f2v); /* LED F4,C4 ; QDEDR F4,F2 */
            halmat_scalar_t c3 = dx_mk(DATAN2_C3_MSW, DATAN2_C3_LSW);
            f4 = hrfp_addE(&f4, &c3); /* AED F4,C3 */
            f4 = hrfp_addE(&f4, &xsq); /* AEDR F4,F0 */
            halmat_scalar_t c2 = dx_mk(DATAN2_C2_MSW, DATAN2_C2_LSW);
            f2v = datan2_qdedr(c2, f4); /* LED F2,C2 ; QDEDR F2,F4 */
            halmat_scalar_t c1 = dx_mk(DATAN2_C1_MSW, DATAN2_C1_LSW);
            f2v = hrfp_addE(&f2v, &c1); /* AED F2,C1 */
            halmat_scalar_t f0f1 = hrfp_mulQeE(&xsq, &f2v); /* MEDR F0,F2 */
            f0f1 = hrfp_mulQeE(&f0f1, &f6); /* MEDR F0,F6 */
            f0f1 = hrfp_addE(&f0f1, &f6); /* AEDR F0,F6 */
            f0 = f0f1.msw; f1 = f0f1.lsw;
        }
        /* else REDUC: X<16**-7, ATAN(X)~=X -- F0:F1 already holds X (or
         * 1/X), fall through unchanged. */

        /* READY: F0 += DATA[r2] ; F0 -= (ZERO or ONE), per the r3
         * selection above -- the ONE case cancels DATA2/DATA3's own +1
         * bias (see the constants' own header comment). */
        {
            halmat_scalar_t f0f1 = dx_mk(f0, f1);
            halmat_scalar_t data = dx_mk(data_msw, data_lsw);
            f0f1 = hrfp_addE(&f0f1, &data); /* AED F0,0(R2) */
            halmat_scalar_t zo = dx_mk(zo_msw, zo_lsw);
            f0f1 = hrfp_subE(&f0f1, &zo); /* SED F0,0(R2) */
            f0 = f0f1.msw; f1 = f0f1.lsw;
        }
        if ((int32_t)f0 < 0) f0 = atan2_negate_ws(f0); /* BNM POSOK ; LECR F0,F0 */
    }

posok:
    /* POSOK: ARCTAN2 entry always reaches here (R1 flag always nonzero)
     * -- if COSARG<0, reflect through PI-F0 to place the answer in the
     * correct half-plane. */
    if ((int32_t)r7 < 0) {
        halmat_scalar_t pi = dx_mk(DATAN2_PI_MSW, DATAN2_PI_LSW);
        halmat_scalar_t f0f1 = dx_mk(f0, f1);
        halmat_scalar_t diff = hrfp_subE(&pi, &f0f1); /* SEDR F2,F0 -- F2:F3 = PI - F0:F1 */
        f0 = diff.msw; f1 = diff.lsw; /* LER F1,F3 ; LER F0,F2 */
        if ((int32_t)f0 < 0) f0 = atan2_negate_ws(f0); /* BNM STEST ; LECR F0,F0 */
    }

stest:
    /* STEST: sign of the answer must agree with the ORIGINAL SINARG's
     * own sign (r6, saved at entry, before |SINARG| was ever taken). */
    if ((int32_t)r6 < 0 && f0 != 0u) f0 = atan2_negate_ws(f0);

    return dx_mk(f0, f1);
}
