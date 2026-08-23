/* Per-instruction AP-101S execution times.  TWO models live here and
 * the caller picks between them with CPU.timingPass2 (the --timing
 * option):
 *
 *   POO (the DEFAULT).  The AP-101S Principles of Operation section 17,
 *   "INSTRUCTION EXECUTION TIME IN US" -- the hardware specification,
 *   in microseconds, stated as such by the table's own heading.  Seven
 *   columns, one per addressing mode; the column is chosen by the
 *   CPU.xtCase the effective-address computation recorded.  A handful
 *   of instructions have times the table states as formulas rather than
 *   numbers (shift counts, MVH's element count, ICR's command) and
 *   those are computed, not tabulated.
 *
 *   PASS2 (--timing=pass2).  The real HAL/S-FC PASS2 compiler's
 *   EXECUTION_TIMES procedure (nested in GENERATE_OPERANDS, "Source
 *   Code/PASS.REL32V0/PASS2.PROCS/OBJECTGE.xpl") -- the same computation
 *   that produces the "TIME: X.XX" annotations in a HALSFC compile's
 *   pass2.rpt listing.  This is a COMPILER'S ESTIMATE of the hardware,
 *   made statically and without the operand information a running
 *   emulator has, and it is kept only because comparing the two is
 *   interesting.  Its values are HAL/S-FC's own unlabeled units; the
 *   conventional reading is that they too are microseconds.
 *
 * See timing.c's header comment for the full porting notes on both. */
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
 * don't need it.
 *
 * It also sets CPU.timePooOverrideUs, for the one instruction (MVH)
 * whose section-17 figure cannot be reconstructed after the fact at
 * all; it is reset to "none" here for every other instruction, so
 * cpu_exec1() does not have to clear it separately. */
uint32_t instr_time_pre_n(CPU *cpu, const InstrDesc *desc, const DInstr *v, uint32_t hw1);

/* Returns the execution time in microseconds for the instruction just
 * executed, under whichever model CPU.timingPass2 selects. `preN` is
 * instr_time_pre_n()'s result, captured before execution; CPU.xtCase
 * is the addressing-mode column cpu_g_ea()/cpu_g_ea_16() recorded.
 * `branchTaken` is only meaningful for branch instructions whose time
 * genuinely depends on the outcome (see timing.c) -- compute it as
 * (actual post-execution NIA != the sequential fall-through NIA) and
 * pass it regardless for non-branch instructions (ignored there).
 *
 * `cpu` is not const because a few section-17 figures are finished
 * from post-execution register state (LXA/LXAR's DSE early-out); the
 * function changes nothing. Anything in neither model's table costs
 * INSTR_TIME_UNKNOWN_US rather than nothing. */
double instr_time_us(CPU *cpu, const InstrDesc *desc, const DInstr *v, uint32_t preN, bool branchTaken);

/* What an instruction absent from the timing tables is charged.  0.25
 * us is the section-17 table's own floor -- every simple RR-format
 * operation in it costs exactly that -- so an untabulated instruction
 * costs a plausible minimum instead of being free.  gpc charges the
 * same 250 ns for the same reason. */
#define INSTR_TIME_UNKNOWN_US 0.25

#endif
