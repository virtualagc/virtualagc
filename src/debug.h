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

/* Interactive gdb-subset debugger (Plan.md Phase 3 M7). v1 scope:
 * instruction-only stepping (break/step/continue/run/kill/delete/x/info
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
 * killing the process. */
int debug_run(halmat_state_t *state, const halmat_symtab_t *symtab, const halmat_srcmap_t *srcmap,
              const debug_colors_t *colors, FILE *out);

#endif
