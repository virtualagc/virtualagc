/* Needed (before any header pulls in <time.h> transitively) for
 * clock_gettime()/CLOCK_MONOTONIC/nanosleep() below (interp_run()'s
 * wall-clock pacing) -- POSIX.1-2008, not exposed under plain -std=c99
 * without this. No effect on _WIN32 (which takes the QueryPerformanceCounter/
 * Sleep() path instead). */
#ifndef _WIN32
#define _POSIX_C_SOURCE 200809L
#endif

#include "interp.h"

#include <errno.h>
#include <math.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <signal.h>
#include <time.h>
#endif

#include "opcode_table.h"
#include "value.h"

/* Combined 12-bit class:opcode values for the instructions implemented so
 * far. Extended opcode-by-opcode as later fixtures require -- see
 * Plan.md M4. */
#define OP_NOP 0x000
#define OP_EXTN 0x001
#define OP_XREC 0x002
#define OP_SMRK 0x004
#define OP_PXRC 0x005
#define OP_IFHD 0x007
#define OP_LBL 0x008
#define OP_BRA 0x009
#define OP_FBRA 0x00A
#define OP_DCAS 0x00B
#define OP_ECAS 0x00C
#define OP_CLBL 0x00D
#define OP_ADLP 0x017
#define OP_IDLP 0x01A
#define OP_DLPE 0x018
#define OP_STRI 0x801
#define OP_SLRI 0x802
#define OP_ELRI 0x803
#define OP_ETRI 0x804
#define OP_IDEF 0x051
#define OP_ICLS 0x052
#define OP_IMRK 0x003
#define OP_TDCL 0x033
#define OP_UDEF 0x02E
#define OP_EINT 0x8E3
#define OP_PMHD 0x059
#define OP_PMAR 0x05A
#define OP_PMIN 0x05B
#define OP_DFOR 0x010
#define OP_EFOR 0x011
#define OP_CFOR 0x012
#define OP_DSMP 0x013
#define OP_ESMP 0x014
#define OP_AFOR 0x015
#define OP_DTST 0x00E
#define OP_ETST 0x00F
#define OP_CTST 0x016
#define OP_DSUB 0x019
#define OP_TSUB 0x01B
#define OP_FILE 0x022
#define OP_RDAL 0x020
#define OP_READ 0x01F
#define OP_WRIT 0x021
#define OP_ERON 0x03C
#define OP_ERSE 0x03D
#define OP_TNEQ 0x04D
#define OP_TEQU 0x04E
#define OP_TASN 0x04F
#define OP_NNEQ 0x055
#define OP_NEQU 0x056
#define OP_NASN 0x057
#define OP_MSHP 0x040
#define OP_VSHP 0x041
#define OP_SSHP 0x042
#define OP_ISHP 0x043
#define OP_BFNC 0x04A
#define OP_LFNC 0x04B
/* OP_LFNC (0x04B, MAX/MIN over an ARRAY) not implemented -- its argument
 * is bracketed by ADLP/DLPE (class-0/ADLP.md's "free arrayness" loop
 * markers), a distinct and substantially larger mechanism not built yet;
 * falls through to the default "not yet implemented" case. */
#define OP_SFST 0x045
#define OP_SFND 0x046
#define OP_SFAR 0x047
#define OP_XXST 0x025
#define OP_XXND 0x026
#define OP_XXAR 0x027
#define OP_TDEF 0x02A
#define OP_MDEF 0x02B
#define OP_CDEF 0x02F
#define OP_FDEF 0x02C
#define OP_PDEF 0x02D
#define OP_WAIT 0x034
#define OP_SGNL 0x035
#define OP_CANC 0x036
#define OP_TERM 0x037
#define OP_PRIO 0x038
#define OP_SCHD 0x039
#define OP_CLOS 0x030
#define OP_EDCL 0x031
#define OP_RTRN 0x032
#define OP_PCAL 0x01D
#define OP_FCAL 0x01E
#define OP_IASN 0x601
#define OP_SASN 0x501
#define OP_BASN 0x101
#define OP_BCAT 0x105
#define OP_BAND 0x102
#define OP_BOR 0x103
#define OP_BNOT 0x104
#define OP_ITOB 0x1C1
#define OP_BTOI 0x621
#define OP_BTOB 0x121
#define OP_BTOQ 0x122
#define OP_CTOB 0x141
#define OP_CTOQ 0x142
#define OP_STOQ 0x1A2
#define OP_ITOQ 0x1C2
#define OP_STOB 0x1A1
#define OP_BTOC 0x221
#define OP_BTOS 0x521
#define OP_ITOI 0x6C1
#define OP_BTRU 0x720
#define OP_BNEQ 0x725
#define OP_BEQU 0x726
#define OP_CASN 0x201
#define OP_CCAT 0x202
#define OP_CTOC 0x241
#define OP_STOC 0x2A1
#define OP_ITOC 0x2C1
#define OP_CTOS 0x541
#define OP_CTOI 0x641
#define OP_CNEQ 0x745
#define OP_CEQU 0x746
#define OP_CNGT 0x747
#define OP_CGT 0x748
#define OP_CNLT 0x749
#define OP_CLT 0x74A
#define OP_SNEQ 0x7A5
#define OP_SEQU 0x7A6
#define OP_SNGT 0x7A7
#define OP_SGT 0x7A8
#define OP_SNLT 0x7A9
#define OP_SLT 0x7AA
#define OP_CAND 0x7E2
#define OP_COR 0x7E3
#define OP_CNOT 0x7E4
#define OP_INEQ 0x7C5
#define OP_IEQU 0x7C6
#define OP_INGT 0x7C7
#define OP_IGT 0x7C8
#define OP_INLT 0x7C9
#define OP_ILT 0x7CA
#define OP_IADD 0x6CB
#define OP_ISUB 0x6CC
#define OP_IIPR 0x6CD
#define OP_INEG 0x6D0
#define OP_IPEX 0x6D2
#define OP_SADD 0x5AB
#define OP_SSUB 0x5AC
#define OP_SSPR 0x5AD
#define OP_SSDV 0x5AE
#define OP_MASN 0x301
#define OP_MTRA 0x329
#define OP_MINV 0x3CA
#define OP_MNEG 0x344
#define OP_MTOM 0x341
#define OP_MADD 0x362
#define OP_MSUB 0x363
#define OP_MMPR 0x368
#define OP_VVPR 0x387
#define OP_MSPR 0x3A5
#define OP_MSDV 0x3A6
#define OP_VASN 0x401
#define OP_VNEG 0x444
#define OP_VTOV 0x441
#define OP_MVPR 0x46C
#define OP_VMPR 0x46D
#define OP_VADD 0x482
#define OP_VSUB 0x483
#define OP_VCRS 0x48B
#define OP_VSPR 0x4A5
#define OP_VSDV 0x4A6
#define OP_VDOT 0x58E
#define OP_MNEQ 0x765
#define OP_MEQU 0x766
#define OP_VNEQ 0x785
#define OP_VEQU 0x786
#define OP_SIEX 0x571
#define OP_SPEX 0x572
#define OP_SEXP 0x5AF
#define OP_SNEG 0x5B0
#define OP_ITOS 0x5C1
#define OP_STOI 0x6A1
#define OP_STOS 0x5A1
#define OP_IINT 0x8C1
#define OP_SINT 0x8A1
#define OP_CINT 0x841
#define OP_TINT 0x8E2
#define OP_BINT 0x821
#define OP_MINT 0x861
#define OP_VINT 0x881
#define OP_NINT 0x8E1

#define NO_TARGET ((size_t)-1)

typedef enum { RV_STRING, RV_INTEGER, RV_SCALAR, RV_BITS } rv_kind_t;

typedef struct {
    rv_kind_t kind;
    char *string;   /* RV_STRING; borrowed from the literal table */
    int32_t integer; /* RV_INTEGER */
    halmat_scalar_t scalar; /* RV_SCALAR */
    uint32_t bits;   /* RV_BITS -- raw pattern, no declared-width tracking (see state.h) */
} resolved_value_t;

static int32_t rv_to_integer(const resolved_value_t *v) {
    if (v->kind == RV_SCALAR) return halmat_scalar_to_integer(v->scalar);
    if (v->kind == RV_BITS) return (int32_t)v->bits;
    return v->integer;
}

static halmat_scalar_t rv_to_scalar(const resolved_value_t *v) {
    if (v->kind == RV_SCALAR) return v->scalar;
    if (v->kind == RV_INTEGER) return halmat_scalar_from_integer(v->integer, false);
    return halmat_scalar_zero(false);
}

/* Stores a resolved_value_t into a VAC slot by its own kind (mirrors the
 * inline field-setting every other opcode does at its own ins->index,
 * factored out for OP_RTRN's inline-FUNCTION case, which needs to store
 * to a slot other than its own -- IDEF's, not RTRN's -- and must
 * preserve whatever type the inline function actually returns, unlike
 * the existing FCAL/RTRN path which always narrows to INTEGER). */
static void store_resolved_to_vac(halmat_vac_slot_t *slot, const resolved_value_t *val) {
    memset(slot, 0, sizeof(*slot));
    switch (val->kind) {
        case RV_SCALAR:
            slot->is_scalar = true;
            slot->scalar = val->scalar;
            break;
        case RV_STRING:
            slot->is_string = true;
            slot->string = val->string;
            break;
        case RV_BITS:
            slot->is_bits = true;
            slot->bits = val->bits;
            break;
        default:
            slot->integer = val->integer;
            break;
    }
}

/* Precision-scale conversion for STOS/MTOM/VTOV's family (class-5/
 * STOS.md, class-3/MTOM.md, class-4/VTOV.md), per USA00309 Sec. 8.2's
 * confirmed bit-level rules: rule 12 (widening, single->double) pads 32
 * zero bits onto the mantissa's right; rule 7 (narrowing, double->
 * single) truncates the rightmost 32 bits. Since this project's
 * halmat_scalar_t already keeps lsw==0 for every single-precision value
 * (halmat_scalar_from_ibm_words, value.c), both directions reduce to
 * just flipping the double_precision flag (widening) or additionally
 * zeroing lsw (narrowing) -- no reconstruction through a native double
 * intermediate needed, so this is exact, not an approximation. */
static halmat_scalar_t scale_precision(halmat_scalar_t s, bool to_double) {
    s.double_precision = to_double;
    if (!to_double) s.lsw = 0;
    return s;
}

static void fail(halmat_state_t *state, const char *fmt, ...) {
    char buf[256];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);
    fprintf(stderr, "yaHALMAT2: %s (at HALMAT word #%zu)\n", buf,
            state->prog->instrs[state->pc].index);
    state->halted = true;
    state->exit_code = 1;
}

/* Converts a resolved HAL/S numeric-seconds value (as produced by SCHD's
 * AT/IN/EVERY/AFTER/UNTIL-time arith exps, or WAIT's interval exp) to a
 * tick count via HALMAT_TICKS_PER_SECOND (state.h) -- multiplying the
 * *raw* seconds value (as a double) by the tick rate, then rounding once
 * at the end. Deliberately NOT implemented as rv_to_integer() followed
 * by a multiply: rv_to_integer() rounds a SCALAR to the nearest whole
 * number first (halmat_scalar_to_integer), which would round to the
 * nearest whole *second* before ever being scaled -- destroying
 * sub-second precision (WAIT(0.5) must become
 * round(0.5*HALMAT_TICKS_PER_SECOND) ticks, not round(0.5)=... seconds
 * first). `what` names the clause for fail()'s message (e.g. "SCHD: AT/IN",
 * "WAIT"). Fails loudly (via fail(), state->halted per this file's
 * established convention) and returns false if the tick count doesn't
 * fit in an int64_t, or -- when want_int32 is true -- doesn't fit in an
 * int32_t either. Only repeat_interval needs want_int32=true: it's the
 * one genuinely fixed-width int32_t field of halmat_task_t this value
 * ever gets narrowed into (state.h). at_in_value/stop_deadline/WAIT's
 * own tick count all flow into int64_t fields/locals (wake_deadline,
 * etc.) and pass want_int32=false accordingly -- none of them have a
 * real 32-bit ceiling to enforce, and at HALMAT_TICKS_PER_SECOND=276000,
 * an ordinary multi-thousand-second WAIT/AT/IN interval can legitimately
 * exceed INT32_MAX ticks without being any kind of error. */
static bool schd_seconds_to_ticks(halmat_state_t *state, const resolved_value_t *v,
                                   const char *what, bool want_int32, int64_t *out_ticks) {
    double seconds = (v->kind == RV_SCALAR) ? halmat_scalar_to_double(v->scalar)
                      : (v->kind == RV_BITS) ? (double)(int32_t)v->bits
                                              : (double)v->integer;
    double rounded = round(seconds * (double)HALMAT_TICKS_PER_SECOND);
    if (!(rounded >= (double)INT64_MIN && rounded <= (double)INT64_MAX)) {
        fail(state, "%s: %.6g seconds overflows a 64-bit tick count at %d ticks/second",
             what, seconds, HALMAT_TICKS_PER_SECOND);
        return false;
    }
    int64_t ticks = (int64_t)rounded;
    if (want_int32 && (ticks < INT32_MIN || ticks > INT32_MAX)) {
        fail(state, "%s: %.6g seconds (%lld ticks) overflows a 32-bit tick count at %d ticks/second",
             what, seconds, (long long)ticks, HALMAT_TICKS_PER_SECOND);
        return false;
    }
    *out_ticks = ticks;
    return true;
}

/* strdup is POSIX, not ISO C99 -- MSVC (Plan.md's cross-platform build
 * target) doesn't provide it under strict conformance either. */
static char *dup_string(const char *s) {
    size_t len = strlen(s) + 1;
    char *copy = malloc(len);
    if (copy) memcpy(copy, s, len);
    return copy;
}

/* Forward-declared: defined later in this file (needs HALMAT_CONTAINER_
 * CAPACITY-adjacent machinery), but resolve_operand/write_destination's
 * QUAL_SYT case (arrayed-paragraph-replay redirection, see state.h's
 * arrayed_index comment) needs it earlier in the file than its own
 * natural home alongside resolve_container/store_container_result. */
static void ensure_container(halmat_state_t *state, uint16_t syt_index);

/* Shared by QUAL_SYT and QUAL_XPT (structure-field shadow slots, see
 * state.h's halmat_struct_field_t) -- both address the same shape of
 * storage, just keyed differently. */
static void read_syt_entry(const halmat_syt_entry_t *e, resolved_value_t *out) {
    if (e->type == SYT_TYPE_SCALAR) {
        out->kind = RV_SCALAR;
        out->scalar = e->scalar;
    } else if (e->type == SYT_TYPE_CHARACTER) {
        out->kind = RV_STRING;
        out->string = e->char_value ? e->char_value : "";
    } else if (e->type == SYT_TYPE_BIT) {
        out->kind = RV_BITS;
        out->bits = e->bit_value;
    } else {
        out->kind = RV_INTEGER;
        out->integer = e->value;
    }
}

/* The copy index for whatever structure-field touch is happening right
 * now (state.h's halmat_struct_field_t comment) -- state->arrayed_index
 * during an ADLP/DLPE-driven multi-copy replay, 0 for an ordinary
 * single-instance structure access outside one. */
static int32_t current_copy_index(halmat_state_t *state) {
    return state->arrayed_index >= 0 ? state->arrayed_index : 0;
}

/* Finds (or lazily creates) the shadow storage slot for a structure
 * field reference, keyed by (base_syt, field_syt, copy_index) -- see
 * state.h's halmat_struct_field_t comment for why this indirection
 * exists (field symbols are shared across every instance of a STRUCTURE
 * TEMPLATE, so field_syt alone can't be used as a direct storage key;
 * copy_index further distinguishes copies of a multiple-copy structure). */
static halmat_syt_entry_t *find_or_create_struct_field(halmat_state_t *state, uint16_t base_syt, uint16_t field_syt, int32_t copy_index) {
    for (size_t i = 0; i < state->struct_field_count; i++) {
        if (state->struct_fields[i].base_syt == base_syt && state->struct_fields[i].field_syt == field_syt &&
            state->struct_fields[i].copy_index == copy_index) {
            return &state->struct_fields[i].value;
        }
    }
    if (state->struct_field_count >= state->struct_field_capacity) {
        size_t new_cap = state->struct_field_capacity ? state->struct_field_capacity * 2 : 32;
        state->struct_fields = realloc(state->struct_fields, new_cap * sizeof(halmat_struct_field_t));
        state->struct_field_capacity = new_cap;
    }
    halmat_struct_field_t *slot = &state->struct_fields[state->struct_field_count++];
    memset(slot, 0, sizeof(*slot));
    slot->base_syt = base_syt;
    slot->field_syt = field_syt;
    slot->copy_index = copy_index;
    return &slot->value;
}

/* Resolves a QUAL_XPT operand (class-0/EXTN.md's "extended pointer",
 * DATA=stream position of the resolving EXTN instruction) to its shadow
 * storage slot, for whichever copy is current (current_copy_index).
 * Fails loudly if the referenced VAC slot isn't actually an EXTN
 * result, or if it's a bare/unqualified reference (struct_field_
 * syt is the structure's own TEMPLATE symbol, not a real field --
 * TASN/TEQU/TNEQ handle that case themselves; this helper is only for
 * ordinary xASN-family opcodes reading/writing a single qualified
 * field). */
static halmat_syt_entry_t *resolve_xpt_field(halmat_state_t *state, const halmat_operand_t *op) {
    if (op->data >= HALMAT_VAC_MAX) {
        fail(state, "XPT stream position %u out of range", op->data);
        return NULL;
    }
    const halmat_vac_slot_t *slot = &state->vac[op->data];
    if (!slot->is_struct_ref) {
        fail(state, "XPT operand does not reference an EXTN result");
        return NULL;
    }
    int32_t copy_idx = slot->struct_copy_index >= 0 ? slot->struct_copy_index : current_copy_index(state);
    return find_or_create_struct_field(state, slot->struct_base_syt, slot->struct_field_syt, copy_idx);
}

/* True if the symbol table (state->symtab, unavailable e.g. for --py
 * units) confirms this SYT index is a declared ARRAY/VECTOR/MATRIX --
 * used by resolve_operand/write_destination's QUAL_SYT case to tell a
 * genuine whole-array reference (only valid inside an arrayed-paragraph
 * replay, state.h's arrayed_index) from an ordinary scalar/integer one. */
static bool syt_is_array_shaped(halmat_state_t *state, uint16_t syt_index) {
    if (!state->symtab) return false;
    const halmat_symtab_entry_t *sym = halmat_symtab_find_by_index(state->symtab, syt_index);
    return sym && (sym->shape == HALMAT_SHAPE_ARRAY || sym->shape == HALMAT_SHAPE_VECTOR || sym->shape == HALMAT_SHAPE_MATRIX);
}

static bool resolve_operand(halmat_state_t *state, const halmat_operand_t *op, resolved_value_t *out) {
    memset(out, 0, sizeof(*out));
    switch (op->qual) {
        case QUAL_SYT: {
            if (op->data >= HALMAT_SYT_MAX) {
                fail(state, "SYT index %u out of range", op->data);
                return false;
            }
            if (syt_is_array_shaped(state, op->data)) {
                if (state->arrayed_index < 0) {
                    fail(state, "SYT index %u is a whole ARRAY/VECTOR/MATRIX referenced outside an arrayed-paragraph replay", op->data);
                    return false;
                }
                ensure_container(state, op->data);
                halmat_syt_entry_t *e = &state->syt[op->data];
                size_t idx = (size_t)state->arrayed_index % (e->element_count ? e->element_count : 1);
                out->kind = RV_SCALAR;
                out->scalar = e->elements[idx];
                return true;
            }
            read_syt_entry(&state->syt[op->data], out);
            return true;
        }
        case QUAL_XPT: {
            const halmat_syt_entry_t *e = resolve_xpt_field(state, op);
            if (!e) return false;
            read_syt_entry(e, out);
            return true;
        }
        case QUAL_LIT: {
            if (!state->literals || op->data >= state->literals->count) {
                fail(state, "literal index %u out of range", op->data);
                return false;
            }
            const halmat_literal_t *lit = &state->literals->entries[op->data];
            if (lit->type == LIT_STRING) {
                out->kind = RV_STRING;
                out->string = lit->string;
            } else if (lit->type == LIT_FIXED || lit->type == LIT_DOUBLE) {
                /* Litfile numeric entries carry no INTEGER-vs-SCALAR
                 * distinction of their own (see literal.h) -- resolve as
                 * the exact bit-level SCALAR value; INTEGER-context
                 * consumers convert via rv_to_integer(). Callers that
                 * instead *store* this resolved value under a type tag
                 * (XXAR's CALL/WRITE argument binding, interp.c) can't
                 * rely on `out->kind` alone for that -- they reclassify
                 * using the operand's own tag1 (the HALMAT class the
                 * compiler actually recorded for it), the same signal
                 * XXAR's READ/READALL destination-class case already
                 * uses; see OP_XXAR's `literal_is_integer` below. */
                out->kind = RV_SCALAR;
                out->scalar = halmat_scalar_from_ibm_words(lit->msw, lit->lsw, lit->type == LIT_DOUBLE);
            } else if (lit->type == LIT_BIT) {
                out->kind = RV_BITS;
                out->bits = lit->bits;
            } else {
                fail(state, "literal index %u has an unsupported type (%d) for this context",
                     op->data, (int)lit->type);
                return false;
            }
            return true;
        }
        case QUAL_IMD:
            out->kind = RV_INTEGER;
            out->integer = (int32_t)(int16_t)op->data; /* IMD is a signed 16-bit immediate */
            return true;
        case QUAL_VAC: {
            if (op->data >= HALMAT_VAC_MAX) {
                fail(state, "VAC index %u out of range", op->data);
                return false;
            }
            const halmat_vac_slot_t *slot = &state->vac[op->data];
            if (slot->is_ref) {
                if (slot->ref_syt >= HALMAT_SYT_MAX) {
                    fail(state, "VAC subscript reference SYT out of range");
                    return false;
                }
                const halmat_syt_entry_t *base = &state->syt[slot->ref_syt];
                if (!base->elements || slot->ref_offset >= base->element_count) {
                    fail(state, "subscript reference out of range");
                    return false;
                }
                out->kind = RV_SCALAR;
                out->scalar = base->elements[slot->ref_offset];
            } else if (slot->is_string) {
                out->kind = RV_STRING;
                out->string = slot->string ? slot->string : "";
            } else if (slot->is_bits) {
                out->kind = RV_BITS;
                out->bits = slot->bits;
            } else if (slot->is_scalar) {
                out->kind = RV_SCALAR;
                out->scalar = slot->scalar;
            } else {
                out->kind = RV_INTEGER;
                out->integer = slot->integer;
            }
            return true;
        }
        default:
            fail(state, "operand qualifier %s not yet implemented in this context", halmat_qual_name(op->qual));
            return false;
    }
}

/* Assignment destination: a plain SYT slot (coerced to whichever of
 * INTEGER/SCALAR the destination already is, or established by this
 * first write -- matches the empirical finding that the assign opcode's
 * class tracks the *source*'s type, with any INTEGER<->SCALAR coercion
 * happening implicitly at the store, not via a separate conversion
 * opcode; see class-0/FCAL.md-adjacent notes and the out_array/
 * out_matrix fixtures), or a DSUB-produced subscript reference (ARRAY/
 * MATRIX element, always SCALAR for now -- see class-0/DSUB.md). */
/* Shared by QUAL_SYT and QUAL_XPT, mirroring read_syt_entry() above. */
static bool write_syt_entry(halmat_state_t *state, halmat_syt_entry_t *e, const resolved_value_t *val) {
    if (e->type == SYT_TYPE_UNKNOWN) {
        e->type = (val->kind == RV_STRING) ? SYT_TYPE_CHARACTER
                : (val->kind == RV_BITS) ? SYT_TYPE_BIT
                : (val->kind == RV_SCALAR) ? SYT_TYPE_SCALAR : SYT_TYPE_INTEGER;
    }
    if (e->type == SYT_TYPE_CHARACTER) {
        if (val->kind != RV_STRING) {
            fail(state, "cannot assign a non-CHARACTER value to a CHARACTER destination");
            return false;
        }
        free(e->char_value);
        e->char_value = dup_string(val->string);
    } else if (e->type == SYT_TYPE_BIT) {
        if (val->kind != RV_BITS) {
            fail(state, "cannot assign a non-BIT value to a BIT destination");
            return false;
        }
        e->bit_value = val->bits;
    } else if (e->type == SYT_TYPE_SCALAR) {
        e->scalar = rv_to_scalar(val);
    } else {
        e->value = rv_to_integer(val);
    }
    return true;
}

static bool write_destination(halmat_state_t *state, const halmat_operand_t *op, const resolved_value_t *val) {
    if (op->qual == QUAL_SYT) {
        if (op->data >= HALMAT_SYT_MAX) {
            fail(state, "SYT index %u out of range", op->data);
            return false;
        }
        if (syt_is_array_shaped(state, op->data)) {
            if (state->arrayed_index < 0) {
                fail(state, "SYT index %u is a whole ARRAY/VECTOR/MATRIX referenced outside an arrayed-paragraph replay", op->data);
                return false;
            }
            ensure_container(state, op->data);
            halmat_syt_entry_t *e = &state->syt[op->data];
            size_t idx = (size_t)state->arrayed_index % (e->element_count ? e->element_count : 1);
            e->elements[idx] = rv_to_scalar(val);
            return true;
        }
        return write_syt_entry(state, &state->syt[op->data], val);
    }
    if (op->qual == QUAL_XPT) {
        halmat_syt_entry_t *e = resolve_xpt_field(state, op);
        if (!e) return false;
        return write_syt_entry(state, e, val);
    }
    if (op->qual == QUAL_VAC) {
        if (op->data >= HALMAT_VAC_MAX) {
            fail(state, "VAC index %u out of range", op->data);
            return false;
        }
        halmat_vac_slot_t *slot = &state->vac[op->data];
        if (!slot->is_ref) {
            fail(state, "assignment destination is not a subscript reference");
            return false;
        }
        if (slot->ref_syt >= HALMAT_SYT_MAX) {
            fail(state, "VAC subscript reference SYT out of range");
            return false;
        }
        halmat_syt_entry_t *base = &state->syt[slot->ref_syt];
        if (!base->elements || slot->ref_offset >= base->element_count) {
            fail(state, "subscript destination out of range");
            return false;
        }
        base->elements[slot->ref_offset] = rv_to_scalar(val);
        return true;
    }
    if (op->qual == QUAL_OFF) {
        /* OFFSET-addressed element write, used by SINT (etc.) inside a
         * STRI/SLRI/ELRI/ETRI repeated-initialize group (class-8/
         * STRI.md, SLRI.md) -- op->data is a sequential offset (always
         * observed as 0) relative to the current replay iteration, added
         * to state->arrayed_index (the SLRI-driven paragraph-replay
         * counter, same mechanism ADLP/IDLP use for QUAL_SYT redirection
         * -- see interp_step). The target symbol itself isn't carried by
         * this operand at all; it comes from the most recently executed
         * STRI (state->stri_target_syt). */
        if (state->arrayed_index < 0) {
            fail(state, "QUAL_OFF destination used outside a repeated-initialize (STRI/SLRI) replay");
            return false;
        }
        if (state->stri_target_syt < 0 || state->stri_target_syt >= HALMAT_SYT_MAX) {
            fail(state, "QUAL_OFF destination used without a preceding STRI");
            return false;
        }
        uint16_t base_syt = (uint16_t)state->stri_target_syt;
        ensure_container(state, base_syt);
        halmat_syt_entry_t *e = &state->syt[base_syt];
        size_t idx = (size_t)(state->arrayed_index + (int32_t)op->data) % (e->element_count ? e->element_count : 1);
        e->elements[idx] = rv_to_scalar(val);
        return true;
    }
    fail(state, "unsupported assignment destination qualifier %s", halmat_qual_name(op->qual));
    return false;
}

