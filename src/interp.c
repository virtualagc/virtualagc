#include "interp.h"

#include <math.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#include "opcode_table.h"
#include "value.h"

/* Combined 12-bit class:opcode values for the instructions implemented so
 * far. Extended opcode-by-opcode as later fixtures require -- see
 * Plan.md M4. */
#define OP_NOP 0x000
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
#define OP_DFOR 0x010
#define OP_EFOR 0x011
#define OP_DSMP 0x013
#define OP_ESMP 0x014
#define OP_AFOR 0x015
#define OP_DTST 0x00E
#define OP_ETST 0x00F
#define OP_CTST 0x016
#define OP_DSUB 0x019
#define OP_RDAL 0x020
#define OP_READ 0x01F
#define OP_WRIT 0x021
#define OP_ERON 0x03C
#define OP_ERSE 0x03D
#define OP_MSHP 0x040
#define OP_VSHP 0x041
#define OP_SSHP 0x042
#define OP_ISHP 0x043
#define OP_BFNC 0x04A
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
#define OP_BAND 0x102
#define OP_BOR 0x103
#define OP_BNOT 0x104
#define OP_ITOB 0x1C1
#define OP_BTOI 0x621
#define OP_CTOB 0x141
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
#define OP_MADD 0x362
#define OP_MSUB 0x363
#define OP_MMPR 0x368
#define OP_VVPR 0x387
#define OP_MSPR 0x3A5
#define OP_MSDV 0x3A6
#define OP_VASN 0x401
#define OP_VNEG 0x444
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
#define OP_IINT 0x8C1
#define OP_SINT 0x8A1
#define OP_CINT 0x841
#define OP_BINT 0x821
#define OP_MINT 0x861
#define OP_VINT 0x881

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

/* strdup is POSIX, not ISO C99 -- MSVC (Plan.md's cross-platform build
 * target) doesn't provide it under strict conformance either. */
static char *dup_string(const char *s) {
    size_t len = strlen(s) + 1;
    char *copy = malloc(len);
    if (copy) memcpy(copy, s, len);
    return copy;
}

