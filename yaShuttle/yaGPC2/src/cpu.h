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
    /* The Shuttle AGE interrupt shares External 1's PSW pair (0080/0084)
     * and mask bit (36), and is told from it only by the interrupt code
     * in the old PSW -- 0006 against External 1's own 0000/0004.  It has
     * a latch of its own because it is a separate source that can be
     * pending alongside External 1, and it is the LOWEST priority of the
     * twelve: GPCIPL's interrupt-priority self test sets every latch at
     * once and requires AGE to arrive eighth, after External 4. */
    bool age;
} IntPending;

/* One halfword the IU already held when a store rewrote it. */
typedef struct { uint32_t addr; uint16_t val; } IuShadowEntry;

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

    /* DIAGNOSE state (POO sect.15/16.8), the instruction unit's own
     * store-conflict detection.  A store into the halfwords the IU is
     * already holding normally purges the lookahead, and a machine that
     * simply refetches is indistinguishable from one that purges -- so
     * with detection ON (the power-up state) nothing here does anything.
     * DIAG X'7101' turns it OFF, which IS distinguishable: the pipeline
     * is not purged and the STALE halfword executes.  GPCIPL's own self
     * test relies on exactly that, storing an instruction over itself
     * and requiring the old one to run.
     *
     * `iuShadow` holds the pre-store halfwords for the window the IU
     * could have reached, and is discarded at the next discontinuity. */
    bool diagIuStoreDetect;          /* B STAT bit 6; true at power-up */
    IuShadowEntry *iuShadow;
    int iuShadowCount, iuShadowCap;
    uint32_t curIC;                  /* address of the instruction being run */
    bool prevDiscont;                /* last instruction broke sequential fetch */

    /* Left ON by an ISPB with an illegal M1 (100-111): protected
     * locations can then be written without a violation until the next
     * valid ISPB clears it.  Every store an instruction makes honours
     * it. */
    bool storeProtectOverride;

    /* DIAGNOSE (POO sect.15).  The interrupt page's scan register doubles
     * as its Diagnose Error register: the EA Scan 5 assist reads it and
     * clears it, and nothing in a fault-free machine ever sets a bit in
     * it. */
    uint32_t diagScanReg;
    bool diagInterruptPageDiagnoseMode;
    /* Which machine-check code the next machine check carries; 0x0008
     * ("BA Fault", Figure 2-20 row C0) unless an assist forces another. */
    uint32_t mcCode;

    /* External 1 carries an interrupt code of its own: 0000 for an IOP
     * data flow error, 0004 for a DMA store protect violation, 0006 for
     * the Shuttle AGE (which has its own latch).  Reset to 0000 once the
     * interrupt is taken. */
    uint32_t ext1Code;

    /* Leftover simulated nanoseconds owed to the IOP's slice clock while
     * the CPU sits in the wait state -- see cpu_advance_idle_ns(). */
    double idleIopNs;

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

    /* --- Per-instruction timing state (see timing.h) ------------------ */

    /* Which of the AP-101S manual's seven section-17 timing columns the
     * operand address of the instruction currently executing was formed
     * by.  0 = normal addressing; 1..4 = double indirection, indexed by
     * 1 + XC*2 + C; 5 = auto storage modification; 6 = auto indexing.
     * Reset to 0 at the top of every cpu_exec1() and set by cpu_g_ea()/
     * cpu_g_ea_16() as they take each addressing path -- those are the
     * only places that see the indirect word's XC/C bits at all, which
     * is why the case has to be recorded there rather than re-derived
     * afterwards.  Mirrors gpc's CPU.xtCase (gpc/cpu.coffee). */
    int xtCase;

    /* Section-17 time (us) for instructions whose figure can only be
     * computed from register state that the instruction itself destroys
     * -- currently MVH alone.  Set by instr_time_pre_n() BEFORE
     * execution; negative means "no override, use the table".  Mirrors
     * gpc's CPU.opExecT, except that gpc can set it from inside the
     * instruction body and this port cannot. */
    double timePooOverrideUs;

    /* Selects which of the two instruction-timing models cpu_exec1()
     * charges each instruction against: false (the default) = the
     * AP-101S Principles of Operation section-17 tables, i.e. the
     * hardware specification; true = the HAL/S-FC PASS2 compiler's own
     * EXECUTION_TIMES estimates.  See timing.h and --timing. */
    bool timingPass2;
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
void cpu_test_fixed_overflow(CPU *cpu);
void cpu_load_psw(CPU *cpu, uint32_t p1, uint32_t p2);

/* Every store an instruction makes goes through these: they record the
 * IU shadow when detection is off, honour storeProtectOverride, and
 * signal the protection violation.  Return false if the store was
 * suppressed.  The fullword form tests BOTH halfwords' protect bits
 * before writing either, so a fullword store straddling a protection
 * boundary leaves neither half changed. */
bool cpu_store_hw(CPU *cpu, uint32_t addr, uint32_t value);
bool cpu_store_fw(CPU *cpu, uint32_t addr, uint32_t value);
void cpu_shadow_iu_store(CPU *cpu, uint32_t addr);
void cpu_iu_shadow_flush(CPU *cpu);
void cpu_signal_exponent_overflow(CPU *cpu);
void cpu_signal_exponent_underflow(CPU *cpu);
void cpu_signal_significance(CPU *cpu);
void cpu_signal_fp_divide(CPU *cpu);
void cpu_signal_convert_overflow(CPU *cpu);
void cpu_signal_illegal_op(CPU *cpu);
void cpu_signal_privileged_op(CPU *cpu);
void cpu_signal_protection_violation(CPU *cpu);
void cpu_signal_addressing_exception(CPU *cpu);

/* The IOP's store protect violation: Figure 2-20 priority 51, External
 * 1, PSA 0080/0084, mask bit 36, code 0004, and "CPU generated" even
 * though it is the IOP's access that trips it. */
void cpu_signal_dma_protect_violation(CPU *cpu);

/* Could anything still wake a CPU sitting in the wait state?  Only an
 * unmasked system interrupt or an already-pending non-maskable one; with
 * neither, the wait is permanent and callers should stop. */
bool cpu_can_wake(const CPU *cpu);

/* Simulated nanoseconds until the next interval-timer expiry, or 0 if
 * neither counter is armed. */
double cpu_next_timer_ns(const CPU *cpu);

/* Advance simulated time through the wait state by up to `ns`, stopping
 * early if an interrupt takes the CPU out of it.  Returns the
 * nanoseconds actually advanced.  This is what couples the machine's own
 * clock to the wall clock while it is waiting -- see rtpacer.h. */
double cpu_advance_idle_ns(CPU *cpu, double ns);

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
void iop_channel_reset(struct IOP *iop);
void iop_tick_watchdog(struct IOP *iop);
bool iop_any_processor_running(const struct IOP *iop);
void iop_exec_idle(struct IOP *iop);

#endif
