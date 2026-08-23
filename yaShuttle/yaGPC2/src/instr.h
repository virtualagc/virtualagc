/* Shared types bridging cpu.c (addressing/execution engine) and
 * cpu_instr.c/iop_bce_instr.c/iop_msc_instr.c (instruction tables).
 *
 * gpc/cpu_instr.coffee's `decodef` builds a plain JS object `d` with one
 * property per bit-field letter in the matched instruction's descriptor
 * (`for k,f of desc.f: d[k] = getField(hw1,f)`), plus a handful of
 * synthesized properties for extended/indexed addressing (`ia`, `ii`,
 * `extended`) and the RI/SI immediate value (`I`). Since the set of
 * field letters is genuinely per-instruction (not a fixed schema), the
 * most faithful C representation is the same kind of "sparse bag":
 * decoded[c]/present[c] indexed directly by field-letter ASCII code
 * (mirrors util.h's PBField-by-char table), plus explicit members for
 * the synthesized non-single-letter properties.
 */
#ifndef YAGPC_INSTR_H
#define YAGPC_INSTR_H

#include <stdbool.h>
#include <stdint.h>

#include "util.h"

#define DINSTR_FIELD_TABLE_SIZE 128

typedef struct {
    const char *nm;

    uint32_t field[DINSTR_FIELD_TABLE_SIZE];
    bool present[DINSTR_FIELD_TABLE_SIZE];

    bool extended; /* d.extended */
    bool hasIa, hasIi;
    uint32_t ia, ii;

    int niaIncr;    /* v.niaIncr (set by cpu.c from d->len before dispatch) */
    int addrWidth;  /* ADDR_HALFWORD/FULLWORD/DBLEWORD */
    /* How the INDEX register is aligned, which is not always how the
     * OPERAND is addressed.  POO 14.1 exempts a few instructions from
     * automatic index alignment, so they address a fullword operand
     * with a halfword-aligned index.  Defaults to addrWidth. */
    int indexWidth;
    int opType;     /* OPTYPE_DATA/BRCH/SHFT */
    uint32_t hw1, hw2;
} DInstr;

static inline bool df_has(const DInstr *d, char c) { return d->present[(unsigned char)c]; }
static inline uint32_t df_get(const DInstr *d, char c) { return d->field[(unsigned char)c]; }
static inline void df_set(DInstr *d, char c, uint32_t v) {
    d->field[(unsigned char)c] = v;
    d->present[(unsigned char)c] = true;
}

struct CPU; /* forward decl; defined in cpu.h */

typedef void (*InstrExecFn)(struct CPU *cpu, DInstr *v);

typedef struct {
    const char *nm;
    PBDesc pb;         /* mask/maskedVal/len/type/fields, from pb_make_desc(d-pattern) */
    InstrExecFn e;      /* NULL if the real instruction has no exec (shouldn't happen) */
    int addrWidth;
    int indexWidth;
    int opType;
} InstrDesc;

/* ADDR_* / OPTYPE_* — from cpu.coffee/cpu_instr.coffee (both files define
 * the same constants; consolidated here as the single source of truth). */
enum {
    ADDR_HALFWORD = 1,
    ADDR_FULLWORD = 2,
    ADDR_DBLEWORD = 3,
};
enum {
    OPTYPE_DATA = 1,
    OPTYPE_BRCH = 2,
    OPTYPE_SHFT = 4,
};

#endif
