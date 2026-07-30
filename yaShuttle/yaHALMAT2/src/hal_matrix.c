#include "hal_matrix.h"
#include "hal_random.h"

#define HAL_MATRIX_MAX_N 8

/* Plain single-precision (msw-only) wrappers -- same convention as
 * hal_transcendental.c's own log_add/log_sub/log_mul/log_div (real
 * single F-registers have no paired low word, so every intermediate
 * result is genuinely truncated back to 32 bits after each op). */
static uint32_t mx_mul(uint32_t a, uint32_t b) {
    halmat_scalar_t x; x.double_precision = true; x.msw = a; x.lsw = 0;
    halmat_scalar_t y; y.double_precision = true; y.msw = b; y.lsw = 0;
    return hrfp_mulE(&x, &y).msw;
}
static uint32_t mx_div(uint32_t a, uint32_t b) {
    halmat_scalar_t x; x.double_precision = true; x.msw = a; x.lsw = 0;
    halmat_scalar_t y; y.double_precision = true; y.msw = b; y.lsw = 0;
    return hrfp_divE(&x, &y).msw;
}
static uint32_t mx_add(uint32_t a, uint32_t b) {
    halmat_scalar_t x; x.double_precision = true; x.msw = a; x.lsw = 0;
    halmat_scalar_t y; y.double_precision = true; y.msw = b; y.lsw = 0;
    return hrfp_addE(&x, &y).msw;
}
static uint32_t mx_sub(uint32_t a, uint32_t b) {
    halmat_scalar_t x; x.double_precision = true; x.msw = a; x.lsw = 0;
    halmat_scalar_t y; y.double_precision = true; y.msw = b; y.lsw = 0;
    return hrfp_subE(&x, &y).msw;
}
/* LECR -- negate, except real hardware's own documented LECR bug means
 * an exact-zero operand is deliberately left un-negated everywhere
 * MM14SN's own source negates a swapped-in element (its own "WORKAROUND
 * FOR LECR BUG" comments, four separate call sites) -- replicated
 * exactly since a naive negate would flip +0.0 to a distinct -0.0 bit
 * pattern real hardware never actually produces here. */
static uint32_t mx_negate_ws(uint32_t a) { return (a == 0u) ? a : (a ^ 0x80000000u); }
static uint32_t mx_abs(uint32_t a) { return a & 0x7FFFFFFFu; }

