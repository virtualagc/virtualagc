#include "debug.h"

#include <signal.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#include "disasm.h"
#include "value.h"

/* strcasecmp is POSIX (declared in strings.h, not string.h), not ISO
 * C99 -- MSVC (Plan.md's cross-platform build target) has _stricmp
 * instead. Same portability pattern already used elsewhere in this
 * project for strdup (interp.c). */
#ifdef _MSC_VER
#define halmat_strcasecmp _stricmp
#else
#include <strings.h>
#define halmat_strcasecmp strcasecmp
#endif

#define OP_SMRK_CONST 0x004
#define MAX_BREAKPOINTS 64

typedef struct {
    size_t word_index[MAX_BREAKPOINTS];
    int id[MAX_BREAKPOINTS]; /* stable numbering, gdb-style -- not reused/renumbered on delete */
    int count;
    int next_id;
} breakpoints_t;

/* Set by the SIGINT handler during `continue`/`run`, checked once per
 * loop iteration to return to the prompt instead of the process dying.
 * volatile sig_atomic_t is the only type C guarantees is safe to touch
 * from a signal handler. Not part of halmat_state_t -- this is REPL
 * control flow, not interpreter state. */
static volatile sig_atomic_t g_interrupted = 0;

static void on_sigint(int sig) {
    (void)sig;
    g_interrupted = 1;
}

bool debug_color_by_name(const char *name, int *out) {
    static const struct { const char *name; int code; } table[] = {
        {"black", 30}, {"red", 31}, {"green", 32}, {"yellow", 33},
        {"blue", 34}, {"magenta", 35}, {"cyan", 36}, {"white", 37},
        {"brown", 33}, /* no true brown in the base 8-color ANSI palette */
    };
    for (size_t i = 0; i < sizeof(table) / sizeof(table[0]); i++) {
        if (halmat_strcasecmp(name, table[i].name) == 0) {
            *out = table[i].code;
            return true;
        }
    }
    return false;
}

/* Wraps `text` in `code`'s SGR escape (and a reset) if colors are
 * enabled and code >= 0; otherwise prints it plain. Every debugger
 * output site funnels through one of these rather than raw fprintf, so
 * enabling/disabling color is a single flag, not scattered branches. */
static void cprintf(const debug_colors_t *colors, int code, FILE *out, const char *fmt, ...) {
    bool use_color = colors && colors->enabled && code >= 0;
    if (use_color) fprintf(out, "\033[%dm", code);
    va_list ap;
    va_start(ap, fmt);
    vfprintf(out, fmt, ap);
    va_end(ap);
    if (use_color) fprintf(out, "\033[0m");
}

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

/* Shown only when `stmt` differs from *last_shown (updated here) --
 * repeated instructions belonging to the same HAL/S statement (the
 * common case; most statements compile to several HALMAT instructions)
 * no longer reprint the same source line on every step. *last_shown
 * starts at a sentinel no real statement number can equal (state.h's
 * interp_current_stmt_for_next() never returns less than -1). */
static void print_source(const halmat_srcmap_t *srcmap, long stmt, long *last_shown,
                          const debug_colors_t *colors, FILE *out) {
    if (!srcmap || stmt < 0 || stmt == *last_shown) return;
    *last_shown = stmt;
    size_t n;
    const halmat_srcmap_line_t *l = halmat_srcmap_find(srcmap, stmt, &n);
    if (!l) return;
    for (size_t i = 0; i < n; i++) {
        cprintf(colors, colors ? colors->stmt_code : -1, out, "%4ld\t%s\n", l[i].stmt, l[i].text);
    }
}

