#ifndef HALMAT_SYMTAB_H
#define HALMAT_SYMTAB_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Parses a compiler-produced COMMON*.out symbol-table text report
 * (tab-separated "/  SYMuTAB  N  BASED  ..." record headers, ".  SYM_NAME"
 * / ".  SYM_FLAGS" field lines -- see reengineered-documentation and
 * this project's own research notes) into a simple index->{name,flags}
 * table. Used for M6's multi-file linking: matching EXTERNAL-flagged
 * symbols (SYM_FLAGS bit 0x00100000, confirmed against unHALMAT.py's
 * symbolFlags table) by name across independently-compiled units. */

#define HALMAT_SYM_FLAG_EXTERNAL 0x00100000u
/* SINGLE/DOUBLE precision bits, confirmed against unHALMAT.py's own
 * symbolFlags table (0x00800000="SINGLE", 0x00400000="DOUBLE") -- used
 * by interp.c's bind_call_argument() to determine a MATRIX/VECTOR call
 * parameter's declared precision for USA003087 Sec. 11.2/11.4's
 * "precision conversion is allowed" argument-transmission rule. */
#define HALMAT_SYM_FLAG_SINGLE 0x00800000u
#define HALMAT_SYM_FLAG_DOUBLE 0x00400000u

/* MATRIX/VECTOR/ARRAY declared-dimension info, empirically decoded this
 * session (no primary-source page for the COMMON*.out symbol-table
 * layout was available -- see the field-by-field trace in this
 * project's Phase 3 notes for the compiled examples this was derived
 * from):
 *
 * - SYM_TYPE: HALMAT's own class number (XXAR.md's enumeration) --
 *   3=MATRIX, 4=VECTOR, 5=SCALAR, 6=INTEGER, 1=BIT, 2=CHARACTER.
 * - MATRIX(r,c): SYM_LENGTH's two bytes are (r<<8)|c directly --
 *   confirmed against MATRIX(2,4) => SYM_LENGTH=0x0204.
 * - VECTOR(n): SYM_LENGTH is n directly -- confirmed against VECTOR(6)
 *   => SYM_LENGTH=0x0006.
 * - ARRAY(n) [of SCALAR -- other element types not tested]: SYM_ARRAY
 *   is an index into the file's "+  EXTuARRAY  idx  BIT  hex" table
 *   (collected separately, not per-symbol); EXTuARRAY[SYM_ARRAY] is the
 *   ARRAY's dimension count, EXTuARRAY[SYM_ARRAY+1 .. +count] are each
 *   dimension's bound, in order. Confirmed against two single-dimension
 *   arrays (ARRAY(5) => EXTuARRAY[SYM_ARRAY]=1,[SYM_ARRAY+1]=5;
 *   ARRAY(7) => same shape at a different EXTuARRAY offset). Only
 *   dimension count 1 has been exercised; the multi-dimension case is
 *   assumed to work the same way (each extra bound simply follows) but
 *   isn't independently confirmed.
 * - BIT(n): SYM_LENGTH is n directly, same convention as VECTOR --
 *   confirmed against BIT(4) => SYM_LENGTH=0x0004, BIT(8) =>
 *   SYM_LENGTH=0x0008. Needed for BCAT (class-1/BCAT.md), whose operands
 *   carry no width of their own -- the declared width is the only source
 *   of truth for how far to shift during concatenation.
 * - `Q-STRUCTURE(n)` "copiness" (SYM_TYPE=0x0A=`MAJ_STRUC`, primary-
 *   sourced from `PASS1.PROCS/##DRIVER.xpl`'s `MAJ_STRUC LITERALLY '10'`):
 *   SYM_ARRAY holds the copy count `n` *directly*, not an EXTuARRAY table
 *   index as it does for ordinary numeric ARRAYs -- confirmed empirically
 *   against `Q-STRUCTURE(3)` (SYM_ARRAY=0003), `Q-STRUCTURE(5)`
 *   (SYM_ARRAY=0005), and a plain single-instance `Q-STRUCTURE` with no
 *   `(n)` at all (SYM_ARRAY=0000). See `struct_copies` below; needed by
 *   TINT (class-8/TINT.md) to tell a coalesced INITIAL() run that spans
 *   copies from one that spans terminals within a single copy. */
typedef enum {
    HALMAT_SHAPE_NONE = 0,
    HALMAT_SHAPE_MATRIX,
    HALMAT_SHAPE_VECTOR,
    HALMAT_SHAPE_ARRAY,
} halmat_sym_shape_t;

#define HALMAT_SYM_MAX_ARRAY_DIMS 4

typedef struct {
    size_t index; /* SYT slot within its own unit */
    char *name;   /* may be empty ("") for anonymous/reserved slots */
    uint32_t flags;
    uint8_t hal_class; /* raw SYM_TYPE (0 if not present/parsed) */
    halmat_sym_shape_t shape;
    int rows, cols; /* HALMAT_SHAPE_MATRIX: rows x cols. HALMAT_SHAPE_VECTOR: cols = dimension, rows unused. */
    int array_dims[HALMAT_SYM_MAX_ARRAY_DIMS]; /* HALMAT_SHAPE_ARRAY: each dimension's bound, in order */
    int array_dim_count;
    int bit_width; /* declared width for a BIT(n) symbol (hal_class==1), 0 if not a BIT or unknown */
    int struct_copies; /* hal_class==0x0A (MAJ_STRUC) only: declared copy count for `Q-STRUCTURE(n)`,
                         * 0 for a plain single-instance `Q-STRUCTURE` (no `(n)`) -- see above */
    int sym_ptr; /* raw SYM_PTR field, meaning depends on hal_class (SYM_TYPE) -- confirmed this
                  * session for two cases: hal_class==0x47 (PROCEDURE LABEL) points to the
                  * procedure's own first-parameter SYT slot (consistent with FCAL.md's
                  * "parameters occupy contiguous SYT slots immediately after the procedure's
                  * own symbol" finding); hal_class==0x45 (IND CALL LABEL) points to the *real*
                  * PDEF/FDEF-defining symbol this indirect-call alias refers to -- the compiler
                  * emits a *separate*, alias-only symbol-table entry (this one) of type 0x45,
                  * not the real definition's own symbol index, for a call site lexically nested
                  * in a *different* block than the callee's own definition (e.g. one procedure
                  * calling a sibling procedure, both nested in the same enclosing PROGRAM --
                  * USA003087 p. 22ff's block-name scoping rules) -- confirmed via a user-reported
                  * bug and a real HALSFC compile of exactly that shape. interp.c's
                  * resolve_call_target() follows this redirect before treating the call
                  * operand's symbol as a callable PDEF/FDEF target. 0 if not present/parsed. */
} halmat_symtab_entry_t;

typedef struct {
    halmat_symtab_entry_t *entries;
    size_t count;
} halmat_symtab_t;

bool halmat_symtab_load(const char *path, halmat_symtab_t *out, char *errbuf, size_t errbuf_size);

/* Same COMMON*.out text parse as halmat_symtab_load(), but from an
 * already-in-memory buffer (a linked-archive container's verbatim-
 * embedded symtab text, see container.h) rather than a file path. Unlike
 * halmat_symtab_load() (which uses fgets over a FILE*), this scans `buf`
 * directly for '\n'-delimited lines (a bare trailing partial line at EOF
 * still counts as a line) -- deliberately not fmemopen(), which is a
 * POSIX/glibc extension unavailable to the MSVC/nmake Windows build this
 * project supports (Makefile.win). */
bool halmat_symtab_load_from_buffer(const uint8_t *buf, size_t size, halmat_symtab_t *out,
                                     char *errbuf, size_t errbuf_size);
void halmat_symtab_free(halmat_symtab_t *table);

/* Case-sensitive name lookup (HAL/S identifiers are compiled upper-case).
 * Returns NULL if not found or name is empty. */
const halmat_symtab_entry_t *halmat_symtab_find(const halmat_symtab_t *table, const char *name);

/* Looks up by SYT slot index (interp.c's own numbering) rather than
 * name -- what the interpreter actually has in hand when it needs a
 * MATRIX/VECTOR/ARRAY operand's declared shape. Returns NULL if no
 * entry has that index (e.g. an anonymous/reserved slot). */
const halmat_symtab_entry_t *halmat_symtab_find_by_index(const halmat_symtab_t *table, size_t index);

#endif