bool hal_matrix_invert_single(const halmat_scalar_t *in, int n, halmat_scalar_t *out, hal_fpu_state_t *fpu) {
    if (n <= 0 || n > HAL_MATRIX_MAX_N) return false;

    uint32_t m[HAL_MATRIX_MAX_N][HAL_MATRIX_MAX_N];
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            m[i][j] = in[i * n + j].msw;

    if (n == 2) {
        /* IF DIM=2, CALCULATES INVERSE DIRECTLY -- MM14SN's own closed-
         * form branch, confirmed against the standard 2x2 inverse
         * formula [[d,-b],[-c,a]]/det via the routine's own literal
         * operand sequence (task 100/id 51's own derivation). SEDR F0,F2
         * genuinely reads the INCOMING fpu->f1 (no self-reset anywhere
         * in this branch) -- confirmed via a real trace where a prior
         * MATRIX**(-1) call's own leftover F1 measurably changed this
         * det computation's own result (hal_matrix.h's own header
         * comment). */
        uint32_t a = m[0][0], b = m[0][1], c = m[1][0], d = m[1][1];
        /* F0's own companion is F1 (F2:F3's own F3 is never written
         * anywhere in this whole routine, confirmed absent from a real
         * trace, so bc's own lsw is safely 0) -- ad=F0 is the SEDR's
         * first (minuend) operand, so fpu->f1 belongs on `ad`, not `bc`. */
        halmat_scalar_t ad; ad.double_precision = true; ad.msw = mx_mul(a, d); ad.lsw = fpu->f1;
        halmat_scalar_t bc; bc.double_precision = true; bc.msw = mx_mul(b, c); bc.lsw = 0;
        halmat_scalar_t det_ext = hrfp_subE(&ad, &bc);
        fpu->f1 = det_ext.lsw;
        uint32_t det = det_ext.msw;
        if (det == 0u) return false;
        out[0] = (halmat_scalar_t){ .double_precision = false, .msw = mx_div(d, det), .lsw = 0 };
        out[1] = (halmat_scalar_t){ .double_precision = false, .msw = mx_div(mx_negate_ws(b), det), .lsw = 0 };
        out[2] = (halmat_scalar_t){ .double_precision = false, .msw = mx_div(mx_negate_ws(c), det), .lsw = 0 };
        out[3] = (halmat_scalar_t){ .double_precision = false, .msw = mx_div(a, det), .lsw = 0 };
        return true;
    }

    if (n == 3) {
        /* MM14S3.asm (via RUNASM/MM12S3.asm's own Sarrus-rule
         * determinant). m11..m33 use the same 1-based notation as both
         * source files' own comments. */
        uint32_t m11 = m[0][0], m12 = m[0][1], m13 = m[0][2];
        uint32_t m21 = m[1][0], m22 = m[1][1], m23 = m[1][2];
        uint32_t m31 = m[2][0], m32 = m[2][1], m33 = m[2][2];

        /* MM12S3.asm -- pure single precision throughout (plain ME/LE/
         * AER/SER, no AEDR/SEDR/MED anywhere in that file), computed in
         * the EXACT left-to-right instruction order of the source (not
         * associative-rearranged) since single-precision addition isn't
         * associative. */
        uint32_t det = mx_add(mx_add(mx_mul(mx_mul(m11, m22), m33),
                                      mx_mul(mx_mul(m12, m23), m31)),
                               mx_mul(mx_mul(m13, m21), m32));
        det = mx_sub(mx_sub(det, mx_mul(mx_mul(m31, m22), m13)),
                      mx_mul(mx_mul(m32, m23), m11));
        det = mx_sub(det, mx_mul(mx_mul(m33, m21), m12));
        if (det == 0u) return false; /* AOUT: singular */

        /* MM14S3.asm's own 9-way adjugate/DET division. Each SEDR
         * genuinely reads the F2:F3 or F4:F5 odd-companion register
         * pair -- historically MM14S3.asm never reset F3/F5 before any
         * of the 9 SEDRs, so (before id 72) this code modeled each
         * block's own SEDR-result lsw genuinely becoming the NEXT
         * block's own companion input. The DER that immediately follows
         * each SEDR is confirmed via a real trace to NOT touch its own
         * destination's companion at all, AND to genuinely IGNORE both
         * operands' own companion halves for the division itself (hand-
         * verified block 1 against the trace: msw-only -6.0/3.0=-2.0
         * matches the traced 0xc1200000 exactly) -- i.e. DER here is a
         * plain single-precision divide (mx_div), not an extended one.
         *
         * id 72 (yagpc2-yahalmat2-issues.db): the real RTL turned out to
         * have a genuine, undetected bug here -- a result silently
         * depending on unrelated prior floating-point call history, not
         * just the input matrix, is a defect, not intentional design
         * (confirmed and fixed on the MM14SN.asm side, the general-N
         * sibling of this same 9-block SEDR/companion-leak pattern, via
         * an &ASM101S-gated `SER F3,F3`/`SER F5,F5` pair immediately
         * before the equivalent AEDR -- see yaGPC2 commit 8439ae054).
         * MM14S3.asm itself has not yet been given its own equivalent
         * RTL patch, but the identical bug shape (single LE/ME loads
         * into F2/F4 immediately followed by a SEDR that reads BOTH
         * pairs' companions) means the same fix applies by direct
         * analogy -- both companions are now modeled as freshly zeroed
         * before every one of the 9 SEDRs, matching what the corrected
         * RTL does rather than the original buggy leak. No more
         * cross-block companion threading, and nothing survives to leak
         * into whatever RTL call comes next either. */
        uint32_t out9[9];

        /* Each block computes (A*B : companion 0) - (C*D : companion 0)
         * as a genuine extended SEDR (both companions freshly zeroed,
         * id 72), then divides the DIFFERENCE'S OWN MSW ONLY by det
         * (plain single DER -- see comment above). */
#define MM14S3_BLOCK(DEST_IS_F2, A, B, C, D, OUT_IDX) do { \
            uint32_t pa = mx_mul((A), (B)); \
            uint32_t pb = mx_mul((C), (D)); \
            halmat_scalar_t va, vb; \
            va.double_precision = true; vb.double_precision = true; \
            if (DEST_IS_F2) { va.msw = pa; va.lsw = 0; vb.msw = pb; vb.lsw = 0; } \
            else            { va.msw = pb; va.lsw = 0; vb.msw = pa; vb.lsw = 0; } \
            halmat_scalar_t diff = hrfp_subE(&va, &vb); \
            out9[(OUT_IDX)] = mx_div(diff.msw, det); \
        } while (0)

        MM14S3_BLOCK(true,  m22, m33, m32, m23, 0); /* I(1,1) */
        MM14S3_BLOCK(false, m12, m33, m32, m13, 1); /* I(1,2) */
        MM14S3_BLOCK(true,  m12, m23, m22, m13, 2); /* I(1,3) */
        MM14S3_BLOCK(false, m21, m33, m31, m23, 3); /* I(2,1) */
        MM14S3_BLOCK(true,  m11, m33, m31, m13, 4); /* I(2,2) */
        MM14S3_BLOCK(false, m11, m23, m21, m13, 5); /* I(2,3) */
        MM14S3_BLOCK(true,  m21, m32, m31, m22, 6); /* I(3,1) */
        MM14S3_BLOCK(false, m11, m32, m31, m12, 7); /* I(3,2) */
        MM14S3_BLOCK(true,  m11, m22, m21, m12, 8); /* I(3,3) */
#undef MM14S3_BLOCK

        for (int i = 0; i < 9; i++)
            out[i] = (halmat_scalar_t){ .double_precision = false, .msw = out9[i], .lsw = 0 };
        return true;
    }

    /* General N (N==3 handled separately above -- real hardware routes
     * it to MM14S3.asm, not this file's own general Gauss-Jordan path).
     * COMPLETE (row+column) pivoting, computing the inverse in place --
     * MM14SN's own documented algorithm (its header comment block).
     *
     * id 72 (yagpc2-yahalmat2-issues.db): this reduction phase's own
     * AEDR F4,F2 (A(I,J)+=A(I,K)*A(K,J)) previously modeled a genuine
     * single-precision accumulator (`f5_accum`) persisting across every
     * (I,J) step and across K iterations, matching real hardware's own
     * F5 register -- correctly, AS A DESCRIPTION OF THE ORIGINAL,
     * unpatched RTL (F1/F3/F5 really were never reset anywhere in the
     * historical MM14SN.asm, confirmed empirically absent from a real
     * execution trace). But that leak turned out to be a genuine,
     * undetected RTL BUG, not intentional design: three back-to-back,
     * bit-identical INVERSE(A4A) calls on the same singular matrix
     * produced three different (sometimes wildly wrong) results because
     * this AEDR's own F2:F3/F4:F5 companions carried forward whatever
     * unrelated prior floating-point work (e.g. an intervening WRITE
     * statement's own formatting) happened to leave them as -- not a
     * function of the matrix being inverted at all. Fixed on the real
     * RTL side via an &ASM101S-gated `SER F3,F3`/`SER F5,F5` pair
     * immediately before this exact AEDR (yaGPC2 commit 8439ae054,
     * verified end-to-end: all three repeated calls now produce an
     * identical, correct result). Modeled here the same way -- both
     * companions freshly zeroed at every (I,J) step, nothing threaded
     * across steps or K iterations, nothing left to leak into whatever
     * RTL call comes next either. The singularity check just below
     * (`if (big == 0u)`) was never modeled with an F1 leak in the first
     * place (a plain exact-zero compare), which already matches the
     * corrected RTL's own `SER F1,F1` fix at that site -- no change
     * needed there. */
    int isw[HAL_MATRIX_MAX_N], jsw[HAL_MATRIX_MAX_N];

    for (int k = 0; k < n; k++) {
        uint32_t big = 0, big_abs = 0;
        int i1 = k, j1 = k;
        for (int i = k; i < n; i++) {
            for (int j = k; j < n; j++) {
                uint32_t cand_abs = mx_abs(m[i][j]);
                if ((int32_t)cand_abs > (int32_t)big_abs) {
                    big = m[i][j];
                    big_abs = cand_abs;
                    i1 = i; j1 = j;
                }
            }
        }
        isw[k] = i1; jsw[k] = j1;
        if (big == 0u) return false; /* AOUT: genuinely singular (exact zero, not a threshold) */

        if (i1 != k) {
            for (int j = 0; j < n; j++) {
                uint32_t old_i1 = m[i1][j], old_k = m[k][j];
                m[k][j] = old_i1;
                m[i1][j] = mx_negate_ws(old_k);
            }
        }
        if (j1 != k) {
            for (int i = 0; i < n; i++) {
                uint32_t old_k = m[i][k], old_j1 = m[i][j1];
                m[i][j1] = mx_negate_ws(old_k);
                m[i][k] = old_j1;
            }
        }

        /* DIVIDE KTH COLUMN, EXCEPT FOR KTH ELEMENT, BY -BIG. */
        for (int i = 0; i < n; i++) {
            if (i == k) continue;
            m[i][k] = mx_div(mx_negate_ws(m[i][k]), big);
        }

        /* REDUCE MATRIX -- the O(n^2) inner update per K. Both AEDR
         * companions freshly zeroed each step (id 72, see comment
         * above). */
        for (int i = 0; i < n; i++) {
            if (m[i][k] == 0u || i == k) continue;
            for (int j = 0; j < n; j++) {
                if (j == k) continue;
                uint32_t prod = mx_mul(m[i][k], m[k][j]);
                halmat_scalar_t f4; f4.double_precision = true; f4.msw = m[i][j]; f4.lsw = 0;
                halmat_scalar_t f2; f2.double_precision = true; f2.msw = prod; f2.lsw = 0;
                halmat_scalar_t sum = hrfp_addE(&f4, &f2);
                m[i][j] = sum.msw;
            }
        }

        /* DIVIDE KTH ROW, EXCEPT FOR KTH ELEMENT, BY BIG; REPLACE PIVOT
         * BY RECIPROCAL. */
        for (int j = 0; j < n; j++) {
            if (j == k) continue;
            m[k][j] = mx_div(m[k][j], big);
        }
        {
            halmat_scalar_t one; one.double_precision = false; one.msw = 0x41100000u; one.lsw = 0; /* LFLI F2,1 */
            halmat_scalar_t bigv; bigv.double_precision = true; bigv.msw = big; bigv.lsw = 0;
            m[k][k] = hrfp_divE(&one, &bigv).msw;
        }
    }

    /* FINAL ROW AND COLUMN SWITCHES, K=N-1 DOWNTO 0 (reverse of the
     * forward pass's own row/column pivoting, with the negation applied
     * to the OPPOSITE side -- confirmed via both direct code reading
     * and independent mathematical self-consistency, task 100/id 51's
     * own derivation). */
    for (int k = n - 1; k >= 0; k--) {
        if (jsw[k] != k) {
            for (int j = 0; j < n; j++) {
                uint32_t old_k = m[k][j], old_jsw = m[jsw[k]][j];
                m[k][j] = mx_negate_ws(old_jsw);
                m[jsw[k]][j] = old_k;
            }
        }
        if (isw[k] != k) {
            for (int i = 0; i < n; i++) {
                uint32_t old_k = m[i][k], old_isw = m[i][isw[k]];
                m[i][k] = mx_negate_ws(old_isw);
                m[i][isw[k]] = old_k;
            }
        }
    }

    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            out[i * n + j] = (halmat_scalar_t){ .double_precision = false, .msw = m[i][j], .lsw = 0 };
    return true;
}