/* Lazily allocates a SYT slot's ARRAY/MATRIX/VECTOR element storage
 * (idempotent -- returns immediately if already allocated), sizing it
 * from the symbol table's declared dimensions when available (state->
 * symtab, see symtab.h) and falling back to the generic placeholder
 * capacity otherwise (HALMAT_CONTAINER_CAPACITY's comment, state.h).
 * Sets rows/cols too, which DSUB/MASN-family opcodes use to tell a
 * real declared MATRIX shape from the unknown-shape fallback. */
static void ensure_container(halmat_state_t *state, uint16_t syt_index) {
    halmat_syt_entry_t *e = &state->syt[syt_index];
    if (e->elements) return;

    int rows = 0, cols = 0;
    size_t count = 0;
    if (state->symtab) {
        const halmat_symtab_entry_t *sym = halmat_symtab_find_by_index(state->symtab, syt_index);
        if (sym && sym->shape == HALMAT_SHAPE_MATRIX && sym->rows > 0 && sym->cols > 0) {
            rows = sym->rows;
            cols = sym->cols;
            count = (size_t)rows * (size_t)cols;
        } else if (sym && sym->shape == HALMAT_SHAPE_VECTOR && sym->cols > 0) {
            cols = sym->cols;
            count = (size_t)cols;
        } else if (sym && sym->shape == HALMAT_SHAPE_ARRAY && sym->array_dim_count >= 1) {
            count = (size_t)sym->array_dims[0]; /* only a single dimension is used -- see symtab.h */
        }
    }
    if (count == 0) count = HALMAT_CONTAINER_CAPACITY;

    e->elements = calloc(count, sizeof(halmat_scalar_t));
    e->element_count = count;
    e->rows = rows;
    e->cols = cols;
}

/* Matrix inverse (MINV, class-3/MINV.md; BFNC's INVERSE selector), via
 * ordinary double-precision Gauss-Jordan elimination with partial
 * pivoting. No specific inversion algorithm is mandated by the primary
 * sources -- only that INVERSE/MINV compute a genuine matrix inverse --
 * so this doesn't attempt bit-exact matching against whatever routine
 * the original compiler's runtime library used, and goes through double
 * (via halmat_scalar_to_double/from_double) rather than genuine hex-
 * float arithmetic, the same documented precision compromise as SEXP.
 * n is capped at 8 (n*n <= HALMAT_CONTAINER_CAPACITY=64, this
 * interpreter's generic container-size ceiling elsewhere). Returns
 * false for a singular (or n>8) matrix -- a genuine runtime ERROR
 * CONDITION under HAL/S's error model, not a value to silently
 * substitute (same disposition as SSDV's divide-by-zero), though the
 * exact USA003090 Appendix C response text wasn't available to consult
 * in this session -- the caller fail()s loudly rather than guessing at
 * that wording. */
static bool matrix_invert(const halmat_scalar_t *in, int n, halmat_scalar_t *out) {
    if (n <= 0 || n > 8) return false;
    double aug[8][16];
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) aug[i][j] = halmat_scalar_to_double(in[i * n + j]);
        for (int j = 0; j < n; j++) aug[i][n + j] = (i == j) ? 1.0 : 0.0;
    }
    for (int col = 0; col < n; col++) {
        int pivot = col;
        double best = fabs(aug[col][col]);
        for (int r = col + 1; r < n; r++) {
            if (fabs(aug[r][col]) > best) { best = fabs(aug[r][col]); pivot = r; }
        }
        if (best < 1e-12) return false; /* singular */
        if (pivot != col) {
            for (int j = 0; j < 2 * n; j++) { double t = aug[col][j]; aug[col][j] = aug[pivot][j]; aug[pivot][j] = t; }
        }
        double pv = aug[col][col];
        for (int j = 0; j < 2 * n; j++) aug[col][j] /= pv;
        for (int r = 0; r < n; r++) {
            if (r == col) continue;
            double factor = aug[r][col];
            for (int j = 0; j < 2 * n; j++) aug[r][j] -= factor * aug[col][j];
        }
    }
    bool dbl = false;
    for (int i = 0; i < n * n; i++) {
        if (in[i].double_precision) { dbl = true; break; }
    }
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            out[i * n + j] = halmat_scalar_from_double(aug[i][n + j], dbl);
    return true;
}

/* Reads a whole MATRIX/VECTOR operand (SYT variable or a VAC-carried
 * intermediate result, e.g. a prior MADD/VADD -- class-3/MADD.md's "no
 * destination operand, consumed by a following MASN via a VAC-qualified
 * operand" pattern applies to every MATRIX/VECTOR arithmetic opcode).
 * Does not copy -- the returned pointer aliases the SYT/VAC slot's own
 * storage, valid until that slot is next written. */
static bool resolve_container(halmat_state_t *state, const halmat_operand_t *op,
                               halmat_scalar_t **out_elems, size_t *out_count, int *out_rows, int *out_cols) {
    if (op->qual == QUAL_SYT) {
        if (op->data >= HALMAT_SYT_MAX) { fail(state, "SYT index %u out of range", op->data); return false; }
        ensure_container(state, op->data);
        halmat_syt_entry_t *e = &state->syt[op->data];
        *out_elems = e->elements;
        *out_count = e->element_count;
        *out_rows = e->rows;
        *out_cols = e->cols;
        return true;
    }
    if (op->qual == QUAL_VAC) {
        if (op->data >= HALMAT_VAC_MAX) { fail(state, "VAC index %u out of range", op->data); return false; }
        halmat_vac_slot_t *slot = &state->vac[op->data];
        if (!slot->is_container) { fail(state, "operand is not a MATRIX/VECTOR intermediate result"); return false; }
        *out_elems = slot->container;
        *out_count = slot->container_count;
        *out_rows = slot->container_rows;
        *out_cols = slot->container_cols;
        return true;
    }
    fail(state, "unsupported MATRIX/VECTOR operand qualifier %s", halmat_qual_name(op->qual));
    return false;
}

/* Stores a computed MATRIX/VECTOR result (elems/count, freshly built by
 * the caller into a stack buffer -- copied here, not aliased) into a VAC
 * slot, for a following MASN/VASN or chained arithmetic op to consume.
 * Frees any previous container this slot held (unlike the VAC string/
 * bits leak-across-loop-iterations tradeoff elsewhere in this file,
 * freeing here is just as simple as leaking and avoids it outright). */
static bool store_container_result(halmat_state_t *state, size_t vac_index,
                                    const halmat_scalar_t *elems, size_t count, int rows, int cols) {
    if (vac_index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); return false; }
    halmat_vac_slot_t *slot = &state->vac[vac_index];
    free(slot->container);
    slot->container = malloc(count * sizeof(halmat_scalar_t));
    if (!slot->container) { fail(state, "out of memory"); return false; }
    memcpy(slot->container, elems, count * sizeof(halmat_scalar_t));
    slot->is_ref = false;
    slot->is_container = true;
    slot->container_count = count;
    slot->container_rows = rows;
    slot->container_cols = cols;
    return true;
}

/* DTST/ETST bracket a DO WHILE/UNTIL loop, matched by the "bookkeeping
 * label" carried as both instructions' sole INL operand (see
 * class-0/DTST.md, class-0/ETST.md). CTST (class-0/CTST.md) sits right
 * after the per-cycle condition computation and has no label of its own;
 * it belongs to whichever DTST is innermost-open when it's reached, which
 * a single forward pass with a small stack captures directly (HALMAT
 * blocks nest strictly, so this doesn't need label-based matching for
 * CTST). CTST's own tag distinguishes WHILE (0, exit when the condition
 * is false) from UNTIL (1, exit when the condition is true) -- both
 * confirmed against a real compiled test_while.hal trace. */
#define LOOP_STACK_MAX 64

static void precompute_loop_targets(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->ctst_exit_target = malloc(n * sizeof(size_t));
    state->etst_back_target = malloc(n * sizeof(size_t));
    for (size_t i = 0; i < n; i++) {
        state->ctst_exit_target[i] = NO_TARGET;
        state->etst_back_target[i] = NO_TARGET;
    }

    struct {
        size_t dtst_pos;
        size_t ctst_pos;
    } stack[LOOP_STACK_MAX];
    int sp = 0;

    for (size_t i = 0; i < n; i++) {
        uint16_t opcode = state->prog->instrs[i].opcode;
        if (opcode == OP_DTST) {
            if (sp < LOOP_STACK_MAX) {
                stack[sp].dtst_pos = i;
                stack[sp].ctst_pos = NO_TARGET;
                sp++;
            }
        } else if (opcode == OP_CTST) {
            if (sp > 0) stack[sp - 1].ctst_pos = i;
        } else if (opcode == OP_ETST) {
            if (sp > 0) {
                sp--;
                if (stack[sp].ctst_pos != NO_TARGET) {
                    state->ctst_exit_target[stack[sp].ctst_pos] = i + 1;
                }
                state->etst_back_target[i] = stack[sp].dtst_pos + 1;
            }
        }
    }
}

/* See state.h's arrayed_paragraph_end/_count comment. Finds every
 * "ADLP immediately followed by DLPE" trailing-metadata pair (the only
 * shape confirmed empirically this session -- role 2/3's own no-body
 * cases share this exact shape too, so they're harmlessly treated the
 * same way: a paragraph of zero or more instructions, replayed N times,
 * is a correct no-op replay when N-times-replaying an empty or already-
 * scalar paragraph doesn't change anything) and records the preceding
 * paragraph (from the last statement boundary up to the ADLP) as
 * replayable. Multiple consecutive ADLPs before one DLPE (the multi-
 * dimensional-array case) use only the last ADLP's element count --
 * documented simplification, not exercised by any fixture. */
static void precompute_arrayed_paragraphs(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->arrayed_paragraph_end = malloc(n * sizeof(size_t));
    state->arrayed_paragraph_count = malloc(n * sizeof(int));
    for (size_t i = 0; i < n; i++) {
        state->arrayed_paragraph_end[i] = NO_TARGET;
        state->arrayed_paragraph_count[i] = 0;
    }

    size_t boundary = 0;
    for (size_t i = 0; i < n; i++) {
        uint16_t opcode = state->prog->instrs[i].opcode;
        if (opcode == OP_SMRK) {
            boundary = i + 1;
        } else if (opcode == OP_ADLP || opcode == OP_IDLP) {
            /* IDLP (STATIC-array counterpart of ADLP, class-0/IDLP.md)
             * shares the exact same single-instance-plus-trailing-
             * metadata shape for the uniform-INITIAL()-value case
             * (confirmed empirically: `V1 INITIAL(4.0)` on a default/
             * STATIC ARRAY(3) compiles to one SINT then IDLP(3) then
             * DLPE, no per-element repetition) -- treated identically. */
            size_t j = i;
            int count = 0;
            while (j < n && (state->prog->instrs[j].opcode == OP_ADLP || state->prog->instrs[j].opcode == OP_IDLP)) {
                const halmat_instr_t *adlp = &state->prog->instrs[j];
                if (adlp->operand_count == 1 && adlp->operands[0].qual == QUAL_IMD) {
                    count = (int16_t)adlp->operands[0].data;
                }
                j++;
            }
            if (j < n && state->prog->instrs[j].opcode == OP_DLPE && count > 0) {
                state->arrayed_paragraph_end[boundary] = j + 1;
                state->arrayed_paragraph_count[boundary] = count;
            }
        } else if (opcode == OP_SLRI) {
            /* STRI/SLRI/ELRI/ETRI: repeated-initialize group for the
             * n#value INITIAL() repetition-factor form (class-8/
             * SLRI.md). Unlike ADLP/IDLP (which trail the paragraph
             * they replay), SLRI leads it -- the preceding STRI names
             * the target symbol (recorded at runtime into
             * state->stri_target_syt, consumed by QUAL_OFF writes
             * inside the paragraph), SLRI's own first operand carries
             * the repetition count, and the bracketed paragraph runs
             * from just after SLRI up to (not including) ETRI. Contrary
             * to SLRI.md's original documented trace (which showed
             * literal per-element unrolling for a 1000-element array),
             * today's HALSFC build was confirmed (this session) to
             * always emit exactly one SINT/ELRI unit here regardless of
             * count -- i.e. the same single-instance-plus-replay-count
             * shape ADLP/IDLP use, just with SLRI leading instead of
             * trailing. Corrected in SLRI.md alongside this change. */
            const halmat_instr_t *slri = &state->prog->instrs[i];
            if (slri->operand_count == 2 && slri->operands[0].qual == QUAL_IMD) {
                int count = (int16_t)slri->operands[0].data;
                size_t j = i + 1;
                while (j < n && state->prog->instrs[j].opcode != OP_ETRI) j++;
                if (j < n && count > 0) {
                    state->arrayed_paragraph_end[i + 1] = j + 1;
                    state->arrayed_paragraph_count[i + 1] = count;
                }
            }
        }
    }
}

/* Precomputed per array-index position: the HAL/S statement number whose
 * code that position belongs to, for --debug's source-line display (see
 * srcmap.c, debug.c, interp_current_stmt_for_next()). SMRK's confirmed
 * placement (empirically, and per direct user correction) is *after* a
 * statement's own HALMAT, not before it -- SMRK(K) is the last
 * instruction generated for statement K, and the code that follows it
 * belongs to statement K+1. So the statement a given position belongs to
 * can't be determined by remembering the last SMRK *executed* (that's
 * always one statement behind); it has to be found by looking *forward*
 * to the next SMRK at or after that position. Filled by a single
 * backward scan: walking from the end, each SMRK(K) sets a running
 * "next statement" value to K, and every position (including the SMRK's
 * own) gets stamped with whatever that running value currently is.
 * Positions after the last SMRK in the stream (e.g. the trailing XREC)
 * get -1 (no statement). */
static void precompute_stmt_for_pc(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->stmt_for_pc = malloc(n * sizeof(long));
    long next_stmt = -1;
    for (size_t i = n; i-- > 0; ) {
        const halmat_instr_t *ins = &state->prog->instrs[i];
        if (ins->opcode == OP_SMRK && ins->operand_count == 1) {
            next_stmt = (long)ins->operands[0].data;
        }
        state->stmt_for_pc[i] = next_stmt;
    }
}

/* LBL destinations for BRA/FBRA (IF/THEN/ELSE), keyed by INL label
 * number -- a flat table, not stack-based, since BRA/FBRA/LBL don't
 * nest the way DTST/CTST/ETST do (see class-0/LBL.md, class-0/BRA.md,
 * class-0/FBRA.md). Confirmed against a real compiled test_ifelse.hal
 * trace: the branch target is LBL's own position (a no-op instruction),
 * not position+1 -- falling through it naturally lands one past it. */
static void precompute_labels(halmat_state_t *state) {
    state->label_pos = malloc(HALMAT_LABEL_MAX * sizeof(size_t));
    for (size_t i = 0; i < HALMAT_LABEL_MAX; i++) {
        state->label_pos[i] = NO_TARGET;
    }
    for (size_t i = 0; i < state->prog->count; i++) {
        const halmat_instr_t *ins = &state->prog->instrs[i];
        if (ins->opcode == OP_LBL && ins->operand_count == 1) {
            uint16_t label = ins->operands[0].data;
            if (label < HALMAT_LABEL_MAX) state->label_pos[label] = i;
        }
    }
}

/* List-form DO FOR (class-0/AFOR.md's "call-and-computed-return"
 * mechanism): a DFOR with exactly 2 operands (construct id + control
 * variable, no range literals -- see class-0/DFOR.md) opens the list,
 * followed immediately by one AFOR per value, then the (single, shared)
 * loop body, then the matching EFOR. */
#define FOR_STACK_MAX 64

static void precompute_for_loops(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->afor_body_target = malloc(n * sizeof(size_t));
    state->afor_return_target = malloc(n * sizeof(size_t));
    state->afor_control_var = calloc(n, sizeof(uint16_t));
    state->efor_is_list_form = calloc(n, sizeof(bool));
    state->efor_dfor_pos = malloc(n * sizeof(size_t));
    state->cfor_exit_target = malloc(n * sizeof(size_t));
    for (size_t i = 0; i < n; i++) {
        state->afor_body_target[i] = NO_TARGET;
        state->afor_return_target[i] = NO_TARGET;
        state->efor_dfor_pos[i] = NO_TARGET;
        state->cfor_exit_target[i] = NO_TARGET;
    }

    struct {
        bool is_list;
        size_t dfor_pos;
        uint16_t control_var;
        size_t afor_positions[HALMAT_MAX_OPERANDS * 8]; /* generous: real lists are short */
        size_t afor_count;
        size_t cfor_positions[64]; /* range-form only: pending CFORs to patch once EFOR's position is known */
        size_t cfor_count;
    } stack[FOR_STACK_MAX];
    int sp = 0;

    for (size_t i = 0; i < n; i++) {
        const halmat_instr_t *ins = &state->prog->instrs[i];
        if (ins->opcode == OP_DFOR) {
            if (sp < FOR_STACK_MAX) {
                bool is_list = (ins->operand_count == 2);
                stack[sp].is_list = is_list;
                stack[sp].dfor_pos = i;
                stack[sp].control_var = is_list ? ins->operands[1].data : 0;
                stack[sp].afor_count = 0;
                stack[sp].cfor_count = 0;
                sp++;
            }
        } else if (ins->opcode == OP_AFOR) {
            if (sp > 0 && stack[sp - 1].is_list && stack[sp - 1].afor_count < HALMAT_MAX_OPERANDS * 8) {
                stack[sp - 1].afor_positions[stack[sp - 1].afor_count++] = i;
                state->afor_control_var[i] = stack[sp - 1].control_var;
            }
        } else if (ins->opcode == OP_CFOR) {
            if (sp > 0 && !stack[sp - 1].is_list && stack[sp - 1].cfor_count < 64) {
                stack[sp - 1].cfor_positions[stack[sp - 1].cfor_count++] = i;
            }
        } else if (ins->opcode == OP_EFOR) {
            if (sp > 0) {
                sp--;
                if (stack[sp].is_list) {
                    state->efor_is_list_form[i] = true;
                    size_t count = stack[sp].afor_count;
                    for (size_t k = 0; k < count; k++) {
                        size_t pos = stack[sp].afor_positions[k];
                        state->afor_body_target[pos] = stack[sp].afor_positions[count - 1] + 1;
                        state->afor_return_target[pos] = (k + 1 < count) ? stack[sp].afor_positions[k + 1] : (i + 1);
                    }
                } else {
                    state->efor_dfor_pos[i] = stack[sp].dfor_pos;
                    for (size_t k = 0; k < stack[sp].cfor_count; k++) {
                        state->cfor_exit_target[stack[sp].cfor_positions[k]] = i + 1;
                    }
                }
            }
        }
    }
}

/* DO CASE (DCAS/CLBL/ECAS): see state.h's field comments and
 * class-0/DCAS.md, class-0/CLBL.md, class-0/ECAS.md. The final CLBL
 * before ECAS (tag=1, class-0/CLBL.md's "trap" CLBL) is excluded from
 * the selectable case list -- its role for out-of-range selectors is
 * documented as untested/unresolved, so an out-of-range selector fails
 * loudly here rather than guessing. */
#define CASE_STACK_MAX 64

static void precompute_case_dispatch(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->dcas_case_target = malloc(n * HALMAT_MAX_CASES * sizeof(size_t));
    state->dcas_case_count = calloc(n, sizeof(size_t));
    state->clbl_ecas_target = malloc(n * sizeof(size_t));
    for (size_t i = 0; i < n; i++) state->clbl_ecas_target[i] = NO_TARGET;

    struct {
        size_t dcas_pos;
        size_t clbl_positions[HALMAT_MAX_CASES];
        size_t clbl_count;
    } stack[CASE_STACK_MAX];
    int sp = 0;

    for (size_t i = 0; i < n; i++) {
        const halmat_instr_t *ins = &state->prog->instrs[i];
        if (ins->opcode == OP_DCAS) {
            if (sp < CASE_STACK_MAX) {
                stack[sp].dcas_pos = i;
                stack[sp].clbl_count = 0;
                sp++;
            }
        } else if (ins->opcode == OP_CLBL) {
            if (sp > 0 && stack[sp - 1].clbl_count < HALMAT_MAX_CASES) {
                stack[sp - 1].clbl_positions[stack[sp - 1].clbl_count++] = i;
            }
        } else if (ins->opcode == OP_ECAS) {
            if (sp > 0) {
                sp--;
                size_t dcas_pos = stack[sp].dcas_pos;
                size_t clbl_count = stack[sp].clbl_count;
                size_t ordinary_count = clbl_count > 0 ? clbl_count - 1 : 0; /* last CLBL is the trap */
                state->dcas_case_count[dcas_pos] = ordinary_count;
                for (size_t k = 0; k < clbl_count; k++) {
                    size_t clbl_pos = stack[sp].clbl_positions[k];
                    state->clbl_ecas_target[clbl_pos] = i + 1;
                    if (k < ordinary_count) {
                        state->dcas_case_target[dcas_pos * HALMAT_MAX_CASES + k] = clbl_pos + 1;
                    }
                }
            }
        }
    }
}

/* Function/procedure/task definitions (FDEF|TDEF...CLOS) sit inline in
 * the enclosing PROGRAM's own instruction stream, so ordinary
 * fall-through must skip over them entirely -- they're only ever
 * entered via an explicit FCAL/SCHD jump (to def_pos+1, bypassing
 * FDEF/TDEF itself, so its own "skip to my CLOS" logic never fires on
 * entry). Matched by SYT symbol equality (FDEF/TDEF and their CLOS
 * share the same operand), not a nesting stack, since HAL/S
 * functions/procedures/tasks don't nest inside each other -- only
 * inside the top-level MDEF (also closed by CLOS, but never opened via
 * FDEF/TDEF, so it never enters this map). See state.h's field comments. */
static void precompute_subprograms(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->symbol_def_pos = malloc(HALMAT_SYT_MAX * sizeof(size_t));
    state->def_clos_target = malloc(n * sizeof(size_t));
    state->symbol_active_task = malloc(HALMAT_SYT_MAX * sizeof(int));
    for (size_t i = 0; i < HALMAT_SYT_MAX; i++) {
        state->symbol_def_pos[i] = NO_TARGET;
        state->symbol_active_task[i] = -1;
    }
    for (size_t i = 0; i < n; i++) state->def_clos_target[i] = NO_TARGET;

    for (size_t i = 0; i < n; i++) {
        const halmat_instr_t *ins = &state->prog->instrs[i];
        if ((ins->opcode == OP_FDEF || ins->opcode == OP_TDEF || ins->opcode == OP_PDEF) && ins->operand_count == 1) {
            uint16_t sym = ins->operands[0].data;
            if (sym < HALMAT_SYT_MAX) state->symbol_def_pos[sym] = i;
        } else if (ins->opcode == OP_CLOS && ins->operand_count == 1) {
            uint16_t sym = ins->operands[0].data;
            if (sym < HALMAT_SYT_MAX && state->symbol_def_pos[sym] != NO_TARGET) {
                state->def_clos_target[state->symbol_def_pos[sym]] = i + 1;
            }
        }
    }
}

void interp_init(halmat_state_t *state, const halmat_program_t *prog,
                  const halmat_literal_table_t *literals, int num_blanks) {
    memset(state, 0, sizeof(*state));
    state->prog = prog;
    state->literals = literals;
    state->num_blanks = num_blanks;
    precompute_loop_targets(state);
    precompute_labels(state);
    precompute_for_loops(state);
    precompute_case_dispatch(state);
    precompute_subprograms(state);
    precompute_arrayed_paragraphs(state);
    precompute_stmt_for_pc(state);
    state->arrayed_index = -1;

    /* Primal process: priority 50 by default (USA003087 Sec. 13.1-13.3),
     * starts at the first instruction, READY. */
    state->tasks[0].in_use = true;
    state->tasks[0].is_primal = true;
    state->tasks[0].priority = 50;
    state->tasks[0].task_state = TASK_READY;
    state->tasks[0].saved_pc = 0;
    state->task_count = 1;
    state->current_task = 0;
    state->stri_target_syt = -1;
    state->stri_target_template_syt = -1;
    state->time_scale = 1.0; /* genuine real-time pacing by default; --time-scale overrides (main.c) */
    state->pacing_mode = HALMAT_PACING_BURST; /* interp_run_burst() by default; --pacing=signal overrides (main.c) */

    /* Default device mapping: 5=input/6=output, per HAL/S language
     * convention (Plan.md Phase 3) -- overridable via interp_set_device
     * (main.c's --ddi/--ddo). Every other device starts unmapped. */
    state->devices[5] = stdin;
    state->devices[6] = stdout;
}

void interp_set_device(halmat_state_t *state, int device, FILE *f) {
    if (device < 0 || device >= HALMAT_DEVICE_MAX) return;
    state->devices[device] = f;
}

void interp_set_raf_device(halmat_state_t *state, int channel, FILE *f, int record_size) {
    if (channel < 0 || channel >= HALMAT_DEVICE_MAX) return;
    state->raf_devices[channel] = f;
    state->raf_record_size[channel] = record_size;
}

void interp_set_symtab(halmat_state_t *state, const halmat_symtab_t *symtab) {
    state->symtab = symtab;
}

void interp_set_external_units(halmat_state_t *state, const halmat_external_call_map_t *map, size_t count) {
    free(state->external_calls);
    state->external_calls = calloc(HALMAT_SYT_MAX, sizeof(*state->external_calls));
    for (size_t i = 0; i < count; i++) {
        if (map[i].local_syt >= HALMAT_SYT_MAX) continue;
        state->external_calls[map[i].local_syt].target_state = map[i].target_state;
        state->external_calls[map[i].local_syt].target_entry_syt = map[i].target_entry_syt;
    }
}

void interp_set_time_scale(halmat_state_t *state, double scale) {
    state->time_scale = scale;
}

