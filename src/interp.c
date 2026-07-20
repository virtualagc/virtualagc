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
#define OP_READ 0x01F
#define OP_WRIT 0x021
#define OP_XXST 0x025
#define OP_XXND 0x026
#define OP_XXAR 0x027
#define OP_TDEF 0x02A
#define OP_MDEF 0x02B
#define OP_CDEF 0x02F
#define OP_FDEF 0x02C
#define OP_WAIT 0x034
#define OP_SGNL 0x035
#define OP_CANC 0x036
#define OP_TERM 0x037
#define OP_PRIO 0x038
#define OP_SCHD 0x039
#define OP_CLOS 0x030
#define OP_EDCL 0x031
#define OP_RTRN 0x032
#define OP_FCAL 0x01E
#define OP_IASN 0x601
#define OP_SASN 0x501
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
#define OP_SNEG 0x5B0
#define OP_ITOS 0x5C1
#define OP_STOI 0x6A1
#define OP_IINT 0x8C1
#define OP_SINT 0x8A1
#define OP_CINT 0x841

#define NO_TARGET ((size_t)-1)

typedef enum { RV_STRING, RV_INTEGER, RV_SCALAR } rv_kind_t;

typedef struct {
    rv_kind_t kind;
    char *string;   /* RV_STRING; borrowed from the literal table */
    int32_t integer; /* RV_INTEGER */
    halmat_scalar_t scalar; /* RV_SCALAR */
} resolved_value_t;

static int32_t rv_to_integer(const resolved_value_t *v) {
    if (v->kind == RV_SCALAR) return halmat_scalar_to_integer(v->scalar);
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
                    : (val->kind == RV_SCALAR) ? SYT_TYPE_SCALAR : SYT_TYPE_INTEGER;
        }
        if (e->type == SYT_TYPE_CHARACTER) {
            if (val->kind != RV_STRING) {
                fail(state, "cannot assign a non-CHARACTER value to a CHARACTER destination");
                return false;
            }
            free(e->char_value);
            e->char_value = dup_string(val->string);
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
        if ((ins->opcode == OP_FDEF || ins->opcode == OP_TDEF) && ins->operand_count == 1) {
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
                 * Multi-index (MATRIX) flattening uses a placeholder
                 * stride since real per-dimension extents aren't visible
                 * without symbol-table parsing (see HALMAT_CONTAINER_
                 * CAPACITY's comment in state.h) -- unobserved by any
                 * current fixture (no printed output touches array/
                 * matrix element values or addresses). */
                if (ins->operand_count < 2) { fail(state, "DSUB: expected at least 2 operands"); break; }
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "DSUB: reference must be SYT"); break; }
                uint16_t base_syt = ins->operands[0].data;
                if (base_syt >= HALMAT_SYT_MAX) { fail(state, "DSUB: SYT index out of range"); break; }
                halmat_syt_entry_t *base = &state->syt[base_syt];
                if (!base->elements) {
                    base->elements = calloc(HALMAT_CONTAINER_CAPACITY, sizeof(halmat_scalar_t));
                    base->element_count = HALMAT_CONTAINER_CAPACITY;
                }

                bool ok = true;
                size_t offset = 0;
                uint8_t num_indices = ins->operand_count - 1;
                for (uint8_t i = 0; i < num_indices; i++) {
                    resolved_value_t idx;
                    if (!resolve_operand(state, &ins->operands[1 + i], &idx)) { ok = false; break; }
                    int32_t idx_val = rv_to_integer(&idx) - 1; /* HAL/S is 1-indexed */
                    if (idx_val < 0) idx_val = 0;
                    offset = offset * 16 + (size_t)idx_val; /* placeholder stride per extra dimension */
                }
                if (!ok) break;
                offset %= base->element_count;

                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index].is_ref = true;
                state->vac[ins->index].ref_syt = base_syt;
                state->vac[ins->index].ref_offset = offset;
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
                     * LINE/PAGE); TAG1 outside {5=SCALAR,6=INTEGER} means
                     * a type this interpreter doesn't store yet (BIT/
                     * CHARACTER/MATRIX/VECTOR/structure) -- both fail
                     * loudly rather than misbehave, no fixture needs them
                     * yet. */
                    if (ins->operands[0].tag2 != 0) {
                        fail(state, "READ: I/O control specifiers (TAB/COLUMN/SKIP/LINE/PAGE) not yet implemented");
                        break;
                    }
                    uint8_t cls = ins->operands[0].tag1;
                    if (cls != 5 && cls != 6) {
                        fail(state, "READ: only SCALAR/INTEGER arguments are implemented (got HALMAT class %u)", cls);
                        break;
                    }
                    state->io_pending.items[state->io_pending.item_count].dest_operand = ins->operands[0];
                    state->io_pending.items[state->io_pending.item_count].dest_class = cls;
                    state->io_pending.item_count++;
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

            case OP_READ: {
                if (!state->io_pending.active) { fail(state, "READ outside of an XXST...XXND block"); break; }
                if (ins->operand_count != 1) { fail(state, "READ: expected 1 operand"); break; }
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
            case OP_TDEF: {
                /* Only ever reached by ordinary fall-through -- FCAL/SCHD
                 * jump straight to def_pos+1, past this instruction (see
                 * precompute_subprograms). Skip the whole definition;
                 * it's entered only via an explicit call/schedule. */
                size_t target = state->def_clos_target[state->pc];
                if (target == NO_TARGET) { fail(state, "FDEF/TDEF has no matching CLOS"); break; }
                state->pc = target;
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
                if (ins->operand_count != 1) { fail(state, "RTRN: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (state->call_return_sp <= 0) { fail(state, "RTRN with no active call"); break; }
                size_t fcal_pos = state->call_return_stack[--state->call_return_sp];
                size_t vac_index = state->prog->instrs[fcal_pos].index;
                if (vac_index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[vac_index].is_ref = false;
                state->vac[vac_index].integer = rv_to_integer(&a);
                state->pc = fcal_pos + 1;
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