/* Bit-exact replication of RUNASM/MM12SN.asm's own general-N (N>=4)
 * path (id 76, yagpc2-yahalmat2-issues.db) -- HAL/S's DETERMINANT()
 * built-in for a single-precision matrix. Real hardware routes N==2 to
 * MM12SN's own closed-form branch (a genuine extended SEDR) and N==3 to
 * the separate MM12S3.asm (Sarrus rule, already ported inline in
 * hal_matrix_invert_single's own N==3 branch above) -- neither is
 * implemented here; this function is only ever called for n>=4 (see
 * interp.c's own DET case), matching real HALSFC's own dispatch.
 *
 * Same complete (row+column) pivoting structure as
 * hal_matrix_invert_single's general-N path, but computing a running
 * determinant (product of pivots, sign-flipped once per swap) instead
 * of a matrix inverse, and -- confirmed via direct reading, no register-
 * pair leak class bug here at all (id 76's own investigation ruled that
 * out: every op in this routine is single-precision LE/ME/MER/AE/LECR,
 * with SEDR appearing only in the N==2 branch this function never
 * reaches) -- no `hal_fpu_state_t` needed.
 *
 * Precise correspondence to the real instruction sequence, since exact
 * operation ORDER (not just the algorithm) is what id 76 found missing
 * from the previous generic double-precision implementation:
 *   - Pivot search and sign-flip-on-swap exactly mirror
 *     hal_matrix_invert_single's own general-N path (same idiom, same
 *     file, MM12SN.asm and MM14SN.asm share this convention) -- BUT the
 *     swapped VALUES themselves are never negated here (only `det`
 *     itself is, via a genuine LECR per swap) -- DET's own algorithm
 *     never touches the matrix during a swap beyond a plain exchange,
 *     unlike INVERSE's own pivoting.
 *   - `det` accumulates as `det = det * pivot` (MER F4,F0) BEFORE the
 *     reciprocal is derived from that SAME pivot (DER F0,F4 -- F4
 *     reloaded to the pivot value right after the multiply, `LER
 *     F4,F0`), then the elimination step computes TEMP1 = -A(I,K) *
 *     (1/pivot) ONCE per row I (not re-divided per element), and
 *     updates A(I,J) = A(K,J)*TEMP1 + A(I,J) -- the product computed
 *     FIRST, then added to A(I,J) (not the other way around) -- for
 *     every J>K. A final `det *= A(N-1,N-1)` (already updated by the
 *     last elimination pass) happens once after the whole K loop. */