void interp_set_pacing_mode(halmat_state_t *state, halmat_pacing_mode_t mode) {
    state->pacing_mode = mode;
}

void interp_cleanup(halmat_state_t *state) {
    free(state->ctst_exit_target);
    free(state->etst_back_target);
    free(state->label_pos);
    free(state->afor_body_target);
    free(state->afor_return_target);
    free(state->afor_control_var);
    free(state->efor_is_list_form);
    free(state->efor_dfor_pos);
    free(state->cfor_exit_target);
    free(state->dcas_case_target);
    free(state->dcas_case_count);
    free(state->clbl_ecas_target);
    free(state->symbol_def_pos);
    free(state->def_clos_target);
    free(state->symbol_active_task);
    free(state->arrayed_paragraph_end);
    free(state->arrayed_paragraph_count);
    free(state->stmt_for_pc);
    free(state->external_calls); /* the table itself; the target_states it
                                   * points to are not owned here -- main.c's */
    state->external_calls = NULL;
    state->symbol_active_task = NULL;
    state->ctst_exit_target = NULL;
    state->etst_back_target = NULL;
    state->label_pos = NULL;
    state->afor_body_target = NULL;
    state->afor_return_target = NULL;
    state->afor_control_var = NULL;
    state->efor_is_list_form = NULL;
    state->efor_dfor_pos = NULL;
    state->cfor_exit_target = NULL;
    state->dcas_case_target = NULL;
    state->dcas_case_count = NULL;
    state->clbl_ecas_target = NULL;
    state->symbol_def_pos = NULL;
    state->def_clos_target = NULL;
    state->arrayed_paragraph_end = NULL;
    state->arrayed_paragraph_count = NULL;
    state->stmt_for_pc = NULL;

    for (size_t i = 0; i < HALMAT_SYT_MAX; i++) {
        free(state->syt[i].elements);
        state->syt[i].elements = NULL;
        free(state->syt[i].char_value);
        state->syt[i].char_value = NULL;
    }
    for (size_t i = 0; i < HALMAT_VAC_MAX; i++) {
        if (state->vac[i].is_string) free(state->vac[i].string);
        if (state->vac[i].is_container) free(state->vac[i].container);
    }
    for (size_t i = 0; i < state->struct_field_count; i++) {
        free(state->struct_fields[i].value.elements);
        free(state->struct_fields[i].value.char_value);
    }
    free(state->struct_fields);
    state->struct_fields = NULL;
    state->struct_field_count = 0;
    state->struct_field_capacity = 0;
}

static void flush_write(halmat_state_t *state, FILE *out) {
    for (uint8_t i = 0; i < state->io_pending.item_count; i++) {
        if (i > 0) {
            for (int b = 0; b < state->num_blanks; b++) fputc(' ', out);
        }
        if (state->io_pending.items[i].is_string) {
            fputs(state->io_pending.items[i].string, out);
        } else if (state->io_pending.items[i].is_scalar) {
            /* Fixed-width scientific-notation field per class-2/STOC.md
             * (USA00309 Sec. 6.1.3). */
            char buf[32];
            halmat_scalar_format(state->io_pending.items[i].scalar, buf, sizeof(buf));
            fputs(buf, out);
        } else {
            /* INTEGER WRITE field: 11-char right-justified, empirically
             * confirmed against a real HALSFC compile + yaHALMAT run
             * (see commit message / STATUS.md follow-up) -- not yet
             * cross-checked against USA00309's own text. */
            fprintf(out, "%11d", state->io_pending.items[i].integer);
        }
    }
    fputc('\n', out);
    state->io_pending.active = false;
    state->io_pending.item_count = 0;
}

/* Binds `state`'s currently-open io_pending call arguments into
 * `target`'s own SYT numbering (positional, entry_syt+1+i -- the same
 * convention FCAL/PCAL already use for same-unit calls, applied here to
 * the *target* unit's own numbering rather than the caller's) and runs
 * `target` from its own entry point to completion of exactly one call --
 * a cross-unit call into a separately-compiled EXTERNAL FUNCTION/
 * PROCEDURE (source-documentation/Multiple-file-problem.md), triggered
 * by FCAL/PCAL below via state->external_calls[].
 *
 * `target` is a persistent, previously interp_init'd state for the
 * external unit (main.c's interp_set_external_units) -- reused across
 * every call to it, not recreated fresh each time. Its own SYT storage
 * (ordinary local variables) therefore intentionally persists across
 * repeated calls, matching how a same-unit function's own locals
 * already behave (no per-call freshness is modeled anywhere in this
 * interpreter, so this isn't a new inconsistency). Scheduler/task state
 * is reset to a single fresh READY primal task before each call, since
 * concurrent scheduling across units is explicitly out of scope for now
 * (per direct user guidance) -- an external call is always a plain
 * synchronous call, never a SCHEDULEd task of its own.
 *
 * Returns false (having already called fail() on `state`, the *caller*)
 * if entry_syt has no FDEF/PDEF in `target`, there are too many
 * arguments, or the callee itself failed (its own fail() has already
 * fired against `target`, e.g. for a genuinely unimplemented opcode
 * reached inside the callee's own body). */
static bool run_external_call(halmat_state_t *state, halmat_state_t *target, uint16_t entry_syt, FILE *out) {
    if (target->symbol_def_pos[entry_syt] == NO_TARGET) {
        fail(state, "external call has no entry point (symbol %u)", entry_syt);
        return false;
    }
    for (uint8_t i = 0; i < state->io_pending.item_count; i++) {
        uint16_t param_syt = entry_syt + 1 + i;
        if (param_syt >= HALMAT_SYT_MAX) { fail(state, "too many call arguments"); return false; }
        if (state->io_pending.items[i].is_scalar) {
            target->syt[param_syt].type = SYT_TYPE_SCALAR;
            target->syt[param_syt].scalar = state->io_pending.items[i].scalar;
        } else {
            target->syt[param_syt].type = SYT_TYPE_INTEGER;
            target->syt[param_syt].value = state->io_pending.items[i].integer;
        }
    }
    target->pc = target->symbol_def_pos[entry_syt] + 1;
    target->halted = false;
    target->exit_code = 0;
    target->in_external_call = true;
    target->external_call_has_result = false;
    target->call_return_sp = 0;
    target->inline_func_sp = 0;
    target->current_task = 0;
    target->tasks[0].task_state = TASK_READY;
    target->tasks[0].saved_pc = target->pc;
    interp_run(target, out);
    if (target->exit_code != 0) {
        fail(state, "external call failed");
        return false;
    }
    return true;
}

/* Executes exactly one instruction for whatever task is current
 * (state->current_task, state->pc already set to its saved_pc by the
 * scheduler loop in interp_run). Split out from interp_run so the
 * scheduler can interleave tasks at instruction granularity -- see
 * state.h's scheduler field comments. */
