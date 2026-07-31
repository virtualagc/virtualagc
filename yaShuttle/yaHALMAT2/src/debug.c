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
/* breakpoints_t, debug_frame_t, MAX_BREAKPOINTS, MAX_DEBUG_FRAMES moved to
 * debug.h (now embedded by value in debugger_state_t there). */

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

static bool is_breakpoint(const breakpoints_t *bp, size_t word_index, const halmat_state_t *owner) {
    for (int i = 0; i < bp->count; i++) {
        if (bp->word_index[i] == word_index && bp->owner[i] == owner) return true;
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
 * interp_current_stmt_for_next() never returns less than -1); it's also
 * reset to that sentinel whenever the active frame changes (push/pop),
 * so a newly active frame's first source line always prints even if its
 * own statement numbering happens to coincide with what was last shown
 * in a different unit. */
static void print_source(const halmat_srcmap_t *srcmap, long stmt, long *last_shown,
                          const debug_colors_t *colors, FILE *out) {
    if (!srcmap || stmt < 0 || stmt == *last_shown) return;
    *last_shown = stmt;
    size_t n;
    const halmat_srcmap_line_t *l = halmat_srcmap_find(srcmap, stmt, &n);
    if (!l) return;
    /* `text` is now the ENTIRE raw pass1.rpt line verbatim (srcmap.c),
     * already starting with its own STMT field -- printing `l[i].stmt`
     * again here would duplicate it, so just print the line as-is. */
    for (size_t i = 0; i < n; i++) {
        cprintf(colors, colors ? colors->stmt_code : -1, out, "%s\n", l[i].text);
    }
}

static void print_current(const debug_frame_t *frame, long *last_shown,
                           const debug_colors_t *colors, FILE *out) {
    const halmat_instr_t *ins = interp_peek_next(frame->state);
    if (!ins) {
        cprintf(colors, colors ? colors->other_code : -1, out, "(program has ended)\n");
        return;
    }
    print_source(frame->have_srcmap ? &frame->srcmap : NULL, interp_current_stmt_for_next(frame->state),
                 last_shown, colors, out);
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
    /* Approximate elapsed HAL/S-real-time for this frame's own unit, via
     * the same HALMAT_TICKS_PER_SECOND calibration interp_run_burst()/
     * interp_run_signal() use for real-time throttling (state.h) --
     * neither pacing implementation is ever active during --debug
     * (debug_run() drives execution via interp_step() directly, never
     * interp_run(), so time spent waiting on debugger input never counts
     * against it), but virtual_time itself is tracked identically either
     * way (interp_step() increments it unconditionally), so this is
     * accurate regardless of --pacing or whether pacing is even running.
     * Per-frame, not per-program: a stepped-into external unit's own
     * virtual_time is its own persistent, cumulative clock across every
     * call ever made to it (run_external_call()'s target persists across
     * calls, interp.c), not reset per-call or relative to the caller's
     * timeline -- consistent with this debugger's existing per-frame
     * design for breakpoints/symtab/etc.
     *
     * `T=%.2f` is virtual_time in microseconds (a fixed-prefix field
     * meant to be easy to grep/parse out of --debug output) -- the
     * earlier `t~%.3fs` seconds-based sibling field was dropped once
     * this one existed, since both derive from the identical
     * HALMAT_TICKS_PER_SECOND calibration and showing both was
     * redundant. `N=%lld` is instr_count (state.h), a plain running
     * count of real HALMAT instructions actually executed in this
     * frame so far -- distinct from virtual_time itself, which is
     * *ticks* (nominally 1 per instruction today, but a separate
     * concept that could diverge if per-opcode timing were ever added;
     * see state.h's own instr_count comment). Same per-frame,
     * never-reset-per-call semantics as virtual_time above.
     *
     * `[%d: %s]` is the SCHEDULE task index (current_task, genuinely
     * distinct from the compilation unit -- each separately-compiled
     * unit has its own entirely separate tasks[] -- so this is real
     * information, not redundant with the unit name) followed by the
     * unit's own declared name. The name comes from SYT index 1 --
     * MDEF ("Program definition header," the second instruction in
     * every compiled unit) always references that exact index, and
     * confirmed empirically (a real compile of HELLO.hal) that its own
     * symbol-table name IS the unit's declared name ("HELLO"). Falls
     * back to just the bracketed task index if no symtab is loaded for
     * this frame (e.g. a --py unit) or index 1 isn't found/named. */
    const char *unit_name = NULL;
    if (frame->symtab) {
        const halmat_symtab_entry_t *e = halmat_symtab_find_by_index(frame->symtab, 1);
        if (e && e->name && e->name[0]) unit_name = e->name;
    }
    if (unit_name) {
        fprintf(out, "N=%lld T=%.2f [%d: %s] ", (long long)frame->state->instr_count,
                frame->state->virtual_time * 1e6 / (double)HALMAT_TICKS_PER_SECOND,
                frame->state->current_task, unit_name);
    } else {
        fprintf(out, "N=%lld T=%.2f [task %d] ", (long long)frame->state->instr_count,
                frame->state->virtual_time * 1e6 / (double)HALMAT_TICKS_PER_SECOND,
                frame->state->current_task);
    }
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
    if (e->elements || e->bit_elements || e->char_elements) {
        const char *kind = e->bit_elements ? "BIT" : e->char_elements ? "CHARACTER" : "SCALAR/INTEGER";
        fprintf(out, "  container: %zu %s element(s)", e->element_count, kind);
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

/* Same-unit call stack (state->call_return_stack) for one frame --
 * factored out of print_backtrace so it can be shown once per debug
 * frame, in nesting order (point 5, Plan.md). */
static void print_frame_call_stack(halmat_state_t *state, FILE *out) {
    for (int i = state->call_return_sp - 1; i >= 0; i--) {
        size_t fcal_pos = state->call_return_stack[i];
        const halmat_instr_t *ins = &state->prog->instrs[fcal_pos];
        fprintf(out, "      #%d  same-unit call at word #%zu", state->call_return_sp - 1 - i, ins->index);
        if (ins->operand_count >= 1) fprintf(out, " (callee SYT %u)", ins->operands[0].data);
        fprintf(out, "\n");
    }
}

/* `backtrace`/`bt` (point 5, Plan.md): shows both kinds of nesting a
 * running program can have -- the debug frame stack itself (cross-unit
 * CALLs the debugger has `step`-ed into) from outermost to innermost,
 * and each frame's own same-unit call_return_stack, in the actual order
 * they occurred. Reasonable, clearly-labeled output rather than an
 * exactly gdb-identical format -- there's no single gdb analog for
 * "which separately-compiled unit is currently executing". */
static void print_backtrace(const debug_frame_t *frames, int frame_count, FILE *out) {
    bool any_calls = false;
    for (int f = 0; f < frame_count; f++) {
        if (frames[f].state->call_return_sp > 0) any_calls = true;
    }
    if (frame_count == 1 && !any_calls) {
        fprintf(out, "(no active function calls)\n");
        return;
    }
    for (int f = 0; f < frame_count; f++) {
        const debug_frame_t *fr = &frames[f];
        if (f == 0) {
            fprintf(out, "frame #0  %s%s(outermost)\n", fr->label[0] ? fr->label : "", fr->label[0] ? "  " : "");
        } else {
            fprintf(out, "frame #%d  %s", f, fr->label[0] ? fr->label : "<external call>");
            if (fr->return_ins) {
                fprintf(out, " -- entered via cross-unit call at frame #%d word #%zu", f - 1, fr->return_ins->index);
            }
            fprintf(out, "\n");
        }
        print_frame_call_stack(fr->state, out);
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
            "break ADDR      set a breakpoint at HALMAT word index ADDR (as shown by --disasm),\n"
            "                in whichever frame is currently active (see `step`/backtrace) --\n"
            "                there is no UNIT:ADDR syntax; step into a unit once first, then\n"
            "                break there for subsequent visits\n"
            "break :STMT     set a breakpoint at HAL/S statement number STMT, same frame scoping\n"
            "delete [N]      delete breakpoint N, or all breakpoints if N is omitted\n"
            "step, s         execute one HALMAT instruction. If it's a CALL into a separately-\n"
            "                compiled EXTERNAL FUNCTION/PROCEDURE (a cross-unit call), steps\n"
            "                *into* it instead of running it atomically: a new frame becomes\n"
            "                active, showing the callee's own instructions/source. When a\n"
            "                stepped-into call's own CLOS is reached, it automatically returns\n"
            "                to the caller frame (\"returned to caller\"), same as gdb's `finish`\n"
            "                would, but automatic rather than requiring a separate command\n"
            "next, n         execute one HALMAT instruction, like `step`, but any cross-unit\n"
            "                call is always run atomically (never stepped into) -- gdb's `next`\n"
            "step N, s N,\n"
            "stepN, sN       (also next N/n N/nextN/nN) repeat N times in a row, quietly --\n"
            "                only the final resulting state is shown (not every intermediate\n"
            "                step), matching gdb's own repeat-count syntax; \"returned to\n"
            "                caller\" still prints for any auto-return along the way. Stops\n"
            "                early if the program ends partway through\n"
            "continue, c     run until a breakpoint or the program ends. Cross-unit calls stay\n"
            "                atomic during continue (like `next`, not `step`) *unless* the\n"
            "                debugger has already stepped into that unit at some earlier point\n"
            "                in this session, in which case a breakpoint set there can still be\n"
            "                hit -- continue itself never decides to step into a call nobody\n"
            "                has explicitly stepped into before\n"
            "run, r          same as continue (execution is already loaded/paused, not\n"
            "                restarted -- there is no separate \"not yet started\" state)\n"
            "htrace on|off   off (default): continue/run behave as above, no per-instruction\n"
            "                output. on: continue/run print the same message `step` would after\n"
            "                every single instruction executed, as if you'd `step`ped through\n"
            "                each one by hand -- everything else about continue/run (breakpoints,\n"
            "                Ctrl-C) is unchanged\n"
            "kill, k         stop execution without exiting the debugger (applies to whichever\n"
            "                frame is currently active)\n"
            "print NAME, p   show a variable's current value by name, in the active frame\n"
            "                (needs that frame's own symbol table)\n"
            "x syt N         examine SYT slot N directly, by raw index, in the active frame\n"
            "x vac N         examine VAC slot N (intermediate-result cache; no names exist),\n"
            "                in the active frame\n"
            "info tasks      show the active frame's scheduler task table and virtual time\n"
            "backtrace, bt   show both the debug frame stack (cross-unit calls stepped into)\n"
            "                and each frame's own same-unit function-call stack\n"
            "help, h         this message\n"
            "quit, q         stop debugging (does not finish running the program)\n"
            "\n"
            "An empty command repeats the last one. Ctrl-C during continue/run returns\n"
            "to this prompt instead of ending the program.\n");
}

/* Finds unit_info's entry for `target` (a `step`-into callee), for lazy
 * pass1.rpt/symtab setup at push_frame() time. NULL if not found -- e.g.
 * units==NULL/num_units==0 (run_single()'s lone-HALMAT_FILE case, which
 * never triggers step-into at all since a HALMAT_FILE never gets
 * external_calls[] populated, so interp_is_external_call() always
 * returns false there) or, defensively, some other mismatch; push_frame()
 * degrades gracefully (no srcmap/symtab, generic label) either way. */
static const debug_unit_info_t *find_unit_info(const debug_unit_info_t *units, int num_units, halmat_state_t *target) {
    for (int i = 0; i < num_units; i++) {
        if (units[i].state == target) return &units[i];
    }
    return NULL;
}

/* Pushes a new frame for `target` onto *frame_count (point 2/3, Plan.md)
 * -- called once interp_prepare_external_call() has already bound its
 * args/positioned its PC (cmd_step(), below). Lazily loads the callee's
 * own pass1.rpt/symtab via unit_info (may be NULL, degrading to
 * instruction-only display like every other missing optional companion
 * file). `return_ins` is the FCAL/PCAL instruction in the *caller* frame
 * that led here (for backtrace + auto_pop()'s FCAL-vs-PCAL distinction).
 * Returns false (printing a message, pushing nothing) if the frame stack
 * is already at its cap. */
static bool push_frame(debug_frame_t *frames, int *frame_count, halmat_state_t *target,
                        const debug_unit_info_t *unit_info, const halmat_instr_t *return_ins, FILE *out) {
    if (*frame_count >= MAX_DEBUG_FRAMES) {
        fprintf(out, "call nesting too deep for the debugger's own frame stack (max %d) -- staying in the caller frame\n",
                MAX_DEBUG_FRAMES);
        return false;
    }
    debug_frame_t *f = &frames[*frame_count];
    memset(f, 0, sizeof(*f));
    f->state = target;
    f->return_ins = return_ins;
    if (unit_info) {
        f->symtab = unit_info->symtab;
        if (unit_info->dir) {
            strncpy(f->label, unit_info->dir, sizeof(f->label) - 1);
            char src_path[1024];
            snprintf(src_path, sizeof(src_path), "%s/pass1.rpt", unit_info->dir);
            char err[256];
            f->have_srcmap = halmat_srcmap_load(src_path, &f->srcmap, err, sizeof(err));
            f->owns_srcmap = f->have_srcmap;
        }
    }
    if (!f->label[0]) snprintf(f->label, sizeof(f->label), "<external call>");
    (*frame_count)++;
    return true;
}

static void pop_frame(debug_frame_t *frames, int *frame_count) {
    debug_frame_t *f = &frames[*frame_count - 1];
    if (f->owns_srcmap && f->have_srcmap) halmat_srcmap_free(&f->srcmap);
    (*frame_count)--;
}

/* Auto-pop on return (point 3, Plan.md): called once the current top
 * frame (a `step`-into'd callee) has halted -- its own CLOS was reached,
 * finishing the cross-unit call the same way the atomic path (OP_FCAL/
 * OP_PCAL's own run_external_call()) would: interp_finish_external_
 * call() checks the callee's exit_code, and (for an FCAL, never a PCAL)
 * interp_copy_external_call_result() copies its RTRN value back into the
 * caller's own VAC slot. Then completes the caller's *own* FCAL/PCAL
 * instruction bookkeeping that cmd_step() deliberately deferred at
 * step-into time -- mirrors exec_one()'s post-switch "if (!halted &&
 * !branched) state->pc++" and interp_step()'s tasks[].saved_pc/
 * virtual_time bookkeeping exactly, just completed here instead of in
 * one atomic call, since arbitrarily many intervening step/next/continue
 * commands may have run inside the callee in between. Only ever called
 * with *frame_count > 1 (never pops the outermost frame -- that's simply
 * the whole program ending, handled by the caller). */
static void auto_pop(debug_frame_t *frames, int *frame_count, long *last_stmt_shown, FILE *out) {
    debug_frame_t *callee = &frames[*frame_count - 1];
    debug_frame_t *caller = &frames[*frame_count - 2];

    bool ok = interp_finish_external_call(caller->state, callee->state);
    if (ok) {
        bool is_function = false;
        interp_is_external_call(caller->state, callee->return_ins, NULL, NULL, &is_function);
        if (is_function) ok = interp_copy_external_call_result(caller->state, callee->state, callee->return_ins);
    }

    if (!caller->state->halted) caller->state->pc++;
    caller->state->tasks[caller->state->current_task].saved_pc = caller->state->pc;
    caller->state->virtual_time++;

    pop_frame(frames, frame_count);
    *last_stmt_shown = -2; /* force the caller's next print_current() to reprint its source line */
    fprintf(out, ok ? "returned to caller\n" : "returned to caller (external call failed)\n");
}

/* Repeatedly auto-pops while the (possibly just-changed) top frame is
 * halted and isn't the outermost one -- covers both a single return and
 * a fail()-triggered cascade (interp_finish_external_call()/interp_copy_
 * external_call_result() failing calls fail() on the *caller*, which
 * marks it halted too, so the same check catches that on the next
 * iteration). Called after every step-affecting command. */
static void auto_pop_all(debug_frame_t *frames, int *frame_count, long *last_stmt_shown, FILE *out) {
    while (*frame_count > 1 && frames[*frame_count - 1].state->halted) {
        auto_pop(frames, frame_count, last_stmt_shown, out);
    }
}

/* Matches `step`/`next` (or their `s`/`n` abbreviations) optionally
 * followed by a repeat count, in any of gdb's own accepted forms:
 * `step 5` (separate whitespace-delimited arg, `cmd`="step"/`arg`="5"),
 * `step5` (no separator at all, digits fused directly onto the command
 * word), or `s5` (fused onto the abbreviation instead of the full
 * name). Returns false if `cmd` doesn't name this command at all (with
 * or without a count); true otherwise, with *count set to the parsed
 * repeat count (defaulting to 1 if none was given, or if a given count
 * parses to <= 0 -- a single step is still the right fallback for a
 * malformed/nonsensical count rather than silently doing nothing). */
static bool parse_repeat_count(const char *cmd, const char *arg, const char *full, const char *abbrev, long *count) {
    size_t flen = strlen(full), alen = strlen(abbrev);
    const char *suffix;
    if (strncmp(cmd, full, flen) == 0) {
        suffix = cmd + flen;
    } else if (strncmp(cmd, abbrev, alen) == 0) {
        suffix = cmd + alen;
    } else {
        return false;
    }
    if (suffix[0] != '\0') {
        for (const char *p = suffix; *p; p++) {
            if (*p < '0' || *p > '9') return false; /* e.g. "steps" isn't this command at all */
        }
        *count = strtol(suffix, NULL, 10);
    } else if (arg) {
        char *endptr;
        long v = strtol(arg, &endptr, 10);
        *count = (endptr != arg && *endptr == '\0') ? v : 1; /* non-numeric arg: just do 1, don't error */
    } else {
        *count = 1;
    }
    if (*count <= 0) *count = 1;
    return true;
}

/* `step`/`s` (point 3, Plan.md): if the peeked next instruction is a
 * cross-unit call, binds its arguments/positions the callee's PC
 * (interp_prepare_external_call()) but does NOT run it -- pushes a new
 * frame for the callee instead (push_frame(), lazily loading its own
 * pass1.rpt/symtab via `units`), making it the active top frame. The
 * FCAL/PCAL instruction itself is deliberately left "in flight": the
 * caller frame's own current_task/pc are positioned at it (mirroring
 * what interp_step() would have done, via interp_peek_next_task() --
 * the same sched_pick_next() decision interp_peek_next() already made),
 * but its pc++/tasks[].saved_pc/virtual_time completion is deferred to
 * auto_pop(), once the callee eventually returns.
 *
 * Otherwise (not a call, or a same-unit call -- those already step
 * through fine today via the existing call_return_stack/direct pc-branch
 * mechanism, untouched) behaves exactly like `next`/interp_step(). */
static void cmd_step(debug_frame_t *frames, int *frame_count, const debug_unit_info_t *units, int num_units, FILE *out) {
    debug_frame_t *top = &frames[*frame_count - 1];
    const halmat_instr_t *next = interp_peek_next(top->state);
    halmat_state_t *target = NULL;
    uint16_t entry_syt = 0;
    if (next && interp_is_external_call(top->state, next, &target, &entry_syt, NULL)) {
        int task_idx = interp_peek_next_task(top->state);
        if (task_idx >= 0) {
            top->state->current_task = task_idx;
            /* tasks[].saved_pc is the *array* index into prog->instrs
             * interp_step() actually resumes at (state->pc's own units);
             * `next->index` is only the raw HALMAT *word* position (for
             * disassembly/breakpoint display) and must never be assigned
             * to state->pc directly -- they coincide only by chance for
             * short programs, which is exactly what silently corrupted
             * pc here during manual testing before this fix. */
            top->state->pc = top->state->tasks[task_idx].saved_pc;
        }
        if (!interp_prepare_external_call(top->state, target, entry_syt)) return; /* fail() already fired on top->state */
        const debug_unit_info_t *info = find_unit_info(units, num_units, target);
        push_frame(frames, frame_count, target, info, next, out);
        return;
    }
    interp_step(top->state, out);
}

/* Shared by `continue` and `run` (which is currently just an alias --
 * execution is already loaded and paused when the debugger starts, so
 * there's no distinct "not yet started" state for `run` to transition
 * out of; see print_help). Runs the *current top frame* via plain
 * interp_step() -- a cross-unit call therefore always stays atomic
 * during continue (matching gdb's own `continue` not auto-stepping into
 * unrelated function calls), even if that call happens to reach some
 * *other* stepped-into frame's breakpoint along the way; only the top
 * frame's own breakpoints are checked here. Auto-pops (see auto_pop())
 * whenever the top frame halts mid-run and isn't the outermost one --
 * so continuing after a `step`-into and its breakpoint naturally resumes
 * the caller once that nested call finishes. Returns once a breakpoint
 * is hit in the (possibly now-different, post-auto-pop) top frame, the
 * *outermost* frame's own program ends, or SIGINT arrives.
 *
 * `htrace`: when set, prints the same per-instruction message `step`
 * would after *every* instruction executed here, not just once at the
 * end -- i.e. `continue`/`run` behave observably like a rapid series of
 * `step`s. Deliberately skipped for the final instruction that halts
 * the outermost frame: the caller's own post-call `print_current()` (run
 * unconditionally, htrace or not) already shows that exact "(program has
 * ended)" state, so printing it here too would just duplicate it --
 * for every *other* instruction, this is the only place that state ever
 * gets shown, since the loop moves straight on to the next iteration
 * without the caller seeing it otherwise. */
static void run_until_stop(debug_frame_t *frames, int *frame_count, const breakpoints_t *bp, long *last_stmt_shown,
                            const debug_colors_t *colors, bool htrace, FILE *out,
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
        debug_frame_t *top = &frames[*frame_count - 1];
        const halmat_instr_t *next = interp_peek_next(top->state);
        if (next && bp->count > 0 && is_breakpoint(bp, next->index, top->state)) {
            *out_hit_bp = true;
            break;
        }
        interp_step(top->state, out);
        auto_pop_all(frames, frame_count, last_stmt_shown, out);
        top = &frames[*frame_count - 1];
        if (*frame_count == 1 && top->state->halted) {
            *out_done = true;
            break;
        }
        if (htrace) {
            /* Same duplicate-avoidance as the halt case above, for the
             * same reason: if the instruction this step just landed on
             * is itself a breakpoint, the top of the *next* iteration is
             * about to break out (without stepping) and the caller's own
             * unconditional post-call print_current() will show this
             * exact "next instruction" state right after -- printing it
             * here too would duplicate it. Only print when the loop is
             * actually going to keep stepping past it. */
            const halmat_instr_t *pending = interp_peek_next(top->state);
            bool will_stop_here = pending && bp->count > 0 && is_breakpoint(bp, pending->index, top->state);
            if (!will_stop_here) print_current(top, last_stmt_shown, colors, out);
        }
    }
    signal(SIGINT, prev_handler);
}

void debug_run_init(debugger_state_t *dstate, halmat_state_t *state, const halmat_symtab_t *symtab,
                     const halmat_srcmap_t *srcmap, const char *label, const debug_unit_info_t *units,
                     int num_units, const debug_colors_t *colors, FILE *out) {
    memset(dstate, 0, sizeof(*dstate)); /* zeroes bp, htrace, have_last, last_line[0]='\0', frames[] */
    dstate->last_stmt_shown = -2; /* sentinel: interp_current_stmt_for_next() never returns less than -1 */
    dstate->frame_count = 1;
    dstate->units = units;
    dstate->num_units = num_units;
    dstate->colors = colors;
    dstate->out = out;

    dstate->frames[0].state = state;
    dstate->frames[0].symtab = symtab;
    if (srcmap) {
        dstate->frames[0].srcmap = *srcmap;
        dstate->frames[0].have_srcmap = true;
    }
    dstate->frames[0].owns_srcmap = false; /* owned by the caller, exactly as before this refactor */
    dstate->frames[0].return_ins = NULL;
    if (label) {
        strncpy(dstate->frames[0].label, label, sizeof(dstate->frames[0].label) - 1);
    }

    fprintf(out, "yaHALMAT2 debugger. Type 'help' for commands.\n");
    print_current(&dstate->frames[0], &dstate->last_stmt_shown, colors, out);
}

bool debug_run_command(debugger_state_t *dstate) {
    cprintf(dstate->colors, dstate->colors ? dstate->colors->prompt_code : -1, dstate->out, "(halmat) ");
    fflush(dstate->out);
    if (!fgets(dstate->line, sizeof(dstate->line), stdin)) {
        fprintf(dstate->out, "\n");
        return false;
    }
    size_t len = strlen(dstate->line);
    while (len > 0 && (dstate->line[len - 1] == '\n' || dstate->line[len - 1] == '\r')) dstate->line[--len] = '\0';

    /* A blank (or all-whitespace) line repeats the last non-blank
     * command, matching gdb -- most useful for `step`/`continue`.
     * Repeated blank lines keep repeating the same command, not
     * "the previous line" (which would just be blank again). */
    bool blank = true;
    for (size_t i = 0; i < len; i++) {
        if (dstate->line[i] != ' ' && dstate->line[i] != '\t') { blank = false; break; }
    }
    if (blank) {
        if (!dstate->have_last) return true;
        strncpy(dstate->line, dstate->last_line, sizeof(dstate->line) - 1);
        dstate->line[sizeof(dstate->line) - 1] = '\0';
    } else {
        strncpy(dstate->last_line, dstate->line, sizeof(dstate->last_line) - 1);
        dstate->last_line[sizeof(dstate->last_line) - 1] = '\0';
        dstate->have_last = true;
    }
    /* Echo the command actually acted on -- both for a repeated
     * blank line (so it's clear what ran) and for redirected/logged
     * non-interactive sessions, where the terminal's own echo of
     * what was "typed" wouldn't otherwise appear anywhere. */
    cprintf(dstate->colors, dstate->colors ? dstate->colors->input_code : -1, dstate->out, "%s\n", dstate->line);

    char *cmd = strtok(dstate->line, " \t");
    if (!cmd) return true;
    char *arg = strtok(NULL, " \t");
    debug_frame_t *top = &dstate->frames[dstate->frame_count - 1]; /* commands that don't change frame_count may use this directly */
    long step_count; /* set by parse_repeat_count() for step/next's own branches below */

    if (strcmp(cmd, "quit") == 0 || strcmp(cmd, "q") == 0) {
        return false;
    } else if (strcmp(cmd, "help") == 0 || strcmp(cmd, "h") == 0) {
        print_help(dstate->out);
    } else if (strcmp(cmd, "break") == 0 || strcmp(cmd, "b") == 0) {
        if (!arg) {
            fprintf(dstate->out, "usage: break ADDR | break :STMT\n");
            return true;
        }
        size_t target;
        bool ok;
        if (arg[0] == ':') {
            ok = find_word_index_for_stmt(top->state->prog, strtol(arg + 1, NULL, 10), &target);
            if (!ok) fprintf(dstate->out, "no SMRK found for statement %s\n", arg + 1);
        } else {
            target = (size_t)strtoul(arg, NULL, 0);
            ok = (find_instr_by_word_index(top->state->prog, target) != NULL);
            if (!ok) fprintf(dstate->out, "no instruction at word index %s\n", arg);
        }
        if (ok) {
            if (dstate->bp.count >= MAX_BREAKPOINTS) {
                fprintf(dstate->out, "too many breakpoints\n");
            } else {
                int id = ++dstate->bp.next_id;
                dstate->bp.word_index[dstate->bp.count] = target;
                dstate->bp.owner[dstate->bp.count] = top->state;
                dstate->bp.id[dstate->bp.count] = id;
                dstate->bp.count++;
                fprintf(dstate->out, "breakpoint %d at word #%zu (frame #%d%s%s)\n", id, target, dstate->frame_count - 1,
                        top->label[0] ? ", " : "", top->label[0] ? top->label : "");
            }
        }
    } else if (strcmp(cmd, "delete") == 0) {
        if (!arg) {
            dstate->bp.count = 0; /* IDs are never reused, so next_id is left alone -- matches gdb */
            fprintf(dstate->out, "all breakpoints deleted\n");
        } else {
            int id = atoi(arg);
            int found = -1;
            for (int i = 0; i < dstate->bp.count; i++) {
                if (dstate->bp.id[i] == id) { found = i; break; }
            }
            if (found < 0) {
                fprintf(dstate->out, "no breakpoint %d\n", id);
            } else {
                for (int i = found; i < dstate->bp.count - 1; i++) {
                    dstate->bp.word_index[i] = dstate->bp.word_index[i + 1];
                    dstate->bp.owner[i] = dstate->bp.owner[i + 1];
                    dstate->bp.id[i] = dstate->bp.id[i + 1];
                }
                dstate->bp.count--;
                fprintf(dstate->out, "breakpoint %d deleted\n", id);
            }
        }
    } else if (parse_repeat_count(cmd, arg, "step", "s", &step_count)) {
        /* `step N`/`stepN`/`sN` (gdb-style repeat count): N plain
         * `step`s in a row, quietly by default -- only the FINAL
         * resulting state gets a full print_current() instruction
         * dump (matching gdb's own "step N" showing just the line
         * reached, not every intermediate one), but auto_pop()'s own
         * "returned to caller" message (a genuinely notable event,
         * not routine per-instruction noise) still prints on every
         * iteration it fires, same as a real gdb stop-on-something-
         * interesting would. With `htrace on`, EVERY intermediate
         * iteration also gets its own print_current() (matching
         * htrace's own documented "as if you'd stepped through each
         * one by hand" behavior for continue/run, run_until_stop's
         * own convention above) -- except the very last one, since
         * the unconditional post-loop print_current() below already
         * covers it and printing it twice would just duplicate it.
         * Stops early if the outermost frame halts partway through --
         * nothing left to step. */
        for (long i = 0; i < step_count; i++) {
            cmd_step(dstate->frames, &dstate->frame_count, dstate->units, dstate->num_units, dstate->out);
            auto_pop_all(dstate->frames, &dstate->frame_count, &dstate->last_stmt_shown, dstate->out);
            bool halted_now = (dstate->frame_count == 1 && dstate->frames[0].state->halted);
            if (dstate->htrace && !halted_now && i + 1 < step_count) print_current(&dstate->frames[dstate->frame_count - 1], &dstate->last_stmt_shown, dstate->colors, dstate->out);
            if (halted_now) break;
        }
        print_current(&dstate->frames[dstate->frame_count - 1], &dstate->last_stmt_shown, dstate->colors, dstate->out);
        if (dstate->frame_count == 1 && dstate->frames[0].state->halted) fprintf(dstate->out, "(program has ended, exit code %d)\n", dstate->frames[0].state->exit_code);
    } else if (parse_repeat_count(cmd, arg, "next", "n", &step_count)) {
        /* Exactly `step`'s old (pre-multi-unit) behavior -- a
         * cross-unit call always runs atomically via interp_step(),
         * which reaches exec_one()'s own OP_FCAL/OP_PCAL cross-unit
         * branch (run_external_call(): interp_prepare_external_
         * call() + interp_run() + interp_finish_external_call(),
         * plus interp_copy_external_call_result() for an FCAL) --
         * the very same phases `step` calls directly for its own
         * step-into, just run straight through in one shot instead
         * of stopping partway. No peeking needed here: interp_step()
         * already does the right thing regardless of what kind of
         * instruction comes next.
         *
         * `next N`/`nextN`/`nN`: same repeat-count/htrace-aware
         * convention as `step` above -- re-fetches the top frame each
         * iteration (not the `top` pointer computed once, above the
         * whole if/else chain), since auto_pop_all() can change
         * frame_count mid-loop if a stepped-into callee this `next`
         * runs straight through happens to finish along the way. */
        for (long i = 0; i < step_count; i++) {
            debug_frame_t *cur = &dstate->frames[dstate->frame_count - 1];
            interp_step(cur->state, dstate->out);
            auto_pop_all(dstate->frames, &dstate->frame_count, &dstate->last_stmt_shown, dstate->out);
            bool halted_now = (dstate->frame_count == 1 && dstate->frames[0].state->halted);
            if (dstate->htrace && !halted_now && i + 1 < step_count) print_current(&dstate->frames[dstate->frame_count - 1], &dstate->last_stmt_shown, dstate->colors, dstate->out);
            if (halted_now) break;
        }
        print_current(&dstate->frames[dstate->frame_count - 1], &dstate->last_stmt_shown, dstate->colors, dstate->out);
        if (dstate->frame_count == 1 && dstate->frames[0].state->halted) fprintf(dstate->out, "(program has ended, exit code %d)\n", dstate->frames[0].state->exit_code);
    } else if (strcmp(cmd, "continue") == 0 || strcmp(cmd, "c") == 0 ||
               strcmp(cmd, "run") == 0 || strcmp(cmd, "r") == 0) {
        bool done, hit_bp, interrupted;
        run_until_stop(dstate->frames, &dstate->frame_count, &dstate->bp, &dstate->last_stmt_shown, dstate->colors, dstate->htrace, dstate->out, &done, &hit_bp, &interrupted);
        print_current(&dstate->frames[dstate->frame_count - 1], &dstate->last_stmt_shown, dstate->colors, dstate->out);
        if (interrupted) fprintf(dstate->out, "interrupted\n");
        if (hit_bp) fprintf(dstate->out, "breakpoint hit\n");
        if (done) fprintf(dstate->out, "(program has ended, exit code %d)\n", dstate->frames[0].state->exit_code);
    } else if (strcmp(cmd, "htrace") == 0) {
        if (!arg || (strcmp(arg, "on") != 0 && strcmp(arg, "off") != 0)) {
            fprintf(dstate->out, "usage: htrace on | htrace off\n");
        } else {
            dstate->htrace = (strcmp(arg, "on") == 0);
            fprintf(dstate->out, "htrace %s\n", dstate->htrace ? "on" : "off");
        }
    } else if (strcmp(cmd, "kill") == 0 || strcmp(cmd, "k") == 0) {
        if (top->state->halted) {
            fprintf(dstate->out, "(program has already ended)\n");
        } else {
            top->state->halted = true;
            fprintf(dstate->out, "execution stopped\n");
        }
    } else if (strcmp(cmd, "print") == 0 || strcmp(cmd, "p") == 0) {
        if (!arg) {
            fprintf(dstate->out, "usage: print NAME\n");
            return true;
        }
        print_symbol(top->state, top->symtab, arg, dstate->out);
    } else if (strcmp(cmd, "x") == 0) {
        char *idx_str = strtok(NULL, " \t");
        if (!arg || !idx_str) {
            fprintf(dstate->out, "usage: x syt N | x vac N\n");
            return true;
        }
        uint16_t idx = (uint16_t)strtoul(idx_str, NULL, 0);
        if (strcmp(arg, "syt") == 0) {
            examine_syt(top->state, idx, dstate->out);
        } else if (strcmp(arg, "vac") == 0) {
            examine_vac(top->state, idx, dstate->out);
        } else {
            fprintf(dstate->out, "usage: x syt N | x vac N\n");
        }
    } else if (strcmp(cmd, "info") == 0) {
        if (arg && strcmp(arg, "tasks") == 0) {
            print_tasks(top->state, dstate->out);
        } else {
            fprintf(dstate->out, "usage: info tasks\n");
        }
    } else if (strcmp(cmd, "backtrace") == 0 || strcmp(cmd, "bt") == 0) {
        print_backtrace(dstate->frames, dstate->frame_count, dstate->out);
    } else {
        fprintf(dstate->out, "unrecognized command '%s' (type 'help')\n", cmd);
    }

    return true;
}

int debug_run(halmat_state_t *state, const halmat_symtab_t *symtab, const halmat_srcmap_t *srcmap,
              const char *label, const debug_unit_info_t *units, int num_units,
              const debug_colors_t *colors, FILE *out) {
    debugger_state_t dstate;
    debug_run_init(&dstate, state, symtab, srcmap, label, units, num_units, colors, out);
    while (debug_run_command(&dstate)) { }
    return dstate.frames[0].state->exit_code;
}