halmat_scalar_t hal_matrix_determinant_single(const halmat_scalar_t *in, int n) {
    uint32_t m[HAL_MATRIX_MAX_N][HAL_MATRIX_MAX_N];
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            m[i][j] = in[i * n + j].msw;

    uint32_t det = 0x41100000u; /* LFLI F4,1 -- DET starts at exactly 1.0 */

    for (int k = 0; k < n - 1; k++) {
        uint32_t big = 0;
        int i1 = k, j1 = k;
        for (int i = k; i < n; i++) {
            for (int j = k; j < n; j++) {
                uint32_t cand_abs = mx_abs(m[i][j]);
                if ((int32_t)cand_abs > (int32_t)big) {
                    big = cand_abs;
                    i1 = i; j1 = j;
                }
            }
        }

        if (i1 != k) {
            det = mx_negate_ws(det); /* LECR F4,F4 */
            for (int j = k; j < n; j++) {
                uint32_t t = m[k][j]; m[k][j] = m[i1][j]; m[i1][j] = t;
            }
        }
        if (j1 != k) {
            det = mx_negate_ws(det); /* LECR F4,F4 */
            for (int i = k; i < n; i++) {
                uint32_t t = m[i][k]; m[i][k] = m[i][j1]; m[i][j1] = t;
            }
        }

        uint32_t pivot = m[k][k]; /* LE F0,A(K,K) */
        det = mx_mul(det, pivot); /* MER F4,F0 */
        uint32_t recip = mx_div(0x41100000u, pivot); /* LFLI F0,1 ; DER F0,F4 (F4==pivot here) */

        for (int i = k + 1; i < n; i++) {
            uint32_t temp1 = mx_mul(mx_negate_ws(m[i][k]), recip); /* LECR F2,F2 ; MER F2,F0 */
            for (int j = k + 1; j < n; j++) {
                uint32_t prod = mx_mul(m[k][j], temp1); /* MER F4,F2 */
                m[i][j] = mx_add(prod, m[i][j]); /* AE F4,A(I,J) */
            }
        }
    }
    det = mx_mul(det, m[n - 1][n - 1]); /* final ME F4,A(N,N) */

    return (halmat_scalar_t){ .double_precision = false, .msw = det, .lsw = 0 };
}