static void exec_one(halmat_state_t *state, FILE *out) {
    (void)out; /* WRIT/READ now resolve their own device via state->devices
                * (--ddi/--ddo, state.h) rather than this parameter; kept
                * for interp_step/interp_run's public signature stability. */
    {
        const halmat_instr_t *ins = &state->prog->instrs[state->pc];
        resolved_value_t a, b;
        bool branched = false;

        switch (ins->opcode) {
            case OP_EXTN:
                /* "Extended pointer" -- resolves a structure-variable
                 * reference for a following TASN/TEQU/TNEQ or ordinary
                 * xASN-family opcode to consume via a QUAL_XPT operand
                 * referencing this instruction's own stream position
                 * (class-0/EXTN.md). Two operands always: base structure
                 * symbol, then either a specific field's symbol
                 * (qualified reference, e.g. ZQ1.QI) or the structure's
                 * own TEMPLATE symbol (bare/unqualified reference, e.g.
                 * plain ZQ1) -- EXTN.md's confirmed shape. No runtime
                 * effect of its own beyond recording this for later
                 * lookup (find_or_create_struct_field/resolve_xpt_field).
                 *
                 * The base operand is ordinarily QUAL_SYT (the plain
                 * structure symbol; struct_copy_index=-1, meaning "use
                 * whatever copy is ambient" -- current_copy_index()).
                 * When a single-copy-select subscript is present (e.g.
                 * `ZQ3 = ZQ1; S 2` picking ZQ3's copy 2, class-0/TSUB.md),
                 * the base is instead QUAL_VAC referencing a preceding
                 * TSUB's own stream position -- an *explicit* copy index
                 * that overrides the ambient one. */
                if (ins->operand_count != 2) { fail(state, "EXTN: expected 2 operands"); break; }
                if (ins->operands[1].qual != QUAL_SYT) {
                    fail(state, "EXTN: expected a SYT field operand");
                    break;
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                if (ins->operands[0].qual == QUAL_SYT) {
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_struct_ref = true;
                    state->vac[ins->index].struct_base_syt = ins->operands[0].data;
                    state->vac[ins->index].struct_field_syt = ins->operands[1].data;
                    state->vac[ins->index].struct_copy_index = -1;
                } else if (ins->operands[0].qual == QUAL_VAC) {
                    if (ins->operands[0].data >= HALMAT_VAC_MAX) { fail(state, "EXTN: VAC index out of range"); break; }
                    const halmat_vac_slot_t *copy_slot = &state->vac[ins->operands[0].data];
                    if (!copy_slot->is_copy_ref) { fail(state, "EXTN: VAC base operand does not reference a TSUB result"); break; }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_struct_ref = true;
                    state->vac[ins->index].struct_base_syt = copy_slot->copy_ref_base_syt;
                    state->vac[ins->index].struct_field_syt = ins->operands[1].data;
                    state->vac[ins->index].struct_copy_index = copy_slot->copy_ref_copy_index;
                } else {
                    fail(state, "EXTN: unsupported base operand qualifier %s", halmat_qual_name(ins->operands[0].qual));
                    break;
                }
                break;

            case OP_TSUB:
                /* Structure-copy subscript specifier, single-copy-select
                 * form only (class-0/TSUB.md) -- range-select (3
                 * operands) fails loudly, untested. Two operands: the
                 * multi-copy structure's own SYT, then the copy number
                 * (confirmed QUAL_IMD for a literal index; an expression
                 * operand, which per USA003087 Sec 19.6 should also be
                 * legal, isn't implemented). Result consumed by a
                 * following EXTN via a QUAL_VAC operand referencing
                 * TSUB's own stream position (see OP_EXTN above), not
                 * used directly by anything else. */
                if (ins->operand_count != 2) { fail(state, "TSUB: only the single-copy-select form (2 operands) is implemented"); break; }
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "TSUB: expected a SYT structure operand"); break; }
                if (ins->operands[1].qual != QUAL_IMD) { fail(state, "TSUB: only a literal copy index is implemented"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_copy_ref = true;
                state->vac[ins->index].copy_ref_base_syt = ins->operands[0].data;
                /* Copy numbers are 1-based in HAL/S source (`copy 2`) but
                 * this interpreter's copy_index is 0-based (matches
                 * arrayed_index's own 0-based convention, and ADLP's
                 * count directly, per state.h) -- subtract 1. */
                state->vac[ins->index].copy_ref_copy_index = (int32_t)(int16_t)ins->operands[1].data - 1;
                break;

            case OP_STRI:
                /* Names the target for a following repeated-initialize
                 * group (class-8/STRI.md). Two distinct forms, per the
                 * operand's own qualifier:
                 * - QUAL_SYT: the `n#value` array-repetition form
                 *   (SLRI/ELRI/ETRI, class-8/SLRI.md) -- stri_target_syt
                 *   is the array's own symbol, consumed by
                 *   write_destination's QUAL_OFF case.
                 * - QUAL_XPT: the whole-structure INITIAL(...) form
                 *   (TINT, class-8/TINT.md) -- the operand is a bare/
                 *   unqualified EXTN reference (struct_field_syt is the
                 *   TEMPLATE's own symbol, not a real field). Records
                 *   both the structure *instance*'s own SYT
                 *   (stri_target_syt, the shadow-slot storage base) and
                 *   the TEMPLATE's SYT (stri_target_template_syt, used
                 *   to compute each terminal's own field symbol via
                 *   offset arithmetic -- see TINT's own case). */
                state->stri_target_template_syt = -1;
                if (ins->operand_count == 1 && ins->operands[0].qual == QUAL_SYT) {
                    state->stri_target_syt = (int32_t)ins->operands[0].data;
                } else if (ins->operand_count == 1 && ins->operands[0].qual == QUAL_XPT) {
                    if (ins->operands[0].data < HALMAT_VAC_MAX) {
                        const halmat_vac_slot_t *slot = &state->vac[ins->operands[0].data];
                        if (slot->is_struct_ref) {
                            state->stri_target_syt = (int32_t)slot->struct_base_syt;
                            state->stri_target_template_syt = (int32_t)slot->struct_field_syt;
                        }
                    }
                }
                break;

            case OP_NOP:
            case OP_PXRC:
            case OP_XREC:
            case OP_SMRK:
            case OP_MDEF:
            case OP_CDEF:
            case OP_EDCL:
            case OP_DSMP:
            case OP_ESMP:
            case OP_DTST:
            case OP_IFHD:
            case OP_LBL:
            case OP_ADLP:
            case OP_IDLP:
            case OP_DLPE:
            case OP_SLRI:
            case OP_ELRI:
            case OP_ETRI:
            case OP_IMRK:
            case OP_TDCL:
            case OP_UDEF:
            case OP_EINT:
                /* IMRK (class-0/IMRK.md) brackets each statement inside
                 * an inline FUNCTION block -- a pure marker (see
                 * OP_IDEF/OP_ICLS below for the block's own open/close
                 * handling). TDCL (class-0/TDCL.md, `TEMPORARY`
                 * data-item declaration) generates no code of its own
                 * ("pure declaration" per its confirmed trace). UDEF
                 * (class-0/UDEF.md) just labels an update block's own
                 * name; the block's body is ordinary already-supported
                 * HALMAT. EINT (`EQUATE EXTERNAL`, class-8/EINT.md) is
                 * pure linker metadata for non-HAL/S callers -- "takes
                 * up no space," generates an ESD entry-point record at
                 * the object-code level, and its new equate name is
                 * flagged INACTIVE so HAL/S itself can never reference
                 * it again (confirmed: doing so is a compile error) --
                 * nothing for this interpreter to do at runtime. */
                /* Structural/bookkeeping markers; no runtime effect on
                 * their own. DTST/LBL just open a bookkeeping label --
                 * the real work happens in CTST/ETST/BRA/FBRA below.
                 * ADLP/DLPE (class-0/ADLP.md) are reached directly here
                 * only as a defensive fallback -- interp_step's own
                 * arrayed-paragraph replay (state.h's arrayed_paragraph_
                 * end/_count, precompute_arrayed_paragraphs) normally
                 * jumps straight past a recognized ADLP/DLPE pair without
                 * ever executing them individually. Falling through to
                 * here (role 3's structureness metadata, which never
                 * wraps a real body; or a role 1/2 shape this session's
                 * precompute didn't recognize) is a safe no-op either
                 * way -- see ADLP.md's own confirmation that role 3
                 * "brackets no HALMAT loop body at all". */
                break;

            case OP_ERON:
            case OP_ERSE:
                /* ON ERROR/OFF ERROR (ERON, class-0/ERON.md) and SEND
                 * ERROR (ERSE, class-0/ERSE.md) register/simulate error-
                 * handling metadata for HAL/S's ERROR CONDITION recovery
                 * mechanism (per the user-supplied-statement form's own
                 * confirmed trace, the handler code itself is skipped in
                 * normal flow by an ordinary BRA already emitted right
                 * after ERON -- not something ERON needs to act on). A
                 * genuine no-op here is therefore correct for normal
                 * (no-runtime-error) execution. What's NOT implemented:
                 * this interpreter's existing runtime-error path (fail(),
                 * used uniformly for divide-by-zero, singular MINV, out-
                 * of-range subscripts, etc.) never consults an ON ERROR
                 * table -- every runtime error is unconditionally fatal
                 * regardless of any ON ERROR IGNORE/SYSTEM/handler-
                 * statement modification a program may have set up, and
                 * ERSE's SEND ERROR doesn't actually simulate a
                 * recovery action. USA003090 Appendix C is understood to
                 * document HAL/S's execution-time-error response
                 * conventions in detail, but wasn't available to consult
                 * in this session -- wiring real ON ERROR dispatch into
                 * every existing fail() call site is deferred rather
                 * than guessed at. */
                break;

            case OP_TASN: {
                /* Structure assign, class-0/TASN.md: source-first,
                 * receiver-second, both QUAL_XPT (stream position of
                 * the resolving EXTN) referencing a *bare* structure
                 * reference. Real hardware copies the whole structure
                 * as a byte blob; this interpreter has no byte-layout
                 * model (state.h's halmat_struct_field_t comment), so
                 * instead copies every field this interpreter has
                 * itself already tracked (via a prior qualified
                 * assignment) from the source's shadow slots to the
                 * receiver's -- an approximation that's exact once every
                 * field has been touched individually at least once, but
                 * won't reproduce a field the source never had assigned
                 * (stays at the receiver's own prior/zero value instead
                 * of copying source's zero-initialized default). */
                if (ins->operand_count != 2) { fail(state, "TASN: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_XPT || ins->operands[1].qual != QUAL_XPT) {
                    fail(state, "TASN: both operands must be XPT");
                    break;
                }
                if (ins->operands[0].data >= HALMAT_VAC_MAX || ins->operands[1].data >= HALMAT_VAC_MAX) {
                    fail(state, "TASN: XPT stream position out of range");
                    break;
                }
                const halmat_vac_slot_t *src_ref = &state->vac[ins->operands[0].data];
                const halmat_vac_slot_t *dst_ref = &state->vac[ins->operands[1].data];
                if (!src_ref->is_struct_ref || !dst_ref->is_struct_ref) {
                    fail(state, "TASN: XPT operand does not reference an EXTN result");
                    break;
                }
                uint16_t src_base = src_ref->struct_base_syt, dst_base = dst_ref->struct_base_syt;
                int32_t ambient_idx = current_copy_index(state);
                int32_t src_copy_idx = src_ref->struct_copy_index >= 0 ? src_ref->struct_copy_index : ambient_idx;
                int32_t dst_copy_idx = dst_ref->struct_copy_index >= 0 ? dst_ref->struct_copy_index : ambient_idx;
                /* Snapshot the count first: find_or_create may realloc/append
                 * (a field touched on the destination for the first time)
                 * while we're iterating, which would otherwise walk into
                 * newly-appended entries. */
                size_t count = state->struct_field_count;
                bool ok = true;
                for (size_t i = 0; ok && i < count; i++) {
                    if (state->struct_fields[i].base_syt != src_base || state->struct_fields[i].copy_index != src_copy_idx) continue;
                    uint16_t field = state->struct_fields[i].field_syt;
                    /* Snapshot the source's scalar fields by value before
                     * find_or_create_struct_field's possible realloc (which
                     * would invalidate a pointer into struct_fields[i]). */
                    halmat_syt_entry_t src_snapshot = state->struct_fields[i].value;
                    if (src_snapshot.elements) {
                        /* ARRAY/MATRIX/VECTOR structure terminal: deep-copying
                         * correctly needs element_count, which is on the
                         * snapshot already -- but no fixture exercises this,
                         * so fail loudly rather than risk a silent aliasing
                         * bug in an unverified path. */
                        fail(state, "TASN: copying a structure terminal with ARRAY/MATRIX/VECTOR type is not yet implemented");
                        ok = false;
                        break;
                    }
                    halmat_syt_entry_t *dst_field = find_or_create_struct_field(state, dst_base, field, dst_copy_idx);
                    free(dst_field->char_value);
                    *dst_field = src_snapshot;
                    dst_field->char_value = src_snapshot.char_value ? dup_string(src_snapshot.char_value) : NULL;
                }
                if (!ok) break;
                break;
            }

            case OP_TEQU:
            case OP_TNEQ: {
                /* Structure equal/not-equal, class-0/TEQU.md/TNEQ.md:
                 * same XPT-pair shape as TASN. Real hardware delegates
                 * to a runtime routine (#QCSTRUC) that loops over every
                 * terminal; this compares every field either side's
                 * shadow-slot table knows about (union of both), via the
                 * same exact-value comparison as SEQU/MEQU -- a field
                 * neither side has touched contributes a vacuous zero-
                 * equals-zero match, consistent with TASN's own
                 * approximation above. */
                if (ins->operand_count != 2) { fail(state, "TEQU/TNEQ: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_XPT || ins->operands[1].qual != QUAL_XPT) {
                    fail(state, "TEQU/TNEQ: both operands must be XPT");
                    break;
                }
                if (ins->operands[0].data >= HALMAT_VAC_MAX || ins->operands[1].data >= HALMAT_VAC_MAX) {
                    fail(state, "TEQU/TNEQ: XPT stream position out of range");
                    break;
                }
                const halmat_vac_slot_t *lhs_ref = &state->vac[ins->operands[0].data];
                const halmat_vac_slot_t *rhs_ref = &state->vac[ins->operands[1].data];
                if (!lhs_ref->is_struct_ref || !rhs_ref->is_struct_ref) {
                    fail(state, "TEQU/TNEQ: XPT operand does not reference an EXTN result");
                    break;
                }
                uint16_t lhs_base = lhs_ref->struct_base_syt, rhs_base = rhs_ref->struct_base_syt;
                int32_t ambient_idx = current_copy_index(state);
                int32_t lhs_copy_idx = lhs_ref->struct_copy_index >= 0 ? lhs_ref->struct_copy_index : ambient_idx;
                int32_t rhs_copy_idx = rhs_ref->struct_copy_index >= 0 ? rhs_ref->struct_copy_index : ambient_idx;
                bool all_equal = true;
                size_t count = state->struct_field_count;
                for (size_t i = 0; i < count && all_equal; i++) {
                    uint16_t base = state->struct_fields[i].base_syt;
                    int32_t want_idx = (base == lhs_base) ? lhs_copy_idx : rhs_copy_idx;
                    if (state->struct_fields[i].copy_index != want_idx) continue;
                    if (base != lhs_base && base != rhs_base) continue;
                    uint16_t field = state->struct_fields[i].field_syt;
                    halmat_syt_entry_t *lhs_field = find_or_create_struct_field(state, lhs_base, field, lhs_copy_idx);
                    halmat_syt_entry_t *rhs_field = find_or_create_struct_field(state, rhs_base, field, rhs_copy_idx);
                    resolved_value_t lv, rv;
                    read_syt_entry(lhs_field, &lv);
                    read_syt_entry(rhs_field, &rv);
                    if (lv.kind == RV_STRING || rv.kind == RV_STRING) {
                        if (lv.kind != rv.kind || strcmp(lv.string, rv.string) != 0) all_equal = false;
                    } else {
                        halmat_scalar_t diff = halmat_scalar_sub(rv_to_scalar(&lv), rv_to_scalar(&rv));
                        if (!(diff.msw == 0 && diff.lsw == 0)) all_equal = false;
                    }
                }
                bool result = (ins->opcode == OP_TEQU) ? all_equal : !all_equal;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = result ? 1 : 0;
                break;
            }

            case OP_NASN:
                /* NAME (pointer) assign, class-0/NASN.md: both operands
                 * are ordinary SYT references to data items, not to the
                 * NAME variable's own stored value -- pointer semantics
                 * are implicit in NASN's identity, not the operand
                 * qualifiers. Bypasses resolve_operand/write_destination
                 * entirely (those resolve a *value*; NASN needs the raw
                 * target SYT index instead). NULL is QUAL=IMD (any
                 * value), per NINT.md's confirmed NULL encoding. */
                if (ins->operand_count != 2) { fail(state, "NASN: expected 2 operands"); break; }
                if (ins->operands[1].qual != QUAL_SYT) { fail(state, "NASN: receiver must be SYT"); break; }
                {
                    uint16_t target = (ins->operands[0].qual == QUAL_SYT) ? ins->operands[0].data : HALMAT_NAME_NULL;
                    uint16_t dest_syt = ins->operands[1].data;
                    if (dest_syt >= HALMAT_SYT_MAX) { fail(state, "NASN: SYT index out of range"); break; }
                    state->syt[dest_syt].type = SYT_TYPE_NAME;
                    state->syt[dest_syt].name_target = target;
                }
                break;

            case OP_NEQU:
            case OP_NNEQ:
                /* NAME (pointer) equal/not-equal, class-0/NEQU.md/
                 * NNEQ.md: TRUE if both sides' stored pointer target
                 * matches (pointer identity, not target-value equality).
                 * A NAME variable never assigned via NASN/NINT defaults
                 * to SYT_TYPE_UNKNOWN with name_target=0 (zero-
                 * initialized), which is a valid-looking SYT index, not
                 * NULL -- comparisons against an unset NAME are
                 * therefore not reliably NULL-equivalent; no fixture
                 * exercises that case. */
                if (ins->operand_count != 2) { fail(state, "NEQU/NNEQ: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_SYT || ins->operands[1].qual != QUAL_SYT) {
                    fail(state, "NEQU/NNEQ: both operands must be SYT");
                    break;
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                {
                    uint16_t sym_a = ins->operands[0].data, sym_b = ins->operands[1].data;
                    if (sym_a >= HALMAT_SYT_MAX || sym_b >= HALMAT_SYT_MAX) { fail(state, "NEQU/NNEQ: SYT index out of range"); break; }
                    bool equal = (state->syt[sym_a].name_target == state->syt[sym_b].name_target);
                    bool result = (ins->opcode == OP_NEQU) ? equal : !equal;
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].integer = result ? 1 : 0;
                }
                break;

            case OP_DFOR:
                if (ins->operand_count == 2) {
                    break; /* list-form: no-op, AFOR does the real work */
                }
                if (ins->operand_count < 4) { fail(state, "DFOR: expected 2 (list) or 4-5 (range) operands"); break; }
                if (!resolve_operand(state, &ins->operands[2], &a)) break; /* initial value */
                if (ins->operands[1].qual != QUAL_SYT) { fail(state, "DFOR: control variable must be SYT"); break; }
                /* Range form always runs its first in-range cycle
                 * without a pre-test (class-0/DFOR.md) -- just set the
                 * control variable and fall through into the body. */
                state->syt[ins->operands[1].data].type = SYT_TYPE_INTEGER;
                state->syt[ins->operands[1].data].value = rv_to_integer(&a);
                break;

            case OP_BRA:
            case OP_FBRA: {
                if (ins->opcode == OP_FBRA) {
                    if (ins->operand_count != 2) { fail(state, "FBRA: expected 2 operands"); break; }
                    if (!resolve_operand(state, &ins->operands[1], &a)) break;
                    if (rv_to_integer(&a) != 0) break; /* condition true: fall through, no branch */
                } else if (ins->operand_count != 1) {
                    fail(state, "BRA: expected 1 operand");
                    break;
                }
                uint16_t label = ins->operands[0].data;
                if (label >= HALMAT_LABEL_MAX || state->label_pos[label] == NO_TARGET) {
                    fail(state, "branch to undefined label %u", label);
                    break;
                }
                state->pc = state->label_pos[label];
                branched = true;
                break;
            }

            case OP_CNEQ:
            case OP_CEQU:
            case OP_CNGT:
            case OP_CGT:
            case OP_CNLT:
            case OP_CLT: {
                /* Plain strcmp: padding rule for unequal-length operands
                 * is unconfirmed (class-7/CEQU.md) -- no fixture found a
                 * counterexample to the natural "compare as-is" reading,
                 * so that's what's implemented; revisit if a fixed-length
                 * CHARACTER comparison ever needs blank-padding instead. */
                if (ins->operand_count != 2) { fail(state, "character comparison: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (a.kind != RV_STRING || b.kind != RV_STRING) { fail(state, "character comparison: both operands must be CHARACTER"); break; }
                int cmp = strcmp(a.string, b.string);
                bool result;
                switch (ins->opcode) {
                    case OP_CNEQ: result = cmp != 0; break;
                    case OP_CEQU: result = cmp == 0; break;
                    case OP_CNGT: result = cmp <= 0; break;
                    case OP_CGT: result = cmp > 0; break;
                    case OP_CNLT: result = cmp >= 0; break;
                    case OP_CLT: default: result = cmp < 0; break;
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = result ? 1 : 0;
                break;
            }

            case OP_SNEQ:
            case OP_SEQU:
            case OP_SNGT:
            case OP_SGT:
            case OP_SNLT:
            case OP_SLT: {
                /* Exact hex-float comparison via subtraction, sign/true-
                 * zero test (SEQU.md's "exact vs. tolerance" question is
                 * unresolved in the primary sources -- exact bit
                 * comparison is the natural hardware-faithful reading,
                 * consistent with this interpreter's genuine-hex-float
                 * (not native-double) arithmetic elsewhere). True zero is
                 * always sign=0 (halmat_scalar_add's convention). */
                if (ins->operand_count != 2) { fail(state, "scalar comparison: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                halmat_scalar_t diff = halmat_scalar_sub(rv_to_scalar(&a), rv_to_scalar(&b));
                bool is_zero = (diff.msw == 0 && diff.lsw == 0);
                bool is_negative = ((diff.msw >> 31) & 1) != 0;
                bool result;
                switch (ins->opcode) {
                    case OP_SNEQ: result = !is_zero; break;
                    case OP_SEQU: result = is_zero; break;
                    case OP_SNGT: result = is_zero || is_negative; break;
                    case OP_SGT: result = !is_zero && !is_negative; break;
                    case OP_SNLT: result = is_zero || !is_negative; break;
                    case OP_SLT: default: result = !is_zero && is_negative; break;
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = result ? 1 : 0;
                break;
            }

            case OP_CAND:
            case OP_COR: {
                if (ins->operand_count != 2) { fail(state, "logical AND/OR: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                bool ab = (rv_to_integer(&a) != 0), bb = (rv_to_integer(&b) != 0);
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = ((ins->opcode == OP_CAND) ? (ab && bb) : (ab || bb)) ? 1 : 0;
                break;
            }

            case OP_CNOT:
                if (ins->operand_count != 1) { fail(state, "logical NOT: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = (rv_to_integer(&a) == 0) ? 1 : 0;
                break;

            case OP_INEQ:
            case OP_IEQU:
            case OP_INGT:
            case OP_IGT:
            case OP_INLT:
            case OP_ILT: {
                if (ins->operand_count != 2) { fail(state, "integer comparison: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                int32_t ai = rv_to_integer(&a), bi = rv_to_integer(&b);
                bool result;
                switch (ins->opcode) {
                    case OP_INEQ: result = ai != bi; break;
                    case OP_IEQU: result = ai == bi; break;
                    case OP_INGT: result = ai <= bi; break;
                    case OP_IGT: result = ai > bi; break;
                    case OP_INLT: result = ai >= bi; break;
                    case OP_ILT: default: result = ai < bi; break;
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = result ? 1 : 0;
                break;
            }

            case OP_CTST: {
                if (ins->operand_count != 1) { fail(state, "CTST: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                bool cond_true = (rv_to_integer(&a) != 0);
                /* tag 0 = WHILE (exit when condition false), tag 1 = UNTIL
                 * (exit when condition true) -- confirmed against a real
                 * compiled test_while.hal trace (see precompute_loop_targets). */
                bool exit_loop = ins->tag ? cond_true : !cond_true;
                if (exit_loop) {
                    size_t target = state->ctst_exit_target[state->pc];
                    if (target == NO_TARGET) { fail(state, "CTST has no matching ETST"); break; }
                    state->pc = target;
                    branched = true;
                }
                break;
            }

            case OP_CFOR: {
                /* Range-form DO FOR's supplementary WHILE/UNTIL clause,
                 * class-0/CFOR.md -- same tag=WHILE(0)/UNTIL(1)
                 * convention as CTST, but exits to one past the
                 * enclosing EFOR (precompute_for_loops' cfor_exit_
                 * target) rather than a DTST/ETST pair's own target. */
                if (ins->operand_count != 1) { fail(state, "CFOR: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                bool cond_true = (rv_to_integer(&a) != 0);
                bool exit_loop = ins->tag ? cond_true : !cond_true;
                if (exit_loop) {
                    size_t target = state->cfor_exit_target[state->pc];
                    if (target == NO_TARGET) { fail(state, "CFOR has no matching (range-form) EFOR"); break; }
                    state->pc = target;
                    branched = true;
                }
                break;
            }

            case OP_ETST: {
                size_t target = state->etst_back_target[state->pc];
                if (target == NO_TARGET) { fail(state, "ETST has no matching DTST"); break; }
                state->pc = target;
                branched = true;
                break;
            }

            case OP_AFOR: {
                if (ins->operand_count != 1) { fail(state, "AFOR: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (state->afor_body_target[state->pc] == NO_TARGET) {
                    fail(state, "AFOR outside of a recognized list-form DO FOR");
                    break;
                }
                state->syt[state->afor_control_var[state->pc]].type = SYT_TYPE_INTEGER;
                state->syt[state->afor_control_var[state->pc]].value = rv_to_integer(&a);
                if (state->for_return_sp >= 64) { fail(state, "DO FOR nesting too deep"); break; }
                state->for_return_stack[state->for_return_sp++] = state->afor_return_target[state->pc];
                state->pc = state->afor_body_target[state->pc];
                branched = true;
                break;
            }

            case OP_EFOR: {
                if (state->efor_is_list_form[state->pc]) {
                    if (state->for_return_sp <= 0) { fail(state, "EFOR with no matching AFOR dispatch"); break; }
                    state->pc = state->for_return_stack[--state->for_return_sp];
                    branched = true;
                    break;
                }
                size_t dfor_pos = state->efor_dfor_pos[state->pc];
                if (dfor_pos == NO_TARGET) { fail(state, "EFOR has no matching DFOR"); break; }
                const halmat_instr_t *dfor = &state->prog->instrs[dfor_pos];
                resolved_value_t final_val, incr_val;
                if (!resolve_operand(state, &dfor->operands[3], &final_val)) break;
                if (dfor->operand_count == 5) {
                    if (!resolve_operand(state, &dfor->operands[4], &incr_val)) break;
                } else {
                    incr_val.kind = RV_INTEGER;
                    incr_val.integer = 1; /* implicit default increment (class-0/DFOR.md) */
                }
                int32_t incr = rv_to_integer(&incr_val);
                int32_t final = rv_to_integer(&final_val);
                uint16_t control_var = dfor->operands[1].data;
                int32_t new_value = state->syt[control_var].value + incr;
                state->syt[control_var].value = new_value;
                bool in_range = (incr >= 0) ? (new_value <= final) : (new_value >= final);
                if (in_range) {
                    state->pc = dfor_pos + 1;
                    branched = true;
                }
                /* else: fall through, loop exit */
                break;
            }

            case OP_DCAS: {
                if (ins->operand_count != 2) { fail(state, "DCAS: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                int32_t sel = rv_to_integer(&a);
                size_t count = state->dcas_case_count[state->pc];
                if (sel < 1 || (size_t)sel > count) {
                    fail(state, "DO CASE selector %d out of range 1..%zu (out-of-range/ELSE handling not yet implemented)",
                         sel, count);
                    break;
                }
                state->pc = state->dcas_case_target[state->pc * HALMAT_MAX_CASES + (sel - 1)];
                branched = true;
                break;
            }

            case OP_CLBL: {
                /* Reached here only by falling through from the
                 * preceding case's body (DCAS always jumps past its
                 * target CLBL) -- this is the implicit "branch to ECAS"
                 * every case body ends with (class-0/ECAS.md). */
                size_t target = state->clbl_ecas_target[state->pc];
                if (target == NO_TARGET) { fail(state, "CLBL has no matching ECAS"); break; }
                state->pc = target;
                branched = true;
                break;
            }

            case OP_ECAS:
                break; /* join point; no-op */

            case OP_DSUB: {
                /* Only the single-index "index" subscript kind is
                 * implemented (alpha=5 array-dimension / alpha=1
                 * component -- both single-value forms; see
                 * class-0/DSUB.md's confirmed table). Asterisk/to-
                 * partition/at-partition/CSZ/ASZ forms aren't handled.
                 * Two-index (MATRIX) flattening uses the real declared
                 * row-major shape when the symbol table confirms it
                 * (ensure_container/symtab.h); otherwise (no symtab, or
                 * more than 2 indices) falls back to a placeholder
                 * stride -- unobserved by any fixture that doesn't also
                 * have its COMMON*.out available. */
                if (ins->operand_count < 2) { fail(state, "DSUB: expected at least 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "DSUB: reference must be SYT"); break; }
                uint16_t base_syt = ins->operands[0].data;
                if (base_syt >= HALMAT_SYT_MAX) { fail(state, "DSUB: SYT index out of range"); break; }
                ensure_container(state, base_syt);
                halmat_syt_entry_t *base = &state->syt[base_syt];

                bool ok = true;
                size_t offset = 0;
                uint8_t num_indices = ins->operand_count - 1;
                if (base->rows > 0 && num_indices == 2) {
                    resolved_value_t ridx, cidx;
                    if (!resolve_operand(state, &ins->operands[1], &ridx)) { ok = false; }
                    else if (!resolve_operand(state, &ins->operands[2], &cidx)) { ok = false; }
                    else {
                        int32_t r = rv_to_integer(&ridx) - 1, c = rv_to_integer(&cidx) - 1;
                        if (r < 0) r = 0;
                        if (c < 0) c = 0;
                        offset = (size_t)r * (size_t)base->cols + (size_t)c;
                    }
                } else {
                    for (uint8_t i = 0; i < num_indices; i++) {
                        resolved_value_t idx;
                        if (!resolve_operand(state, &ins->operands[1 + i], &idx)) { ok = false; break; }
                        int32_t idx_val = rv_to_integer(&idx) - 1; /* HAL/S is 1-indexed */
                        if (idx_val < 0) idx_val = 0;
                        offset = offset * 16 + (size_t)idx_val; /* placeholder stride per extra dimension */
                    }
                }
                if (!ok) break;
                offset %= base->element_count;

                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = true;
                state->vac[ins->index].ref_syt = base_syt;
                state->vac[ins->index].ref_offset = offset;
                break;
            }

            case OP_MASN:
            case OP_VASN: {
                /* Whole-container assign, source-first/receiver-second
                 * like the rest of the xASN family (class-3/MASN.md,
                 * class-4/VASN.md). */
                if (ins->operand_count != 2) { fail(state, "MASN/VASN: expected 2 operands"); break; }
                halmat_scalar_t *src; size_t src_count; int src_rows, src_cols;
                if (!resolve_container(state, &ins->operands[0], &src, &src_count, &src_rows, &src_cols)) break;
                if (ins->operands[1].qual != QUAL_SYT) { fail(state, "MASN/VASN: receiver must be SYT"); break; }
                uint16_t dest_syt = ins->operands[1].data;
                if (dest_syt >= HALMAT_SYT_MAX) { fail(state, "MASN/VASN: SYT index out of range"); break; }
                ensure_container(state, dest_syt);
                halmat_syt_entry_t *dest = &state->syt[dest_syt];
                if (dest->element_count != src_count) {
                    fail(state, "MASN/VASN: shape mismatch (%zu vs %zu elements)", src_count, dest->element_count);
                    break;
                }
                memcpy(dest->elements, src, src_count * sizeof(halmat_scalar_t));
                dest->rows = src_rows;
                dest->cols = src_cols;
                break;
            }

            case OP_MNEG:
            case OP_VNEG: {
                if (ins->operand_count != 1) { fail(state, "MNEG/VNEG: expected 1 operand"); break; }
                halmat_scalar_t *src; size_t count; int rows, cols;
                if (!resolve_container(state, &ins->operands[0], &src, &count, &rows, &cols)) break;
                if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "MNEG/VNEG: container too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (size_t i = 0; i < count; i++) result[i] = halmat_scalar_negate(src[i]);
                if (!store_container_result(state, ins->index, result, count, rows, cols)) break;
                break;
            }

            case OP_MTOM:
            case OP_VTOV: {
                /* Matrix/vector precision scale (class-3/MTOM.md,
                 * class-4/VTOV.md) -- same exp$(@SINGLE)/exp$(@DOUBLE)
                 * trigger and TAG convention as STOS, applied
                 * elementwise. One operand (source SYT); consumed by a
                 * following MASN/VASN via this instruction's own VAC
                 * slot, same "no destination operand" pattern as MADD/
                 * VADD. Confirmed empirically this session to compile as
                 * a single whole-container instruction (like MADD/VADD),
                 * not the ADLP/DLPE-wrapped per-element loop originally
                 * documented -- see MTOM.md/VTOV.md's correction. */
                if (ins->operand_count != 1) { fail(state, "MTOM/VTOV: expected 1 operand"); break; }
                halmat_scalar_t *ca; size_t count_a; int rows_a, cols_a;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (count_a > HALMAT_CONTAINER_CAPACITY) { fail(state, "MTOM/VTOV: container too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                bool to_double = (ins->tag == 2);
                for (size_t i = 0; i < count_a; i++) result[i] = scale_precision(ca[i], to_double);
                if (!store_container_result(state, ins->index, result, count_a, rows_a, cols_a)) break;
                break;
            }

            case OP_MADD:
            case OP_MSUB:
            case OP_VADD:
            case OP_VSUB: {
                /* Elementwise add/sub, class-3/MADD.md's confirmed
                 * "no destination operand -- consumed by a following
                 * MASN via a VAC-qualified operand" pattern. */
                if (ins->operand_count != 2) { fail(state, "MADD/MSUB/VADD/VSUB: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (count_a != count_b) { fail(state, "MADD/MSUB/VADD/VSUB: operand shape mismatch"); break; }
                if (count_a > HALMAT_CONTAINER_CAPACITY) { fail(state, "MADD/MSUB/VADD/VSUB: container too large"); break; }
                bool is_sub = (ins->opcode == OP_MSUB || ins->opcode == OP_VSUB);
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (size_t i = 0; i < count_a; i++) {
                    result[i] = is_sub ? halmat_scalar_sub(ca[i], cb[i]) : halmat_scalar_add(ca[i], cb[i]);
                }
                if (!store_container_result(state, ins->index, result, count_a, rows_a, cols_a)) break;
                break;
            }

            case OP_MSPR:
            case OP_MSDV:
            case OP_VSPR:
            case OP_VSDV: {
                /* Matrix/vector times/divided-by a plain SCALAR operand
                 * (class-3/MSPR.md, class-3/MSDV.md, class-4/VSPR.md,
                 * class-4/VSDV.md) -- assumed container-operand-first,
                 * scalar-operand-second by analogy with every other
                 * base-then-modifier operand order in this project
                 * (e.g. SPEX/IPEX's base-then-exponent); operand-word
                 * order isn't independently confirmed in the primary
                 * sources for these four opcodes specifically. */
                if (ins->operand_count != 2) { fail(state, "MSPR/MSDV/VSPR/VSDV: expected 2 operands"); break; }
                halmat_scalar_t *ca; size_t count; int rows, cols;
                if (!resolve_container(state, &ins->operands[0], &ca, &count, &rows, &cols)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "MSPR/MSDV/VSPR/VSDV: container too large"); break; }
                halmat_scalar_t scalar_operand = rv_to_scalar(&b);
                bool is_div = (ins->opcode == OP_MSDV || ins->opcode == OP_VSDV);
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                bool ok = true;
                for (size_t i = 0; ok && i < count; i++) {
                    if (is_div) {
                        if (!halmat_scalar_divide(ca[i], scalar_operand, &result[i])) {
                            fail(state, "MSDV/VSDV: division by zero (floating point divide exception)");
                            ok = false;
                        }
                    } else {
                        result[i] = halmat_scalar_multiply(ca[i], scalar_operand);
                    }
                }
                if (!ok) break;
                if (!store_container_result(state, ins->index, result, count, rows, cols)) break;
                break;
            }

            case OP_MTRA: {
                if (ins->operand_count != 1) { fail(state, "MTRA: expected 1 operand"); break; }
                halmat_scalar_t *src; size_t count; int rows, cols;
                if (!resolve_container(state, &ins->operands[0], &src, &count, &rows, &cols)) break;
                if (rows <= 0 || cols <= 0) { fail(state, "MTRA: operand is not a MATRIX (unknown shape)"); break; }
                if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "MTRA: container too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (int r = 0; r < rows; r++)
                    for (int c = 0; c < cols; c++)
                        result[c * rows + r] = src[r * cols + c];
                if (!store_container_result(state, ins->index, result, count, cols, rows)) break;
                break;
            }

            case OP_MINV: {
                /* Two operands, not one -- class-3/MINV.md's own doc
                 * (written before this session, when MINV was still
                 * unimplemented) states the operand-word format as
                 * unconfirmed; empirically it's operand[0]=SYT (the
                 * matrix) plus a second QUAL=5=LIT operand this session
                 * didn't fully decode (the generated object code loads
                 * its DATA value via a bare `LA` -- load-address, not a
                 * literal-table dereference -- suggesting a compile-time
                 * constant/routine-selector rather than a numeric input
                 * to the inversion itself; ignored here since the
                 * inverse computed from operand[0] alone already matches
                 * hand-derived expected values exactly). */
                if (ins->operand_count != 2) { fail(state, "MINV: expected 2 operands"); break; }
                halmat_scalar_t *src; size_t count; int rows, cols;
                if (!resolve_container(state, &ins->operands[0], &src, &count, &rows, &cols)) break;
                if (rows <= 0 || cols <= 0 || rows != cols) { fail(state, "MINV: operand is not a square MATRIX"); break; }
                if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "MINV: container too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                if (!matrix_invert(src, rows, result)) {
                    fail(state, "MINV: singular matrix (floating point error condition)");
                    break;
                }
                if (!store_container_result(state, ins->index, result, count, rows, cols)) break;
                break;
            }

            case OP_MMPR: {
                if (ins->operand_count != 2) { fail(state, "MMPR: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (rows_a <= 0 || cols_a <= 0 || rows_b <= 0 || cols_b <= 0) { fail(state, "MMPR: operands must be MATRIX (unknown shape)"); break; }
                if (cols_a != rows_b) { fail(state, "MMPR: dimension mismatch (%dx%d times %dx%d)", rows_a, cols_a, rows_b, cols_b); break; }
                size_t result_count = (size_t)rows_a * (size_t)cols_b;
                if (result_count > HALMAT_CONTAINER_CAPACITY) { fail(state, "MMPR: result too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (int i = 0; i < rows_a; i++) {
                    for (int j = 0; j < cols_b; j++) {
                        halmat_scalar_t sum = halmat_scalar_zero(false);
                        for (int k = 0; k < cols_a; k++) {
                            sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[i * cols_a + k], cb[k * cols_b + j]));
                        }
                        result[i * cols_b + j] = sum;
                    }
                }
                if (!store_container_result(state, ins->index, result, result_count, rows_a, cols_b)) break;
                break;
            }

            case OP_MVPR: {
                /* Matrix-vector product (matrix premultiplies vector),
                 * class-4/MVPR.md. */
                if (ins->operand_count != 2) { fail(state, "MVPR: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (rows_a <= 0 || cols_a <= 0) { fail(state, "MVPR: first operand must be MATRIX"); break; }
                if ((size_t)cols_a != count_b) { fail(state, "MVPR: dimension mismatch"); break; }
                if ((size_t)rows_a > HALMAT_CONTAINER_CAPACITY) { fail(state, "MVPR: result too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (int i = 0; i < rows_a; i++) {
                    halmat_scalar_t sum = halmat_scalar_zero(false);
                    for (int k = 0; k < cols_a; k++) sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[i * cols_a + k], cb[k]));
                    result[i] = sum;
                }
                if (!store_container_result(state, ins->index, result, (size_t)rows_a, 0, rows_a)) break;
                break;
            }

            case OP_VMPR: {
                /* Vector-matrix product (vector premultiplies matrix),
                 * class-4/VMPR.md. */
                if (ins->operand_count != 2) { fail(state, "VMPR: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (rows_b <= 0 || cols_b <= 0) { fail(state, "VMPR: second operand must be MATRIX"); break; }
                if (count_a != (size_t)rows_b) { fail(state, "VMPR: dimension mismatch"); break; }
                if ((size_t)cols_b > HALMAT_CONTAINER_CAPACITY) { fail(state, "VMPR: result too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (int j = 0; j < cols_b; j++) {
                    halmat_scalar_t sum = halmat_scalar_zero(false);
                    for (int k = 0; k < rows_b; k++) sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[k], cb[k * cols_b + j]));
                    result[j] = sum;
                }
                if (!store_container_result(state, ins->index, result, (size_t)cols_b, 0, cols_b)) break;
                break;
            }

            case OP_VCRS: {
                if (ins->operand_count != 2) { fail(state, "VCRS: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (count_a != 3 || count_b != 3) { fail(state, "VCRS: both operands must be 3-element VECTORs"); break; }
                halmat_scalar_t result[3];
                result[0] = halmat_scalar_sub(halmat_scalar_multiply(ca[1], cb[2]), halmat_scalar_multiply(ca[2], cb[1]));
                result[1] = halmat_scalar_sub(halmat_scalar_multiply(ca[2], cb[0]), halmat_scalar_multiply(ca[0], cb[2]));
                result[2] = halmat_scalar_sub(halmat_scalar_multiply(ca[0], cb[1]), halmat_scalar_multiply(ca[1], cb[0]));
                if (!store_container_result(state, ins->index, result, 3, 0, 3)) break;
                break;
            }

            case OP_VDOT: {
                /* Vector dot product, class-5/VDOT.md -- classed under
                 * SCALAR by HALMAT's result-type convention; unlike
                 * every other MATRIX/VECTOR opcode here, the result is a
                 * plain scalar VAC value, not a container. */
                if (ins->operand_count != 2) { fail(state, "VDOT: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                if (count_a != count_b) { fail(state, "VDOT: operand shape mismatch"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                halmat_scalar_t sum = halmat_scalar_zero(false);
                for (size_t i = 0; i < count_a; i++) sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[i], cb[i]));
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = sum;
                break;
            }

            case OP_VVPR: {
                /* Vector outer product, class-3/VVPR.md -- classed under
                 * MATRIX by HALMAT's result-type convention. */
                if (ins->operand_count != 2) { fail(state, "VVPR: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                size_t result_count = count_a * count_b;
                if (result_count > HALMAT_CONTAINER_CAPACITY) { fail(state, "VVPR: result too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                for (size_t i = 0; i < count_a; i++)
                    for (size_t j = 0; j < count_b; j++)
                        result[i * count_b + j] = halmat_scalar_multiply(ca[i], cb[j]);
                if (!store_container_result(state, ins->index, result, result_count, (int)count_a, (int)count_b)) break;
                break;
            }

            case OP_MEQU:
            case OP_MNEQ:
            case OP_VEQU:
            case OP_VNEQ: {
                /* Elementwise comparison across the whole container
                 * (class-7/MEQU.md/VEQU.md); *EQU true only if every
                 * element matches exactly (same exact-comparison
                 * rationale as SEQU -- see that case's comment). */
                if (ins->operand_count != 2) { fail(state, "MEQU/MNEQ/VEQU/VNEQ: expected 2 operands"); break; }
                halmat_scalar_t *ca, *cb; size_t count_a, count_b; int rows_a, cols_a, rows_b, cols_b;
                if (!resolve_container(state, &ins->operands[0], &ca, &count_a, &rows_a, &cols_a)) break;
                if (!resolve_container(state, &ins->operands[1], &cb, &count_b, &rows_b, &cols_b)) break;
                bool all_equal = (count_a == count_b);
                for (size_t i = 0; all_equal && i < count_a; i++) {
                    halmat_scalar_t diff = halmat_scalar_sub(ca[i], cb[i]);
                    if (!(diff.msw == 0 && diff.lsw == 0)) all_equal = false;
                }
                bool is_neq = (ins->opcode == OP_MNEQ || ins->opcode == OP_VNEQ);
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = (is_neq ? !all_equal : all_equal) ? 1 : 0;
                break;
            }

            case OP_IINT:
                if (ins->operand_count != 2) { fail(state, "IINT: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "IINT: destination must be SYT"); break; }
                state->syt[ins->operands[0].data].type = SYT_TYPE_INTEGER;
                state->syt[ins->operands[0].data].value = rv_to_integer(&a);
                break;

            case OP_SINT:
                /* Direct symbol-table form (class-8/SINT.md) -- goes
                 * through write_destination (not a raw state->syt field
                 * write) specifically so a whole-ARRAY/VECTOR/MATRIX
                 * destination (the uniform-INITIAL()-value case, e.g.
                 * `V1 INITIAL(4.0)` on ARRAY(3) SCALAR, confirmed to
                 * compile to exactly this single SINT plus a trailing
                 * IDLP/ADLP-and-DLPE metadata pair -- see interp_step's
                 * arrayed-paragraph replay) correctly redirects through
                 * the same syt_is_array_shaped check ordinary assignment
                 * opcodes use, instead of silently corrupting the
                 * array's element storage with a scalar write. The
                 * OFFSET-addressed form (QUAL_OFF, a `n#value` repeated-
                 * INITIAL list, STRI.md's family) is handled the same
                 * way, via write_destination's QUAL_OFF case. */
                if (ins->operand_count != 2) { fail(state, "SINT: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                {
                    halmat_scalar_t sv = rv_to_scalar(&a);
                    a.kind = RV_SCALAR;
                    a.scalar = sv;
                }
                if (!write_destination(state, &ins->operands[0], &a)) break;
                break;

            case OP_CINT:
                /* Direct symbol-table form only (class-8/CINT.md), same
                 * shape as SINT/IINT. */
                if (ins->operand_count != 2) { fail(state, "CINT: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "CINT: OFFSET-addressed form not yet implemented"); break; }
                if (a.kind != RV_STRING) { fail(state, "CINT: initializer is not CHARACTER"); break; }
                {
                    halmat_syt_entry_t *e = &state->syt[ins->operands[0].data];
                    free(e->char_value);
                    e->type = SYT_TYPE_CHARACTER;
                    e->char_value = dup_string(a.string);
                }
                break;

            case OP_TINT: {
                /* Structure-terminal initialize (class-8/TINT.md):
                 * whole-structure INITIAL(...) list, one TINT per
                 * *coalesced run* of consecutive terminals (the
                 * compiler's ICQ_OUTPUT coalescing -- confirmed
                 * empirically this session: the literal operand's own
                 * tag1 carries the run length, defaulting to 1 when
                 * absent/zero). Two operands: OFFSET (the run's starting
                 * terminal-slot index, cumulative across the whole STRI
                 * group) and the first coalesced value's literal-table
                 * index. Requires a preceding structure-form STRI (see
                 * OP_STRI) to have resolved the target instance/template;
                 * each terminal's own field symbol is template_syt+1+
                 * offset -- the compiler emits a template's terminal
                 * symbols at consecutive SYT indices immediately
                 * following the template's own (confirmed empirically),
                 * matching FCAL's "callee+1+i" argument convention.
                 * ARRAY/MATRIX/VECTOR terminals (which occupy more than
                 * one terminal-slot each, per TINT.md's own worked
                 * multi-terminal trace) aren't handled -- this only
                 * covers the plain scalar/integer-terminal case, no
                 * fixture needs more yet. */
                if (ins->operand_count != 2) { fail(state, "TINT: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_OFF) { fail(state, "TINT: expected an OFFSET first operand"); break; }
                if (ins->operands[1].qual != QUAL_LIT) { fail(state, "TINT: expected a LIT second operand"); break; }
                if (state->stri_target_syt < 0 || state->stri_target_template_syt < 0) {
                    fail(state, "TINT used without a preceding whole-structure STRI");
                    break;
                }
                uint16_t base_syt = (uint16_t)state->stri_target_syt;
                uint16_t template_syt = (uint16_t)state->stri_target_template_syt;
                int run_count = ins->operands[1].tag1 > 0 ? ins->operands[1].tag1 : 1;
                int32_t copy_idx = current_copy_index(state);
                bool ok = true;
                for (int k = 0; ok && k < run_count; k++) {
                    halmat_operand_t lit_op = {0};
                    lit_op.qual = QUAL_LIT;
                    lit_op.data = (uint16_t)(ins->operands[1].data + k);
                    resolved_value_t rv;
                    if (!resolve_operand(state, &lit_op, &rv)) { ok = false; break; }
                    uint32_t field_syt32 = (uint32_t)template_syt + 1 + ins->operands[0].data + (uint32_t)k;
                    if (field_syt32 >= HALMAT_SYT_MAX) { fail(state, "TINT: computed field SYT out of range"); ok = false; break; }
                    /* Litfile numeric entries carry no INTEGER-vs-SCALAR
                     * distinction of their own (resolve_operand's QUAL_LIT
                     * case always resolves FIXED/DOUBLE as RV_SCALAR) --
                     * unlike SINT/IINT (whose own opcode identity already
                     * says which), TINT is shared across every terminal
                     * type, so the declared type has to come from the
                     * symbol table instead, per-terminal. */
                    if (state->symtab && rv.kind == RV_SCALAR) {
                        const halmat_symtab_entry_t *fsym = halmat_symtab_find_by_index(state->symtab, field_syt32);
                        if (fsym && fsym->hal_class == 6) { /* INTEGER */
                            int32_t iv = rv_to_integer(&rv);
                            rv.kind = RV_INTEGER;
                            rv.integer = iv;
                        }
                    }
                    halmat_syt_entry_t *field = find_or_create_struct_field(state, base_syt, (uint16_t)field_syt32, copy_idx);
                    if (!write_syt_entry(state, field, &rv)) { ok = false; break; }
                }
                if (!ok) break;
                break;
            }

            case OP_BINT:
                /* Direct symbol-table form only (class-8/BINT.md), same
                 * shape as SINT/IINT/CINT. */
                if (ins->operand_count != 2) { fail(state, "BINT: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "BINT: OFFSET-addressed form not yet implemented"); break; }
                if (a.kind != RV_BITS) { fail(state, "BINT: initializer is not BIT"); break; }
                state->syt[ins->operands[0].data].type = SYT_TYPE_BIT;
                state->syt[ins->operands[0].data].bit_value = a.bits;
                break;

            case OP_NINT:
                /* NAME (pointer) initialize, class-8/NINT.md: operand 1
                 * = the NAME variable, operand 2 = SYT target (real
                 * pointer) or IMD (NULL) -- same raw-index handling as
                 * NASN, bypassing resolve_operand. */
                if (ins->operand_count != 2) { fail(state, "NINT: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "NINT: OFFSET-addressed form not yet implemented"); break; }
                {
                    uint16_t target = (ins->operands[1].qual == QUAL_SYT) ? ins->operands[1].data : HALMAT_NAME_NULL;
                    state->syt[ins->operands[0].data].type = SYT_TYPE_NAME;
                    state->syt[ins->operands[0].data].name_target = target;
                }
                break;

            case OP_MINT:
            case OP_VINT:
                /* Uniform fill: every element of the MATRIX/VECTOR gets
                 * the same literal value (class-8/MINT.md/VINT.md);
                 * per-element INITIAL() lists instead use repeated SINT,
                 * already handled by SINT's own direct-SYT case. */
                if (ins->operand_count != 2) { fail(state, "MINT/VINT: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "MINT/VINT: OFFSET-addressed form not yet implemented"); break; }
                {
                    uint16_t dest_syt = ins->operands[0].data;
                    if (dest_syt >= HALMAT_SYT_MAX) { fail(state, "MINT/VINT: SYT index out of range"); break; }
                    ensure_container(state, dest_syt);
                    halmat_syt_entry_t *e = &state->syt[dest_syt];
                    halmat_scalar_t fill = rv_to_scalar(&a);
                    for (size_t i = 0; i < e->element_count; i++) e->elements[i] = fill;
                }
                break;

            case OP_IADD:
            case OP_ISUB:
                if (ins->operand_count != 2) { fail(state, "IADD/ISUB: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = (ins->opcode == OP_IADD)
                    ? (rv_to_integer(&a) + rv_to_integer(&b))
                    : (rv_to_integer(&a) - rv_to_integer(&b));
                break;

            case OP_IIPR:
                if (ins->operand_count != 2) { fail(state, "IIPR: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = rv_to_integer(&a) * rv_to_integer(&b);
                break;

            case OP_INEG:
                if (ins->operand_count != 1) { fail(state, "INEG: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = -rv_to_integer(&a);
                break;

            case OP_IPEX: {
                /* Positive-literal-exponent integer power (class-6/IPEX.md):
                 * repeated multiplication, exponent >= 0 (non-negative
                 * literal, confirmed compile-time-known). Negative/non-
                 * literal exponents never reach this opcode -- HAL/S
                 * coerces those to SCALAR (ITOS+SIEX/SEXP) at compile
                 * time instead, per IPEX.md's Usage Context. */
                if (ins->operand_count != 2) { fail(state, "IPEX: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                int32_t base = rv_to_integer(&a);
                int32_t exponent = rv_to_integer(&b);
                if (exponent < 0) { fail(state, "IPEX: negative exponent (expected non-negative literal)"); break; }
                int32_t result = 1;
                for (int32_t i = 0; i < exponent; i++) result *= base;
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = result;
                break;
            }

            case OP_SADD:
            case OP_SSUB:
                /* Genuine IBM hex-float arithmetic (value.c's
                 * halmat_scalar_add/sub), not a native-double
                 * approximation -- see value.h's documented caveats
                 * (no guard digits, characteristic overflow clamps
                 * rather than raising the real ERROR CONDITION). */
                if (ins->operand_count != 2) { fail(state, "SADD/SSUB: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = (ins->opcode == OP_SADD)
                    ? halmat_scalar_add(rv_to_scalar(&a), rv_to_scalar(&b))
                    : halmat_scalar_sub(rv_to_scalar(&a), rv_to_scalar(&b));
                break;

            case OP_SSPR:
                if (ins->operand_count != 2) { fail(state, "SSPR: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_multiply(rv_to_scalar(&a), rv_to_scalar(&b));
                break;

            case OP_SSDV: {
                if (ins->operand_count != 2) { fail(state, "SSDV: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                halmat_scalar_t quotient;
                if (!halmat_scalar_divide(rv_to_scalar(&a), rv_to_scalar(&b), &quotient)) {
                    fail(state, "division by zero (floating point divide exception)");
                    break;
                }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = quotient;
                break;
            }

            case OP_SPEX:
            case OP_SIEX: {
                /* SPEX (positive-literal exponent, class-5/SPEX.md) and
                 * SIEX (any-sign integer exponent, class-5/SIEX.md): both
                 * inline repeated multiplication on the base; SIEX
                 * additionally takes the reciprocal for a negative
                 * exponent (1/base^|n|) since HAL/S has no separate
                 * negative-exponent opcode. */
                if (ins->operand_count != 2) { fail(state, "SPEX/SIEX: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                halmat_scalar_t base = rv_to_scalar(&a);
                int32_t exponent = rv_to_integer(&b);
                bool dbl = base.double_precision;
                if (ins->opcode == OP_SPEX && exponent < 0) {
                    fail(state, "SPEX: negative exponent (expected a positive literal)");
                    break;
                }
                halmat_scalar_t result = halmat_scalar_from_integer(1, dbl);
                uint32_t magnitude = (exponent < 0) ? (uint32_t)(-(int64_t)exponent) : (uint32_t)exponent;
                for (uint32_t i = 0; i < magnitude; i++) result = halmat_scalar_multiply(result, base);
                if (exponent < 0) {
                    halmat_scalar_t reciprocal;
                    if (!halmat_scalar_divide(halmat_scalar_from_integer(1, dbl), result, &reciprocal)) {
                        fail(state, "SIEX: division by zero (0 raised to a negative exponent)");
                        break;
                    }
                    result = reciprocal;
                }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = result;
                break;
            }

            case OP_SEXP: {
                /* Scalar-exponent-by-scalar (class-5/SEXP.md), the fully
                 * general case (e.g. fractional exponents). No documented
                 * hex-float power algorithm exists in the extracted
                 * AP-101S material (unlike SADD/SSPR/SSDV's primary-
                 * sourced characteristic/fraction algorithms) -- goes
                 * through double via pow(), a documented precision
                 * compromise for this one opcode rather than the genuine
                 * hex-float arithmetic used everywhere else in this
                 * interpreter. */
                if (ins->operand_count != 2) { fail(state, "SEXP: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                halmat_scalar_t base = rv_to_scalar(&a);
                double result = pow(halmat_scalar_to_double(base), halmat_scalar_to_double(rv_to_scalar(&b)));
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_from_double(result, base.double_precision);
                break;
            }

            case OP_SNEG:
                if (ins->operand_count != 1) { fail(state, "SNEG: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_negate(rv_to_scalar(&a));
                break;

            case OP_ITOS:
                /* Integer->scalar, per class-5/ITOS.md's USA00309 Sec.
                 * 8.2 rule 9. The rule's "double-precision intermediate,
                 * narrowed afterward if needed" framing describes the
                 * conversion *algorithm* (exact for any INTEGER value
                 * either way -- INTEGER's full range fits losslessly in
                 * a single-precision 6-hex-digit fraction too, since
                 * HAL/S INTEGER is at most 32 bits ~ 8 hex digits...
                 * actually not always lossless at single precision, but
                 * empirically ITOS's own HALMAT-level result is single
                 * -- see below), not the static HALMAT-level type ITOS
                 * itself produces: cross-checked against the reference
                 * yaHALMAT emulator on `S2 = I1 + S1;` (S1/S2 single-
                 * precision SCALAR), which prints single-precision
                 * (7 fractional digits), not double -- ITOS carries no
                 * precision tag of its own in the compiled HALMAT (no
                 * operand/TAG distinguishes it), so single is the only
                 * representation consistent with that observation. */
                if (ins->operand_count != 1) { fail(state, "ITOS: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_from_integer(rv_to_integer(&a), false);
                break;

            case OP_STOS:
                /* Scalar precision scale (class-5/STOS.md), triggered by
                 * the explicit exp$(@SINGLE)/exp$(@DOUBLE) qualifier
                 * (not plain assignment, which widens/narrows via the
                 * object code directly with no HALMAT-level opcode of
                 * its own). One operand (source SCALAR SYT); the
                 * instruction's own TAG carries the target precision --
                 * confirmed 2=DOUBLE_FLAG, 1=SINGLE_FLAG. */
                if (ins->operand_count != 1) { fail(state, "STOS: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = scale_precision(rv_to_scalar(&a), ins->tag == 2);
                break;

            case OP_STOI:
                /* Scalar->integer, per class-6/STOI.md's USA00309 Sec.
                 * 8.2 rule 10: rounds to nearest, ties away from zero
                 * (halmat_scalar_to_integer's documented behavior,
                 * value.h -- confirmed against the reference emulator,
                 * NOT truncation) -- the real out-of-range ERROR
                 * CONDITION isn't implemented, no fixture exercises it
                 * (same documented gap as halmat_scalar_to_integer
                 * itself). */
                if (ins->operand_count != 1) { fail(state, "STOI: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = rv_to_integer(&a);
                break;

            case OP_IASN:
            case OP_SASN:
                /* Resolve the source, then coerce it to the kind the
                 * opcode's own class asserts (IASN=INTEGER, SASN=SCALAR)
                 * *before* write_destination() sees it. This matters
                 * because a LIT-qualified source carries no INTEGER-vs-
                 * SCALAR distinction of its own (litfile numeric entries
                 * always resolve as RV_SCALAR -- see resolve_operand),
                 * so on a destination's *first* write (still
                 * SYT_TYPE_UNKNOWN) write_destination's type inference
                 * needs the opcode's own class as the ground truth, not
                 * the source operand's generic resolved kind. This still
                 * lets write_destination correctly write an
                 * IASN-sourced INTEGER value into an already-SCALAR
                 * destination (e.g. out_array's ARR=I into a SCALAR
                 * array element) via its own coercion -- only the
                 * *kind tag* changes here, not any value. */
                if (ins->operand_count != 2) { fail(state, "IASN/SASN: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->opcode == OP_IASN) {
                    int32_t iv = rv_to_integer(&a);
                    a.kind = RV_INTEGER;
                    a.integer = iv;
                } else {
                    halmat_scalar_t sv = rv_to_scalar(&a);
                    a.kind = RV_SCALAR;
                    a.scalar = sv;
                }
                if (!write_destination(state, &ins->operands[1], &a)) break;
                break;

            case OP_BASN:
                /* Bit-string assign, source-first/receiver-second like
                 * the rest of the xASN family (class-1/BASN.md). */
                if (ins->operand_count != 2) { fail(state, "BASN: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BASN: source is not BIT"); break; }
                if (!write_destination(state, &ins->operands[1], &a)) break;
                break;

            case OP_BCAT:
                /* Bit-string catenate (class-1/BCAT.md): B1 || B2, B1
                 * occupying the more-significant bits. Neither operand
                 * carries its own width (confirmed empirically: both are
                 * plain SYT references, tag1=0) -- the declared BIT(n)
                 * width is the only source of truth for how far to shift
                 * B1 left, so this requires a symtab (state->symtab) and
                 * both operands to be QUAL_SYT; any other shape fails
                 * loudly rather than guessing a width. */
                if (ins->operand_count != 2) { fail(state, "BCAT: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_SYT || ins->operands[1].qual != QUAL_SYT) {
                    fail(state, "BCAT: only plain SYT operands are implemented (need declared BIT width)");
                    break;
                }
                if (!state->symtab) { fail(state, "BCAT: needs a symbol table (auto-discovered COMMON*.out) for declared BIT widths"); break; }
                {
                    const halmat_symtab_entry_t *sym2 = halmat_symtab_find_by_index(state->symtab, ins->operands[1].data);
                    if (!sym2 || sym2->bit_width <= 0) { fail(state, "BCAT: second operand's declared BIT width is unknown"); break; }
                    if (!resolve_operand(state, &ins->operands[0], &a)) break;
                    if (!resolve_operand(state, &ins->operands[1], &b)) break;
                    if (a.kind != RV_BITS || b.kind != RV_BITS) { fail(state, "BCAT: both operands must be BIT"); break; }
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    uint32_t mask2 = (sym2->bit_width >= 32) ? 0xFFFFFFFFu : ((1u << sym2->bit_width) - 1u);
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_bits = true;
                    state->vac[ins->index].bits = (a.bits << sym2->bit_width) | (b.bits & mask2);
                }
                break;

            case OP_BAND:
            case OP_BOR:
                /* class-1/BAND.md/BOR.md: full 32-bit pattern AND/OR, no
                 * declared-width masking (unconfirmed truncation rule,
                 * see state.h). */
                if (ins->operand_count != 2) { fail(state, "BAND/BOR: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (a.kind != RV_BITS || b.kind != RV_BITS) { fail(state, "BAND/BOR: both operands must be BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = (ins->opcode == OP_BAND) ? (a.bits & b.bits) : (a.bits | b.bits);
                break;

            case OP_BNOT:
                if (ins->operand_count != 1) { fail(state, "BNOT: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BNOT: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = ~a.bits;
                break;

            case OP_ITOB:
                /* Integer->bit, class-1/ITOB.md: raw bit pattern of the
                 * integer value (inline shift/store per real object code
                 * -- here just a reinterpretation of the same 32 bits). */
                if (ins->operand_count != 1) { fail(state, "ITOB: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = (uint32_t)rv_to_integer(&a);
                break;

            case OP_BTOI:
                if (ins->operand_count != 1) { fail(state, "BTOI: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BTOI: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = (int32_t)a.bits;
                break;

            case OP_BTOS:
                /* Bit->scalar, class-5/BTOS.md: the raw bit pattern
                 * reinterpreted as an unsigned integer value (matching
                 * the reference emulator's own `(double)a.v.bits` -- no
                 * primary-source operand format exists to check this
                 * against independently, but it's the only reading
                 * consistent with BTOI's parallel "raw pattern as
                 * integer" conversion). */
                if (ins->operand_count != 1) { fail(state, "BTOS: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BTOS: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_from_double((double)a.bits, false);
                break;

            case OP_ITOI:
                /* Integer precision scale, class-6/ITOI.md -- this
                 * interpreter's INTEGER has no single/double precision
                 * distinction to scale between (int32_t only), so this
                 * is a plain passthrough. */
                if (ins->operand_count != 1) { fail(state, "ITOI: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = rv_to_integer(&a);
                break;

            case OP_BTOC: {
                /* Bit->character, class-2/BTOC.md. No confirmed output
                 * format (BIT has no declared-width tracking here to
                 * inform how many digits to show either way -- see
                 * state.h) -- matches the reference emulator's own
                 * plain "%u" decimal-of-the-raw-pattern convention. */
                if (ins->operand_count != 1) { fail(state, "BTOC: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BTOC: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                char buf[16];
                snprintf(buf, sizeof(buf), "%u", a.bits);
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_string = true;
                state->vac[ins->index].string = dup_string(buf);
                break;
            }

            case OP_CTOB:
                /* Character->bit, class-1/CTOB.md. No reference
                 * implementation exists to cross-check (falls to
                 * yaHALMAT's own "unknown popcode" default there) --
                 * implemented as the natural inverse of BTOC's decimal-
                 * of-raw-pattern convention above. */
                if (ins->operand_count != 1) { fail(state, "CTOB: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_STRING) { fail(state, "CTOB: operand is not CHARACTER"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = (uint32_t)strtoul(a.string, NULL, 10);
                break;

            case OP_STOB:
                /* Scalar->bit, class-1/STOB.md. No reference
                 * implementation exists to cross-check -- implemented as
                 * BTOS's inverse: round to the nearest integer (STOI's
                 * rule, halmat_scalar_to_integer) then reinterpret as an
                 * unsigned bit pattern. */
                if (ins->operand_count != 1) { fail(state, "STOB: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = (uint32_t)rv_to_integer(&a);
                break;

            case OP_BTOB:
                /* Bit->bit self-conversion (length adjustment), class-1/
                 * BTOB.md -- confirmed to compile to a plain register
                 * load/store with no runtime call, i.e. a pure
                 * passthrough at the value level (this interpreter has
                 * no declared-width tracking to actually adjust, see
                 * state.h). */
                if (ins->operand_count != 1) { fail(state, "BTOB: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BTOB: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                state->vac[ins->index].bits = a.bits;
                break;

            case OP_BTOQ:
            case OP_CTOQ:
            case OP_STOQ:
            case OP_ITOQ:
                /* SUBBIT pseudo-conversion (class-1/ITOQ.md's shared
                 * XBTOQ family): TAG=0 is reference context (read the
                 * argument's raw representation as a bit pattern --
                 * identical in effect to BTOB/CTOB/STOB/ITOB's own
                 * conversions, per ITOQ.md's confirmed "I1's raw bit
                 * pattern copied directly into B1" trace); TAG=1 is
                 * assignment context (`SUBBIT(x) = ...;`, where this
                 * opcode's result instead supplies a *destination* for
                 * the following assign) -- not implemented, no fixture
                 * needs it, fails loudly rather than silently dropping
                 * the write-through. */
                if (ins->tag != 0) {
                    fail(state, "SUBBIT assignment context (TAG=%u) is not yet implemented", ins->tag);
                    break;
                }
                if (ins->operand_count != 1) { fail(state, "BTOQ/CTOQ/STOQ/ITOQ: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_bits = true;
                switch (a.kind) {
                    case RV_BITS: state->vac[ins->index].bits = a.bits; break;
                    case RV_INTEGER: state->vac[ins->index].bits = (uint32_t)a.integer; break;
                    case RV_SCALAR: state->vac[ins->index].bits = (uint32_t)rv_to_integer(&a); break;
                    case RV_STRING: state->vac[ins->index].bits = (uint32_t)strtoul(a.string, NULL, 10); break;
                }
                break;

            case OP_BTRU:
                /* Bit-is-true test, class-7/BTRU.md: the generic "make
                 * this bit value branch-testable" operator FBRA consumes
                 * -- nonzero is true, matching BEQU/BNEQ/every other
                 * comparison's VAC-carried 0/1 convention. */
                if (ins->operand_count != 1) { fail(state, "BTRU: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_BITS) { fail(state, "BTRU: operand is not BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].integer = (a.bits != 0) ? 1 : 0;
                break;

            case OP_BEQU:
            case OP_BNEQ:
                if (ins->operand_count != 2) { fail(state, "BEQU/BNEQ: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (a.kind != RV_BITS || b.kind != RV_BITS) { fail(state, "BEQU/BNEQ: both operands must be BIT"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                {
                    bool equal = (a.bits == b.bits);
                    bool result = (ins->opcode == OP_BEQU) ? equal : !equal;
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].integer = result ? 1 : 0;
                }
                break;

            case OP_CASN:
                /* Character assign, source-first/receiver-second like the
                 * rest of the xASN family (class-2/CASN.md). Unlike IASN/
                 * SASN, no kind coercion is needed: a CHARACTER source
                 * (SYT or LIT) already resolves as RV_STRING. */
                if (ins->operand_count != 2) { fail(state, "CASN: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_STRING) { fail(state, "CASN: source is not CHARACTER"); break; }
                if (!write_destination(state, &ins->operands[1], &a)) break;
                break;

            case OP_CCAT: {
                if (ins->operand_count != 2) { fail(state, "CCAT: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (a.kind != RV_STRING || b.kind != RV_STRING) { fail(state, "CCAT: both operands must be CHARACTER"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                size_t len_a = strlen(a.string), len_b = strlen(b.string);
                char *result = malloc(len_a + len_b + 1);
                if (!result) { fail(state, "CCAT: out of memory"); break; }
                memcpy(result, a.string, len_a);
                memcpy(result + len_a, b.string, len_b + 1);
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_string = true;
                state->vac[ins->index].string = result;
                break;
            }

            case OP_CTOC:
                /* Character-to-character (length-adjustment) self-
                 * conversion, class-2/CTOC.md. This interpreter's
                 * CHARACTER storage has no fixed-length/VARYING
                 * distinction (state.h), so there's nothing to truncate
                 * or pad -- a straight passthrough copy. */
                if (ins->operand_count != 1) { fail(state, "CTOC: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_STRING) { fail(state, "CTOC: operand is not CHARACTER"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_string = true;
                state->vac[ins->index].string = dup_string(a.string);
                break;

            case OP_STOC: {
                /* Scalar->character, class-2/STOC.md: same fixed-width
                 * scientific-notation field as WRITE's own SCALAR
                 * formatting (halmat_scalar_format) -- STOC.md's format
                 * rules explicitly cite the same USA00309 Sec. 6.1.3
                 * source WRITE uses. */
                if (ins->operand_count != 1) { fail(state, "STOC: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                char buf[32];
                halmat_scalar_format(rv_to_scalar(&a), buf, sizeof(buf));
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_string = true;
                state->vac[ins->index].string = dup_string(buf);
                break;
            }

            case OP_ITOC: {
                /* Integer->character, class-2/ITOC.md: variable-length
                 * (up to 11 chars), right-justified with leading zeros
                 * suppressed, no sign character for non-negative values
                 * -- i.e. just "%d", not WRITE's fixed-width "%11d". */
                if (ins->operand_count != 1) { fail(state, "ITOC: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                char buf[16];
                snprintf(buf, sizeof(buf), "%d", rv_to_integer(&a));
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_string = true;
                state->vac[ins->index].string = dup_string(buf);
                break;
            }

            case OP_CTOS:
                /* Character->scalar, class-5/CTOS.md: parses the
                 * standard input formats (USA00309 Sec. 6.1.2) --
                 * strtod() covers the decimal and "dddEddd" forms
                 * directly; the HAL/S-specific B(binary)/H(hex) exponent
                 * suffixes aren't implemented (no fixture uses them). No
                 * rounding step for SCALAR (unlike CTOI below). */
                if (ins->operand_count != 1) { fail(state, "CTOS: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_STRING) { fail(state, "CTOS: operand is not CHARACTER"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = halmat_scalar_from_double(strtod(a.string, NULL), false);
                break;

            case OP_CTOI:
                /* Character->integer, class-6/CTOI.md: same parse as
                 * CTOS, then rounds to nearest (per the doc's explicit
                 * "rounded to the nearest integral value" rule) rather
                 * than truncating. */
                if (ins->operand_count != 1) { fail(state, "CTOI: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (a.kind != RV_STRING) { fail(state, "CTOI: operand is not CHARACTER"); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = false;
                state->vac[ins->index].integer = (int32_t)lround(strtod(a.string, NULL));
                break;

            case OP_SFST:
                /* Shaping-function argument-list start (class-0/SFST.md);
                 * its own operand (nesting level/flow number) isn't
                 * needed for evaluation, only by the compiler itself. */
                state->shape_pending.active = true;
                state->shape_pending.item_count = 0;
                break;

            case OP_SFAR:
                /* One per shaping-function argument (class-0/SFAR.md).
                 * Stored raw -- see state.h's shape_pending comment for
                 * why resolution is deferred to the shaping-result
                 * opcode (VSHP/MSHP/etc) rather than done here. */
                if (!state->shape_pending.active) { fail(state, "SFAR outside of an SFST...SFND block"); break; }
                if (ins->operand_count != 1) { fail(state, "SFAR: expected 1 operand"); break; }
                if (state->shape_pending.item_count >= HALMAT_MAX_OPERANDS) {
                    fail(state, "shaping-function argument list too long");
                    break;
                }
                state->shape_pending.items[state->shape_pending.item_count++] = ins->operands[0];
                break;

            case OP_SFND:
                state->shape_pending.active = false;
                break;

            case OP_VSHP: {
                /* List-form VECTOR(...) construction (class-0/VSHP.md):
                 * own operand is the resulting length (IMD literal);
                 * each pending SFAR argument resolves as a plain SCALAR
                 * (unlike MSHP, whose arguments are themselves VECTORs
                 * -- not implemented, see state.h). */
                if (ins->operand_count != 1) { fail(state, "VSHP: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                size_t length = (size_t)rv_to_integer(&a);
                if (length != state->shape_pending.item_count) {
                    fail(state, "VSHP: declared length %zu doesn't match %u arguments", length, state->shape_pending.item_count);
                    break;
                }
                if (length > HALMAT_CONTAINER_CAPACITY) { fail(state, "VSHP: result too large"); break; }
                halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                bool ok = true;
                for (size_t i = 0; ok && i < length; i++) {
                    resolved_value_t item;
                    if (!resolve_operand(state, &state->shape_pending.items[i], &item)) { ok = false; break; }
                    result[i] = rv_to_scalar(&item);
                }
                if (!ok) break;
                if (!store_container_result(state, ins->index, result, length, 0, (int)length)) break;
                break;
            }

            case OP_MSHP:
            case OP_SSHP:
            case OP_ISHP:
                fail(state, "list-form MATRIX(...)/SCALAR(...)/INTEGER(...) shaping functions are not yet implemented");
                break;

            case OP_LFNC: {
                /* MAX(array)/MIN(array), class-0/LFNC.md: selector 7=MAX,
                 * 8=MIN, QUAL=IMD on LFNC's own operand. The array
                 * argument itself was captured raw by SFAR (inside an
                 * ADLP/DLPE bracket this interpreter treats as a no-op --
                 * see interp_step's arrayed-paragraph replay comment;
                 * SFAR's own operand capture doesn't call resolve_operand
                 * so it's unaffected by the arrayed-whole-array guard
                 * either way), so it's read here via resolve_container. */
                if (ins->operand_count != 1 || ins->operands[0].qual != QUAL_IMD) {
                    fail(state, "LFNC: expected 1 IMD operand");
                    break;
                }
                if (!state->shape_pending.active || state->shape_pending.item_count != 1) {
                    fail(state, "LFNC: expected exactly one SFAR-captured array argument");
                    break;
                }
                halmat_scalar_t *ca; size_t count; int rows, cols;
                if (!resolve_container(state, &state->shape_pending.items[0], &ca, &count, &rows, &cols)) break;
                if (count == 0) { fail(state, "LFNC: empty array argument"); break; }
                bool want_max = (ins->operands[0].data == 7);
                if (!want_max && ins->operands[0].data != 8) {
                    fail(state, "LFNC: unknown selector %u (expected 7=MAX or 8=MIN)", ins->operands[0].data);
                    break;
                }
                halmat_scalar_t best = ca[0];
                for (size_t i = 1; i < count; i++) {
                    halmat_scalar_t diff = halmat_scalar_sub(ca[i], best); /* ca[i] - best */
                    bool is_zero = (diff.msw == 0 && diff.lsw == 0);
                    bool is_negative = ((diff.msw >> 31) & 1) != 0;
                    bool i_is_greater = !is_zero && !is_negative;
                    bool i_is_less = !is_zero && is_negative;
                    if ((want_max && i_is_greater) || (!want_max && i_is_less)) {
                        best = ca[i];
                    }
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = false;
                state->vac[ins->index].is_scalar = true;
                state->vac[ins->index].scalar = best;
                break;
            }

            case OP_BFNC: {
                /* Built-in function call, class-0/BFNC.md's confirmed
                 * selector table (the instruction's own TAG field). Only
                 * the plain-SCALAR-argument arithmetic functions plus
                 * PRIO (no argument) and the VECTOR/CHARACTER functions
                 * ABVAL/UNIT/LENGTH/TRIM are implemented; INVERSE (matrix
                 * inverse) fails loudly -- same deferred numerical
                 * algorithm as MINV (class-3/MINV.md). SIGN's documented
                 * return type is unconfirmed; implemented returning
                 * SCALAR like its arithmetic-function siblings in the
                 * same table, not INTEGER. */
                if (ins->tag == 19) { /* PRIO: no argument, current task's priority */
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    state->vac[ins->index].is_ref = false;
                    state->vac[ins->index].is_scalar = false;
                    state->vac[ins->index].integer = state->tasks[state->current_task].priority;
                    break;
                }
                if (ins->operand_count != 1) { fail(state, "BFNC: expected 1 operand (selector %u)", ins->tag); break; }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                /* ABVAL(28)/UNIT(27)/INVERSE(49) take a whole VECTOR/
                 * MATRIX argument and resolve it via resolve_container
                 * themselves below -- resolve_operand would (correctly,
                 * per the new arrayed-paragraph-replay guard) reject a
                 * bare whole-array SYT reference outside a replay
                 * context, so it's only called for the plain-scalar-
                 * argument selectors that actually need `a`. */
                if (ins->tag != 27 && ins->tag != 28 && ins->tag != 49) {
                    if (!resolve_operand(state, &ins->operands[0], &a)) break;
                }

                switch (ins->tag) {
                    case 1: case 2: case 5: case 6: case 13: case 15: case 21: case 24: case 33: {
                        /* ABS/COS/EXP/LOG/SIN/TAN/SIGN/SQRT/ROUND: through
                         * double via libm, same documented precision
                         * compromise as SEXP (no hex-float algorithm for
                         * these in the extracted AP-101S material). */
                        double x = halmat_scalar_to_double(rv_to_scalar(&a));
                        double r;
                        switch (ins->tag) {
                            case 1: r = fabs(x); break;
                            case 2: r = cos(x); break;
                            case 5: r = exp(x); break;
                            case 6: r = log(x); break;
                            case 13: r = sin(x); break;
                            case 15: r = tan(x); break;
                            case 21: r = (x > 0.0) ? 1.0 : (x < 0.0) ? -1.0 : 0.0; break;
                            case 24: r = sqrt(x); break;
                            case 33: default: r = round(x); break;
                        }
                        bool dbl = rv_to_scalar(&a).double_precision;
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = true;
                        state->vac[ins->index].scalar = halmat_scalar_from_double(r, dbl);
                        break;
                    }
                    case 28: { /* ABVAL: vector magnitude -> SCALAR */
                        halmat_scalar_t *ca; size_t count; int rows, cols;
                        if (!resolve_container(state, &ins->operands[0], &ca, &count, &rows, &cols)) break;
                        halmat_scalar_t sum = halmat_scalar_zero(false);
                        for (size_t i = 0; i < count; i++) sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[i], ca[i]));
                        double mag = sqrt(halmat_scalar_to_double(sum));
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = true;
                        state->vac[ins->index].scalar = halmat_scalar_from_double(mag, false);
                        break;
                    }
                    case 27: { /* UNIT: normalize -> VECTOR */
                        halmat_scalar_t *ca; size_t count; int rows, cols;
                        if (!resolve_container(state, &ins->operands[0], &ca, &count, &rows, &cols)) break;
                        if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "UNIT: container too large"); break; }
                        halmat_scalar_t sum = halmat_scalar_zero(false);
                        for (size_t i = 0; i < count; i++) sum = halmat_scalar_add(sum, halmat_scalar_multiply(ca[i], ca[i]));
                        double mag = sqrt(halmat_scalar_to_double(sum));
                        if (mag == 0.0) { fail(state, "UNIT: zero-magnitude vector"); break; }
                        halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                        for (size_t i = 0; i < count; i++) {
                            result[i] = halmat_scalar_from_double(halmat_scalar_to_double(ca[i]) / mag, false);
                        }
                        if (!store_container_result(state, ins->index, result, count, rows, cols)) break;
                        break;
                    }
                    case 40: /* LENGTH: CHARACTER length -> INTEGER */
                        if (a.kind != RV_STRING) { fail(state, "LENGTH: operand is not CHARACTER"); break; }
                        state->vac[ins->index].is_ref = false;
                        state->vac[ins->index].is_scalar = false;
                        state->vac[ins->index].integer = (int32_t)strlen(a.string);
                        break;
                    case 26: /* TRIM: strip trailing blanks -> CHARACTER */
                        if (a.kind != RV_STRING) { fail(state, "TRIM: operand is not CHARACTER"); break; }
                        {
                            size_t len = strlen(a.string);
                            while (len > 0 && a.string[len - 1] == ' ') len--;
                            char *trimmed = malloc(len + 1);
                            memcpy(trimmed, a.string, len);
                            trimmed[len] = '\0';
                            state->vac[ins->index].is_ref = false;
                            state->vac[ins->index].is_string = true;
                            state->vac[ins->index].string = trimmed;
                        }
                        break;
                    case 49: { /* INVERSE: matrix inverse, same algorithm as MINV */
                        halmat_scalar_t *ca; size_t count; int rows, cols;
                        if (!resolve_container(state, &ins->operands[0], &ca, &count, &rows, &cols)) break;
                        if (rows <= 0 || cols <= 0 || rows != cols) { fail(state, "INVERSE: operand is not a square MATRIX"); break; }
                        if (count > HALMAT_CONTAINER_CAPACITY) { fail(state, "INVERSE: container too large"); break; }
                        halmat_scalar_t result[HALMAT_CONTAINER_CAPACITY];
                        if (!matrix_invert(ca, rows, result)) {
                            fail(state, "INVERSE: singular matrix (floating point error condition)");
                            break;
                        }
                        if (!store_container_result(state, ins->index, result, count, rows, cols)) break;
                        break;
                    }
                    default:
                        fail(state, "BFNC: unknown/unimplemented built-in function selector %u", ins->tag);
                        break;
                }
                break;
            }

            case OP_XXST: {
                /* General bracketed-argument-list start: I/O (IMD kind
                 * code) or a function/procedure call (SYT callee) --
                 * see class-0/XXST.md. Two reasons io_pending can already
                 * be active here: (1) this exact XXST instruction is
                 * being re-entered mid-ADLP/DLPE-driven replay (a whole-
                 * array/structure-field WRITE argument, e.g.
                 * `WRITE(6) ZQ3.QI;` on a multi-copy structure, compiles
                 * with XXST itself inside the replayed paragraph) --
                 * state->pc == io_pending.start_pc identifies this case,
                 * and it must keep accumulating into the same item list
                 * rather than wiping it; or (2) this is a genuinely
                 * different, nested XXST (e.g. `WRITE(6) I, SQUARE(I);`,
                 * where SQUARE(I)'s own call brackets sit inside WRITE's
                 * argument list -- source-documentation/Multiple-file-
                 * problem.md's reproduction case), which must push the
                 * enclosing frame onto io_pending_stack and start a fresh
                 * one, so the nested call's own XXAR/FCAL/XXND see their
                 * own frame instead of corrupting the outer one. */
                if (ins->operand_count != 1) { fail(state, "XXST: expected 1 operand"); break; }
                bool replay = state->io_pending.active && state->io_pending.start_pc == state->pc;
                if (!replay) {
                    if (state->io_pending.active) {
                        if (state->io_pending_sp >= 8) { fail(state, "XXST nesting too deep"); break; }
                        state->io_pending_stack[state->io_pending_sp++] = state->io_pending;
                    }
                    state->io_pending.active = true;
                    state->io_pending.item_count = 0;
                    state->io_pending.start_pc = state->pc;
                    if (ins->operands[0].qual == QUAL_SYT) {
                        state->io_pending.is_call = true;
                        state->io_pending.call_target = ins->operands[0].data;
                    } else {
                        if (!resolve_operand(state, &ins->operands[0], &a)) break;
                        state->io_pending.is_call = false;
                        state->io_pending.kind = rv_to_integer(&a);
                    }
                }
                break;
            }

            case OP_XXAR:
                if (!state->io_pending.active) { fail(state, "XXAR outside of an XXST...XXND block"); break; }
                if (ins->operand_count != 1) { fail(state, "XXAR: expected 1 operand"); break; }
                if (state->io_pending.item_count >= HALMAT_MAX_OPERANDS) {
                    fail(state, "I/O statement has too many items");
                    break;
                }
                if (!state->io_pending.is_call && state->io_pending.kind != 2) {
                    /* READ/READALL: the argument is a destination, not a
                     * value -- capture the raw operand for OP_READ to
                     * write through later, per class-0/XXAR.md. TAG2 != 0
                     * means an I/O control specifier (TAB/COLUMN/SKIP/
                     * LINE/PAGE); TAG1 outside {2=CHARACTER,5=SCALAR,
                     * 6=INTEGER} means a type this interpreter doesn't
                     * store yet (BIT/MATRIX/VECTOR/structure) -- both
                     * fail loudly rather than misbehave, no fixture needs
                     * them yet. (CHARACTER matters in practice: real
                     * HAL/S's READALL requires CHARACTER-typed targets --
                     * confirmed via a real HALSFC compile rejecting an
                     * INTEGER/SCALAR READALL with "VARIABLE IN READALL IS
                     * NOT OF CHARACTER TYPE".) */
                    if (ins->operands[0].tag2 != 0) {
                        fail(state, "READ: I/O control specifiers (TAB/COLUMN/SKIP/LINE/PAGE) not yet implemented");
                        break;
                    }
                    uint8_t cls = ins->operands[0].tag1;
                    if (cls != 2 && cls != 5 && cls != 6) {
                        fail(state, "READ: only CHARACTER/SCALAR/INTEGER arguments are implemented (got HALMAT class %u)", cls);
                        break;
                    }
                    state->io_pending.items[state->io_pending.item_count].dest_operand = ins->operands[0];
                    state->io_pending.items[state->io_pending.item_count].dest_class = cls;
                    state->io_pending.item_count++;
                    break;
                }
                if (state->io_pending.is_call && ins->operands[0].tag2 != 0) {
                    /* ASSIGN-form CALL argument (class-0/XXST.md's `CALL
                     * TWO(I1) ASSIGN(I1);` trace): the callee's parameter
                     * value must be written back into the caller's
                     * variable after the procedure returns. Not
                     * implemented -- fail loudly rather than silently
                     * dropping the write-back; no fixture needs it yet. */
                    fail(state, "PCAL: ASSIGN-form arguments are not yet implemented");
                    break;
                }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                /* A bare numeric literal (QUAL_LIT) always resolves as
                 * RV_SCALAR (see resolve_operand's QUAL_LIT case -- the
                 * litfile itself carries no INTEGER-vs-SCALAR distinction
                 * for LIT_FIXED/LIT_DOUBLE entries), even when the
                 * literal is actually being used in an INTEGER context
                 * (e.g. `CALL P(5);` with P's parameter declared
                 * INTEGER, or `WRITE(6) 5;`). This operand's own tag1 --
                 * the HALMAT class the compiler recorded for it, already
                 * used the same way just above for READ/READALL's
                 * dest_class -- is the actual source of truth for a
                 * literal's intended class, so use it to reclassify a
                 * QUAL_LIT/RV_SCALAR resolution as INTEGER when tag1
                 * says so. Not needed for non-literal operands (SYT reads
                 * already carry the correct kind via the SYT entry's own
                 * stored type, independent of tag1). */
                bool literal_is_integer = (a.kind == RV_SCALAR) &&
                    ins->operands[0].qual == QUAL_LIT && ins->operands[0].tag1 == 6;
                if (literal_is_integer) {
                    a.integer = halmat_scalar_to_integer(a.scalar);
                    a.kind = RV_INTEGER;
                }
                state->io_pending.items[state->io_pending.item_count].is_string = (a.kind == RV_STRING);
                state->io_pending.items[state->io_pending.item_count].is_scalar = (a.kind == RV_SCALAR);
                state->io_pending.items[state->io_pending.item_count].string = a.string;
                if (a.kind == RV_SCALAR) {
                    state->io_pending.items[state->io_pending.item_count].scalar = a.scalar;
                } else if (a.kind != RV_STRING) {
                    state->io_pending.items[state->io_pending.item_count].integer = rv_to_integer(&a);
                }
                state->io_pending.item_count++;
                break;

            case OP_WRIT: {
                if (!state->io_pending.active) { fail(state, "WRIT outside of an XXST...XXND block"); break; }
                if (ins->operand_count != 1) { fail(state, "WRIT: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                int device = rv_to_integer(&a);
                if (device < 0 || device >= HALMAT_DEVICE_MAX || !state->devices[device]) {
                    fail(state, "WRITE(%d): device not mapped (use --ddo)", device);
                    break;
                }
                flush_write(state, state->devices[device]);
                break;
            }

            case OP_FILE: {
                /* Random-access file I/O (class-0/FILE.md): FILE(n,addr)=exp
                 * (write) or var=FILE(n,addr) (read). Two operands: LIT
                 * (the record address/number -- confirmed to be the address
                 * itself, not a format descriptor) and SYT (the transferred
                 * variable) -- only a plain unsubscripted SYT is confirmed/
                 * implemented. The channel is the operator word's own TAG
                 * (confirmed via two independent real compiles this
                 * session: FILE(1,...) both times shows tag=0x01). Write
                 * vs read is disambiguated by the SYT operand's own TAG2
                 * (confirmed empirically this session, not previously
                 * documented: 1=write/source, 0=read/destination).
                 *
                 * Channel/record-size mapping comes from --raf (main.c),
                 * modeled directly on the historical HAL/S-FC runtime's
                 * own option of the same name and shape (a *separate*
                 * device-number namespace from READ/WRITE's --ddi/--ddo,
                 * per that option's own documentation) -- see
                 * interp_set_raf_device. Record layout: INTEGER as a
                 * 4-byte big-endian value; SCALAR as its existing
                 * msw/lsw wire format (4 bytes single, 8 bytes double,
                 * matching this project's already-established bit-exact
                 * representation elsewhere, e.g. literal.c). No
                 * real-toolchain cross-validation is possible (BFS
                 * object files use a different format from PFS, and the
                 * available lnk101 doesn't support BFS -- direct user
                 * confirmation), so this is validated by internal
                 * write-then-read round-trip correctness only, not
                 * byte-for-byte compatibility with any other tool. */
                if (ins->operand_count != 2) { fail(state, "FILE: expected 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_LIT) { fail(state, "FILE: expected a LIT address operand"); break; }
                if (ins->operands[1].qual != QUAL_SYT) { fail(state, "FILE: only a plain SYT transferred-variable operand is implemented"); break; }
                int channel = ins->tag;
                if (channel < 0 || channel >= HALMAT_DEVICE_MAX || !state->raf_devices[channel]) {
                    fail(state, "FILE(%d): channel not mapped (use --raf)", channel);
                    break;
                }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                int32_t record_num = rv_to_integer(&a);
                int record_size = state->raf_record_size[channel];
                FILE *fp = state->raf_devices[channel];
                long position = (long)record_size * (long)record_num;
                uint16_t var_syt = ins->operands[1].data;
                if (var_syt >= HALMAT_SYT_MAX) { fail(state, "FILE: SYT index out of range"); break; }
                bool is_write = (ins->operands[1].tag2 != 0);
                halmat_syt_entry_t *e = &state->syt[var_syt];
                if (fseek(fp, position, SEEK_SET) != 0) { fail(state, "FILE(%d): seek to record %d failed", channel, record_num); break; }
                if (is_write) {
                    uint8_t buf[8];
                    int nbytes;
                    if (e->type == SYT_TYPE_SCALAR) {
                        nbytes = e->scalar.double_precision ? 8 : 4;
                        buf[0] = (uint8_t)(e->scalar.msw >> 24); buf[1] = (uint8_t)(e->scalar.msw >> 16);
                        buf[2] = (uint8_t)(e->scalar.msw >> 8);  buf[3] = (uint8_t)e->scalar.msw;
                        if (e->scalar.double_precision) {
                            buf[4] = (uint8_t)(e->scalar.lsw >> 24); buf[5] = (uint8_t)(e->scalar.lsw >> 16);
                            buf[6] = (uint8_t)(e->scalar.lsw >> 8);  buf[7] = (uint8_t)e->scalar.lsw;
                        }
                    } else {
                        int32_t v = (e->type == SYT_TYPE_INTEGER) ? e->value : 0;
                        nbytes = 4;
                        buf[0] = (uint8_t)(v >> 24); buf[1] = (uint8_t)(v >> 16);
                        buf[2] = (uint8_t)(v >> 8);  buf[3] = (uint8_t)v;
                    }
                    if (nbytes > record_size) {
                        fail(state, "FILE(%d): value needs %d bytes, --raf record size is only %d", channel, nbytes, record_size);
                        break;
                    }
                    if (fwrite(buf, 1, (size_t)nbytes, fp) != (size_t)nbytes) {
                        fail(state, "FILE(%d): write to record %d failed", channel, record_num);
                        break;
                    }
                    fflush(fp);
                } else {
                    /* If the destination has never been written before
                     * (still SYT_TYPE_UNKNOWN), its format can't be
                     * inferred from itself -- consult the symbol table's
                     * declared type instead (same fallback TINT uses),
                     * since guessing INTEGER by default would silently
                     * misinterpret a SCALAR's hex-float bit pattern as a
                     * plain integer. */
                    bool as_scalar = (e->type == SYT_TYPE_SCALAR);
                    if (e->type == SYT_TYPE_UNKNOWN && state->symtab) {
                        const halmat_symtab_entry_t *vsym = halmat_symtab_find_by_index(state->symtab, var_syt);
                        if (vsym && vsym->hal_class == 5) as_scalar = true;
                    }
                    int nbytes = as_scalar ? (e->scalar.double_precision ? 8 : 4) : 4;
                    if (nbytes > record_size) {
                        fail(state, "FILE(%d): value needs %d bytes, --raf record size is only %d", channel, nbytes, record_size);
                        break;
                    }
                    uint8_t buf[8] = {0};
                    if (fread(buf, 1, (size_t)nbytes, fp) != (size_t)nbytes) {
                        fail(state, "FILE(%d): read from record %d failed (short or missing record)", channel, record_num);
                        break;
                    }
                    if (as_scalar) {
                        uint32_t msw = ((uint32_t)buf[0] << 24) | ((uint32_t)buf[1] << 16) | ((uint32_t)buf[2] << 8) | buf[3];
                        uint32_t lsw = e->scalar.double_precision
                            ? (((uint32_t)buf[4] << 24) | ((uint32_t)buf[5] << 16) | ((uint32_t)buf[6] << 8) | buf[7])
                            : 0;
                        e->type = SYT_TYPE_SCALAR;
                        e->scalar = halmat_scalar_from_ibm_words(msw, lsw, e->scalar.double_precision);
                    } else {
                        int32_t v = (int32_t)(((uint32_t)buf[0] << 24) | ((uint32_t)buf[1] << 16) | ((uint32_t)buf[2] << 8) | buf[3]);
                        e->type = SYT_TYPE_INTEGER;
                        e->value = v;
                    }
                }
                break;
            }

            case OP_READ:
            case OP_RDAL: {
                /* RDAL (READALL) is structurally identical to READ for
                 * the plain scalar/integer-list case (class-0/RDAL.md) --
                 * shares this handler. READALL's real-HAL/S array/until-
                 * EOF looping behavior isn't modeled (reads exactly the
                 * listed items, same as READ); no fixture uses an
                 * arrayed READALL target yet. */
                if (!state->io_pending.active) { fail(state, "READ/READALL outside of an XXST...XXND block"); break; }
                if (ins->operand_count != 1) { fail(state, "READ/READALL: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                int device = rv_to_integer(&a);
                if (device < 0 || device >= HALMAT_DEVICE_MAX || !state->devices[device]) {
                    fail(state, "READ(%d): device not mapped (use --ddi)", device);
                    break;
                }
                FILE *in = state->devices[device];
                for (uint8_t i = 0; i < state->io_pending.item_count; i++) {
                    resolved_value_t rv;
                    if (state->io_pending.items[i].dest_class == 6) {
                        long v;
                        if (fscanf(in, "%ld", &v) != 1) {
                            fail(state, "READ(%d): end of input or malformed INTEGER", device);
                            break;
                        }
                        rv.kind = RV_INTEGER;
                        rv.integer = (int32_t)v;
                    } else if (state->io_pending.items[i].dest_class == 2) {
                        /* Whitespace-delimited token, same convention as
                         * the numeric cases -- HAL/S's real fixed-column
                         * card-image READ format isn't modeled (see
                         * state.h's CHARACTER-storage note), just enough
                         * for the common case of reading a plain word. */
                        char buf[1024];
                        if (fscanf(in, "%1023s", buf) != 1) {
                            fail(state, "READ(%d): end of input for CHARACTER", device);
                            break;
                        }
                        rv.kind = RV_STRING;
                        rv.string = buf;
                        if (!write_destination(state, &state->io_pending.items[i].dest_operand, &rv)) break;
                        continue;
                    } else {
                        double v;
                        if (fscanf(in, "%lf", &v) != 1) {
                            fail(state, "READ(%d): end of input or malformed SCALAR", device);
                            break;
                        }
                        rv.kind = RV_SCALAR;
                        rv.scalar = halmat_scalar_from_double(v, false);
                    }
                    if (!write_destination(state, &state->io_pending.items[i].dest_operand, &rv)) break;
                }
                state->io_pending.active = false;
                state->io_pending.item_count = 0;
                break;
            }

            case OP_XXND:
                /* Closes whichever bracket was most recently opened. If
                 * that bracket was nested inside an enclosing one (e.g. a
                 * function-call argument list nested inside a WRITE's own
                 * argument list -- see OP_XXST above), restore the
                 * enclosing frame so its own XXAR/WRIT/FCAL/PCAL/XXND see
                 * their own item list again instead of an empty one. */
                if (state->io_pending_sp > 0) {
                    state->io_pending = state->io_pending_stack[--state->io_pending_sp];
                } else {
                    state->io_pending.active = false;
                }
                break;

            case OP_FDEF:
            case OP_TDEF:
            case OP_PDEF: {
                /* Only ever reached by ordinary fall-through -- FCAL/PCAL/
                 * SCHD jump straight to def_pos+1, past this instruction
                 * (see precompute_subprograms). Skip the whole
                 * definition; it's entered only via an explicit
                 * call/schedule. */
                size_t target = state->def_clos_target[state->pc];
                if (target == NO_TARGET) { fail(state, "FDEF/TDEF/PDEF has no matching CLOS"); break; }
                state->pc = target;
                branched = true;
                break;
            }

            case OP_PCAL: {
                /* Procedure call header (class-0/PCAL.md): same
                 * bracketed-argument-list/positional-binding mechanism as
                 * FCAL, but no VAC return-value slot to fill -- the
                 * callee returns via RTRN's 0-operand (procedure) form. */
                if (!state->io_pending.active || !state->io_pending.is_call) {
                    fail(state, "PCAL outside of an XXST...XXND call block");
                    break;
                }
                if (ins->operand_count != 1) { fail(state, "PCAL: expected 1 operand"); break; }
                uint16_t proc = ins->operands[0].data;
                if (proc < HALMAT_SYT_MAX && state->symbol_def_pos[proc] == NO_TARGET &&
                    state->external_calls && state->external_calls[proc].target_state) {
                    /* Cross-unit call into a separately-compiled EXTERNAL
                     * PROCEDURE (source-documentation/Multiple-file-
                     * problem.md) -- see run_external_call(). No result
                     * to copy back (procedures don't return a value). */
                    run_external_call(state, state->external_calls[proc].target_state,
                                       state->external_calls[proc].target_entry_syt, out);
                    break;
                }
                if (proc >= HALMAT_SYT_MAX || state->symbol_def_pos[proc] == NO_TARGET) {
                    fail(state, "call to undefined procedure (symbol %u)", proc);
                    break;
                }
                for (uint8_t i = 0; i < state->io_pending.item_count; i++) {
                    uint16_t param_syt = proc + 1 + i;
                    if (param_syt >= HALMAT_SYT_MAX) { fail(state, "too many call arguments"); break; }
                    if (state->io_pending.items[i].is_scalar) {
                        state->syt[param_syt].type = SYT_TYPE_SCALAR;
                        state->syt[param_syt].scalar = state->io_pending.items[i].scalar;
                    } else {
                        state->syt[param_syt].type = SYT_TYPE_INTEGER;
                        state->syt[param_syt].value = state->io_pending.items[i].integer;
                    }
                }
                if (state->call_return_sp >= 64) { fail(state, "call nesting too deep"); break; }
                state->call_return_stack[state->call_return_sp++] = state->pc;
                state->pc = state->symbol_def_pos[proc] + 1;
                branched = true;
                break;
            }

            case OP_FCAL: {
                if (!state->io_pending.active || !state->io_pending.is_call) {
                    fail(state, "FCAL outside of an XXST...XXND call block");
                    break;
                }
                if (ins->operand_count != 1) { fail(state, "FCAL: expected 1 operand"); break; }
                uint16_t callee = ins->operands[0].data;
                if (callee < HALMAT_SYT_MAX && state->symbol_def_pos[callee] == NO_TARGET &&
                    state->external_calls && state->external_calls[callee].target_state) {
                    /* Cross-unit call into a separately-compiled EXTERNAL
                     * FUNCTION (source-documentation/Multiple-file-
                     * problem.md) -- see run_external_call(). Copy the
                     * callee's captured RTRN result into *this* call's
                     * own VAC slot, the same place a same-unit call's
                     * result would land. */
                    halmat_state_t *target = state->external_calls[callee].target_state;
                    uint16_t entry_syt = state->external_calls[callee].target_entry_syt;
                    if (!run_external_call(state, target, entry_syt, out)) break;
                    if (!target->external_call_has_result) {
                        fail(state, "external function returned no value");
                        break;
                    }
                    if (target->external_call_result.is_string || target->external_call_result.is_container) {
                        /* Both carry owned heap pointers -- copying the
                         * slot verbatim would alias ownership between
                         * this caller's own VAC array and the callee's,
                         * risking a double-free when both states are
                         * eventually cleaned up. Neither case is
                         * confirmed to even be legal for a FUNCTION
                         * return anyway, so fail loudly rather than risk
                         * silent corruption for an untested path. */
                        fail(state, "external function: CHARACTER/MATRIX/VECTOR return values are not yet implemented");
                        break;
                    }
                    if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    state->vac[ins->index] = target->external_call_result;
                    break;
                }
                if (callee >= HALMAT_SYT_MAX || state->symbol_def_pos[callee] == NO_TARGET) {
                    fail(state, "call to undefined function (symbol %u)", callee);
                    break;
                }
                /* Positional argument binding: SYT callee+1+i, per
                 * class-0/FCAL.md's confirmed convention. */
                for (uint8_t i = 0; i < state->io_pending.item_count; i++) {
                    uint16_t param_syt = callee + 1 + i;
                    if (param_syt >= HALMAT_SYT_MAX) { fail(state, "too many call arguments"); break; }
                    if (state->io_pending.items[i].is_scalar) {
                        state->syt[param_syt].type = SYT_TYPE_SCALAR;
                        state->syt[param_syt].scalar = state->io_pending.items[i].scalar;
                    } else {
                        state->syt[param_syt].type = SYT_TYPE_INTEGER;
                        state->syt[param_syt].value = state->io_pending.items[i].integer;
                    }
                }
                if (state->call_return_sp >= 64) { fail(state, "call nesting too deep"); break; }
                state->call_return_stack[state->call_return_sp++] = state->pc;
                state->pc = state->symbol_def_pos[callee] + 1;
                branched = true;
                break;
            }

            case OP_IDEF:
                /* Opens an inline FUNCTION block (class-0/IDEF.md) --
                 * unlike FCAL, no branch: the block's own HALMAT already
                 * appears in-line in the stream and simply falls
                 * through. Pushed so the matching RTRN (see below) knows
                 * which VAC slot to write its result to. */
                if (state->inline_func_sp >= 16) { fail(state, "inline FUNCTION nesting too deep"); break; }
                state->inline_func_stack[state->inline_func_sp++] = state->pc;
                break;

            case OP_ICLS:
                /* Closes the inline FUNCTION block opened by the most
                 * recent IDEF (class-0/ICLS.md); pure bracket, no
                 * runtime effect of its own beyond popping the stack IDEF
                 * pushed -- the RTRN inside already wrote the result. */
                if (state->inline_func_sp <= 0) { fail(state, "ICLS with no active inline FUNCTION"); break; }
                state->inline_func_sp--;
                break;

            case OP_RTRN: {
                /* Two forms (class-0/RTRN.md): 1 operand = function
                 * return value (result flows back via the FCAL's own VAC
                 * slot); 0 operands = procedure/task return (no value --
                 * used by PCAL-initiated calls, which have no VAC result
                 * to write). Inline-FUNCTION form (class-0/IDEF.md): a
                 * RTRN reached with no active FCAL/PCAL call frame but an
                 * open IDEF instead writes its result to the IDEF's own
                 * VAC slot (mirroring FCAL's role) and simply falls
                 * through (no branch -- IDEF.md's confirmed trace shows
                 * the inline body already appears in-line in the
                 * instruction stream, unlike a real subprogram body
                 * defined elsewhere). External-call form (source-
                 * documentation/Multiple-file-problem.md): a RTRN
                 * reached with no active call frame at all, while this
                 * state is being run as a run_external_call() target,
                 * instead captures its result (if any) for the *caller*
                 * (a different state entirely) to retrieve, and signals
                 * completion via halted=true -- the same signal CLOS's
                 * existing "primal process closing" branch already gives
                 * for an ordinary top-level program falling through
                 * without an explicit RETURN. */
                if (ins->operand_count > 1) { fail(state, "RTRN: expected 0 or 1 operands"); break; }
                if (state->call_return_sp <= 0) {
                    if (state->inline_func_sp > 0) {
                        if (ins->operand_count != 1) { fail(state, "RTRN: inline FUNCTION requires a return value"); break; }
                        if (!resolve_operand(state, &ins->operands[0], &a)) break;
                        size_t idef_pos = state->inline_func_stack[state->inline_func_sp - 1];
                        size_t vac_index = state->prog->instrs[idef_pos].index;
                        if (vac_index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                        store_resolved_to_vac(&state->vac[vac_index], &a);
                        break;
                    }
                    if (state->in_external_call) {
                        if (ins->operand_count == 1) {
                            if (!resolve_operand(state, &ins->operands[0], &a)) break;
                            store_resolved_to_vac(&state->external_call_result, &a);
                            state->external_call_has_result = true;
                        }
                        state->halted = true;
                        break;
                    }
                    fail(state, "RTRN with no active call");
                    break;
                }
                if (ins->operand_count == 1) {
                    if (!resolve_operand(state, &ins->operands[0], &a)) break;
                    size_t fcal_pos = state->call_return_stack[--state->call_return_sp];
                    size_t vac_index = state->prog->instrs[fcal_pos].index;
                    if (vac_index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                    state->vac[vac_index].is_ref = false;
                    state->vac[vac_index].integer = rv_to_integer(&a);
                    state->pc = fcal_pos + 1;
                } else {
                    size_t call_pos = state->call_return_stack[--state->call_return_sp];
                    state->pc = call_pos + 1;
                }
                branched = true;
                break;
            }

            case OP_CLOS:
                if (state->call_return_sp > 0) {
                    /* Implicit return (procedure with no explicit RETURN,
                     * or a fallthrough past the last statement) -- no
                     * return value is available here. */
                    size_t fcal_pos = state->call_return_stack[--state->call_return_sp];
                    state->pc = fcal_pos + 1;
                    branched = true;
                } else if (!state->tasks[state->current_task].is_primal) {
                    /* A scheduled task's body fell through to its own end
                     * without an explicit TERMINATE -- either genuine
                     * completion (class-0/RTRN.md's "every subprogram body
                     * is terminated regardless" note, TASK analog) or, for
                     * a cyclic (REPEAT) task, just the end of one cycle.
                     * Explicit TERMINATE/CANCEL (OP_TERM/OP_CANC below)
                     * always end the task outright and bypass this rearm
                     * check entirely -- only a *fallthrough* CLOS is
                     * eligible to rearm, matching REPEAT/WHILE/UNTIL's
                     * role as governing the task's own natural completion,
                     * not something an explicit mid-body CANCEL could be
                     * talked out of. */
                    halmat_task_t *cur = &state->tasks[state->current_task];
                    bool stop = true;
                    if (cur->repeat_kind != SCHD_REPEAT_NONE) {
                        /* Stopping-condition expressions are evaluated only
                         * here -- once per completed cycle, at the moment
                         * the task would otherwise be rearmed -- never
                         * continuously every tick. class-0/SCHD.md frames
                         * WHILE/UNTIL as governing *whether the cycle
                         * continues*, the same "test at the iteration
                         * boundary" shape HAL/S's own DO WHILE/DO UNTIL
                         * loops use (already this interpreter's CFOR
                         * pattern) -- there's no primary-source basis for
                         * treating it as an asynchronous mid-execution
                         * interrupt, and WAIT is already the language's
                         * only mechanism for a task to suspend mid-body. */
                        switch (cur->stop_kind) {
                            case SCHD_STOP_NONE:
                                stop = false;
                                break;
                            case SCHD_STOP_UNTIL_TIME:
                                stop = (state->virtual_time >= cur->stop_deadline);
                                break;
                            case SCHD_STOP_WHILE_BIT:
                                /* WHILE <bit exp>: keep cycling while true, stop once false. */
                                stop = (cur->stop_event_syt >= HALMAT_SYT_MAX ||
                                        state->syt[cur->stop_event_syt].bit_value == 0);
                                break;
                            case SCHD_STOP_UNTIL_BIT:
                                /* UNTIL <bit exp>: keep cycling until true, stop once true. */
                                stop = (cur->stop_event_syt < HALMAT_SYT_MAX &&
                                        state->syt[cur->stop_event_syt].bit_value != 0);
                                break;
                        }
                    }
                    if (!stop) {
                        /* Rearming jumps this task's own pc back to its
                         * body's start -- must go through the same state-
                         * >pc/branched mechanism TDEF/RTRN use (not a bare
                         * cur->saved_pc write), since exec_one's own tail
                         * ("if (!branched) state->pc++") and interp_step's
                         * post-exec_one "saved_pc = state->pc" would
                         * otherwise clobber it with CLOS's own position+1
                         * right after this case returns. */
                        state->pc = state->symbol_def_pos[cur->symbol] + 1;
                        branched = true;
                        switch (cur->repeat_kind) {
                            case SCHD_REPEAT_BARE:
                                /* No interval -- immediate back-to-back retrigger. */
                                cur->task_state = TASK_READY;
                                break;
                            case SCHD_REPEAT_EVERY:
                                /* Fixed period, chained off the previous
                                 * target (not off "now") so a late-running
                                 * cycle doesn't push later ones out --
                                 * every_phase_ref already holds that
                                 * previous target (set at SCHD time, or by
                                 * the prior rearm), kept in its own field
                                 * (state.h) so it can't be clobbered by an
                                 * internal WAIT in the task's body (OP_WAIT
                                 * only ever touches wake_deadline). Assign
                                 * wake_deadline from the post-increment
                                 * value since sched_wake_waiting() only
                                 * ever reads wake_deadline, never this
                                 * field directly. */
                                cur->every_phase_ref += cur->repeat_interval;
                                cur->wake_deadline = cur->every_phase_ref;
                                cur->task_state = TASK_WAITING;
                                break;
                            case SCHD_REPEAT_AFTER:
                                /* Delay measured from *this* completion,
                                 * so it does drift with however long the
                                 * cycle actually took -- the language-level
                                 * distinction from EVERY. */
                                cur->wake_deadline = state->virtual_time + cur->repeat_interval;
                                cur->task_state = TASK_WAITING;
                                break;
                            default:
                                break;
                        }
                    } else {
                        cur->task_state = TASK_TERMINATED;
                        if (cur->symbol < HALMAT_SYT_MAX) state->symbol_active_task[cur->symbol] = -1;
                    }
                } else {
                    /* Primal process closing: per USA003087 Sec. 13.3,
                     * all other processes are always dependent on the
                     * primal process for their existence, so this ends
                     * the whole program. */
                    state->halted = true;
                    state->exit_code = 0;
                }
                break;

            case OP_SCHD: {
                /* Full tag decode per class-0/SCHD.md's primary-source-
                 * confirmed bitmask (PASS1.PROCS/SYNTHESI.xpl's <SCHEDULE
                 * HEAD>/<SCHEDULE PHRASE>/<SCHEDULE CONTROL> construction
                 * of INX(REFER_LOC)) -- every field below is exclusive
                 * within its own bit range, so a plain switch/if-chain on
                 * each extracted sub-field covers every legal combination
                 * with no guessing. Operands appear in strict left-to-
                 * right source order (SCHD.md's confirmed general rule):
                 * task, [AT/IN-exp or ON-event], [priority], [EVERY/AFTER-
                 * exp], [stop-exp-or-event] -- operand_idx just walks that
                 * fixed sequence, skipping whichever clauses the tag says
                 * aren't present. */
                if (ins->operand_count < 1 || ins->operands[0].qual != QUAL_SYT) {
                    fail(state, "SCHD: expected task symbol as first operand");
                    break;
                }
                uint16_t task_sym = ins->operands[0].data;
                if (task_sym >= HALMAT_SYT_MAX || state->symbol_def_pos[task_sym] == NO_TARGET) {
                    fail(state, "SCHEDULE of undefined task (symbol %u)", task_sym);
                    break;
                }

                uint8_t init_kind = ins->tag & 0x3;          /* 0=immediate, 1=AT, 2=IN, 3=ON */
                bool has_priority = (ins->tag & 0x4) != 0;
                bool dependent = (ins->tag & 0x8) != 0;
                uint8_t repeat_bits = (ins->tag & 0x30) >> 4; /* 0=none, 1=bare, 2=EVERY, 3=AFTER -- matches halmat_schd_repeat_t's own numbering */
                uint8_t stop_bits = (ins->tag & 0xC0) >> 6;   /* 0=none, 1=UNTIL-time, 2=WHILE-bit, 3=UNTIL-bit -- matches halmat_schd_stop_t's own numbering */
                if (repeat_bits == 0 && stop_bits != 0) {
                    /* Grammatically legal per SCHD.md's <SCHEDULE CONTROL>
                     * ::= <STOPPING> alternative (WHILE/UNTIL with no
                     * REPEAT at all) -- confirmed HALSFC really does
                     * accept and compile it (three SCHEDULE HEAD variants
                     * tried: AT+UNTIL, ON+WHILE, and plain immediate+
                     * WHILE, each producing exactly the tag/operand-order
                     * this decode already expects). But its *runtime*
                     * semantics are genuinely undocumented, not just
                     * unconfirmed by this project: SYNTHESI.xpl's own
                     * grammar action for this case is a bare no-op (no
                     * special-casing vs. the cyclic <TIMING><STOPPING>
                     * form), and USA003087 discusses WHILE/UNTIL stopping
                     * conditions exclusively as a cyclic-process
                     * ("cancel the next cycle") concept (Sec. 23.4-23.5)
                     * that has no defined meaning for a process with no
                     * next cycle. See SCHD.md's Unresolved Questions for
                     * the full writeup -- failing loudly here reflects an
                     * actually-researched open question, not an
                     * unexplored one. */
                    fail(state, "SCHEDULE: WHILE/UNTIL without REPEAT is not implemented (tag 0x%X) -- see class-0/SCHD.md", ins->tag);
                    break;
                }

                int64_t at_in_value = 0;
                uint16_t on_event_syt = 0;
                uint8_t operand_idx = 1;
                if (init_kind == 1 || init_kind == 2) { /* AT or IN: VAC ref to the arith exp */
                    if (operand_idx >= ins->operand_count) { fail(state, "SCHD: missing AT/IN operand"); break; }
                    if (!resolve_operand(state, &ins->operands[operand_idx], &a)) break;
                    if (!schd_seconds_to_ticks(state, &a, "SCHD: AT/IN", false, &at_in_value)) break;
                    operand_idx++;
                } else if (init_kind == 3) { /* ON: plain EVENT SYT ref (SCHD.md's confirmed "no VAC needed" case) */
                    if (operand_idx >= ins->operand_count || ins->operands[operand_idx].qual != QUAL_SYT) {
                        fail(state, "SCHD: ON expects a plain EVENT symbol operand (subscripted/latched bit exps unconfirmed)");
                        break;
                    }
                    on_event_syt = ins->operands[operand_idx].data;
                    operand_idx++;
                }

                int priority = 50; /* default when no PRIORITY(...) clause; matches the primal's own default, but untested -- no primary-source confirmation for this specific case */
                if (has_priority) {
                    if (operand_idx >= ins->operand_count) { fail(state, "SCHD: missing PRIORITY operand"); break; }
                    if (!resolve_operand(state, &ins->operands[operand_idx], &a)) break;
                    priority = rv_to_integer(&a);
                    operand_idx++;
                }
                if (priority <= 0 || priority >= 255) {
                    fail(state, "SCHEDULE priority %d out of range 0<P<255 (USA003087 Sec. 13.1-13.3)", priority);
                    break;
                }

                int32_t repeat_interval = 0;
                if (repeat_bits == 2 || repeat_bits == 3) { /* EVERY or AFTER: VAC ref to the arith exp */
                    if (operand_idx >= ins->operand_count) { fail(state, "SCHD: missing REPEAT EVERY/AFTER operand"); break; }
                    if (!resolve_operand(state, &ins->operands[operand_idx], &a)) break;
                    int64_t repeat_interval64;
                    if (!schd_seconds_to_ticks(state, &a, "SCHD: REPEAT EVERY/AFTER", true, &repeat_interval64)) break;
                    repeat_interval = (int32_t)repeat_interval64;
                    operand_idx++;
                }

                int64_t stop_deadline = 0;
                uint16_t stop_event_syt = 0;
                if (stop_bits == 1) { /* UNTIL <ARITH EXP>: VAC ref to the time-valued exp */
                    if (operand_idx >= ins->operand_count) { fail(state, "SCHD: missing WHILE/UNTIL operand"); break; }
                    if (!resolve_operand(state, &ins->operands[operand_idx], &a)) break;
                    if (!schd_seconds_to_ticks(state, &a, "SCHD: WHILE/UNTIL <time>", false, &stop_deadline)) break;
                    operand_idx++;
                } else if (stop_bits == 2 || stop_bits == 3) { /* WHILE/UNTIL <BIT EXP>: plain SYT ref, same as ON */
                    if (operand_idx >= ins->operand_count || ins->operands[operand_idx].qual != QUAL_SYT) {
                        fail(state, "SCHD: WHILE/UNTIL <bit exp> expects a plain event symbol operand (subscripted/latched bit exps unconfirmed)");
                        break;
                    }
                    stop_event_syt = ins->operands[operand_idx].data;
                    operand_idx++;
                }

                if (operand_idx != ins->operand_count) {
                    fail(state, "SCHD: operand count %u doesn't match tag 0x%X's expected clauses", ins->operand_count, ins->tag);
                    break;
                }

                if (state->symbol_active_task[task_sym] != -1) {
                    /* At most one active instance per task symbol for
                     * now -- reentrant/concurrent re-scheduling of the
                     * same task block isn't implemented; no fixture
                     * exercises it. */
                    fail(state, "task already active (concurrent re-scheduling of the same task not yet implemented)");
                    break;
                }
                if (state->task_count >= HALMAT_MAX_TASKS) { fail(state, "too many concurrent tasks"); break; }
                int idx = state->task_count++;
                halmat_task_t *nt = &state->tasks[idx];
                nt->in_use = true;
                nt->is_primal = false;
                nt->symbol = task_sym;
                nt->priority = priority;
                nt->saved_pc = state->symbol_def_pos[task_sym] + 1;
                nt->dependent = dependent;
                nt->repeat_kind = (halmat_schd_repeat_t)repeat_bits;
                nt->repeat_interval = repeat_interval;
                nt->stop_kind = (halmat_schd_stop_t)stop_bits;
                nt->stop_deadline = stop_deadline;
                nt->stop_event_syt = stop_event_syt;
                /* every_phase_ref (state.h) holds REPEAT EVERY's own
                 * phase reference, kept separate from wake_deadline so an
                 * internal WAIT in the task's body can't corrupt it --
                 * default to "now" (this SCHD's own execution tick) so a
                 * bare/ON/immediate-start cyclic task's first period is
                 * measured from here; overridden just below for AT/IN,
                 * whose own target is the more natural first reference
                 * point. Mirrors wake_deadline's own default/override
                 * below for exactly the same reason -- at this moment,
                 * before the task has ever run, both fields agree. */
                nt->wake_deadline = state->virtual_time;
                nt->every_phase_ref = state->virtual_time;

                switch (init_kind) {
                    case 1: /* AT <absolute virtual time> */
                        nt->task_state = TASK_WAITING;
                        nt->wake_deadline = at_in_value;
                        nt->every_phase_ref = at_in_value;
                        break;
                    case 2: /* IN <relative delay> */
                        nt->task_state = TASK_WAITING;
                        nt->wake_deadline = state->virtual_time + at_in_value;
                        nt->every_phase_ref = nt->wake_deadline;
                        break;
                    case 3: /* ON <bit exp>: no fixed deadline, re-checked every tick (state.h's TASK_WAITING_ON) */
                        nt->task_state = TASK_WAITING_ON;
                        nt->has_on_event = true;
                        nt->on_event_syt = on_event_syt;
                        break;
                    default: /* immediate */
                        nt->task_state = TASK_READY;
                        break;
                }
                state->symbol_active_task[task_sym] = idx;
                /* No branch here -- SCHD only adds the task to the pool;
                 * the scheduler loop in interp_run naturally picks it up
                 * next if it's immediately READY and higher-priority than
                 * whatever is currently executing, or lets the current
                 * flow continue otherwise (delayed/ON forms aren't READY
                 * at all yet). */
                break;
            }

            case OP_WAIT: {
                /* Only the interval form (WAIT <seconds>;, tag=1) is
                 * implemented; WAIT UNTIL (tag=2) and WAIT FOR DEPENDENT
                 * (tag=0, no operands) fail loudly -- see class-0/WAIT.md. */
                if (ins->operand_count != 1 || ins->tag != 1) {
                    fail(state, "WAIT: only the interval form is implemented");
                    break;
                }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                /* Not narrowed to int32_t: unlike repeat_interval (a real,
                 * fixed-width int32_t field of halmat_task_t), WAIT's tick
                 * count is only ever added into wake_deadline (int64_t) --
                 * there's no persisted 32-bit field it must fit into, and
                 * at HALMAT_TICKS_PER_SECOND=276000, a real (if unusually
                 * long) WAIT(10000) already exceeds INT32_MAX ticks, so
                 * narrowing here would fail loudly on a perfectly ordinary
                 * interval. want_int32=false matches at_in_value/
                 * stop_deadline's own int64_t treatment above. */
                int64_t ticks;
                if (!schd_seconds_to_ticks(state, &a, "WAIT", false, &ticks)) break;
                if (ticks < 0) ticks = 0;
                halmat_task_t *cur = &state->tasks[state->current_task];
                cur->task_state = TASK_WAITING;
                cur->wake_deadline = state->virtual_time + ticks;
                break;
            }

            case OP_CANC: {
                /* CANCEL statement (class-0/CANC.md): gracefully cancels
                 * a cyclic process, removing it from the run queue --
                 * same observable effect as TERM for this interpreter's
                 * purposes (no distinct "cyclic re-arm" state is
                 * modeled, since SCHD's cyclic REPEAT EVERY/AFTER forms
                 * aren't implemented either -- see OP_SCHD above), so
                 * this reuses TERM's exact self/named-form logic. */
                if (ins->operand_count == 0) {
                    halmat_task_t *cur = &state->tasks[state->current_task];
                    cur->task_state = TASK_TERMINATED;
                    if (cur->symbol < HALMAT_SYT_MAX) state->symbol_active_task[cur->symbol] = -1;
                } else {
                    for (uint8_t i = 0; i < ins->operand_count; i++) {
                        if (ins->operands[i].qual != QUAL_SYT) { fail(state, "CANC: expected SYT operand"); break; }
                        uint16_t sym = ins->operands[i].data;
                        if (sym < HALMAT_SYT_MAX && state->symbol_active_task[sym] != -1) {
                            int idx = state->symbol_active_task[sym];
                            state->tasks[idx].task_state = TASK_TERMINATED;
                            state->symbol_active_task[sym] = -1;
                        }
                    }
                }
                break;
            }

            case OP_SGNL: {
                /* SIGNAL statement (class-0/SGNL.md): makes an EVENT
                 * data item transiently TRUE. Modeled as a direct BIT
                 * write to the target's SYT entry (bit_value=1) -- the
                 * "transient" (auto-reset) aspect and WAIT-ON-EVENT
                 * consumption aren't modeled, since this interpreter has
                 * no EVENT-aware WAIT form yet (only WAIT's interval
                 * form is implemented -- see OP_WAIT above); no fixture
                 * currently observes the target afterward, so this is a
                 * safe, honest partial implementation rather than a
                 * silent no-op. */
                if (ins->operand_count != 1 || ins->operands[0].qual != QUAL_SYT) {
                    fail(state, "SGNL: expected one SYT operand");
                    break;
                }
                uint16_t sym = ins->operands[0].data;
                if (sym >= HALMAT_SYT_MAX) { fail(state, "SGNL: SYT index out of range"); break; }
                halmat_syt_entry_t *e = &state->syt[sym];
                e->type = SYT_TYPE_BIT;
                e->bit_value = 1;
                break;
            }

            case OP_TERM: {
                if (ins->operand_count == 0) {
                    /* Self form. */
                    halmat_task_t *cur = &state->tasks[state->current_task];
                    cur->task_state = TASK_TERMINATED;
                    if (cur->symbol < HALMAT_SYT_MAX) state->symbol_active_task[cur->symbol] = -1;
                } else {
                    /* Named/list form: terminating an inactive/already-
                     * finished task is a no-op (USA003087's "removed
                     * from the process queue" framing), not an error. */
                    for (uint8_t i = 0; i < ins->operand_count; i++) {
                        if (ins->operands[i].qual != QUAL_SYT) { fail(state, "TERM: expected SYT operand"); break; }
                        uint16_t sym = ins->operands[i].data;
                        if (sym < HALMAT_SYT_MAX && state->symbol_active_task[sym] != -1) {
                            int idx = state->symbol_active_task[sym];
                            state->tasks[idx].task_state = TASK_TERMINATED;
                            state->symbol_active_task[sym] = -1;
                        }
                    }
                }
                break;
            }

            case OP_PMHD:
            case OP_PMAR:
            case OP_PMIN:
                /* %macro invocation (class-0/PMHD.md/PMAR.md/PMIN.md):
                 * a small, fixed set of compiler-predefined utility
                 * macros (%SVC, %NAMEBIAS, %NAMECOPY, %COPY, %SVCI,
                 * %NAMEADD) that compile directly to raw AP-101S
                 * machine instructions (confirmed: %SVC(5) literally
                 * emits an SVC -- supervisor call -- trap instruction),
                 * not portable HALMAT-level semantics. Deliberately out
                 * of scope, per this project's own stated boundary
                 * (yaHALMAT2 interprets HALMAT, never AP-101S object
                 * code) -- failing loudly here with a specific message
                 * rather than silently no-opping, since ignoring an SVC
                 * call could hide behavior a real program depends on. */
                fail(state, "opcode 0x%03X (%s): %%macro invocations (%%SVC etc.) compile to raw "
                            "AP-101S machine instructions with no portable HALMAT-level semantics -- "
                            "out of scope for this interpreter",
                     ins->opcode, ins->opcode == OP_PMHD ? "PMHD" : ins->opcode == OP_PMAR ? "PMAR" : "PMIN");
                break;

            default: {
                const opcode_desc_t *desc = opcode_lookup(ins->opcode);
                fail(state, "opcode 0x%03X (%s) not yet implemented", ins->opcode,
                     desc ? desc->mnemonic : "????");
                break;
            }
        }

        if (!state->halted && !branched) {
            state->pc++;
        }
    }
}

/* Highest-priority TASK_READY task, or -1 if none are ready (everything
 * is TERMINATED or TASK_WAITING). */
static int sched_pick_next(halmat_state_t *state) {
    int best = -1;
    for (int i = 0; i < state->task_count; i++) {
        if (!state->tasks[i].in_use || state->tasks[i].task_state != TASK_READY) continue;
        if (best == -1 || state->tasks[i].priority > state->tasks[best].priority) best = i;
    }
    return best;
}

static void sched_wake_waiting(halmat_state_t *state) {
    for (int i = 0; i < state->task_count; i++) {
        if (state->tasks[i].in_use && state->tasks[i].task_state == TASK_WAITING &&
            state->tasks[i].wake_deadline <= state->virtual_time) {
            state->tasks[i].task_state = TASK_READY;
        }
    }
}

/* SCHD's ON <bit exp> initiation (state.h's TASK_WAITING_ON): unlike
 * TASK_WAITING's fixed wake_deadline, there's no way to know in advance
 * *when* (or whether) some other task's SIGNAL will flip the event, so
 * this has to actually re-read the live SYT bit_value every tick rather
 * than being folded into sched_advance_to_next_wake's fast-forward --
 * see that function's comment for why TASK_WAITING_ON is deliberately
 * left out of it. */
static void sched_wake_on_events(halmat_state_t *state) {
    for (int i = 0; i < state->task_count; i++) {
        halmat_task_t *t = &state->tasks[i];
        if (t->in_use && t->task_state == TASK_WAITING_ON &&
            t->on_event_syt < HALMAT_SYT_MAX && state->syt[t->on_event_syt].bit_value != 0) {
            t->task_state = TASK_READY;
        }
    }
}

/* If every in-use task is either TERMINATED, TASK_WAITING_ON, or
 * TASK_WAITING (nothing READY right now, but something will eventually
 * wake), fast-forwards state->virtual_time to the earliest pending
 * wake_deadline and re-applies sched_wake_waiting -- otherwise the
 * interpreter would incorrectly treat "nothing is READY this instant" as
 * "the program has ended" even though a WAIT(n)/delayed SCHD is due to
 * expire later, since virtual_time (per state.h's scheduler comment) only
 * otherwise advances one tick per *executed* instruction, and no
 * instruction executes while every task is blocked. A no-op when
 * something is already READY or truly nothing is left (all TERMINATED).
 * TASK_WAITING_ON tasks are deliberately excluded from the "something will
 * eventually wake" determination -- an ON condition has no deadline to
 * fast-forward to, so if only TASK_WAITING_ON tasks remain (nothing left
 * that could ever SIGNAL the event they're waiting on), this correctly
 * falls through to "nothing left to run" rather than spinning forever;
 * that's a silent-starvation outcome (the ON task just never runs), not a
 * crash or a hang, and no fixture has hit it in practice. */
static void sched_advance_to_next_wake(halmat_state_t *state) {
    bool any_ready = false, any_waiting = false;
    int64_t earliest = 0;
    for (int i = 0; i < state->task_count; i++) {
        if (!state->tasks[i].in_use) continue;
        if (state->tasks[i].task_state == TASK_READY) { any_ready = true; break; }
        if (state->tasks[i].task_state == TASK_WAITING) {
            if (!any_waiting || state->tasks[i].wake_deadline < earliest) earliest = state->tasks[i].wake_deadline;
            any_waiting = true;
        }
    }
    if (!any_ready && any_waiting && earliest > state->virtual_time) {
        state->virtual_time = earliest;
        sched_wake_waiting(state);
    }
}

/* Runs the scheduler for exactly one instruction (picks the
 * highest-priority TASK_READY task, executes one instruction for it,
 * advances the virtual clock). Returns true once nothing is left to run
 * (halted, or no task is READY/ever going to wake). Exposed for
 * --debugger's step command; interp_run() is just this called in a loop. */
bool interp_step(halmat_state_t *state, FILE *out) {
    if (state->halted) return true;

    sched_wake_waiting(state);
    sched_wake_on_events(state);
    sched_advance_to_next_wake(state);
    int next = sched_pick_next(state);
    if (next == -1) return true; /* nothing left ready (and nothing left to ever wake) */

    state->current_task = next;
    state->pc = state->tasks[next].saved_pc;

    if (state->pc >= state->prog->count) {
        fail(state, "instruction stream ended without a CLOS");
        return true;
    }

    /* Arrayed-paragraph replay (state.h's arrayed_paragraph_end/_count):
     * if this position starts a recognized ADLP-trailed paragraph,
     * replay it element-count times (once per array index) instead of
     * executing it once -- see precompute_arrayed_paragraphs() and the
     * resolve_operand/write_destination QUAL_SYT redirection it enables. */
    size_t paragraph_end = state->arrayed_paragraph_end[state->pc];
    if (paragraph_end != NO_TARGET) {
        size_t paragraph_start = state->pc;
        int count = state->arrayed_paragraph_count[paragraph_start];
        for (int idx = 0; idx < count && !state->halted; idx++) {
            state->arrayed_index = idx;
            state->pc = paragraph_start;
            while (state->pc < paragraph_end && !state->halted) {
                exec_one(state, out);
            }
        }
        state->arrayed_index = -1;
        if (!state->halted) state->pc = paragraph_end;
    } else {
        exec_one(state, out);
    }

    state->tasks[next].saved_pc = state->pc;
    /* 1 tick per HALMAT instruction executed -- unchanged, still the
     * interpreter's fundamental virtual-time granularity. WAIT/SCHD
     * intervals are converted from real seconds into however many of
     * these ticks that represents (schd_seconds_to_ticks(), OP_SCHD/
     * OP_WAIT above, via HALMAT_TICKS_PER_SECOND); interp_run()'s
     * wall-clock pacing (below) is a separate layer on top of this that
     * never changes the tick arithmetic itself, only how fast real time
     * elapses alongside it. */
    state->virtual_time++;

    return state->halted;
}

#ifdef _WIN32
static double monotonic_seconds(void) {
    static LARGE_INTEGER freq;
    static bool have_freq = false;
    if (!have_freq) {
        QueryPerformanceFrequency(&freq);
        have_freq = true;
    }
    LARGE_INTEGER count;
    QueryPerformanceCounter(&count);
    return (double)count.QuadPart / (double)freq.QuadPart;
}

static void sleep_seconds(double seconds) {
    if (seconds <= 0.0) return;
    /* Sleep() only takes whole milliseconds -- round up so this never
     * sleeps for less than the computed deficit. */
    DWORD ms = (DWORD)ceil(seconds * 1000.0);
    Sleep(ms);
}
#else
static double monotonic_seconds(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec / 1e9;
}

static void sleep_seconds(double seconds) {
    if (seconds <= 0.0) return;
    struct timespec req;
    req.tv_sec = (time_t)seconds;
    req.tv_nsec = (long)((seconds - (double)req.tv_sec) * 1e9);
    nanosleep(&req, NULL);
}
#endif

/* Runs interp_step() in a loop (same as always) but paced against the
 * wall clock, per the project owner's own direction: "burst execute some
 * number of instructions, then sleep to let the operating system do
 * whatever else it needs to do, then execute a new burst ... on a 50 or
 * 100 millisecond cycle. This keeps you close to being synchronized with
 * real time from a human user's perception without really using much of
 * the CPU." Deliberately NOT inside interp_step() itself -- that stays a
 * pure virtual-time primitive shared by --debug's own run/step loop
 * (debug_run(), debug.c), which must NOT be throttled (time spent
 * blocked on debugger input must never count against real time).
 *
 * ref_wall/ref_virtual are reset together every time a pacing window's
 * threshold (window_ticks, ~HALMAT_REALTIME_BURST_MS worth of ticks) is
 * crossed: interp_step() is called repeatedly, accumulating virtual_time
 * ticks with no wall-clock check at all, until elapsed_virtual crosses
 * that threshold -- so the monotonic-clock read happens only ~20x/sec of
 * virtual-equivalent time, not once per instruction. This same check
 * also correctly handles sched_advance_to_next_wake()'s idle fast-
 * forward (a single interp_step() call that can jump virtual_time a
 * large amount at once, when every task is TASK_WAITING and nothing is
 * READY): that jump alone pushes elapsed_virtual past the threshold, and
 * the resulting sleep correctly represents the real elapsed time
 * equivalent to it -- sched_advance_to_next_wake() itself needs no
 * special-casing here at all.
 *
 * If a burst genuinely took longer in wall-clock terms than its virtual-
 * time equivalent (slow host, heavy/debug build), target_wall_seconds >
 * actual_wall_seconds is false, nothing sleeps, and the reference pair
 * simply resets to "now" -- no catch-up/runaway-acceleration debt ever
 * accumulates across windows; a stall is never made up for by later
 * blasting through instructions faster than real time. */
static int interp_run_burst(halmat_state_t *state, FILE *out) {
    double ref_wall = monotonic_seconds();
    int64_t ref_virtual = state->virtual_time;
    int64_t window_ticks = (int64_t)(HALMAT_TICKS_PER_SECOND * (HALMAT_REALTIME_BURST_MS / 1000.0));

    while (!interp_step(state, out)) {
        int64_t elapsed_virtual = state->virtual_time - ref_virtual;
        if (elapsed_virtual >= window_ticks) {
            double target_wall_seconds = (elapsed_virtual / (double)HALMAT_TICKS_PER_SECOND) / state->time_scale;
            double actual_wall_seconds = monotonic_seconds() - ref_wall;
            if (target_wall_seconds > actual_wall_seconds) {
                sleep_seconds(target_wall_seconds - actual_wall_seconds);
            }
            ref_wall = monotonic_seconds();
            ref_virtual = state->virtual_time;
        }
    }
    return state->exit_code;
}

/* interp_run_signal(): the alternative, signal/timer-notification-driven
 * pacing implementation, added purely for direct side-by-side comparison
 * against interp_run_burst() above (both implement the exact same
 * pacing contract -- see state.h's halmat_pacing_mode_t comment; select
 * with --pacing=signal, main.c). Where interp_run_burst() periodically
 * *asks* "how much wall-clock time has elapsed?" (a polling design whose
 * reaction granularity is bounded by how often it happens to check, i.e.
 * HALMAT_REALTIME_BURST_MS), this implementation is *notified*: a POSIX
 * per-process real-time timer (CLOCK_MONOTONIC, same clock source as
 * interp_run_burst() -- must not be affected by wall-clock/NTP
 * adjustments) delivers a real-time signal on a fixed schedule, and the
 * interpreter blocks (sigsuspend(), never a busy-poll) until notified,
 * rather than discovering drift only at its next scheduled check.
 *
 * SIGRTMIN+2 (a real-time signal), not SIGALRM: real-time signals queue
 * rather than coalescing multiple pending instances into one, so if
 * interp_step() occasionally takes a while (a genuinely slow
 * instruction, or the idle-fast-forward case below) no tick
 * notifications are silently lost while the interpreter is busy -- they
 * are delivered/counted once it catches up. (+2 rather than bare
 * SIGRTMIN on the untested-but-plausible theory that SIGRTMIN itself is
 * the first one anything else sharing this process might reach for.)
 *
 * The signal handler (pacing_signal_handler, below) does *only*
 * `pacing_flag = 1` -- a static volatile sig_atomic_t, nothing else
 * touched, no calls into interpreter state -- the same async-signal-safe
 * pattern discussed with the project owner. Race-free wait: the signal
 * is blocked up front (sigprocmask), then sigsuspend() atomically
 * unblocks it and sleeps until *some* unblocked signal arrives, closing
 * the check-then-sleep missed-wakeup window a naive
 * "if (!pacing_flag) sleep()" loop would leave open.
 *
 * Budget accounting mirrors interp_run_burst()'s own window (point 5 of
 * the project owner's spec, for an apples-to-apples comparison): each
 * timer firing grants HALMAT_TICKS_PER_SECOND * (HALMAT_REALTIME_BURST_MS
 * / 1000.0) * time_scale ticks of budget, exactly interp_run_burst()'s
 * own per-window tick count -- HALMAT_TICKS_PER_SECOND itself and every
 * SCHD/WAIT seconds-to-ticks conversion are untouched either way.
 *
 * Idle-fast-forward special case (point 4): sched_advance_to_next_wake()
 * (unchanged) can jump virtual_time far ahead in a single interp_step()
 * call when every task is TASK_WAITING/TASK_WAITING_ON and nothing is
 * READY. interp_run_burst() handles this for free (its check is purely
 * "how much virtual time has elapsed", regardless of how it
 * accumulated) -- but naively letting this fall through here would mean
 * looping on sigsuspend() through however many real timer firings the
 * gap represents (a 10-second idle gap at a 50ms window is ~200
 * firings): correct, but needlessly granular for a jump the interpreter
 * already knows about in one shot from a single virtual_time read.
 * Instead, once a step's tick delta exceeds a whole window's worth,
 * compute the equivalent real-time gap directly (same computation
 * interp_run_burst() already does) and sleep that directly, then resume
 * normal signal-driven pacing for the next window. */
#ifdef HAVE_POSIX_TIMERS

/* SIGRTMIN is not a compile-time constant on Linux glibc (it's a function
 * call, to allow for kernel-reserved real-time signals) -- fine, this is
 * only ever evaluated at runtime, never in a preprocessor conditional. */
#define HALMAT_PACING_RT_SIGNAL (SIGRTMIN + 2)

static volatile sig_atomic_t pacing_flag = 0;

static void pacing_signal_handler(int signo) {
    (void)signo;
    pacing_flag = 1;
}

static int interp_run_signal(halmat_state_t *state, FILE *out) {
    pacing_flag = 0;

    sigset_t rt_set;
    sigemptyset(&rt_set);
    sigaddset(&rt_set, HALMAT_PACING_RT_SIGNAL);

    struct sigaction sa, old_sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = pacing_signal_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    if (sigaction(HALMAT_PACING_RT_SIGNAL, &sa, &old_sa) != 0) {
        fail(state, "interp_run_signal: sigaction failed: %s", strerror(errno));
        return state->exit_code;
    }

    /* Block the signal up front so it can never be delivered
     * asynchronously mid-check between interp_step() calls -- sigsuspend()
     * below is the only place it's ever transiently unblocked, atomically,
     * right before going to sleep for it. */
    sigset_t old_mask;
    if (sigprocmask(SIG_BLOCK, &rt_set, &old_mask) != 0) {
        fail(state, "interp_run_signal: sigprocmask failed: %s", strerror(errno));
        sigaction(HALMAT_PACING_RT_SIGNAL, &old_sa, NULL);
        return state->exit_code;
    }

    timer_t timerid;
    struct sigevent sev;
    memset(&sev, 0, sizeof(sev));
    sev.sigev_notify = SIGEV_SIGNAL;
    sev.sigev_signo = HALMAT_PACING_RT_SIGNAL;
    sev.sigev_value.sival_ptr = &timerid;
    if (timer_create(CLOCK_MONOTONIC, &sev, &timerid) != 0) {
        fail(state, "interp_run_signal: timer_create failed: %s", strerror(errno));
        sigprocmask(SIG_SETMASK, &old_mask, NULL);
        sigaction(HALMAT_PACING_RT_SIGNAL, &old_sa, NULL);
        return state->exit_code;
    }

    double window_seconds = HALMAT_REALTIME_BURST_MS / 1000.0;
    struct itimerspec its;
    its.it_value.tv_sec = (time_t)window_seconds;
    its.it_value.tv_nsec = (long)((window_seconds - (double)its.it_value.tv_sec) * 1e9);
    its.it_interval = its.it_value;
    if (timer_settime(timerid, 0, &its, NULL) != 0) {
        fail(state, "interp_run_signal: timer_settime failed: %s", strerror(errno));
        timer_delete(timerid);
        sigprocmask(SIG_SETMASK, &old_mask, NULL);
        sigaction(HALMAT_PACING_RT_SIGNAL, &old_sa, NULL);
        return state->exit_code;
    }

    int64_t window_ticks_budget =
        (int64_t)(HALMAT_TICKS_PER_SECOND * (HALMAT_REALTIME_BURST_MS / 1000.0) * state->time_scale);
    if (window_ticks_budget < 1) window_ticks_budget = 1;
    int64_t budget_ticks = 0;

    bool halted = false;
    while (!halted) {
        if (budget_ticks <= 0) {
            while (!pacing_flag) {
                sigsuspend(&old_mask);
            }
            pacing_flag = 0;
            budget_ticks += window_ticks_budget;
        }

        int64_t before_virtual = state->virtual_time;
        halted = interp_step(state, out);
        int64_t consumed = state->virtual_time - before_virtual;

        if (consumed > window_ticks_budget) {
            /* Idle fast-forward (see this function's own comment above) --
             * sleep the equivalent real time directly instead of waiting
             * out however many timer firings it represents. */
            double gap_seconds = (consumed / (double)HALMAT_TICKS_PER_SECOND) / state->time_scale;
            sleep_seconds(gap_seconds);
            budget_ticks = 0; /* resume ordinary signal-driven pacing next window */
        } else {
            budget_ticks -= consumed;
        }
    }

    timer_delete(timerid);
    sigprocmask(SIG_SETMASK, &old_mask, NULL);
    sigaction(HALMAT_PACING_RT_SIGNAL, &old_sa, NULL);
    return state->exit_code;
}

#elif defined(_WIN32)

/* Windows has no POSIX signals at all, so this uses the platform's own
 * equivalent primitives rather than trying to emulate signals:
 * CreateTimerQueueTimer() for the periodic notification -- which runs
 * its callback on a thread-pool thread, NOT synchronously on the main
 * thread, a real difference from POSIX signals interrupting the same
 * thread -- and a Win32 Event object (CreateEvent/SetEvent in the
 * callback, WaitForSingleObject in the main loop) as the equivalent of
 * sigsuspend()'s blocking wait, rather than a raw flag spin-polled in a
 * loop (which would defeat the entire "don't waste CPU" point).
 *
 * Because the callback runs on a separate thread, the tick-budget
 * bookkeeping can't just be a flag the way POSIX's sig_atomic_t works
 * (same-thread signal handlers get an implicit ordering guarantee a
 * plain cross-thread write does not). pacing_fired_count is instead a
 * genuine Interlocked (atomic) counter of how many timer periods have
 * fired since the main loop last serviced it -- not just a boolean --
 * for the same reason the POSIX side uses a *queuing* real-time signal
 * instead of SIGALRM: a plain auto-reset Event collapses any number of
 * un-waited SetEvent() calls into a single signaled state, which would
 * silently lose tick notifications if the callback fires again before
 * the main thread catches up (e.g. while it's blocked in a slow
 * interp_step()). Counting fired periods, then multiplying by
 * window_ticks_budget when serviced, avoids that loss. */
static volatile LONG pacing_fired_count = 0;

static void CALLBACK pacing_timer_callback(void *param, BOOLEAN timer_or_wait_fired) {
    (void)timer_or_wait_fired;
    InterlockedIncrement(&pacing_fired_count);
    SetEvent((HANDLE)param);
}

static int interp_run_signal(halmat_state_t *state, FILE *out) {
    pacing_fired_count = 0;

    HANDLE event = CreateEvent(NULL, FALSE, FALSE, NULL); /* auto-reset, initially unsignaled */
    if (!event) {
        fail(state, "interp_run_signal: CreateEvent failed (error %lu)", (unsigned long)GetLastError());
        return state->exit_code;
    }

    HANDLE timer = NULL;
    DWORD period_ms = (DWORD)HALMAT_REALTIME_BURST_MS;
    if (!CreateTimerQueueTimer(&timer, NULL, pacing_timer_callback, event, period_ms, period_ms,
                                WT_EXECUTEDEFAULT)) {
        fail(state, "interp_run_signal: CreateTimerQueueTimer failed (error %lu)", (unsigned long)GetLastError());
        CloseHandle(event);
        return state->exit_code;
    }

    int64_t window_ticks_budget =
        (int64_t)(HALMAT_TICKS_PER_SECOND * (HALMAT_REALTIME_BURST_MS / 1000.0) * state->time_scale);
    if (window_ticks_budget < 1) window_ticks_budget = 1;
    int64_t budget_ticks = 0;

    bool halted = false;
    while (!halted) {
        if (budget_ticks <= 0) {
            LONG fired;
            while ((fired = InterlockedExchange(&pacing_fired_count, 0)) == 0) {
                WaitForSingleObject(event, INFINITE);
            }
            budget_ticks += (int64_t)fired * window_ticks_budget;
        }

        int64_t before_virtual = state->virtual_time;
        halted = interp_step(state, out);
        int64_t consumed = state->virtual_time - before_virtual;

        if (consumed > window_ticks_budget) {
            /* Idle fast-forward -- see this function's own comment above
             * interp_run_signal's POSIX branch for the full reasoning
             * (identical here). */
            double gap_seconds = (consumed / (double)HALMAT_TICKS_PER_SECOND) / state->time_scale;
            sleep_seconds(gap_seconds);
            budget_ticks = 0;
        } else {
            budget_ticks -= consumed;
        }
    }

    /* INVALID_HANDLE_VALUE as the completion event makes this call block
     * until any in-flight callback finishes, so the timer is fully torn
     * down (no lingering thread-pool callback touching `event` after
     * it's closed) before returning. */
    DeleteTimerQueueTimer(NULL, timer, INVALID_HANDLE_VALUE);
    CloseHandle(event);
    return state->exit_code;
}

#else

/* Neither HAVE_POSIX_TIMERS (Makefile's build-time probe) nor _WIN32:
 * this target has no known reliable periodic-timer-plus-notification
 * primitive available (notably, real per-process interval timers via
 * timer_create()/timer_settime() have historically been unreliable or
 * absent on some BSD-family systems, including macOS, despite this
 * project's own Makefile listing Mac as a supported target). Fail
 * loudly and specifically rather than silently falling back to
 * interp_run_burst()'s behavior or crashing -- matches this project's
 * established "fail loudly, don't silently degrade" discipline. */
static int interp_run_signal(halmat_state_t *state, FILE *out) {
    (void)out;
    fail(state,
         "this build was compiled without POSIX real-time timer support -- "
         "rebuild with HAVE_POSIX_TIMERS, or use --pacing=burst");
    return state->exit_code;
}

#endif

int interp_run(halmat_state_t *state, FILE *out) {
    if (state->pacing_mode == HALMAT_PACING_SIGNAL) return interp_run_signal(state, out);
    return interp_run_burst(state, out);
}

const halmat_instr_t *interp_peek_next(halmat_state_t *state) {
    if (state->halted) return NULL;
    sched_wake_waiting(state);
    sched_wake_on_events(state);
    sched_advance_to_next_wake(state);
    int next = sched_pick_next(state);
    if (next == -1) return NULL;
    if (state->tasks[next].saved_pc >= state->prog->count) return NULL;
    return &state->prog->instrs[state->tasks[next].saved_pc];
}

/* HAL/S statement number of the instruction interp_peek_next() would
 * return (see precompute_stmt_for_pc()'s comment for why this can't be
 * tracked incrementally as SMRK instructions execute), or -1 if there is
 * no next instruction (halted, or nothing left to run). For --debug's
 * source-line display. */
long interp_current_stmt_for_next(halmat_state_t *state) {
    if (state->halted) return -1;
    sched_wake_waiting(state);
    sched_wake_on_events(state);
    sched_advance_to_next_wake(state);
    int next = sched_pick_next(state);
    if (next == -1) return -1;
    size_t pc = state->tasks[next].saved_pc;
    if (pc >= state->prog->count) return -1;
    return state->stmt_for_pc[pc];
}
