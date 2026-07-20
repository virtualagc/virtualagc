#ifndef HALMAT_DEBUG_H
#define HALMAT_DEBUG_H

#include <stdio.h>

#include "interp.h"
#include "srcmap.h"
#include "state.h"
#include "symtab.h"

/* Interactive gdb-subset debugger (Plan.md Phase 3 M7). v1 scope:
 * instruction-only stepping (break/step/continue/print/backtrace/quit),
 * plus HAL/S source-line display alongside each instruction (via SMRK's
 * statement-number correlation, interp_current_stmt_for_next(), and
 * srcmap.c's pass1.rpt parser) when a PASS1 report is available. HAL/S-
 * statement-level step/next and AP-101S-object interleaving (pass2.rpt's LSTALL
 * output) remain deferred -- see the plan file. symtab/srcmap may each
 * independently be NULL (print falls back to "no symbol table loaded";
 * source display is simply omitted), same "transparently accept, just
 * don't display it" degradation main.c already applies to every other
 * optional companion file. */
int debug_run(halmat_state_t *state, const halmat_symtab_t *symtab, const halmat_srcmap_t *srcmap, FILE *out);

#endif
