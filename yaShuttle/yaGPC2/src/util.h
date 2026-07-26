/* PackedBits — bit-field descriptor DSL, ported from gpc/util.coffee.
 *
 * A descriptor string like "00000xxx11100yyy" describes a 16-bit
 * instruction word: '0'/'1' are literal opcode bits, lowercase letters
 * (and '_') are named field placeholders. Two-halfword instructions use a
 * '/' separator followed by a single 'I' (16-bit immediate, no further
 * field breakdown) or 'X' (extended/indexed addressing, decoded
 * specially by the caller) — e.g. "1011000011100yyy/I".
 *
 * This module only builds the descriptor (masks/shifts per field, overall
 * instruction mask/maskedVal, halfword length, format type) and extracts/
 * packs field values. The opcode dispatch table itself (name -> Desc,
 * plus the exec callback) is built by each instruction set (cpu_instr.c,
 * iop_bce_instr.c, iop_msc_instr.c) — mirroring cpu_instr.coffee's
 * `makeOpTbl`, not this file's JS counterpart. */
#ifndef YAGPC_UTIL_H
#define YAGPC_UTIL_H

#include <stdbool.h>
#include <stdint.h>

/* Field-name characters are ASCII letters or '_'; index directly by char
 * code (matches gpc/util.coffee's dynamic per-letter field map). */
#define PB_FIELD_TABLE_SIZE 128

typedef enum {
    PB_TYPE_NONE = 0,
    PB_TYPE_RR,
    PB_TYPE_SRS,
    PB_TYPE_RS,
    PB_TYPE_SI,
    PB_TYPE_RI,
} PBType;

typedef struct {
    bool present;
    uint32_t mask;
    int shift;
    int bitlen;
} PBField;

typedef struct {
    int bitLen;      /* strlen() of the full descriptor string passed in */
    int len;         /* halfword length: 1 or 2 */
    int origLen;      /* == len as built; cpu_instr.c resets desc.len from
                        * this before each decode, matching decode()'s
                        * `desc.len = desc.origLen` */
    PBType type;
    uint32_t mask;        /* over the first halfword only */
    uint32_t maskedVal;   /* over the first halfword only */
    PBField field[PB_FIELD_TABLE_SIZE];
} PBDesc;

/* Parse a descriptor string (gpc/util.coffee's PackedBits#makeDesc). */
PBDesc pb_make_desc(const char *s);

/* (data & field.mask) >>> field.shift */
uint32_t pb_get_field(uint32_t data, const PBField *f);

/* (v << f.shift) & f.mask */
uint32_t pb_fld(const PBField *f, uint32_t v);

/* Clear field f's bits in t (within a value of the given bit width), then
 * OR in v shifted/masked into place. */
uint32_t pb_set_fld(uint32_t t, int bitLen, const PBField *f, uint32_t v);

#endif
