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

/* Overrides interp_init's default time_scale of 1.0 (state.h) -- the
 * wall-clock pacing divisor interp_run() applies to the *sleep* duration
 * of its burst-execute-then-sleep throttling (--time-scale, main.c).
 * Does not affect HALMAT_TICKS_PER_SECOND or any SCHD/WAIT tick
 * arithmetic at all -- every task's tick counts, interleaving order, and
 * therefore every program's computed output are completely independent
 * of this; only how long interp_run() actually sleeps changes. */
void interp_set_time_scale(halmat_state_t *state, double scale);

/* Overrides interp_init's default pacing_mode of HALMAT_PACING_BURST
 * (state.h) -- selects which of interp_run()'s two wall-clock pacing
 * implementations a run uses (--pacing, main.c): HALMAT_PACING_BURST
 * (interp_run_burst(), the original burst-execute-then-sleep polling
 * design) or HALMAT_PACING_SIGNAL (interp_run_signal(), the POSIX/Win32
 * timer-notification-driven alternative). Purely a dispatch choice --
 * both implement the identical pacing contract and honor time_scale
 * identically; see state.h's halmat_pacing_mode_t comment. */
void interp_set_pacing_mode(halmat_state_t *state, halmat_pacing_mode_t mode);

/* Overrides interp_init's default line_length of 80 (state.h, USA003087
 * Sec. 12.2's "unpaged output: [80 columns/line]") -- the WRITE
 * data-field wrap column (--line-length, main.c). Only affects where
 * flush_write (interp.c) starts a new output line; never affects any
 * computed program value. */
void interp_set_line_length(halmat_state_t *state, int line_length);

/* Runs to completion (CLOS on the outermost program) or to the first
 * unimplemented/malformed instruction. Returns the process exit code:
 * 0 on a clean CLOS, nonzero (with a message on stderr) otherwise. */
int interp_run(halmat_state_t *state, FILE *out);

/* Executes exactly one scheduler step (see interp.c). Returns true once
 * nothing is left to run (halted, or no task ready/ever waking) -- the
 * building block interp_run() loops on, and what --debugger's `next`
 * command (and `step`, for anything that isn't a cross-unit call) calls
 * directly. */
bool interp_step(halmat_state_t *state, FILE *out);

/* Read-only(-ish; may transition a TASK_WAITING task to TASK_READY if
 * its deadline has already passed) peek at whichever instruction
 * interp_step() would execute next, without executing it. Returns NULL
 * if the program has halted or nothing is left ready. For --debugger's
 * breakpoint/step display. */
const halmat_instr_t *interp_peek_next(halmat_state_t *state);

/* Which tasks[] index interp_step()/interp_peek_next() would resume next
 * (identical sched_pick_next() logic, called the same way), or -1 if
 * nothing is ready. interp_peek_next() itself doesn't expose this (see
 * its own comment for why an approximation was fine before); the
 * debugger's step-into (point 3, Plan.md) needs the exact value, since it
 * defers interp_step()'s own current_task/tasks[].saved_pc bookkeeping
 * for a cross-unit FCAL/PCAL until the stepped-into callee's call
 * eventually returns (debug.c's auto_pop()). */
int interp_peek_next_task(halmat_state_t *state);

/* HAL/S statement number whose code interp_peek_next() falls within, or
 * -1 if there's no next instruction. For --debugger's source-line
 * display (debug.c, srcmap.c). */
long interp_current_stmt_for_next(halmat_state_t *state);

/* True iff `ins` is an FCAL/PCAL resolving to a cross-unit call in
 * `state`'s external_calls[] table (interp_set_external_units(), main.c)
 * -- same detection OP_FCAL/OP_PCAL's own handlers use internally, for
 * the debugger's step-into decision (point 1/3, Plan.md). On true,
 * target_out/entry_syt_out identify the callee; is_function_out
 * distinguishes FCAL (has a return value to copy back) from PCAL
 * (doesn't). Any of the three output pointers may be NULL if the caller
 * doesn't need that particular value. `ins` may be NULL (returns false). */
bool interp_is_external_call(const halmat_state_t *state, const halmat_instr_t *ins,
                              halmat_state_t **target_out, uint16_t *entry_syt_out, bool *is_function_out);

/* Phase 1 of a cross-unit call (source-documentation/Multiple-file-
 * problem.md): binds `state`'s currently-open io_pending call arguments
 * into `target`'s own SYT numbering and positions `target`'s PC at its
 * entry point, resetting its scheduler to a single fresh READY primal
 * task -- everything the interpreter's own cross-unit FCAL/PCAL handling
 * used to do inline before running the callee, now exposed so a caller
 * (the debugger, for step-into) can run the callee itself (its own step
 * loop) instead of via interp_run(). Returns false (having already
 * called fail() on `state`, the *caller*) if entry_syt has no FDEF/PDEF
 * in `target`, or there are too many arguments. */
bool interp_prepare_external_call(halmat_state_t *state, halmat_state_t *target, uint16_t entry_syt);

/* Phase 2: checks target->exit_code after the callee has finished
 * (however it got run -- interp_run() for the atomic path, or the
 * debugger's own step loop for step-into) and fail()s `state` (the
 * caller) if it didn't succeed. Returns false in that case (fail()
 * already called), true otherwise. */
bool interp_finish_external_call(halmat_state_t *state, halmat_state_t *target);

/* Copies a just-finished external FUNCTION call's captured RTRN result
 * (target->external_call_result) into `ins`'s own VAC slot in `state` --
 * the same place a same-unit call's result would land. Used by OP_FCAL's
 * own cross-unit path and by the debugger's step-into return path (once
 * a stepped-into callee frame auto-pops). Never called for a PCAL
 * (procedures don't return a value). Returns false (having already
 * called fail() on `state`) if the callee's RTRN carried no result, or
 * if the result is a CHARACTER/MATRIX/VECTOR value (not yet implemented
 * for a FUNCTION return -- see the implementation). */
bool interp_copy_external_call_result(halmat_state_t *state, halmat_state_t *target, const halmat_instr_t *ins);

#endif
