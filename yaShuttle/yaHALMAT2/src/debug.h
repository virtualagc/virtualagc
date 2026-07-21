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

#endif
