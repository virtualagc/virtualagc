#include "interp.h"

#include <math.h>
#include <stdarg.h>
#include <string.h>

#include "opcode_table.h"

/* Combined 12-bit class:opcode values for the instructions implemented so
 * far (M4 step 2, targeting the out_simple_do fixture). Extended
 * opcode-by-opcode as later fixtures require -- see Plan.md M4. */
#define OP_XREC 0x002
#define OP_SMRK 0x004
#define OP_PXRC 0x005
#define OP_DSMP 0x013
#define OP_ESMP 0x014
#define OP_WRIT 0x021
#define OP_XXST 0x025
#define OP_XXND 0x026
#define OP_XXAR 0x027
#define OP_MDEF 0x02B
#define OP_CLOS 0x030
#define OP_EDCL 0x031
#define OP_IASN 0x601
#define OP_IADD 0x6CB
#define OP_ISUB 0x6CC
#define OP_IINT 0x8C1

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

void interp_init(halmat_state_t *state, const halmat_program_t *prog,
                  const halmat_literal_table_t *literals, int num_blanks) {
    memset(state, 0, sizeof(*state));
    state->prog = prog;
    state->literals = literals;
    state->num_blanks = num_blanks;
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

        switch (ins->opcode) {
            case OP_PXRC:
            case OP_XREC:
            case OP_SMRK:
            case OP_MDEF:
            case OP_EDCL:
            case OP_DSMP:
            case OP_ESMP:
                /* Structural/bookkeeping markers; no runtime effect for a
                 * single straight-line program (see Plan.md M4 step 2). */
                break;

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

        if (!state->halted) {
            state->pc++;
        }
    }

    if (state->pc >= state->prog->count && !state->halted) {
        fail(state, "instruction stream ended without a CLOS");
    }

    return state->exit_code;
}
