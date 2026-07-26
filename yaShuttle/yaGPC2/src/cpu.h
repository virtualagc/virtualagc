/* AP-101 CPU core, ported from gpc/cpu.coffee. Instruction *execution*
 * bodies (the ~135-entry opcode table) live in cpu_instr.c — this file
 * covers everything else: register/PSW access, effective-address
 * computation (the RS/SRS/indexed/indirect addressing modes), condition
 * codes, interrupts, and the fetch-decode-dispatch loop (exec1), which
 * calls into cpu_instr.c's instr_decode() (declared here, defined
 * there).
 *
 * `cpu->ram` starts NULL — gpc/cpu.coffee self-aliases `@ram = @mainStorage`
 * in the constructor, but every real code path (always via AP101) then
 * overwrites it with the shared CPU/IOP MemoryBus, so the self-alias is
 * never actually observed by `gpc run`. Whoever wires up the system
 * (ap101.c, Phase 7) must set cpu->ram before calling cpu_exec1(). */
#ifndef YAGPC_CPU_H
#define YAGPC_CPU_H

#include <stdbool.h>
#include <stdint.h>

#include "instr.h"
#include "mcm.h"
#include "membus.h"
#include "regmem.h"

struct IOP; /* forward decl; wired in ap101.c (Phase 7) */

typedef struct {
    bool powerTransient, systemReset, ipl, machineCheck, programCheck, svc;
    bool clk1, clk2, ext1, ext2, ext3, ext4;
    bool iopGrp1, iopGrp2, iopProg;
} IntPending;

typedef struct CPU {
    MCM mainStorage;      /* CPU's own 40K-word (80K-halfword) core memory */
    MemoryBus *ram;        /* set externally; see header comment */
    RegisterFile regFiles[3]; /* [0]=R0-R7, [1]=R8-R15, [2]=FP0-FP7 */
    ProgramStatusWord psw;

    IntPending intPending;
    uint32_t intCode;

    struct IOP *iop;        /* set externally (Phase 7) */
    void *halUCP;            /* set externally (Phase 8); opaque here */
    /* HalUCP hooks — wired as callbacks so cpu.c/cpu_instr.c don't need
     * to know halUCP.c's internals.
     *   halUCPLog: cpu.coffee calls @halUCP._log(...) for one
     *     diagnostic message (unhandled program check).
     *   halUCPHandleSVC: cpu_instr.coffee's SVC instruction calls
     *     @halUCP.handleSVC(ea, r1) — a truthy return means HalUCP
     *     intercepted the SVC (SEND ERROR, halt, etc.) and the standard
     *     SVC-interrupt PSW swap must be skipped. */
    void (*halUCPLog)(void *halUCP, const char *msg);
    bool (*halUCPHandleSVC)(void *halUCP, uint32_t ea, uint32_t r1);

    uint32_t counter1, counter2;
    bool counter1Enabled, counter2Enabled;
} CPU;

void cpu_init(CPU *cpu);
void cpu_free(CPU *cpu);

Register *cpu_r(CPU *cpu, int x);  /* current-bank general register x */
Register *cpu_f(CPU *cpu, int x);  /* floating-point register x (bank 2) */

void cpu_set_nia(CPU *cpu, uint32_t x);
void cpu_incr_nia(CPU *cpu, int incr);
void cpu_compute_cc_arith(CPU *cpu, uint32_t v1, uint32_t v2);
void cpu_compute_cc_logical(CPU *cpu, uint32_t result);

void cpu_swap_psw(CPU *cpu, uint32_t oldAddr, uint32_t newAddr);

void cpu_send_to_iop(CPU *cpu, uint32_t cmd, uint32_t data);
uint32_t cpu_recv_from_iop(CPU *cpu);

void cpu_check_interrupts(CPU *cpu);

void cpu_signal_fixed_overflow(CPU *cpu);
void cpu_signal_exponent_overflow(CPU *cpu);
void cpu_signal_exponent_underflow(CPU *cpu);
void cpu_signal_significance(CPU *cpu);
void cpu_signal_fp_divide(CPU *cpu);
void cpu_signal_convert_overflow(CPU *cpu);
void cpu_signal_illegal_op(CPU *cpu);
void cpu_signal_privileged_op(CPU *cpu);
void cpu_signal_protection_violation(CPU *cpu);
void cpu_signal_addressing_exception(CPU *cpu);

/* Returns true iff the caller should proceed to write back the FP result
 * and set CC normally (see floatIBM.h's FP_EXC_* for the exc codes). */
bool cpu_fp_dispatch_exc(CPU *cpu, int exc);

bool cpu_i_super(CPU *cpu); /* privileged-instruction guard */

uint32_t cpu_g_ea(CPU *cpu, DInstr *v);
uint32_t cpu_g_ea_16(CPU *cpu, DInstr *v);
uint32_t cpu_g_expand(CPU *cpu, uint32_t ea, int bsrdsr);
uint32_t cpu_g_expand_dse(CPU *cpu, uint32_t ea, int bsrdsr, uint32_t dseVal);

uint32_t cpu_g_eaf(CPU *cpu, DInstr *v, int extraOffset);
uint32_t cpu_g_eah(CPU *cpu, DInstr *v);
void cpu_s_eaf(CPU *cpu, DInstr *v, uint32_t value, int extraOffset);
void cpu_s_eah(CPU *cpu, DInstr *v, uint32_t value);

uint32_t cpu_g_shift_cnt(CPU *cpu, uint32_t hw1);

void cpu_reset(CPU *cpu);
void cpu_run(CPU *cpu);
void cpu_exec1(CPU *cpu);

/* Defined in cpu_instr.c (Phase 5). Mirrors Instruction.decode(hw1,hw2):
 * on a match, fills *v (including v->niaIncr, matching `d.len` after
 * decodef()'s own extended-addressing mutations) and returns the matched
 * descriptor; returns NULL on no match, mirroring `[undefined, undefined]`. */
const InstrDesc *instr_decode(uint32_t hw1, uint32_t hw2, DInstr *v);

/* Defined in iop.c (Phase 6). */
void iop_recv_from_cpu(struct IOP *iop, uint32_t cmd, uint32_t data);
uint32_t iop_get_cc_data(struct IOP *iop);

#endif
