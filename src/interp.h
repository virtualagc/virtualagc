#ifndef HALMAT_INTERP_H
#define HALMAT_INTERP_H

#include <stdbool.h>
#include <stdio.h>

#include "halmat.h"
#include "literal.h"
#include "state.h"

void interp_init(halmat_state_t *state, const halmat_program_t *prog,
                  const halmat_literal_table_t *literals, int num_blanks);
void interp_cleanup(halmat_state_t *state);

/* Maps a logical device number (0-9, HALMAT_DEVICE_MAX) to an already-open
 * file, overriding the default (5=stdin/6=stdout, set by interp_init).
 * The interpreter never opens or closes device files itself -- the caller
 * (main.c, for --ddi/--ddo) owns their lifetime. */
void interp_set_device(halmat_state_t *state, int device, FILE *f);

/* Maps a --raf random-access-file channel number (0-9, HALMAT_DEVICE_MAX,
 * a namespace distinct from interp_set_device's) to an already-open file
 * plus its fixed record size, for the FILE opcode (class-0/FILE.md).
 * Not owned by the interpreter, same caller-owns-lifetime convention as
 * interp_set_device. */
void interp_set_raf_device(halmat_state_t *state, int channel, FILE *f, int record_size);

/* Attaches a (possibly NULL) symbol table for MATRIX/VECTOR/ARRAY
 * declared-dimension lookups (state.h's symtab field) -- optional; not
 * calling this at all leaves it NULL, and DSUB/MASN-family opcodes fall
 * back to the generic placeholder-stride behavior. Not owned by the
 * interpreter (main.c manages the halmat_symtab_t's lifetime). */
void interp_set_symtab(halmat_state_t *state, const halmat_symtab_t *symtab);

/* One entry of interp_set_external_units()'s map: `local_syt` (this
 * unit's own SYT index for an EXTERNAL FUNCTION/PROCEDURE symbol, the
 * exact index for which symbol_def_pos[] is NO_TARGET) resolves to
 * `target_entry_syt` -- *target_state's own* SYT for its top-level
 * FDEF/PDEF symbol. See source-documentation/Multiple-file-problem.md
 * and state.h's external_calls field comment for the full mechanism. */
typedef struct {
    uint16_t local_syt;
    halmat_state_t *target_state;
    uint16_t target_entry_syt;
} halmat_external_call_map_t;

/* Installs the cross-unit call table built above (state.h's
 * external_calls) -- replaces any previous one. `target_state`s are not
 * owned by `state`; the caller (main.c) must keep each one alive
 * (its own interp_init/interp_cleanup pair) for as long as `state`
 * might still call into it, and is responsible for cleaning them up
 * itself afterward. */
void interp_set_external_units(halmat_state_t *state, const halmat_external_call_map_t *map, size_t count);

/* Runs to completion (CLOS on the outermost program) or to the first
 * unimplemented/malformed instruction. Returns the process exit code:
 * 0 on a clean CLOS, nonzero (with a message on stderr) otherwise. */
int interp_run(halmat_state_t *state, FILE *out);

/* Executes exactly one scheduler step (see interp.c). Returns true once
 * nothing is left to run (halted, or no task ready/ever waking) -- the
 * building block interp_run() loops on, and what --debugger's `step`
 * command calls directly. */
bool interp_step(halmat_state_t *state, FILE *out);

/* Read-only(-ish; may transition a TASK_WAITING task to TASK_READY if
 * its deadline has already passed) peek at whichever instruction
 * interp_step() would execute next, without executing it. Returns NULL
 * if the program has halted or nothing is left ready. For --debugger's
 * breakpoint/step display. */
const halmat_instr_t *interp_peek_next(halmat_state_t *state);

/* HAL/S statement number whose code interp_peek_next() falls within, or
 * -1 if there's no next instruction. For --debugger's source-line
 * display (debug.c, srcmap.c). */
long interp_current_stmt_for_next(halmat_state_t *state);

#endif
