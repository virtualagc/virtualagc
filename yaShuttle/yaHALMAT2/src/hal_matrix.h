#ifndef HALMAT_HAL_MATRIX_H
#define HALMAT_HAL_MATRIX_H

#include "value.h"
#include "hal_fpu.h"

/* Bit-exact replication of RUNASM/MM14SN.asm ("MM14SN__INVERSE MATRIX
 * M(N,N) . SP") -- HAL/S's MATRIX**(-1) / INVERSE built-in, single
 * precision (class-3/MINV.md, BFNC's INVERSE selector 49). Independently
 * verified against yaGPC2's own real execution trace and cross-checked
 * bit-for-bit against plain yaGPC2 runs across multiple N and matrices
 * (task 100/id 51).
 *
 * Confirmed via a real trace that a real HALSFC compile dispatches to
 * this exact routine for N=2 (its own internal closed-form 2x2 branch)
 * and for general N>=4; N==3 instead routes to the separate MM14S3.asm
 * (RUNASM/MM12S3.asm's own Sarrus-rule determinant plus a 9-way
 * cofactor/DET division, task 108/id 51) -- ALSO implemented here, in
 * `hal_matrix_invert_single`'s own dedicated N==3 branch, since real
 * hardware treats N==3 as a genuinely separate, non-general-Gauss-
 * Jordan algorithm rather than a special case of the N>=4 path.
 *
 * `in`/`out` are row-major N*N single-precision halmat_scalar_t arrays
 * (any incoming double-precision elements are narrowed to their own
 * msw, matching real hardware's own single F-register constraint, the
 * same convention as hal_exp_single/hal_log_single). Returns false for
 * a genuinely singular matrix (BIG found by the complete-pivoting
 * search is EXACTLY zero, not merely small -- this is a different,
 * stricter test than the existing native double-based matrix_invert's
 * own `< 1e-12` threshold, and is why a near-singular matrix that real
 * hardware still manages to (numerically unstably) invert was
 * previously misreported as singular by the old implementation).
 *
 * `fpu` is the shared persistent AP-101S floating-register state
 * (hal_fpu.h). Unlike EXP/LOG (which explicitly self-reset their own
 * odd companion before use), MM14SN's N==2 branch's own SEDR does NOT
 * reset first -- it genuinely READs whatever `fpu->f1` a PRIOR floating-
 * point-heavy RTL call left behind, confirmed via a real trace where a
 * first MATRIX**(-1) call's own leftover F1 measurably changed a
 * SECOND, otherwise-independent MATRIX**(-1) call's own result (task
 * 100/id 51). It's written back before returning so the leak keeps
 * propagating correctly to whatever comes after this call too.
 *
 * id 72 (yagpc2-yahalmat2-issues.db, 2026-07-29): the general path's own
 * reduction-loop AEDR, and the N==3 branch's own 9-block SEDR chain,
 * USED TO model an incoming-`fpu->f3`/`fpu->f5` read/write the same way
 * -- correctly, as a description of the ORIGINAL, unpatched RTL (real
 * MM14SN.asm/MM14S3.asm genuinely never reset these companions). But
 * that turned out to be a genuine, undetected bug in the real RTL, not
 * intentional design: three back-to-back, bit-identical INVERSE(A4A)
 * calls on the same singular matrix produced three different results
 * purely because of unrelated prior floating-point call history, not
 * the matrix being inverted. Fixed on the real MM14SN.asm side via an
 * &ASM101S-gated conditional-assembly patch (yaGPC2 commit 8439ae054)
 * that clears these companions immediately before use; MM14S3.asm has
 * the identical bug shape (confirmed by direct reading) but has not
 * been given its own equivalent RTL patch yet -- fixed here by analogy
 * regardless, per direct user authorization, since a defect doesn't
 * stop being one just because only one of its two occurrences has been
 * patched upstream so far. Both `hal_matrix_invert_single`'s general-N
 * reduction loop and its N==3 branch now model both companions as
 * freshly zeroed at every use, matching the corrected RTL rather than
 * the historical leak -- neither reads nor writes `fpu->f3`/`fpu->f5`
 * anymore. `fpu->f1` (N==2 branch only, above) is unaffected -- it was
 * never implicated by id 53's own repro and has no corresponding RTL
 * patch to mirror.
 *
 * This also makes moot a KNOWN GAP previously documented here for N==3
 * only: a real trace of `M2 = MATRIX(1,2,3,...) ** (-1);` (an inversion
 * immediately preceded by a runtime MATRIX(...) literal-constructor
 * assignment) used to show the compiler's own literal-loading code
 * leaving nonzero values in F1/F3/F5/F7 that this file's own N==3
 * branch would then incorrectly read as a genuine incoming leak. Since
 * the corrected model no longer reads `fpu->f3`/`fpu->f5` as an input
 * at all, whatever a prior compiled-code register access left behind is
 * irrelevant now, the same way the real corrected hardware's own
 * `SER F3,F3`/`SER F5,F5` makes it irrelevant there too. */
