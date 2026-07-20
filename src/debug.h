#ifndef HALMAT_DEBUG_H
#define HALMAT_DEBUG_H

#include <stdio.h>

#include "interp.h"
#include "state.h"
#include "symtab.h"

/* Interactive gdb-subset debugger (Plan.md Phase 3 M7). v1 scope:
 * instruction-only stepping (break/step/continue/print/backtrace/quit).
 * HAL/S-statement-level step/next and HAL/S-source/AP-101S-object
 * interleaved display are deferred -- see the plan file. symtab may be
 * NULL (print falls back to a "no symbol table loaded" message instead
 * of resolving names). */
int debug_run(halmat_state_t *state, const halmat_symtab_t *symtab, FILE *out);

#endif