/* Genuine extended-pair wrappers for the DOUBLE-precision routines
 * below -- unlike mx_mul/mx_add/mx_sub/mx_div above (msw-only,
 * modeling a real single F-register's lack of a paired low word),
 * these operate on genuine {msw,lsw} halmat_scalar_t values loaded
 * whole from memory (LED), matching hal_matrix_invert_double's own
 * header comment on why no odd-companion-register leakage applies
 * here. mxd_mul is MED/MEDR (rounded -- hrfp_mulQeE), NOT the exact
 * ME/MER (hrfp_mulE) the single-precision routines use -- a genuine
 * distinction in the primary source itself. */
static halmat_scalar_t mxd_mul(halmat_scalar_t a, halmat_scalar_t b) { return hrfp_mulQeE(&a, &b); }
static halmat_scalar_t mxd_add(halmat_scalar_t a, halmat_scalar_t b) { return hrfp_addE(&a, &b); }
static halmat_scalar_t mxd_sub(halmat_scalar_t a, halmat_scalar_t b) { return hrfp_subE(&a, &b); }
static halmat_scalar_t mxd_negate(halmat_scalar_t a) {
    if (a.msw != 0u) a.msw ^= 0x80000000u; /* LECR bug workaround, same as mx_negate_ws */
    return a;
}
static halmat_scalar_t mxd_mk(uint32_t msw, uint32_t lsw) {
    halmat_scalar_t v; v.double_precision = true; v.msw = msw; v.lsw = lsw; return v;
}