bool hal_matrix_invert_single(const halmat_scalar_t *in, int n, halmat_scalar_t *out, hal_fpu_state_t *fpu);

/* Bit-exact replication of RUNASM/MM12SN.asm's own general-N (n>=4)
 * path -- HAL/S's DETERMINANT() built-in, single precision (id 76,
 * yagpc2-yahalmat2-issues.db). Real hardware routes N==2 to MM12SN's
 * own closed-form branch and N==3 to the separate MM12S3.asm (Sarrus
 * rule) -- neither is implemented here; ONLY CALL THIS FOR n>=4,
 * matching real HALSFC's own dispatch (see hal_matrix.c's own header
 * comment on this function for the full instruction-by-instruction
 * correspondence). Confirmed via direct reading that this routine has
 * no register-pair-leak bug class at all (every op is single-precision
 * LE/ME/MER/AE/LECR; the sole SEDR lives only in the N==2 branch this
 * function never reaches) -- no `hal_fpu_state_t` parameter needed. */
halmat_scalar_t hal_matrix_determinant_single(const halmat_scalar_t *in, int n);

/* Bit-exact replication of RUNASM/MM14DN.asm ("MM14DN MATRIX INVERSE,
 * N X N,DOUBLE PREC") and RUNASM/MM14D3.asm (N==3) -- the genuine
 * DOUBLE-precision counterpart of hal_matrix_invert_single above,
 * task 107/id 51. MM14DN.asm's own header comment documents that it
 * handles "N NOT=3" (its own internal N==2 closed form plus a general
 * Gauss-Jordan for every other N), with N==3 routed to the separate
 * MM14D3.asm (via MM12D3.asm's own genuine extended-precision Sarrus-
 * rule determinant) -- both are implemented together here in one
 * function's own N==2/N==3/general-N branches, mirroring
 * hal_matrix_invert_single's own three-way structure.
 *
 * Structurally the SAME complete-pivoting Gauss-Jordan algorithm as
 * MM14SN.asm (confirmed instruction-by-instruction: identical pivot
 * search, row/column swap-with-negation pattern, reduction formula,
 * and final reverse-swap logic), but genuinely simpler to model
 * faithfully: MM14SN.asm's own single-precision LE only loads a
 * register's own high half, forcing every extended (AEDR/SEDR) step to
 * "borrow" whatever a PRIOR RTL call left in the paired odd companion
 * register (hal_matrix_invert_single's own persistent hal_fpu_state_t
 * threading exists specifically for that) -- MM14DN.asm/MM14D3.asm's
 * own LED always loads a FULL 64-bit double from memory in one
 * instruction, so every AEDR/SEDR/MEDR/QDEDR operand here is either a
 * fresh memory load or a value this SAME routine call already computed
 * itself, with NO genuine leakage into or out of a prior/subsequent
 * unrelated RTL call anywhere in either file (confirmed by reading
 * every extended instruction in both files) -- hence no `hal_fpu_state_t
 * *fpu` parameter here at all, unlike the single-precision sibling.
 *
 * Also note MED/MEDR here (real hardware's own genuinely-rounded
 * extended multiply, hal_random.h's own hrfp_mulQeE) where
 * hal_matrix_invert_single's own single-precision routines used the
 * EXACT ME/MER (hrfp_mulE) -- a real, deliberate distinction in the
 * primary source itself, not a porting inconsistency (see
 * hal_random.c's own hrfp_mulQeE header comment on the MED-vs-ME
 * distinction generally). Every division in both files goes through
 * QDEDR (a Newton-refined extended divide -- see
 * hal_atan2_double's own header comment in hal_transcendental.h for
 * the identical macro's own derivation) computed ONCE per pivot as a
 * reciprocal, then multiplied through -- unlike MM14SN.asm's own
 * single-precision general path, which instead calls a plain
 * (narrower) DER once per element.
 *
 * `in`/`out` are row-major N*N DOUBLE-precision halmat_scalar_t
 * arrays (genuine {msw,lsw} pairs throughout, no narrowing). Returns
 * false for a genuinely singular matrix, same exact-zero convention as
 * hal_matrix_invert_single. */
bool hal_matrix_invert_double(const halmat_scalar_t *in, int n, halmat_scalar_t *out);

#endif
