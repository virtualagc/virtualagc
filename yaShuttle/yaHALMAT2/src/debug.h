#ifndef HALMAT_DEBUG_H
#define HALMAT_DEBUG_H

#include <stdbool.h>
#include <stdio.h>

#include "interp.h"
#include "srcmap.h"
#include "state.h"
#include "symtab.h"

/* ANSI SGR (30-37, standard 8-color) foreground codes for the debugger's
 * own output, or -1 for "don't emit an escape, use the terminal's
 * default". `enabled` gates all of it (main.c's --color=auto|always|never,
 * auto being TTY-detected). Distinguishes the debugger's own prompt,
 * the command it just read back (echoed, since a redirected/logged
 * session has no terminal echo of its own to show what was typed), and
 * HAL/S source lines, from everything else (`other_code`). */
typedef struct {
    bool enabled;
    int prompt_code;
    int input_code;
    int stmt_code;
    int other_code;
} debug_colors_t;

/* Parses an ANSI color name (case-insensitive: black/red/green/yellow/
 * blue/magenta/cyan/white, plus "brown" as an alias for yellow -- there's
 * no true brown in the base 8-color ANSI palette) into its SGR code.
 * Returns false (leaving *out untouched) for an unrecognized name. */
bool debug_color_by_name(const char *name, int *out);

/* One linked external unit's own directory (or, for a linked-archive
 * container, its embedded diagnostic label -- not necessarily a live
 * filesystem path) and symbol table, keyed by its halmat_state_t* --
 * lets the debugger find a callee's own pass1.rpt/symtab the first time
 * `step` descends into it (point 2, Plan.md): interp_is_external_call()
 * only hands back the bare halmat_state_t* target already wired via
 * interp_set_external_units(), which carries no directory of its own.
 * Built by main.c's run_linked_units() from its own units[]/ext_states[]
 * arrays (one entry per linked EXTERNAL FUNCTION/PROCEDURE unit); a lone
 * HALMAT_FILE (run_single()) or an @list with no such units passes
 * units=NULL/num_units=0 -- step-into is then simply never triggered
 * (interp_is_external_call() always returns false when a state's
 * external_calls is NULL, e.g. a HALMAT_FILE never gets one at all). Not
 * owned by debug_run() -- main.c keeps every referenced dir/symtab alive
 * for as long as debug_run() might still run. */
typedef struct {
    halmat_state_t *state;
    const char *dir;
    const halmat_symtab_t *symtab; /* may be NULL, same optional-companion convention as everywhere else */
} debug_unit_info_t;

#define MAX_BREAKPOINTS 64

/* How deep `step` can push the debug frame stack (point 2, Plan.md) --
 * matches state->call_return_stack's own 64-deep same-unit cap being
 * generous but bounded; cross-unit nesting is expected to be far
 * shallower in practice (each frame is a whole separately-compiled
 * EXTERNAL FUNCTION/PROCEDURE unit, not a single call instruction). */
#define MAX_DEBUG_FRAMES 32

typedef struct {
    size_t word_index[MAX_BREAKPOINTS];
    halmat_state_t *owner[MAX_BREAKPOINTS]; /* which frame's state this breakpoint belongs to (point 4, Plan.md) --
                                              * break ADDR/break :STMT apply to whichever frame is active when the
                                              * command is issued; is_breakpoint() filters by word_index AND owner. */
    int id[MAX_BREAKPOINTS]; /* stable numbering, gdb-style -- not reused/renumbered on delete */
    int count;
    int next_id;
} breakpoints_t;

/* One entry of the debugger's own frame stack (point 2, Plan.md): a
 * cross-unit CALL into a separately-compiled EXTERNAL FUNCTION/PROCEDURE
 * makes the callee's own halmat_state_t (main.c's interp_set_external_
 * units()/state->external_calls[]) the active top frame while `step` is
 * inside it, instead of the atomic single-shot run_external_call() every
 * *other* command (`next`, `continue`, and ordinary non-debug execution)
 * still uses. frames[0] (the outermost frame) is always the triple
 * debug_run_init()'s own caller passed in; every frame above it was
 * pushed by push_frame() at some `step`-into moment. */
typedef struct {
    halmat_state_t *state;
    const halmat_symtab_t *symtab; /* may be NULL -- same optional-companion convention as always */
    halmat_srcmap_t srcmap;        /* only valid if have_srcmap */
    bool have_srcmap;
    bool owns_srcmap;              /* true for a lazily-loaded callee frame (must halmat_srcmap_free on pop);
                                     * false for the outermost frame, whose srcmap is owned by the caller
                                     * exactly as before this refactor. */
    char label[128];               /* unit directory/label (unit_t.dir, a container's diagnostic label, or the
                                     * HALMAT_FILE path), for backtrace/display. */
    const halmat_instr_t *return_ins; /* the FCAL/PCAL instruction in the frame below that led here; NULL for
                                        * the outermost frame. */
} debug_frame_t;

