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
 * of resolving names, same "transparently accept, just don't display
 * it" degradation main.c already applies to missing --litfile/--memory/
 * symtab companions in general -- not specific to --py).
 *
 * Design note for whoever implements the deferred source/object
 * interleaving above: the HAL/S source-listing file (pass1.rpt/
 * LISTING2.txt-equivalent) and the AP-101S object/assembly listing
 * (pass2.rpt's LSTALL output) are each independently optional. If
 * either is missing or fails to parse, that side of the interleaved
 * display must simply be omitted -- degrade to instruction-only
 * display for that missing piece, not an error, consistent with every
 * other optional companion file in this program. */
int debug_run(halmat_state_t *state, const halmat_symtab_t *symtab, FILE *out);

#endif
