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
    bool clk1, clk2, ext2;
    /* CPU Breakpoint (Instruction Monitor): its own PE-class interrupt,
     * AP-101S-instruction-set.txt Figure 2-20 row 17 -- old PSW 0070, new
     * PSW 0074, mask bit 34 (0x20), no interrupt code.  This slot used to
     * be called ext1 and was dispatched on mask 0x02, which is EX3's bit,
     * while the condition that raises it was reported as a program check
     * on 0048/004c instead. */
    bool instrMonitor;
    /* iopGrp1/iopGrp2/iopProg are EX0/EX1/EX2 (vectors 0078/0080/0088,
     * mask bits 0x10/0x08/0x04) -- named after the IOP-flavored sources
     * AP-101S-instruction-set.txt row 50/51/53 documents for them.
     * ext3/ext4 are EX3/EX4 (vectors 0090/0098, mask bits 0x02/0x01),
     * both spare per the same table -- see cpu_check_interrupts. */
    bool ext3, ext4;
    bool iopGrp1, iopGrp2, iopProg;
} IntPending;

typedef struct CPU {
    MCM mainStorage;      /* The AP-101S's real, single, shared main
                            * storage -- 0x40000 words (0x80000 halfwords),
                            * the full 19-bit address space (AP-101S-
                            * instruction-set.txt Sec. III "1.1.2 Addressing
                            * and Instruction Formats"). Lives on CPU
                            * (mirroring gpc/cpu.coffee's own
                            * @mainStorage) because the IOP has no separate
                            * storage of its own -- see membus.h's header
                            * comment -- but it's the one memory both the
                            * CPU (through cpu->ram/MemoryBus) and the IOP
                            * (directly, iop.c's iop_g_eaf/iop_g_eah/
                            * iop_s_eaf/iop_s_eah) read and write. */
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

    /* The two interval timers' 16-bit HARDWARE counters.  Their high
     * halfwords are not here -- they live in main store at 0x00B0 and
     * 0x00B1, which is where the microcode borrows from and where Read/
     * Write Counter assemble the full 32-bit value from. */
    uint32_t counter1, counter2;
    bool counter1Enabled, counter2Enabled;
    /* Sub-microsecond remainder carried between ticks.  The timers run at
     * 1 MHz off simulated execution time, so an instruction that takes
     * 2.8us advances them by two ticks and leaves 0.8us here. */
    double timerAccumUs;

    /* --fcos (see opts.h): simulate specific known behaviors of FCOS
     * (the Shuttle flight-software OS), which real bare-hardware/no-OS
     * programs never get since nothing is installed at the program-check
     * interrupt vector to provide them. So far this covers exactly one
     * case (see exec_CVFX's FP_EXC_CONVERT_OVERFLOW handling, cpu_instr.c):
     * FCOS's FPMCVFX interrupt handler (source-confirmed,
     * workspace/PFS/OI340600/SSSRC/FPMSDERR.asm) patches a CVFX
     * instruction's destination register to +32767/-32767 (by the
     * source float's sign) when the conversion overflows, then resumes
     * — a real HAL/S program compiled for flight use relies on this;
     * one compiled to run standalone with no OS underneath it does not
     * get it, and instead sees whatever raw truncation the bare CVFX
     * instruction itself produces. */
    bool fcosMode;

    /* Cumulative estimated AP-101S execution time (HAL/S-FC's own
     * unlabeled time units -- see timing.h), summed unconditionally by
     * every cpu_exec1() call, not just under --debug -- a GPC embedded
     * in a larger simulator (see yaGpcIntegration.h) needs this whether
     * or not a debugger is attached. */
    double elapsedTimeUs;

    /* DATE()/CLOCKTIME() wall-clock anchor (USA003090 8.2 items 17/18;
     * see halucp.c's own SVC #22 TYPE=1/2 handling) -- a Unix epoch
     * value (seconds since 1970-01-01 UTC). yaGPC2 has no real mission-
     * epoch the way real FCOS would (an actual launch GMT); DATE()/
     * CLOCKTIME() report dateTimeAnchorEpochSec + elapsedTimeUs/1e6,
     * decomposed via localtime() (the process's own configured
     * timezone) at query time -- this field itself never changes after
     * being set once. Defaults to the Unix epoch itself (0) here, a
     * fixed and deterministic value matching fcosMode's own "safe
     * default for direct/embedded/test use" precedent -- the CLI's own
     * "default to the real host clock at program start" behavior (see
     * opts.h's --date-time-epoch) is applied one layer up, in
     * ageharness_configure_from_opts(), not here, so existing/future
     * tests that construct an AGEHarness/CPU directly stay
     * deterministic regardless of what wall-clock time they happen to
     * run at. */
    double dateTimeAnchorEpochSec;
} CPU;

void cpu_init(CPU *cpu);
void cpu_free(CPU *cpu);

Register *cpu_r(CPU *cpu, int x);  /* current-bank general register x */
Register *cpu_f(CPU *cpu, int x);  /* floating-point register x (bank 2) */

void cpu_set_nia(CPU *cpu, uint32_t x);
void cpu_incr_nia(CPU *cpu, int incr);
void cpu_compute_cc_arith(CPU *cpu, uint32_t v1, uint32_t v2);
void cpu_compute_cc_logical(CPU *cpu, uint32_t result);

/* Fixed-point add/subtract that maintain the PSW carry bit and raise the
 * fixed-point overflow interrupt; see cpu.c.  Every A/S-family
 * instruction must go through these rather than a bare + or -. */
uint32_t cpu_add_fixed(CPU *cpu, uint32_t a, uint32_t b, uint32_t carryIn);
uint32_t cpu_sub_fixed(CPU *cpu, uint32_t a, uint32_t b);

void cpu_swap_psw(CPU *cpu, uint32_t oldAddr, uint32_t newAddr);

void cpu_send_to_iop(CPU *cpu, uint32_t cmd, uint32_t data);
uint32_t cpu_recv_from_iop(CPU *cpu);

void cpu_check_interrupts(CPU *cpu);

/* Advance simulated execution time by `us` and tick the 1 MHz interval
 * timers with it.  Every path that consumes time must go through this so
 * the timers see it -- see cpu.c. */
void cpu_advance_time_us(CPU *cpu, double us);

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
void cpu_power_on(CPU *cpu);
void cpu_run(CPU *cpu);
void cpu_exec1(CPU *cpu);
void cpu_tick(CPU *cpu); /* counter decrement + interrupt dispatch only; see cpu.c */

/* Defined in cpu_instr.c (Phase 5). Mirrors Instruction.decode(hw1,hw2):
 * on a match, fills *v (including v->niaIncr, matching `d.len` after
 * decodef()'s own extended-addressing mutations) and returns the matched
 * descriptor; returns NULL on no match, mirroring `[undefined, undefined]`. */
const InstrDesc *instr_decode(uint32_t hw1, uint32_t hw2, DInstr *v);

/* Defined in iop.c (Phase 6). */
void iop_recv_from_cpu(struct IOP *iop, uint32_t cmd, uint32_t data);
uint32_t iop_get_cc_data(struct IOP *iop);

#endif