/* QDEDR -- the same Newton-refined extended-precision divide as
 * hal_transcendental.c's own datan2_qdedr (see that function's own
 * header comment for the macro-expansion derivation): plain DER/DE
 * are a NARROWING divide on real hardware -- BOTH the dividend AND
 * the divisor are used msw-only (their own lsw ignored entirely for
 * the division itself), and the result is msw-only too, with the
 * destination's own companion register left completely untouched
 * (still whatever the DIVIDEND's own original lsw was, since the
 * dividend register IS the divide's destination in both DER/DE forms
 * here). An initial attempt used hrfp_divE's own full-precision
 * (msw+lsw) inputs, reasoning the extra input precision was needed
 * for a correct msw -- this happened to give the right answer for
 * MM14D3.asm's own N==3 cofactor divisions AND for this routine's own
 * K=0/1/2 pivots in one 4x4 test case, purely because every one of
 * those divisors' own lsw was coincidentally 0 -- but a real trace of
 * this same test's own K=3 pivot (5/3, genuinely nonzero lsw) proved
 * definitively that real DER/DE narrow the INPUT too: feeding the
 * divisor's real lsw into hrfp_divE there computed a measurably wrong
 * msw, while narrowing both operands to msw-only reproduced the
 * traced answer exactly (task 107/id 51). */
static halmat_scalar_t mxd_qdedr(halmat_scalar_t dividend, halmat_scalar_t divisor) {
    halmat_scalar_t dividend_narrow = mxd_mk(dividend.msw, 0);
    halmat_scalar_t divisor_narrow = mxd_mk(divisor.msw, 0);
    uint32_t approx_msw = hrfp_divE(&dividend_narrow, &divisor_narrow).msw; /* DER -- narrow msw-only divide */
    halmat_scalar_t approx = mxd_mk(approx_msw, dividend.lsw); /* companion NOT written -- dividend's own original lsw */
    halmat_scalar_t err = hrfp_mulQeE(&approx, &divisor); /* MED -- genuinely extended, both halves written */
    err = hrfp_subE(&err, &dividend); /* SED -- genuinely extended */
    halmat_scalar_t err_narrow = mxd_mk(err.msw, 0);
    uint32_t err_div_msw = hrfp_divE(&err_narrow, &divisor_narrow).msw; /* DE -- narrow msw-only divide */
    halmat_scalar_t err_div = mxd_mk(err_div_msw, err.lsw); /* companion NOT written -- err's own lsw from SED */
    return hrfp_subE(&approx, &err_div); /* SEDR -- genuinely extended */
}
static uint32_t mxd_abs_msw(halmat_scalar_t a) { return a.msw & 0x7FFFFFFFu; }

