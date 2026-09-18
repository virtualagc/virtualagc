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
    /* Precomputed by cpu_instr_table_init() so decodef() need not rediscover
     * them on every instruction: the indices of pb.field[] that are present
     * (it used to walk all DINSTR_FIELD_TABLE_SIZE of them to find ~18), and
     * whether this is LFXI (it used to strcmp the mnemonic per decode). */
    uint8_t fieldIx[DINSTR_FIELD_TABLE_SIZE];
    uint8_t fieldN;
    bool isLFXI;
    /* THE TIMING MODEL, BOUND TO THE OPCODE INSTEAD OF LOOKED UP BY NAME.
     * Both of these used to be found by comparing the mnemonic STRING on
     * every emulated instruction -- once against the 161-row timing table
     * and once against the twenty names that can carry an override.  Each
     * was memoised on the mnemonic's pointer, but a 256-slot direct-mapped
     * memo holding 135 mnemonics collides often, and every collision paid
     * the full scan again: __strcmp_sse42 was still 3.19% of all cycles.
     * There are only 135 opcodes and neither answer can change, so both are
     * settled once here, exactly as isLFXI above already is.
     * `pooRow` is a `const PooTimingEntry *`, opaque outside timing.c. */
    const void *pooRow;
    bool pooOverridePossible;
    /* WHICH OPCODE THIS IS, AS A BIT, so the hot paths stop asking by name.
     * instr_time_pre_n() ran SIX strcmps on desc->nm for EVERY instruction
     * and decodef() a seventh, which is why __strcmp_sse42 stayed at 3.6% of
     * cycles even after the timing table and override list were bound: the
     * cost was never in those two lookups.  Same technique as isLFXI above,
     * applied where the comparisons actually were. */
    uint16_t nmBits;
} InstrDesc;

/* Bits in InstrDesc.nmBits. */
#define NM_MVH  (1u << 0)
#define NM_NCT  (1u << 1)
#define NM_SUM  (1u << 2)
#define NM_LXA  (1u << 3)
#define NM_LXAR (1u << 4)
#define NM_ICR  (1u << 5)
#define NM_IAL  (1u << 6)

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