static void print_current(halmat_state_t *state, const halmat_srcmap_t *srcmap, long *last_shown,
                           const debug_colors_t *colors, FILE *out) {
    const halmat_instr_t *ins = interp_peek_next(state);
    if (!ins) {
        cprintf(colors, colors ? colors->other_code : -1, out, "(program has ended)\n");
        return;
    }
    print_source(srcmap, interp_current_stmt_for_next(state), last_shown, colors, out);
    /* interp_peek_next() doesn't expose which task it picked without a
     * step actually happening, so state->current_task here is only
     * accurate right after a step -- a reasonable approximation before
     * the first one (still shows the primal task, task 0). */
    int oc = colors ? colors->other_code : -1;
    bool use_color = colors && colors->enabled && oc >= 0;
    /* halmat_disasm_instr formats its (possibly multi-line) output
     * straight to a FILE*, so the color span has to bracket the whole
     * call manually rather than going through cprintf's single-fmt-call
     * shape. */
    if (use_color) fprintf(out, "\033[%dm", oc);
    fprintf(out, "[task %d] ", state->current_task);
    halmat_disasm_instr(ins, out);
    if (use_color) fprintf(out, "\033[0m");
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

/* `x syt N` -- same value formatting as print_symbol, but by raw SYT
 * index rather than a name looked up through the symbol table (useful
 * with no symtab loaded, or to inspect a slot directly). Covers every
 * halmat_syt_type_t, unlike print_symbol's INTEGER/SCALAR-only switch,
 * since this is meant as the more complete low-level inspection tool. */
static void examine_syt(halmat_state_t *state, uint16_t index, FILE *out) {
    if (index >= HALMAT_SYT_MAX) {
        fprintf(out, "SYT %u: out of range (max %d)\n", index, HALMAT_SYT_MAX - 1);
        return;
    }
    const halmat_syt_entry_t *e = &state->syt[index];
    switch (e->type) {
        case SYT_TYPE_INTEGER:
            fprintf(out, "syt[%u] = %d (INTEGER)\n", index, e->value);
            break;
        case SYT_TYPE_SCALAR:
            fprintf(out, "syt[%u] = %g (SCALAR)\n", index, halmat_scalar_to_double(e->scalar));
            break;
        case SYT_TYPE_CHARACTER:
            fprintf(out, "syt[%u] = '%s' (CHARACTER)\n", index, e->char_value ? e->char_value : "");
            break;
        case SYT_TYPE_BIT:
            fprintf(out, "syt[%u] = 0x%08X (BIT)\n", index, e->bit_value);
            break;
        case SYT_TYPE_NAME:
            if (e->name_target == HALMAT_NAME_NULL) {
                fprintf(out, "syt[%u] = NULL (NAME)\n", index);
            } else {
                fprintf(out, "syt[%u] = -> syt[%u] (NAME)\n", index, e->name_target);
            }
            break;
        default:
            fprintf(out, "syt[%u] = <unset>\n", index);
            break;
    }
    if (e->elements) {
        fprintf(out, "  container: %zu element(s)", e->element_count);
        if (e->rows || e->cols) fprintf(out, ", shape %dx%d", e->rows, e->cols);
        fprintf(out, "\n");
    }
}

/* `x vac N` -- VAC slots have no name at all (unlike SYT), so this is
 * the only way to inspect one. Priority order matches the tagged-union
 * precedence documented on halmat_vac_slot_t itself in state.h. */
static void examine_vac(halmat_state_t *state, uint16_t index, FILE *out) {
    if (index >= HALMAT_VAC_MAX) {
        fprintf(out, "VAC %u: out of range (max %d)\n", index, HALMAT_VAC_MAX - 1);
        return;
    }
    const halmat_vac_slot_t *v = &state->vac[index];
    if (v->is_ref) {
        fprintf(out, "vac[%u] = subscript ref -> syt[%u][%zu]\n", index, v->ref_syt, v->ref_offset);
    } else if (v->is_string) {
        fprintf(out, "vac[%u] = '%s' (CHARACTER)\n", index, v->string ? v->string : "");
    } else if (v->is_bits) {
        fprintf(out, "vac[%u] = 0x%08X (BIT)\n", index, v->bits);
    } else if (v->is_container) {
        fprintf(out, "vac[%u] = container, %zu element(s)", index, v->container_count);
        if (v->container_rows || v->container_cols) fprintf(out, ", shape %dx%d", v->container_rows, v->container_cols);
        fprintf(out, "\n");
    } else if (v->is_struct_ref) {
        fprintf(out, "vac[%u] = struct ref, base syt[%u] field syt[%u] copy %d\n",
                index, v->struct_base_syt, v->struct_field_syt, v->struct_copy_index);
    } else if (v->is_copy_ref) {
        fprintf(out, "vac[%u] = TSUB copy ref, base syt[%u] copy %d\n", index, v->copy_ref_base_syt, v->copy_ref_copy_index);
    } else if (v->is_scalar) {
        fprintf(out, "vac[%u] = %g (SCALAR)\n", index, halmat_scalar_to_double(v->scalar));
    } else {
        fprintf(out, "vac[%u] = %d (INTEGER)\n", index, v->integer);
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

static const char *task_state_name(halmat_task_state_t s) {
    switch (s) {
        case TASK_READY: return "READY";
        case TASK_WAITING: return "WAITING";
        case TASK_TERMINATED: return "TERMINATED";
        default: return "?";
    }
}

/* `info tasks` -- the closest meaningful analog to gdb's `info
 * registers` this design has: there's no AP-101S register file modeled
 * at all (deliberately out of scope), but the scheduler's task table
 * is real, inspectable interpreter state. */
static void print_tasks(halmat_state_t *state, FILE *out) {
    fprintf(out, "virtual_time=%lld\n", (long long)state->virtual_time);
    for (int i = 0; i < state->task_count; i++) {
        const halmat_task_t *t = &state->tasks[i];
        if (!t->in_use) continue;
        fprintf(out, "%s task %d: %s priority=%d saved_pc=%zu",
                (i == state->current_task) ? "*" : " ", i, task_state_name(t->task_state), t->priority, t->saved_pc);
        if (t->task_state == TASK_WAITING) fprintf(out, " wake_deadline=%lld", (long long)t->wake_deadline);
        if (t->is_primal) fprintf(out, " (primal)");
        fprintf(out, "\n");
    }
}

static void print_help(FILE *out) {
    fprintf(out,
            "break ADDR      set a breakpoint at HALMAT word index ADDR (as shown by --disasm)\n"
            "break :STMT     set a breakpoint at HAL/S statement number STMT\n"
            "delete [N]      delete breakpoint N, or all breakpoints if N is omitted\n"
            "step, s         execute one HALMAT instruction\n"
            "continue, c     run until a breakpoint or the program ends\n"
            "run, r          same as continue (execution is already loaded/paused, not\n"
            "                restarted -- there is no separate \"not yet started\" state)\n"
            "kill, k         stop execution without exiting the debugger\n"
            "print NAME, p   show a variable's current value by name (needs a symbol table)\n"
            "x syt N         examine SYT slot N directly, by raw index\n"
            "x vac N         examine VAC slot N (intermediate-result cache; no names exist)\n"
            "info tasks      show the scheduler's task table and virtual time\n"
            "backtrace, bt   show the active function-call stack\n"
            "help, h         this message\n"
            "quit, q         stop debugging (does not finish running the program)\n"
            "\n"
            "An empty command repeats the last one. Ctrl-C during continue/run returns\n"
            "to this prompt instead of ending the program.\n");
}

/* Shared by `continue` and `run` (which is currently just an alias --
 * execution is already loaded and paused when the debugger starts, so
 * there's no distinct "not yet started" state for `run` to transition
 * out of; see print_help). Returns once a breakpoint is hit, the
 * program ends, or SIGINT arrives. */
static void run_until_stop(halmat_state_t *state, const breakpoints_t *bp, FILE *out,
                            bool *out_done, bool *out_hit_bp, bool *out_interrupted) {
    *out_done = false;
    *out_hit_bp = false;
    *out_interrupted = false;
    g_interrupted = 0;
    void (*prev_handler)(int) = signal(SIGINT, on_sigint);
    for (;;) {
        if (g_interrupted) {
            *out_interrupted = true;
            break;
        }
        const halmat_instr_t *next = interp_peek_next(state);
        if (next && bp->count > 0 && is_breakpoint(bp, next->index)) {
            *out_hit_bp = true;
            break;
        }
        *out_done = interp_step(state, out);
        if (*out_done) break;
    }
    signal(SIGINT, prev_handler);
}

int debug_run(halmat_state_t *state, const halmat_symtab_t *symtab, const halmat_srcmap_t *srcmap,
              const debug_colors_t *colors, FILE *out) {
    breakpoints_t bp = {0};
    char line[256];
    char last_line[256] = "";
    bool have_last = false;
    long last_stmt_shown = -2; /* sentinel: interp_current_stmt_for_next() never returns less than -1 */

    fprintf(out, "yaHALMAT2 debugger. Type 'help' for commands.\n");
    print_current(state, srcmap, &last_stmt_shown, colors, out);

    for (;;) {
        cprintf(colors, colors ? colors->prompt_code : -1, out, "(halmat) ");
        fflush(out);
        if (!fgets(line, sizeof(line), stdin)) {
            fprintf(out, "\n");
            return state->exit_code;
        }
        size_t len = strlen(line);
        while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r')) line[--len] = '\0';

        /* A blank (or all-whitespace) line repeats the last non-blank
         * command, matching gdb -- most useful for `step`/`continue`.
         * Repeated blank lines keep repeating the same command, not
         * "the previous line" (which would just be blank again). */
        bool blank = true;
        for (size_t i = 0; i < len; i++) {
            if (line[i] != ' ' && line[i] != '\t') { blank = false; break; }
        }
        if (blank) {
            if (!have_last) continue;
            strncpy(line, last_line, sizeof(line) - 1);
            line[sizeof(line) - 1] = '\0';
        } else {
            strncpy(last_line, line, sizeof(last_line) - 1);
            last_line[sizeof(last_line) - 1] = '\0';
            have_last = true;
        }
        /* Echo the command actually acted on -- both for a repeated
         * blank line (so it's clear what ran) and for redirected/logged
         * non-interactive sessions, where the terminal's own echo of
         * what was "typed" wouldn't otherwise appear anywhere. */
        cprintf(colors, colors ? colors->input_code : -1, out, "%s\n", line);

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
                    int id = ++bp.next_id;
                    bp.word_index[bp.count] = target;
                    bp.id[bp.count] = id;
                    bp.count++;
                    fprintf(out, "breakpoint %d at word #%zu\n", id, target);
                }
            }
        } else if (strcmp(cmd, "delete") == 0) {
            if (!arg) {
                bp.count = 0; /* IDs are never reused, so next_id is left alone -- matches gdb */
                fprintf(out, "all breakpoints deleted\n");
            } else {
                int id = atoi(arg);
                int found = -1;
                for (int i = 0; i < bp.count; i++) {
                    if (bp.id[i] == id) { found = i; break; }
                }
                if (found < 0) {
                    fprintf(out, "no breakpoint %d\n", id);
                } else {
                    for (int i = found; i < bp.count - 1; i++) {
                        bp.word_index[i] = bp.word_index[i + 1];
                        bp.id[i] = bp.id[i + 1];
                    }
                    bp.count--;
                    fprintf(out, "breakpoint %d deleted\n", id);
                }
            }
        } else if (strcmp(cmd, "step") == 0 || strcmp(cmd, "s") == 0) {
            bool done = interp_step(state, out);
            print_current(state, srcmap, &last_stmt_shown, colors, out);
            if (done) fprintf(out, "(program has ended, exit code %d)\n", state->exit_code);
        } else if (strcmp(cmd, "continue") == 0 || strcmp(cmd, "c") == 0 ||
                   strcmp(cmd, "run") == 0 || strcmp(cmd, "r") == 0) {
            /* `run` is currently just an alias: the debugger starts
             * already loaded and paused before the first instruction,
             * so there's no distinct "not yet started" state to
             * transition out of -- see print_help. */
            bool done, hit_bp, interrupted;
            run_until_stop(state, &bp, out, &done, &hit_bp, &interrupted);
            print_current(state, srcmap, &last_stmt_shown, colors, out);
            if (interrupted) fprintf(out, "interrupted\n");
            if (hit_bp) fprintf(out, "breakpoint hit\n");
            if (done) fprintf(out, "(program has ended, exit code %d)\n", state->exit_code);
        } else if (strcmp(cmd, "kill") == 0 || strcmp(cmd, "k") == 0) {
            if (state->halted) {
                fprintf(out, "(program has already ended)\n");
            } else {
                state->halted = true;
                fprintf(out, "execution stopped\n");
            }
        } else if (strcmp(cmd, "print") == 0 || strcmp(cmd, "p") == 0) {
            if (!arg) {
                fprintf(out, "usage: print NAME\n");
                continue;
            }
            print_symbol(state, symtab, arg, out);
        } else if (strcmp(cmd, "x") == 0) {
            char *idx_str = strtok(NULL, " \t");
            if (!arg || !idx_str) {
                fprintf(out, "usage: x syt N | x vac N\n");
                continue;
            }
            uint16_t idx = (uint16_t)strtoul(idx_str, NULL, 0);
            if (strcmp(arg, "syt") == 0) {
                examine_syt(state, idx, out);
            } else if (strcmp(arg, "vac") == 0) {
                examine_vac(state, idx, out);
            } else {
                fprintf(out, "usage: x syt N | x vac N\n");
            }
        } else if (strcmp(cmd, "info") == 0) {
            if (arg && strcmp(arg, "tasks") == 0) {
                print_tasks(state, out);
            } else {
                fprintf(out, "usage: info tasks\n");
            }
        } else if (strcmp(cmd, "backtrace") == 0 || strcmp(cmd, "bt") == 0) {
            print_backtrace(state, out);
        } else {
            fprintf(out, "unrecognized command '%s' (type 'help')\n", cmd);
        }
    }
}
