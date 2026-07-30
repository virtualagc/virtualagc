/* Per-instruction AP-101S execution-time estimates, ported from the
 * real HAL/S-FC PASS2 compiler's EXECUTION_TIMES procedure (nested in
 * GENERATE_OPERANDS, "Source Code/PASS.REL32V0/PASS2.PROCS/OBJECTGE.xpl")
 * -- the same computation that produces the "TIME: X.XX" annotations
 * seen in a HALSFC compile's pass2.rpt listing. See timing.c's header
 * comment for the full porting notes (table provenance, the historical
 * INST-index scheme vs. this port's mnemonic-keyed one, and which
 * "(SEE POO)" cases a runtime emulator can resolve that the static
 * compiler couldn't).
 *
 * Values are HAL/S-FC's own unlabeled time units (its listings just
 * print bare numbers like "TIME: 0.25") -- not independently confirmed
 * as microseconds here, though that's the conventional assumption for
 * this era of flight hardware. */
#ifndef YAGPC_TIMING_H
#define YAGPC_TIMING_H

#include "cpu.h"
#include "instr.h"

/* Captures whatever operand value instr_time_us() will need from
 * register state that isn't safe (or isn't meaningful) to re-derive
 * after the instruction has executed -- MVH's own count register gets
 * overwritten by MVH itself; shift instructions' count source is
 * stable across execution but captured here too for uniformity. Call
 * this BEFORE ap101_exec1(). Returns 0 (unused) for instructions that
 * don't need it. */
uint32_t instr_time_pre_n(CPU *cpu, const InstrDesc *desc, const DInstr *v, uint32_t hw1);

/* Returns the estimated execution time for the instruction just
 * executed. `preN` is instr_time_pre_n()'s result, captured before
 * execution. `branchTaken` is only meaningful for branch instructions
 * whose time genuinely depends on the outcome (see timing.c) --
 * compute it as (actual post-execution NIA != the sequential
 * fall-through NIA) and pass it regardless for non-branch instructions
 * (ignored there). Returns 0.0 for any mnemonic HAL/S-FC's own table
 * has no timing data for (never emitted by the historical compiler). */
double instr_time_us(const InstrDesc *desc, const DInstr *v, uint32_t preN, bool branchTaken);

#endif
