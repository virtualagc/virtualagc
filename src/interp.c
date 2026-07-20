#include "interp.h"

#include <math.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#include "opcode_table.h"

/* Combined 12-bit class:opcode values for the instructions implemented so
 * far (M4 step 2, targeting the out_simple_do fixture). Extended
 * opcode-by-opcode as later fixtures require -- see Plan.md M4. */
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
#define OP_WRIT 0x021
#define OP_XXST 0x025
#define OP_XXND 0x026
#define OP_XXAR 0x027
#define OP_MDEF 0x02B
#define OP_CLOS 0x030
#define OP_EDCL 0x031
#define OP_IASN 0x601
#define OP_INEQ 0x7C5
#define OP_IEQU 0x7C6
#define OP_INGT 0x7C7
#define OP_IGT 0x7C8
#define OP_INLT 0x7C9
#define OP_ILT 0x7CA
#define OP_IADD 0x6CB
#define OP_ISUB 0x6CC
#define OP_IINT 0x8C1

#define NO_TARGET ((size_t)-1)

typedef struct {
    bool is_string;
    char *string;   /* borrowed */
    int32_t integer;
} resolved_value_t;

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

static bool resolve_operand(halmat_state_t *state, const halmat_operand_t *op, resolved_value_t *out) {
    memset(out, 0, sizeof(*out));
    switch (op->qual) {
        case QUAL_SYT:
            if (op->data >= HALMAT_SYT_MAX) {
                fail(state, "SYT index %u out of range", op->data);
                return false;
            }
            out->is_string = false;
            out->integer = state->syt[op->data].value;
            return true;
        case QUAL_LIT: {
            if (!state->literals || op->data >= state->literals->count) {
                fail(state, "literal index %u out of range", op->data);
                return false;
            }
            const halmat_literal_t *lit = &state->literals->entries[op->data];
            if (lit->type == LIT_STRING) {
                out->is_string = true;
                out->string = lit->string;
            } else if (lit->type == LIT_FIXED || lit->type == LIT_DOUBLE) {
                out->is_string = false;
                out->integer = (int32_t)lround(lit->numeric);
            } else {
                fail(state, "literal index %u has an unsupported type (%d) for this context",
                     op->data, (int)lit->type);
                return false;
            }
            return true;
        }
        case QUAL_IMD:
            out->is_string = false;
            out->integer = (int32_t)(int16_t)op->data; /* IMD is a signed 16-bit immediate */
            return true;
        case QUAL_VAC:
            if (op->data >= HALMAT_VAC_MAX) {
                fail(state, "VAC index %u out of range", op->data);
                return false;
            }
            out->is_string = false;
            out->integer = state->vac[op->data];
            return true;
        default:
            fail(state, "operand qualifier %s not yet implemented in this context", halmat_qual_name(op->qual));
            return false;
    }
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
 * loop body, then the matching EFOR. Range-form DO FOR (DFOR with 4+
 * operands) isn't implemented yet -- efor_is_list_form stays false for
 * it, and EFOR fails loudly rather than misbehaving silently. */
#define FOR_STACK_MAX 64

static void precompute_for_loops(halmat_state_t *state) {
    size_t n = state->prog->count;
    state->afor_body_target = malloc(n * sizeof(size_t));
    state->afor_return_target = malloc(n * sizeof(size_t));
    state->afor_control_var = calloc(n, sizeof(uint16_t));
    state->efor_is_list_form = calloc(n, sizeof(bool));
    for (size_t i = 0; i < n; i++) {
        state->afor_body_target[i] = NO_TARGET;
        state->afor_return_target[i] = NO_TARGET;
    }

    struct {
        bool is_list;
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
}

void interp_cleanup(halmat_state_t *state) {
    free(state->ctst_exit_target);
    free(state->etst_back_target);
    free(state->label_pos);
    free(state->afor_body_target);
    free(state->afor_return_target);
    free(state->afor_control_var);
    free(state->efor_is_list_form);
    free(state->dcas_case_target);
    free(state->dcas_case_count);
    free(state->clbl_ecas_target);
    state->ctst_exit_target = NULL;
    state->etst_back_target = NULL;
    state->label_pos = NULL;
    state->afor_body_target = NULL;
    state->afor_return_target = NULL;
    state->afor_control_var = NULL;
    state->efor_is_list_form = NULL;
    state->dcas_case_target = NULL;
    state->dcas_case_count = NULL;
    state->clbl_ecas_target = NULL;
}

static void flush_write(halmat_state_t *state, FILE *out) {
    for (uint8_t i = 0; i < state->io_pending.item_count; i++) {
        if (i > 0) {
            for (int b = 0; b < state->num_blanks; b++) fputc(' ', out);
        }
        if (state->io_pending.items[i].is_string) {
            fputs(state->io_pending.items[i].string, out);
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

int interp_run(halmat_state_t *state, FILE *out) {
    while (!state->halted && state->pc < state->prog->count) {
        const halmat_instr_t *ins = &state->prog->instrs[state->pc];
        resolved_value_t a, b;
        bool branched = false;

        switch (ins->opcode) {
            case OP_PXRC:
            case OP_XREC:
            case OP_SMRK:
            case OP_MDEF:
            case OP_EDCL:
            case OP_DSMP:
            case OP_ESMP:
            case OP_DTST:
            case OP_IFHD:
            case OP_LBL:
            case OP_DFOR:
                /* Structural/bookkeeping markers; no runtime effect on
                 * their own. DTST/LBL just open a bookkeeping label --
                 * the real work happens in CTST/ETST/BRA/FBRA below. */
                break;

            case OP_BRA:
            case OP_FBRA: {
                if (ins->opcode == OP_FBRA) {
                    if (ins->operand_count != 2) { fail(state, "FBRA: expected 2 operands"); break; }
                    if (!resolve_operand(state, &ins->operands[1], &a)) break;
                    if (a.integer != 0) break; /* condition true: fall through, no branch */
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

            case OP_INEQ:
            case OP_IEQU:
            case OP_INGT:
            case OP_IGT:
            case OP_INLT:
            case OP_ILT: {
                if (ins->operand_count != 2) { fail(state, "integer comparison: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                bool result;
                switch (ins->opcode) {
                    case OP_INEQ: result = a.integer != b.integer; break;
                    case OP_IEQU: result = a.integer == b.integer; break;
                    case OP_INGT: result = a.integer <= b.integer; break;
                    case OP_IGT: result = a.integer > b.integer; break;
                    case OP_INLT: result = a.integer >= b.integer; break;
                    case OP_ILT: default: result = a.integer < b.integer; break;
                }
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index] = result ? 1 : 0;
                break;
            }

            case OP_CTST: {
                if (ins->operand_count != 1) { fail(state, "CTST: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                bool cond_true = (a.integer != 0);
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
                state->syt[state->afor_control_var[state->pc]].value = a.integer;
                if (state->for_return_sp >= 64) { fail(state, "DO FOR nesting too deep"); break; }
                state->for_return_stack[state->for_return_sp++] = state->afor_return_target[state->pc];
                state->pc = state->afor_body_target[state->pc];
                branched = true;
                break;
            }

            case OP_EFOR: {
                if (!state->efor_is_list_form[state->pc]) {
                    fail(state, "range-form DO FOR not yet implemented");
                    break;
                }
                if (state->for_return_sp <= 0) { fail(state, "EFOR with no matching AFOR dispatch"); break; }
                state->pc = state->for_return_stack[--state->for_return_sp];
                branched = true;
                break;
            }

            case OP_DCAS: {
                if (ins->operand_count != 2) { fail(state, "DCAS: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                size_t count = state->dcas_case_count[state->pc];
                if (a.integer < 1 || (size_t)a.integer > count) {
                    fail(state, "DO CASE selector %d out of range 1..%zu (out-of-range/ELSE handling not yet implemented)",
                         a.integer, count);
                    break;
                }
                state->pc = state->dcas_case_target[state->pc * HALMAT_MAX_CASES + (a.integer - 1)];
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

            case OP_IINT:
                if (ins->operand_count != 2) { fail(state, "IINT: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[1], &a)) break;
                if (ins->operands[0].qual != QUAL_SYT) { fail(state, "IINT: destination must be SYT"); break; }
                state->syt[ins->operands[0].data].type = SYT_TYPE_INTEGER;
                state->syt[ins->operands[0].data].value = a.integer;
                break;

            case OP_IADD:
            case OP_ISUB:
                if (ins->operand_count != 2) { fail(state, "IADD/ISUB: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (!resolve_operand(state, &ins->operands[1], &b)) break;
                if (ins->index >= HALMAT_VAC_MAX) { fail(state, "VAC index out of range"); break; }
                state->vac[ins->index] = (ins->opcode == OP_IADD) ? (a.integer + b.integer) : (a.integer - b.integer);
                break;

            case OP_IASN:
                if (ins->operand_count != 2) { fail(state, "IASN: expected 2 operands"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (ins->operands[1].qual != QUAL_SYT) { fail(state, "IASN: destination must be SYT"); break; }
                state->syt[ins->operands[1].data].type = SYT_TYPE_INTEGER;
                state->syt[ins->operands[1].data].value = a.integer;
                break;

            case OP_XXST:
                if (ins->operand_count != 1) { fail(state, "XXST: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                state->io_pending.active = true;
                state->io_pending.kind = a.integer;
                state->io_pending.item_count = 0;
                break;

            case OP_XXAR:
                if (!state->io_pending.active) { fail(state, "XXAR outside of an XXST...XXND block"); break; }
                if (ins->operand_count != 1) { fail(state, "XXAR: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                if (state->io_pending.item_count >= HALMAT_MAX_OPERANDS) {
                    fail(state, "WRITE statement has too many items");
                    break;
                }
                state->io_pending.items[state->io_pending.item_count].is_string = a.is_string;
                state->io_pending.items[state->io_pending.item_count].string = a.string;
                state->io_pending.items[state->io_pending.item_count].integer = a.integer;
                state->io_pending.item_count++;
                break;

            case OP_WRIT:
                if (!state->io_pending.active) { fail(state, "WRIT outside of an XXST...XXND block"); break; }
                if (ins->operand_count != 1) { fail(state, "WRIT: expected 1 operand"); break; }
                if (!resolve_operand(state, &ins->operands[0], &a)) break;
                /* a.integer is the device number; device-to-file mapping
                 * (--ddo) is out of scope for this milestone, everything
                 * goes to `out` (stdout by default from main.c). */
                flush_write(state, out);
                break;

            case OP_XXND:
                state->io_pending.active = false;
                break;

            case OP_CLOS:
                state->halted = true;
                state->exit_code = 0;
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

    if (state->pc >= state->prog->count && !state->halted) {
        fail(state, "instruction stream ended without a CLOS");
    }

    return state->exit_code;
}
