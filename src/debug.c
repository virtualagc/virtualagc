#include "debug.h"

#include <stdlib.h>
#include <string.h>

#include "disasm.h"
#include "value.h"

#define OP_SMRK_CONST 0x004
#define MAX_BREAKPOINTS 64

typedef struct {
    size_t word_index[MAX_BREAKPOINTS];
    int count;
} breakpoints_t;

static bool is_breakpoint(const breakpoints_t *bp, size_t word_index) {
    for (int i = 0; i < bp->count; i++) {
        if (bp->word_index[i] == word_index) return true;
    }
    return false;
}

static bool find_word_index_for_stmt(const halmat_program_t *prog, long stmt, size_t *out) {
    for (size_t i = 0; i < prog->count; i++) {
        const halmat_instr_t *ins = &prog->instrs[i];
        if (ins->opcode == OP_SMRK_CONST && ins->operand_count == 1 && ins->operands[0].data == (uint16_t)stmt) {
            *out = ins->index;
            return true;
        }
    }
    return false;
}

static const halmat_instr_t *find_instr_by_word_index(const halmat_program_t *prog, size_t word_index) {
    for (size_t i = 0; i < prog->count; i++) {
        if (prog->instrs[i].index == word_index) return &prog->instrs[i];
    }
    return NULL;
}

static void print_current(halmat_state_t *state, FILE *out) {
    const halmat_instr_t *ins = interp_peek_next(state);
    if (!ins) {
        fprintf(out, "(program has ended)\n");
        return;
    }
    /* interp_peek_next() doesn't expose which task it picked without a
     * step actually happening, so state->current_task here is only
     * accurate right after a step -- a reasonable approximation before
     * the first one (still shows the primal task, task 0). */
    fprintf(out, "[task %d] ", state->current_task);
    halmat_disasm_instr(ins, out);
}

static void print_symbol(halmat_state_t *state, const halmat_symtab_t *symtab, const char *name, FILE *out) {
    if (!symtab) {
        fprintf(out, "no symbol table loaded (auto-discovered COMMON*.out not found)\n");
        return;
    }
    const halmat_symtab_entry_t *sym = halmat_symtab_find(symtab, name);
    if (!sym) {
        fprintf(out, "no such symbol '%s'\n", name);
        return;
    }
    if (sym->index >= HALMAT_SYT_MAX) {
        fprintf(out, "%s: SYT index out of range\n", name);
        return;
    }
    const halmat_syt_entry_t *e = &state->syt[sym->index];
    switch (e->type) {
        case SYT_TYPE_INTEGER:
            fprintf(out, "%s = %d (INTEGER, SYT %zu)\n", name, e->value, sym->index);
            break;
        case SYT_TYPE_SCALAR:
            fprintf(out, "%s = %g (SCALAR, SYT %zu)\n", name, halmat_scalar_to_double(e->scalar), sym->index);
            break;
        default:
            fprintf(out, "%s = <unset> (SYT %zu)\n", name, sym->index);
            break;
    }
}

static void print_backtrace(halmat_state_t *state, FILE *out) {
    if (state->call_return_sp <= 0) {
        fprintf(out, "(no active function calls)\n");
        return;
    }
    for (int i = state->call_return_sp - 1; i >= 0; i--) {
        size_t fcal_pos = state->call_return_stack[i];
        const halmat_instr_t *ins = &state->prog->instrs[fcal_pos];
        fprintf(out, "#%d  FCAL at word #%zu", state->call_return_sp - 1 - i, ins->index);
        if (ins->operand_count >= 1) fprintf(out, " (callee SYT %u)", ins->operands[0].data);
        fprintf(out, "\n");
    }
}

static void print_help(FILE *out) {
    fprintf(out,
            "break ADDR      set a breakpoint at HALMAT word index ADDR (as shown by --disasm)\n"
            "break :STMT     set a breakpoint at HAL/S statement number STMT\n"
            "step, s         execute one HALMAT instruction\n"
            "continue, c     run until a breakpoint or the program ends\n"
            "print NAME, p   show a variable's current value (needs an auto-discovered symbol table)\n"
            "backtrace, bt   show the active function-call stack\n"
            "help, h         this message\n"
            "quit, q         stop debugging (does not finish running the program)\n");
}

int debug_run(halmat_state_t *state, const halmat_symtab_t *symtab, FILE *out) {
    breakpoints_t bp = {0};
    char line[256];

    fprintf(out, "yaHALMAT2 debugger. Type 'help' for commands.\n");
    print_current(state, out);

    for (;;) {
        fprintf(out, "(halmat) ");
        fflush(out);
        if (!fgets(line, sizeof(line), stdin)) {
            fprintf(out, "\n");
            return state->exit_code;
        }
        size_t len = strlen(line);
        while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r')) line[--len] = '\0';

        char *cmd = strtok(line, " \t");
        if (!cmd) continue;
        char *arg = strtok(NULL, " \t");

        if (strcmp(cmd, "quit") == 0 || strcmp(cmd, "q") == 0) {
            return state->exit_code;
        } else if (strcmp(cmd, "help") == 0 || strcmp(cmd, "h") == 0) {
            print_help(out);
        } else if (strcmp(cmd, "break") == 0 || strcmp(cmd, "b") == 0) {
            if (!arg) {
                fprintf(out, "usage: break ADDR | break :STMT\n");
                continue;
            }
            size_t target;
            bool ok;
            if (arg[0] == ':') {
                ok = find_word_index_for_stmt(state->prog, strtol(arg + 1, NULL, 10), &target);
                if (!ok) fprintf(out, "no SMRK found for statement %s\n", arg + 1);
            } else {
                target = (size_t)strtoul(arg, NULL, 0);
                ok = (find_instr_by_word_index(state->prog, target) != NULL);
                if (!ok) fprintf(out, "no instruction at word index %s\n", arg);
            }
            if (ok) {
                if (bp.count >= MAX_BREAKPOINTS) {
                    fprintf(out, "too many breakpoints\n");
                } else {
                    bp.word_index[bp.count++] = target;
                    fprintf(out, "breakpoint at word #%zu\n", target);
                }
            }
        } else if (strcmp(cmd, "step") == 0 || strcmp(cmd, "s") == 0) {
            bool done = interp_step(state, out);
            print_current(state, out);
            if (done) fprintf(out, "(program has ended, exit code %d)\n", state->exit_code);
        } else if (strcmp(cmd, "continue") == 0 || strcmp(cmd, "c") == 0) {
            bool done = false;
            bool hit_bp = false;
            for (;;) {
                const halmat_instr_t *next = interp_peek_next(state);
                if (next && bp.count > 0 && is_breakpoint(&bp, next->index)) {
                    hit_bp = true;
                    break;
                }
                done = interp_step(state, out);
                if (done) break;
            }
            print_current(state, out);
            if (hit_bp) fprintf(out, "breakpoint hit\n");
            if (done) fprintf(out, "(program has ended, exit code %d)\n", state->exit_code);
        } else if (strcmp(cmd, "print") == 0 || strcmp(cmd, "p") == 0) {
            if (!arg) {
                fprintf(out, "usage: print NAME\n");
                continue;
            }
            print_symbol(state, symtab, arg, out);
        } else if (strcmp(cmd, "backtrace") == 0 || strcmp(cmd, "bt") == 0) {
            print_backtrace(state, out);
        } else {
            fprintf(out, "unrecognized command '%s' (type 'help')\n", cmd);
        }
    }
}