bool hal_matrix_invert_double(const halmat_scalar_t *in, int n, halmat_scalar_t *out) {
    if (n <= 0 || n > HAL_MATRIX_MAX_N) return false;

    halmat_scalar_t m[HAL_MATRIX_MAX_N][HAL_MATRIX_MAX_N];
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            m[i][j] = mxd_mk(in[i * n + j].msw, in[i * n + j].lsw);

    if (n == 2) {
        /* MM14DN.asm's own internal N==2 closed form -- same formula as
         * hal_matrix_invert_single's own N==2 branch, but every operand
         * here is a fresh LED load (both halves genuinely from
         * memory), so unlike the single-precision version there is no
         * incoming companion-register leak to thread through. */
        halmat_scalar_t a = m[0][0], b = m[0][1], c = m[1][0], d = m[1][1];
        halmat_scalar_t det = mxd_sub(mxd_mul(a, d), mxd_mul(b, c));
        if (det.msw == 0u) return false;
        halmat_scalar_t recip = mxd_qdedr(mxd_mk(0x41100000u, 0), det); /* LFLI F4,1 ; QDEDR F4,F0 */
        out[0] = mxd_mul(d, recip);
        out[1] = mxd_mul(mxd_negate(b), recip);
        out[2] = mxd_mul(mxd_negate(c), recip);
        out[3] = mxd_mul(a, recip);
        return true;
    }

    if (n == 3) {
        /* MM14D3.asm (via RUNASM/MM12D3.asm's own genuine extended-
         * precision Sarrus-rule determinant) -- identical cofactor
         * formulas to hal_matrix_invert_single's own N==3 branch
         * (MM14S3.asm/MM12S3.asm), confirmed via direct comparison of
         * both primary sources' own operand offsets, but with every
         * multiply/add/subtract genuinely extended (MED/AEDR/SEDR, no
         * per-block companion-register bookkeeping needed) and all 9
         * cofactors multiplied by ONE precomputed reciprocal (QDEDR)
         * rather than 9 separate narrowing divisions. */
        halmat_scalar_t m11 = m[0][0], m12 = m[0][1], m13 = m[0][2];
        halmat_scalar_t m21 = m[1][0], m22 = m[1][1], m23 = m[1][2];
        halmat_scalar_t m31 = m[2][0], m32 = m[2][1], m33 = m[2][2];

        halmat_scalar_t det = mxd_add(mxd_add(mxd_mul(mxd_mul(m11, m22), m33),
                                               mxd_mul(mxd_mul(m12, m23), m31)),
                                       mxd_mul(mxd_mul(m13, m21), m32));
        det = mxd_sub(mxd_sub(det, mxd_mul(mxd_mul(m31, m22), m13)),
                       mxd_mul(mxd_mul(m32, m23), m11));
        det = mxd_sub(det, mxd_mul(mxd_mul(m33, m21), m12));
        if (det.msw == 0u) return false;
        halmat_scalar_t recip = mxd_qdedr(mxd_mk(0x41100000u, 0), det);

        halmat_scalar_t out9[9];
#define MM14D3_BLOCK(A, B, C, D, OUT_IDX) do { \
            halmat_scalar_t diff = mxd_sub(mxd_mul((A), (B)), mxd_mul((C), (D))); \
            out9[(OUT_IDX)] = mxd_mul(diff, recip); \
        } while (0)
        MM14D3_BLOCK(m22, m33, m32, m23, 0); /* I(1,1) */
        MM14D3_BLOCK(m32, m13, m12, m33, 1); /* I(1,2) = M32*M13 - M12*M33 */
        MM14D3_BLOCK(m12, m23, m22, m13, 2); /* I(1,3) */
        MM14D3_BLOCK(m31, m23, m21, m33, 3); /* I(2,1) = M31*M23 - M21*M33 */
        MM14D3_BLOCK(m11, m33, m31, m13, 4); /* I(2,2) */
        MM14D3_BLOCK(m21, m13, m11, m23, 5); /* I(2,3) = M21*M13 - M11*M23 */
        MM14D3_BLOCK(m21, m32, m31, m22, 6); /* I(3,1) */
        MM14D3_BLOCK(m31, m12, m11, m32, 7); /* I(3,2) = M31*M12 - M11*M32 */
        MM14D3_BLOCK(m11, m22, m21, m12, 8); /* I(3,3) */
#undef MM14D3_BLOCK
        for (int i = 0; i < 9; i++) out[i] = out9[i];
        return true;
    }

    /* General N (N==2/N==3 handled separately above). Same complete
     * (row+column) pivoting Gauss-Jordan as hal_matrix_invert_single's
     * own general path -- see hal_matrix_invert_double's own header
     * comment for the instruction-by-instruction correspondence to
     * MM14DN.asm. No accumulator-companion modeling needed here
     * (MM14DN.asm's own "SEDR F2,F2" self-zero at the top of the K loop
     * confirms the reduction step's own accumulator is genuinely fresh
     * every K) -- MM14SN.asm's own single-precision counterpart used to
     * differ (a companion that persisted across the whole routine), but
     * that was id 72's own confirmed RTL bug, now fixed on both the real
     * RTL side and hal_matrix_invert_single's own general-N path above;
     * this double-precision routine was never affected in the first
     * place. */
    int isw[HAL_MATRIX_MAX_N], jsw[HAL_MATRIX_MAX_N];

    for (int k = 0; k < n; k++) {
        halmat_scalar_t big = mxd_mk(0, 0);
        uint32_t big_abs = 0;
        int i1 = k, j1 = k;
        for (int i = k; i < n; i++) {
            for (int j = k; j < n; j++) {
                uint32_t cand_abs = mxd_abs_msw(m[i][j]);
                if ((int32_t)cand_abs > (int32_t)big_abs) {
                    big = m[i][j];
                    big_abs = cand_abs;
                    i1 = i; j1 = j;
                }
            }
        }
        isw[k] = i1; jsw[k] = j1;
        if (big.msw == 0u) return false; /* AOUT: genuinely singular */

        if (i1 != k) {
            for (int j = 0; j < n; j++) {
                halmat_scalar_t old_i1 = m[i1][j], old_k = m[k][j];
                m[k][j] = old_i1;
                m[i1][j] = mxd_negate(old_k);
            }
        }
        if (j1 != k) {
            for (int i = 0; i < n; i++) {
                halmat_scalar_t old_k = m[i][k], old_j1 = m[i][j1];
                m[i][j1] = mxd_negate(old_k);
                m[i][k] = old_j1;
            }
        }

        halmat_scalar_t recip = mxd_qdedr(mxd_mk(0x41100000u, 0), big); /* LFLI F0,1 ; QDEDR F0,F2 */

        /* DIVIDE KTH COLUMN, EXCEPT FOR KTH ELEMENT, BY -BIG (via
         * multiply-by-reciprocal, MM14DN.asm's own ROWD label). */
        for (int i = 0; i < n; i++) {
            if (i == k) continue;
            m[i][k] = mxd_mul(mxd_negate(m[i][k]), recip);
        }

        /* REDUCE MATRIX -- every AEDR here is genuinely fresh both
         * operands (a memory-loaded M[I][K]/M[K][J] and the running
         * M[I][J]), no accumulator persistence needed. */
        for (int i = 0; i < n; i++) {
            if (m[i][k].msw == 0u || i == k) continue;
            for (int j = 0; j < n; j++) {
                if (j == k) continue;
                m[i][j] = mxd_add(m[i][j], mxd_mul(m[i][k], m[k][j]));
            }
        }

        /* DIVIDE KTH ROW, EXCEPT FOR KTH ELEMENT, BY BIG; REPLACE
         * PIVOT BY RECIPROCAL. */
        for (int j = 0; j < n; j++) {
            if (j == k) continue;
            m[k][j] = mxd_mul(m[k][j], recip);
        }
        m[k][k] = recip;
    }

    /* FINAL ROW AND COLUMN SWITCHES, K=N-1 DOWNTO 0 (JSW selects a ROW
     * to swap with K here, ISW selects a COLUMN -- opposite roles from
     * the forward pass, confirmed via MM14DN.asm's own header comment
     * "INTERCHANGE JSW(K) ROW AND KTH; INTERCHANGE ISW(K) COLUMN AND
     * KTH" and cross-checked instruction-by-instruction against the
     * REVERS label's own code). */
    for (int k = n - 1; k >= 0; k--) {
        if (jsw[k] != k) {
            for (int j = 0; j < n; j++) {
                halmat_scalar_t old_k = m[k][j], old_jsw = m[jsw[k]][j];
                m[k][j] = mxd_negate(old_jsw);
                m[jsw[k]][j] = old_k;
            }
        }
        if (isw[k] != k) {
            for (int i = 0; i < n; i++) {
                halmat_scalar_t old_k = m[i][k], old_isw = m[i][isw[k]];
                m[i][k] = mxd_negate(old_isw);
                m[i][isw[k]] = old_k;
            }
        }
    }

    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            out[i * n + j] = m[i][j];
    return true;
}