static bool resolve_operand(halmat_state_t *state, const halmat_operand_t *op, resolved_value_t *out) {
    memset(out, 0, sizeof(*out));
    switch (op->qual) {
        case QUAL_SYT: {
            if (op->data >= HALMAT_SYT_MAX) {
                fail(state, "SYT index %u out of range", op->data);
                return false;
            }
            const halmat_syt_entry_t *e = &state->syt[op->data];
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
                 * consumers convert via rv_to_integer(). */
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
static bool write_destination(halmat_state_t *state, const halmat_operand_t *op, const resolved_value_t *val) {
    if (op->qual == QUAL_SYT) {
        if (op->data >= HALMAT_SYT_MAX) {
            fail(state, "SYT index %u out of range", op->data);
            return false;
        }
        halmat_syt_entry_t *e = &state->syt[op->data];
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
    for (size_t i = 0; i < n; i++) {
        state->afor_body_target[i] = NO_TARGET;
        state->afor_return_target[i] = NO_TARGET;
        state->efor_dfor_pos[i] = NO_TARGET;
    }

    struct {
        bool is_list;
        size_t dfor_pos;
        uint16_t control_var;
        size_t afor_positions[HALMAT_MAX_OPERANDS * 8]; /* generous: real lists are short */
        size_t afor_count;
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
                sp++;
            }
        } else if (ins->opcode == OP_AFOR) {
            if (sp > 0 && stack[sp - 1].is_list && stack[sp - 1].afor_count < HALMAT_MAX_OPERANDS * 8) {
                stack[sp - 1].afor_positions[stack[sp - 1].afor_count++] = i;
                state->afor_control_var[i] = stack[sp - 1].control_var;
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

    /* Primal process: priority 50 by default (USA003087 Sec. 13.1-13.3),
     * starts at the first instruction, READY. */
    state->tasks[0].in_use = true;
    state->tasks[0].is_primal = true;
    state->tasks[0].priority = 50;
    state->tasks[0].task_state = TASK_READY;
    state->tasks[0].saved_pc = 0;
    state->task_count = 1;
    state->current_task = 0;

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

void interp_set_symtab(halmat_state_t *state, const halmat_symtab_t *symtab) {
    state->symtab = symtab;
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
    free(state->dcas_case_target);
    free(state->dcas_case_count);
    free(state->clbl_ecas_target);
    free(state->symbol_def_pos);
    free(state->def_clos_target);
    free(state->symbol_active_task);
    state->symbol_active_task = NULL;
    state->ctst_exit_target = NULL;
    state->etst_back_target = NULL;
    state->label_pos = NULL;
    state->afor_body_target = NULL;
    state->afor_return_target = NULL;
    state->afor_control_var = NULL;
    state->efor_is_list_form = NULL;
    state->efor_dfor_pos = NULL;
    state->dcas_case_target = NULL;
    state->dcas_case_count = NULL;
    state->clbl_ecas_target = NULL;
    state->symbol_def_pos = NULL;
    state->def_clos_target = NULL;

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
                /* Structural/bookkeeping markers; no runtime effect on
                 * their own. DTST/LBL just open a bookkeeping label --
                 * the real work happens in CTST/ETST/BRA/FBRA below. */
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
                /* Direct symbol-table form only (class-8/SINT.md); the
                 * OFFSET-addressed element-by-element form (ARRAY/MATRIX/
                 * VECTOR of SCALAR) isn't implemented -- no fixture needs
                 * it yet (containers so far are only ever assigned at
                 * runtime, never INITIAL()'d). */
                if (ins->operand_count != 2) { fail(state, "SINT: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "SINT: OFFSET-addressed form not yet implemented"); break; }
                state->syt[ins->operands[0].data].type = SYT_TYPE_SCALAR;
                state->syt[ins->operands[0].data].scalar = rv_to_scalar(&a);
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
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }

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

            case OP_XXST:
                /* General bracketed-argument-list start: I/O (IMD kind
                 * code) or a function/procedure call (SYT callee) --
                 * see class-0/XXST.md. */
                if (ins->operand_count != 1) { fail(state, "XXST: expected 1 operand"); break; }
                state->io_pending.active = true;
                state->io_pending.item_count = 0;
                if (ins->operands[0].qual == QUAL_SYT) {
                    state->io_pending.is_call = true;
                    state->io_pending.call_target = ins->operands[0].data;
                } else {
                    if (!resolve_operand(state, &ins->operands[0], &a)) break;
                    state->io_pending.is_call = false;
                    state->io_pending.kind = rv_to_integer(&a);
                }
                break;

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
                state->io_pending.active = false;
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

            case OP_RTRN: {
                /* Two forms (class-0/RTRN.md): 1 operand = function
                 * return value (result flows back via the FCAL's own VAC
                 * slot); 0 operands = procedure/task return (no value --
                 * used by PCAL-initiated calls, which have no VAC result
                 * to write). */
                if (ins->operand_count > 1) { fail(state, "RTRN: expected 0 or 1 operands"); break; }
                if (state->call_return_sp <= 0) { fail(state, "RTRN with no active call"); break; }
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
                    /* A scheduled task's body fell through to its own
                     * end without an explicit TERMINATE -- implicit
                     * self-termination (class-0/RTRN.md's "every
                     * subprogram body is terminated regardless" note,
                     * TASK analog). Ends this task only, not the whole
                     * program -- the scheduler picks the next READY task. */
                    halmat_task_t *cur = &state->tasks[state->current_task];
                    cur->task_state = TASK_TERMINATED;
                    if (cur->symbol < HALMAT_SYT_MAX) state->symbol_active_task[cur->symbol] = -1;
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
                /* Only the immediate-initiation form (PRIORITY/DEPENDENT
                 * only) is implemented; delayed (AT/IN/ON) and cyclic
                 * (REPEAT EVERY/AFTER, WHILE/UNTIL) forms fail loudly
                 * rather than misbehaving -- see class-0/SCHD.md's
                 * confirmed tag bitmask. */
                if (ins->operand_count < 1 || ins->operands[0].qual != QUAL_SYT) {
                    fail(state, "SCHD: expected task symbol as first operand");
                    break;
                }
                uint16_t task_sym = ins->operands[0].data;
                if (task_sym >= HALMAT_SYT_MAX || state->symbol_def_pos[task_sym] == NO_TARGET) {
                    fail(state, "SCHEDULE of undefined task (symbol %u)", task_sym);
                    break;
                }
                if (ins->tag & ~(uint8_t)0x0C) { /* anything beyond PRIORITY(4)|DEPENDENT(8) */
                    fail(state, "SCHEDULE: only the immediate PRIORITY/DEPENDENT form is implemented (tag 0x%X)", ins->tag);
                    break;
                }
                int priority = 50; /* default when no PRIORITY(...) clause; matches the primal's own default, but untested -- no primary-source confirmation for this specific case */
                bool dependent = (ins->tag & 0x8) != 0;
                uint8_t operand_idx = 1;
                if (ins->tag & 0x4) { /* PRIORITY(...) present */
                    if (operand_idx >= ins->operand_count) { fail(state, "SCHD: missing PRIORITY operand"); break; }
                    if (!resolve_operand(state, &ins->operands[operand_idx], &a)) break;
                    priority = rv_to_integer(&a);
                }
                if (priority <= 0 || priority >= 255) {
                    fail(state, "SCHEDULE priority %d out of range 0<P<255 (USA003087 Sec. 13.1-13.3)", priority);
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
                state->tasks[idx].in_use = true;
                state->tasks[idx].is_primal = false;
                state->tasks[idx].symbol = task_sym;
                state->tasks[idx].priority = priority;
                state->tasks[idx].task_state = TASK_READY;
                state->tasks[idx].saved_pc = state->symbol_def_pos[task_sym] + 1;
                state->tasks[idx].dependent = dependent;
                state->symbol_active_task[task_sym] = idx;
                /* No branch here -- SCHD only adds the task to the pool;
                 * the scheduler loop in interp_run naturally picks it up
                 * next if its priority is higher than whatever is
                 * currently executing (immediate preemption), or lets
                 * the current flow continue otherwise. */
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
                int32_t ticks = rv_to_integer(&a); /* WAIT's duration treated as tick count -- see state.h's scheduler comment on the tick/second calibration */
                if (ticks < 0) ticks = 0;
                halmat_task_t *cur = &state->tasks[state->current_task];
                cur->task_state = TASK_WAITING;
                cur->wake_deadline = state->virtual_time + ticks;
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

/* Runs the scheduler for exactly one instruction (picks the
 * highest-priority TASK_READY task, executes one instruction for it,
 * advances the virtual clock). Returns true once nothing is left to run
 * (halted, or no task is READY/ever going to wake). Exposed for
 * --debugger's step command; interp_run() is just this called in a loop. */
bool interp_step(halmat_state_t *state, FILE *out) {
    if (state->halted) return true;

    sched_wake_waiting(state);
    int next = sched_pick_next(state);
    if (next == -1) return true; /* nothing left ready (and nothing left to ever wake) */

    state->current_task = next;
    state->pc = state->tasks[next].saved_pc;

    if (state->pc >= state->prog->count) {
        fail(state, "instruction stream ended without a CLOS");
        return true;
    }

    exec_one(state, out);

    state->tasks[next].saved_pc = state->pc;
    /* sched_advance seam: 1 tick per HALMAT instruction executed (the
     * user's confirmed per-instruction granularity choice) -- see
     * state.h's scheduler field comments for what a future --time-scale
     * option would multiply here. */
    state->virtual_time++;

    return state->halted;
}

int interp_run(halmat_state_t *state, FILE *out) {
    while (!interp_step(state, out)) {
        /* keep going */
    }
    return state->exit_code;
}

const halmat_instr_t *interp_peek_next(halmat_state_t *state) {
    if (state->halted) return NULL;
    sched_wake_waiting(state);
    int next = sched_pick_next(state);
    if (next == -1) return NULL;
    if (state->tasks[next].saved_pc >= state->prog->count) return NULL;
    return &state->prog->instrs[state->tasks[next].saved_pc];
}
