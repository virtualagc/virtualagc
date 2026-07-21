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
 *   of truth for how far to shift during concatenation. */
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
} halmat_symtab_entry_t;

typedef struct {
    halmat_symtab_entry_t *entries;
    size_t count;
} halmat_symtab_t;

bool halmat_symtab_load(const char *path, halmat_symtab_t *out, char *errbuf, size_t errbuf_size);
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
