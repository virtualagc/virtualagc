/* CPU instruction set (135 instructions), ported from gpc/cpu_instr.coffee.
 * See instr.h for the DInstr/InstrDesc shared types. `encode()` is the
 * assembler-only path (out of scope) and `execInstr()` is dead code (see
 * cpu_instr.c's header comment) — neither is ported. `toStr()`
 * (disassembly text for `--trace` output and watchpoint messages, needed
 * by Phase 10's run.c) IS ported, as `instr_to_str`. */
#ifndef YAGPC_CPU_INSTR_H
#define YAGPC_CPU_INSTR_H

#include "cpu.h"
#include "instr.h"

/* Must be called once before any instr_decode() call (idempotent). */
void cpu_instr_table_init(void);

/* Ported from Instruction#toStr: disassembles one instruction into a
 * human-readable mnemonic+operands string (e.g. "LR   R0,R1"), or
 * "UNDEFINED" if hw1/hw2 don't decode to any known instruction. */
void instr_to_str(uint32_t hw1, uint32_t hw2, char *out, size_t outSize);

#endif