/* All of debug_run()'s own former per-session locals, bundled into one
 * struct so a single dbgState pointer (yaGpcIntegration.h's GpcDebuggerFn)
 * can carry them across separate calls instead of one function's own
 * stack frame. Every existing debug.c helper (cmd_step, auto_pop_all,
 * run_until_stop, print_current, etc.) keeps its own original signature
 * unchanged -- callers now pass dstate->field in place of a bare local,
 * nothing else about them changes. units/num_units/colors/out are
 * session-constant configuration (set once by debug_run_init(), never
 * mutated afterward) folded in here rather than passed as extra
 * parameters to debug_run_command(), since GpcDebuggerFn's own signature
 * is fixed at (GpcState*, void *dbgState) with no room for anything else
 * -- debug_run_command() must be fully self-contained from dstate alone. */
typedef struct {
    breakpoints_t bp;
    bool htrace; /* `htrace on`/`htrace off` -- off (the default) leaves `continue`/`run` exactly as before; on,
                  * they print the same per-instruction message `step` would. Session-scoped, not part of
                  * halmat_state_t -- a debugger display preference, not interpreter state. */
    char line[256];
    char last_line[256];
    bool have_last;
    long last_stmt_shown; /* sentinel -2: interp_current_stmt_for_next() never returns less than -1 */
    debug_frame_t frames[MAX_DEBUG_FRAMES];
    int frame_count;
    const debug_unit_info_t *units;
    int num_units;
    const debug_colors_t *colors;
    FILE *out;
} debugger_state_t;

/* Interactive gdb-subset debugger (Plan.md Phase 3 M7/M8). Instruction-
 * level stepping (break/step/next/continue/run/kill/delete/x/info
 * tasks/print/backtrace/quit), plus HAL/S source-line display alongside
 * each instruction (via SMRK's statement-number correlation,
 * interp_current_stmt_for_next(), and srcmap.c's pass1.rpt parser) when
 * a PASS1 report is available -- shown only when the statement number
 * changes from the preceding instruction visited, not on every step.
 * HAL/S-statement-level step/next and AP-101S-object interleaving
 * (pass2.rpt's LSTALL output) remain deferred -- see the plan file.
 * symtab/srcmap may each independently be NULL (print falls back to "no
 * symbol table loaded"; source display is simply omitted), same
 * "transparently accept, just don't display it" degradation main.c
 * already applies to every other optional companion file. An empty
 * (blank) command repeats the last non-blank one, matching gdb. SIGINT
 * (Ctrl-C) during `continue`/`run` returns to the prompt instead of
 * killing the process.
 *
 * Multi-unit support (point 2/3, Plan.md): `state`/`symtab`/`srcmap`
 * describe the *outermost* frame exactly as before (main.c still only
 * ever constructs that one triple, whether from a single HALMAT_FILE or
 * an @list's primary PROGRAM unit) -- `label` names it for backtrace/
 * display (e.g. the HALMAT_FILE path, or the primary unit's own
 * directory). `debug_run()` pushes additional frames itself, at `step`-
 * into time, for a cross-unit CALL into a separately-compiled EXTERNAL
 * FUNCTION/PROCEDURE (interp_is_external_call()) -- `units`/`num_units`
 * is how it finds each such callee's own directory/symtab when it does.
 * `next` (unlike `step`) always keeps a cross-unit call atomic, same as
 * this function's own pre-multi-unit `step` command used to; see
 * print_help()'s own text (debug.c) for the full step-vs-next-vs-
 * continue contract. */
int debug_run(halmat_state_t *state, const halmat_symtab_t *symtab, const halmat_srcmap_t *srcmap,
              const char *label, const debug_unit_info_t *units, int num_units,
              const debug_colors_t *colors, FILE *out);

/* debug_run()'s own pre-loop setup and per-command loop body, split out
 * so a caller other than debug_run() itself (yaGpcOps.c's GpcDebuggerFn
 * adapter) can drive one command at a time through an explicit
 * debugger_state_t rather than debug_run()'s own stack-local state.
 * debug_run() itself is now just:
 *     debugger_state_t dstate;
 *     debug_run_init(&dstate, state, symtab, srcmap, label, units, num_units, colors, out);
 *     while (debug_run_command(&dstate)) { }
 *     return dstate.frames[0].state->exit_code;
 * -- same signature, same observable behavior as before this split.
 * debug_run_init() can't fail (nothing in the original pre-loop setup
 * had a failure mode), hence void. debug_run_command() blocks on a
 * single fgets(stdin) (unchanged from debug_run()'s own original
 * behavior) to read one command, dispatches it, and returns false only
 * on `quit`/`q` or end-of-input -- true otherwise, meaning "call me
 * again for the next command." */
void debug_run_init(debugger_state_t *dstate, halmat_state_t *state, const halmat_symtab_t *symtab,
                     const halmat_srcmap_t *srcmap, const char *label, const debug_unit_info_t *units,
                     int num_units, const debug_colors_t *colors, FILE *out);
bool debug_run_command(debugger_state_t *dstate);

#endif
