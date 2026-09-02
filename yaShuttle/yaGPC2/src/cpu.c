#include "cpu.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "floatIBM.h"
#include "timing.h"

/* ---------------------------------------------------------------------
 * Construction
 * ------------------------------------------------------------------- */

void cpu_init(CPU *cpu) {
    /* 0x40000 words = 0x80000 halfwords -- the AP-101S's real, full 19-bit
     * address space (see cpu.h's mainStorage comment), not gpc/cpu.coffee's
     * inherited 40*1024-word (80K-halfword) partial size. */
    cpu->mainStorage = mcm_create(0x40000);
    cpu->ram = NULL; /* see cpu.h header comment */
    /* `new RegisterFile("r0",8,32)` etc — num=8 allocates 9 slots
     * (CoffeeScript's inclusive [0..8]); only 0-7 are ever addressed by
     * a 3-bit register field, matching regmem.h's documented behavior. */
    cpu->regFiles[0] = registerfile_create(8);
    cpu->regFiles[1] = registerfile_create(8);
    cpu->regFiles[2] = registerfile_create(8);
    psw_init(&cpu->psw);

    memset(&cpu->intPending, 0, sizeof(cpu->intPending));
    cpu->intCode = 0;
    cpu->iop = NULL;
    cpu->halUCP = NULL;
    cpu->halUCPLog = NULL;
    cpu->halUCPHandleSVC = NULL;
    /* Both interval counters come up ALL ONES, as a hardware down-counter
     * does -- the reference sets 0xffff at construction and at each of its
     * two resets.  Zero meant the very next tick borrowed from the high
     * halfword in PSA 00B0/00B1 immediately, so a Read Counter issued
     * before the first Write Counter came back a full count out.  The POO
     * does not state the reset value; this follows the reference, and it
     * is also the only way the ICR fixtures can agree, since the fixture
     * baseline carries regs/dse/mem/psw but NOT the counters. */
    cpu->counter1 = 0xffff;
    cpu->counter2 = 0xffff;
    cpu->counter1Enabled = false;
    cpu->counter2Enabled = false;
    cpu->fcosMode = false;
    cpu->xtCase = 0;
    cpu->timePooOverrideUs = -1.0;
    cpu->timingPass2 = false;   /* section-17 hardware model -- see timing.h */
    cpu->elapsedTimeUs = 0.0;
    cpu->timerAccumUs = 0.0;
    cpu->dateTimeAnchorEpochSec = 0.0; /* Unix epoch -- see cpu.h's own comment */
    cpu->diagIuStoreDetect = true;   /* B STAT bit 6 is set at power-up */
    cpu->iuShadow = NULL;
    cpu->iuShadowCount = 0;
    cpu->iuShadowCap = 0;
    cpu->curIC = 0;
    cpu->prevDiscont = false;
    cpu->storeProtectOverride = false;
    cpu->diagScanReg = 0;
    cpu->diagInterruptPageDiagnoseMode = false;
    cpu->mcCode = 0x0008;
    cpu->ext1Code = 0x0000;
    cpu->idleIopNs = 0.0;
}

void cpu_free(CPU *cpu) {
    free(cpu->iuShadow);
    cpu->iuShadow = NULL;
    cpu->iuShadowCount = cpu->iuShadowCap = 0;
    mcm_free(&cpu->mainStorage);
    for (int i = 0; i < 3; i++) registerfile_free(&cpu->regFiles[i]);
}

/* ---------------------------------------------------------------------
 * Registers / PSW / condition codes
 * ------------------------------------------------------------------- */

Register *cpu_r(CPU *cpu, int x) {
    return registerfile_r(&cpu->regFiles[psw_get_reg_set(&cpu->psw)], x);
}

Register *cpu_f(CPU *cpu, int x) {
    return registerfile_r(&cpu->regFiles[2], x);
}

void cpu_set_nia(CPU *cpu, uint32_t x) { psw_set_nia(&cpu->psw, x); }

void cpu_incr_nia(CPU *cpu, int incr) {
    cpu_set_nia(cpu, psw_get_nia(&cpu->psw) + (uint32_t)incr);
}

void cpu_compute_cc_arith(CPU *cpu, uint32_t v1, uint32_t v2) {
    int32_t sv1 = (int32_t)v1;
    int32_t sv2 = (int32_t)v2;
    if (sv1 == sv2) psw_set_cc(&cpu->psw, 0);
    else if (sv1 < sv2) psw_set_cc(&cpu->psw, 3);
    else psw_set_cc(&cpu->psw, 1);
}

/* Fixed-point add, with the two side effects the bare `+` this port used
 * everywhere never produced: the PSW carry bit and the fixed-point
 * overflow interrupt.
 *
 * Carry is the 33rd bit of the unsigned sum, so the addition is done wide
 * and then truncated.  Signed overflow is the standard test -- the two
 * addends agreed in sign and the sum disagreed with them -- and raises
 * the program interrupt through cpu_signal_fixed_overflow(), which honors
 * the PSW's own fixed-point-overflow mask and was, until this was wired
 * up, dead code that nothing in the emulator ever called.
 *
 * Subtraction goes through the same path as a + ~b + 1 rather than
 * a + (~b + 1).  The two agree on the result and disagree on the carry
 * when b is zero: the inner increment wraps to zero and loses the carry
 * out that the wide form reports. */
uint32_t cpu_add_fixed(CPU *cpu, uint32_t a, uint32_t b, uint32_t carryIn) {
    uint64_t sum = (uint64_t)a + (uint64_t)b + (uint64_t)carryIn;
    psw_set_carry(&cpu->psw, sum > 0xffffffffu ? 1u : 0u);
    uint32_t result = (uint32_t)sum;
    if (((a ^ result) & (b ^ result) & 0x80000000u) != 0) {
        cpu_signal_fixed_overflow(cpu);
    }
    return result;
}

uint32_t cpu_sub_fixed(CPU *cpu, uint32_t a, uint32_t b) {
    return cpu_add_fixed(cpu, a, ~b, 1);
}

void cpu_compute_cc_logical(CPU *cpu, uint32_t result) {
    psw_set_cc(&cpu->psw, result == 0 ? 0 : 3);
}

void cpu_swap_psw(CPU *cpu, uint32_t oldAddr, uint32_t newAddr) {
    /* One line per interrupt actually taken, naming the PSA vector pair
     * it came through -- which is what identifies the class.  Added to
     * find an interrupt we take that the reference does not. */
    if (getenv("YAGPC_INTTRACE")) {
        /* The interrupt code says WHICH program check / machine check this
         * is, and without it a 0048 line names only the class.  It is set
         * into the PSW before the swap, so it reads correctly here. */
        fprintf(stderr, "INT  old=%04x new=%04x  code=%04x  atNIA=%05x  "
                        "newPSW=%08x  t=%.1f\n",
                (unsigned)oldAddr, (unsigned)newAddr,
                (unsigned)psw_get_int_code(&cpu->psw),
                (unsigned)psw_get_nia(&cpu->psw),
                (unsigned)membus_get32(cpu->ram, newAddr),
                cpu->elapsedTimeUs);
        if (psw_get_int_code(&cpu->psw) == 0x0007)
            fprintf(stderr, "     store-protect at %05x\n",
                    (unsigned)cpu->lastProtFaultAddr);
    }
    membus_set32(cpu->ram, oldAddr, register_get32(&cpu->psw.psw1), true);
    membus_set32(cpu->ram, oldAddr + 2, register_get32(&cpu->psw.psw2), true);
    uint32_t p1 = membus_get32(cpu->ram, newAddr);
    uint32_t p2 = membus_get32(cpu->ram, newAddr + 2);
    cpu_load_psw(cpu, p1, p2);
}

/* IOP link — implemented in iop.c (Phase 6). */
void cpu_send_to_iop(CPU *cpu, uint32_t cmd, uint32_t data) {
    iop_recv_from_cpu(cpu->iop, cmd, data);
}

uint32_t cpu_recv_from_iop(CPU *cpu) {
    return iop_get_cc_data(cpu->iop);
}

/* ---------------------------------------------------------------------
 * Interrupts
 *
 * NOTE: gpc/cpu.coffee's six named INT_* handlers (INT_addressSpec,
 * INT_illegalOperation, INT_privilegedInstruction, INT_supervisorCall,
 * INT_CLK1, INT_CLK2) are defined but never called from anywhere in the
 * codebase (grep-verified) — checkInterrupts has its own inline swapPSW
 * logic for every interrupt class instead. Dead code, not ported.
 * ------------------------------------------------------------------- */

/* Figure 2-20 note '#': "When one of these interrupts is taken, the
 * condition code (CC) in the OLD PSW will be set to a binary 10 and
 * clear the carry and overflow bits.  This can result in erroneous GPC
 * operation of an instruction which tries to utilize the CC, carry bit
 * or overflow bit before they are set by another instruction."  The
 * note is marked on every machine check, on the store protect
 * violation, and on the External 1 DMA store protect violation -- a
 * property of the event, not of the latch.  It must be applied BEFORE
 * the swap, since the swap is what stores the old PSW the handler then
 * reads.  (The third case, the DMA store protect, cannot arise here
 * yet: nothing in this emulator's IOP DMA path checks store protection,
 * so no External 1 ever carries code 0x0004.  When it does, it belongs
 * in this same helper.)  Omitting this left GPCIPL's store-protect
 * handler reading CC 00 out of the old PSW at 0x0048 where the real
 * machine leaves 10. */
static void cc_anomaly(CPU *cpu) {
    psw_set_cc(&cpu->psw, 2);
    psw_set_carry(&cpu->psw, 0);
    psw_set_overflow(&cpu->psw, 0);
}

void cpu_check_interrupts(CPU *cpu) {
    uint32_t intMask = psw_get_int_mask(&cpu->psw);

    /* "Masked machine check and program interrupts do not stay pending"
     * (POO 2.5.2.3): only the SYSTEM class (the interval timers and the
     * externals) waits for an unmask.  The two maskable non-persistent
     * sources are dropped here rather than lingering -- leaving them
     * pending re-delivered a machine check the moment GPCIPL's self test
     * re-enabled the mask at +104f, long after the event. */
    if (cpu->intPending.machineCheck && !psw_get_mach_check_mask(&cpu->psw)) {
        cpu->intPending.machineCheck = false;
        cpu->mcCode = 0x0008;
    }
    if (cpu->intPending.instrMonitor && !(intMask & 0x20)) {
        cpu->intPending.instrMonitor = false;
    }

    if (cpu->intPending.machineCheck) {
        if (psw_get_mach_check_mask(&cpu->psw)) {
            cpu->intPending.machineCheck = false;
            psw_set_int_code(&cpu->psw, cpu->mcCode);
            cpu->mcCode = 0x0008;   /* back to "BA Fault" for the next one */
            cc_anomaly(cpu);
            cpu_swap_psw(cpu, 0x0040, 0x0044);
            return;
        }
    }

    /* CPU Breakpoint (Instruction Monitor) -- Figure 2-20 row 17, a
     * PE-class interrupt of its own with mask bit 34 and vectors
     * 0070/0074, carrying no interrupt code.  It outranks the program
     * check (row 20 and below), which is why it is tested first. */
    if (cpu->intPending.instrMonitor && (intMask & 0x20)) {
        cpu->intPending.instrMonitor = false;
        cpu_swap_psw(cpu, 0x0070, 0x0074);
        return;
    }

    if (cpu->intPending.programCheck) {
        cpu->intPending.programCheck = false;
        uint32_t newPsw1 = membus_get32(cpu->ram, 0x004c);
        uint32_t newPsw2 = membus_get32(cpu->ram, 0x004e);
        if (newPsw1 == 0 && newPsw2 == 0) {
            psw_set_int_code(&cpu->psw, cpu->intCode);
            if (cpu->halUCP && cpu->halUCPLog) {
                char msg[160];
                snprintf(msg, sizeof(msg),
                         "GPC: unhandled program check, code=0x%04X (no handler at 0x004C); continuing\n",
                         (unsigned)cpu->intCode);
                cpu->halUCPLog(cpu->halUCP, msg);
            }
            return;
        }
        psw_set_int_code(&cpu->psw, cpu->intCode);
        if (cpu->intCode == 0x0007) cc_anomaly(cpu); /* store protect */
        cpu_swap_psw(cpu, 0x0048, 0x004c);
        return;
    }

    if (cpu->intPending.svc) {
        cpu->intPending.svc = false;
        cpu_swap_psw(cpu, 0x0058, 0x005c);
        return;
    }

    if (cpu->intPending.clk1 && (intMask & 0x80)) {
        cpu->intPending.clk1 = false;
        cpu_swap_psw(cpu, 0x0060, 0x0064);
        return;
    }
    if (cpu->intPending.clk2 && (intMask & 0x40)) {
        cpu->intPending.clk2 = false;
        cpu_swap_psw(cpu, 0x0068, 0x006c);
        return;
    }
    if (cpu->intPending.iopGrp1 && (intMask & 0x10)) {
        cpu->intPending.iopGrp1 = false;
        /* External 0 and External 1 are the only system interrupts that
         * carry an interrupt code of their own (Figure 2-20's IOP side:
         * 0000 for both, plus External 1's two overrides, the DMA store
         * protect 0004 and the Shuttle AGE 0006, neither of which this
         * emulator raises yet).  The rest carry none, and leave whatever
         * the interrupted program's PSW held.  Not writing the 0000 left
         * a stale code -- the fixed-point overflow's 0004 -- in the old
         * PSW that GPCIPL's External 0 handler reads back at +096a. */
        psw_set_int_code(&cpu->psw, 0x0000);
        cpu_swap_psw(cpu, 0x0078, 0x007c);
        return;
    }
    if (cpu->intPending.iopGrp2 && (intMask & 0x08)) {
        cpu->intPending.iopGrp2 = false;
        psw_set_int_code(&cpu->psw, cpu->ext1Code);
        /* Figure 2-20 marks the DMA store protect violation's PSA entry
         * "0080#", so it carries the same old-PSW anomaly a store
         * protect program check does. */
        if (cpu->ext1Code == 0x0004) cc_anomaly(cpu);
        cpu->ext1Code = 0x0000;
        cpu_swap_psw(cpu, 0x0080, 0x0084);
        return;
    }
    if (cpu->intPending.iopProg && (intMask & 0x04)) {
        cpu->intPending.iopProg = false;
        cpu_swap_psw(cpu, 0x0088, 0x008c);
        return;
    }
    /* EX3/EX4 (vectors 0090/0098, mask 0x02/0x01) -- see cpu.h's
     * IntPending comment. Previously entirely missing; confirmed against
     * BILDNEW5/GPCIPL's own CPUTEST8 interrupt-priority self test, which
     * expects both as two of the eight ordered sources. */
    if (cpu->intPending.ext3 && (intMask & 0x02)) {
        cpu->intPending.ext3 = false;
        cpu_swap_psw(cpu, 0x0090, 0x0094);
        return;
    }
    if (cpu->intPending.ext4 && (intMask & 0x01)) {
        cpu->intPending.ext4 = false;
        cpu_swap_psw(cpu, 0x0098, 0x009c);
        return;
    }
    /* AGE, last of the twelve: External 1's vector and mask bit, its own
     * latch, and interrupt code 0006 to tell it apart. */
    if (cpu->intPending.age && (intMask & 0x08)) {
        cpu->intPending.age = false;
        psw_set_int_code(&cpu->psw, 0x0006);
        cpu_swap_psw(cpu, 0x0080, 0x0084);
        return;
    }
}

/* Re-test POO 2.5.2.3's Note 1 condition -- the fixed-point overflow
 * INDICATOR and its MASK both set.  Called after anything that can set
 * either bit: an overflowing operation, SPM, or a PSW load. */
void cpu_test_fixed_overflow(CPU *cpu) {
    if (psw_get_overflow(&cpu->psw) && psw_get_fixed_pt_overflow(&cpu->psw)) {
        cpu->intPending.programCheck = true;
        /* Figure 2-20 row 20: "0004 | ENDOP | CPU | Fixed Point
         * Overflow".  0002 -- what this used -- is row 31, "CPU Addr
         * Spec 128K, GB Only", an entirely different check. */
        cpu->intCode = 0x0004;
    }
}

void cpu_signal_fixed_overflow(CPU *cpu) {
    /* The overflow INDICATOR is sticky and is set whether or not the
     * mask lets the program check through -- software reads it back out
     * of the PSW with SPM/LPS long after the fact.  Setting only the
     * interrupt, as this did, left the bit permanently clear: GPCIPL's
     * overflow self-test at +0c4b saw PSW 0c4dc000 where the real
     * machine leaves 0c4dd000. */
    psw_set_overflow(&cpu->psw, 1);
    cpu_test_fixed_overflow(cpu);
}

/* psw_load() plus that re-test -- gpc's own loadPSW().  Every place a
 * whole PSW is installed from memory goes through here. */
void cpu_load_psw(CPU *cpu, uint32_t p1, uint32_t p2) {
    psw_load(&cpu->psw, p1, p2);
    cpu_test_fixed_overflow(cpu);
}

void cpu_signal_exponent_overflow(CPU *cpu) {
    cpu->intPending.programCheck = true;
    cpu->intCode = 0x000B;
}

void cpu_signal_exponent_underflow(CPU *cpu) {
    if (psw_get_exponent_underflow(&cpu->psw)) {
        cpu->intPending.programCheck = true;
        cpu->intCode = 0x0009;
    }
}

void cpu_signal_significance(CPU *cpu) {
    if (psw_get_significance_mask(&cpu->psw)) {
        cpu->intPending.programCheck = true;
        cpu->intCode = 0x0005;
    }
}

void cpu_signal_fp_divide(CPU *cpu) {
    cpu->intPending.programCheck = true;
    cpu->intCode = 0x000C;
}

void cpu_signal_convert_overflow(CPU *cpu) {
    cpu->intPending.programCheck = true;
    cpu->intCode = 0x000A;
}

void cpu_signal_illegal_op(CPU *cpu) {
    cpu->intPending.programCheck = true;
    cpu->intCode = 0x0000;
}

void cpu_signal_privileged_op(CPU *cpu) {
    cpu->intPending.programCheck = true;
    cpu->intCode = 0x0001;
}

void cpu_signal_protection_violation(CPU *cpu) {
    /* Confirmed against both the manual (AP-101S-instruction-set.txt's
     * own program-check code table: "AL 0007 CPU STORE PROTECT
     * VIOLATION") and BILDNEW5.lst's own source (STM1.asm's store-
     * protect self-test literally does `CHI R7,7  INTPCK INTRP CODE=7
     * (STORE PROTECT)`) -- 0x0004 is a DIFFERENT program check entirely
     * ("CPU FIXED POINT OVERFLOW"). Inherited verbatim from gpc/
     * cpu.coffee's own signalProtectionViolation (`@intCode = 0x0004`),
     * never caught because nothing in either emulator's corpus ever
     * triggered a real store-protect violation before BILDNEW5/GPCIPL's
     * own --ipl-driven boot did this session: PCHINTH's dispatch table
     * misrouted every violation to SVC026 ("FIXED POINT OVERFLOW")'s
     * handler instead of the real store-protect handler, whose actual
     * job (per STM1.asm) is to recognize and resolve the condition
     * rather than just log it -- so the violation recurred forever
     * instead of ever being handled. */
    /* Counted under YAGPC_PROTTRACE.  Protection here comes from the
     * SECTION map, which protects whole loaded sections; the reference
     * moved off that because it locks the runtime's own IOCODE/IOBUF
     * cells and the stack.  If that over-protects, GPCIPL's own stores
     * fault here, so this counter says whether it does. */
    if (getenv("YAGPC_PROTTRACE")) {
        static long n = 0;
        if (++n <= 20 || n % 1000 == 0)
            fprintf(stderr, "PROTVIOL #%ld at NIA=%05x addr=%05x\n", n,
                    (unsigned)psw_get_nia(&cpu->psw),
                    (unsigned)cpu->lastProtFaultAddr);
    }
    cpu->intPending.programCheck = true;
    cpu->intCode = 0x0007;
}

/* The IOP's store protect violation: Figure 2-20 priority 51, External
 * 1, PSA 0080/0084, mask bit 36, code 0004, and "CPU generated" even
 * though it is the IOP's access that trips it.
 *
 * Figure 2-20 note '##': "A masked DMA store protect interrupt will set
 * the condition code (CC) to a binary 10 and clear the carry and
 * overflow bits...  Additionally, a masked DMA store protect interrupt
 * clears any fixed point overflow, floating point underflow, and
 * floating point overflow interrupts.  This can result in a lost
 * arithmetic interrupt if a masked DMA store protect interrupt occurs
 * during an instruction that causes one of these arithmetic
 * interrupts." */
void cpu_signal_dma_protect_violation(CPU *cpu) {
    cpu->ext1Code = 0x0004;
    cpu->intPending.iopGrp2 = true;
    if (!(psw_get_int_mask(&cpu->psw) & 0x08)) {   /* masked */
        psw_set_cc(&cpu->psw, 2);
        psw_set_carry(&cpu->psw, 0);
        psw_set_overflow(&cpu->psw, 0);
        if (cpu->intPending.programCheck &&
            (cpu->intCode == 0x0004 ||    /* fixed point overflow */
             cpu->intCode == 0x0009 ||    /* floating point underflow */
             cpu->intCode == 0x000B)) {   /* floating point overflow */
            cpu->intPending.programCheck = false;
        }
    }
}

void cpu_signal_addressing_exception(CPU *cpu) {
    cpu->intPending.programCheck = true;
    /* Figure 2-20 row 31: "0002 | ForcedENDOP | CPU | CPU Addr Spec
     * 128K, GB Only".  0003 -- what this used -- is not a program
     * check at all; it is machine check row 06, "CPU Memory Multi-bit
     * Error", on the 0040/0044 pair. */
    cpu->intCode = 0x0002;
}

bool cpu_fp_dispatch_exc(CPU *cpu, int exc) {
    switch (exc) {
        case FP_EXC_OK:
            return true;
        case FP_EXC_EXP_OVERFLOW:
            cpu_signal_exponent_overflow(cpu);
            return false;
        case FP_EXC_EXP_UNDERFLOW:
            cpu_signal_exponent_underflow(cpu);
            return !psw_get_exponent_underflow(&cpu->psw);
        case FP_EXC_SIGNIFICANCE:
            cpu_signal_significance(cpu);
            return true;
        case FP_EXC_DIVIDE:
            cpu_signal_fp_divide(cpu);
            return false;
        case FP_EXC_CONVERT_OVERFLOW:
            cpu_signal_convert_overflow(cpu);
            return false;
        default:
            return true;
    }
}

bool cpu_i_super(CPU *cpu) {
    if (psw_get_problem_state(&cpu->psw) == 1) {
        cpu_signal_privileged_op(cpu);
        return false;
    }
    return true;
}

/* ---------------------------------------------------------------------
 * Effective address computation
 * ------------------------------------------------------------------- */

uint32_t cpu_g_expand(CPU *cpu, uint32_t ea, int bsrdsr) {
    ea = ea & 0xffff;
    if (ea & 0x8000) {
        if (bsrdsr == OPTYPE_DATA || bsrdsr == OPTYPE_SHFT) {
            ea = (psw_get_dsr(&cpu->psw) << 15) + (ea & 0x7fff);
        } else {
            ea = (psw_get_bsr(&cpu->psw) << 15) + (ea & 0x7fff);
        }
    }
    return ea;
}

uint32_t cpu_g_expand_dse(CPU *cpu, uint32_t ea, int bsrdsr, uint32_t dseVal) {
    /* AP-101S-instruction-set.txt Sec. 2.9 "Expanded Addressing", Figure
     * 2-18's own "Data Operand Addressing Expansion" flowchart (verified
     * against the real scanned page, not just OCR text): when the raw
     * 16-bit address's own high bit (X) is 1, the replacement sector is
     * ALWAYS PSW's real DSR (bits 28-31) -- never a base register's DSE,
     * regardless of whether one was used to form the address. It's the
     * OPPOSITE case -- X=0 (already "unexpanded") AND a genuine base
     * register was used -- where that base register's own DSE replaces
     * the (zero) high bit instead of the implied-0000 default. Inherited
     * backwards from gpc/cpu.coffee's own g_EXPAND_DSE (which applied
     * dseVal only when X was already 1); confirmed NOT independently
     * re-verified by yaGPC/yaGPC2's own porting history (yaGPC preserved
     * gpc's bugs exactly, yaGPC2 was derived from yaGPC without a full
     * re-audit), not real corroboration. Branch-type expansion (BSR) never
     * uses DSE at all -- see Figure 2-18's separate, simpler "Branch
     * Addressing Expansion" chart -- so bsrdsr!=DATA/SHFT here mirrors
     * cpu_g_expand()'s own BSR-only behavior exactly. */
    ea = ea & 0xffff;
    if (bsrdsr == OPTYPE_DATA || bsrdsr == OPTYPE_SHFT) {
        if (ea & 0x8000) {
            ea = (psw_get_dsr(&cpu->psw) << 15) + (ea & 0x7fff);
        } else {
            ea = (dseVal << 15) + ea;
        }
    } else if (ea & 0x8000) {
        ea = (psw_get_bsr(&cpu->psw) << 15) + (ea & 0x7fff);
    }
    return ea;
}

/* Expanded addressing for the RS branch, which forms its addresses from a
 * BASE REGISTER and therefore expands them with that register's own Data
 * Sector Extension rather than the implied-zero sector.  The reference
 * passes g_BASE_DSE(v, true) into every g_EXPAND in this branch; ours
 * passed none, so any address whose high bit was 0 landed a sector low --
 * 897 of the 20,447 EA fixtures, every one off by an exact multiple of
 * 0x8000, taking the RS-format memory instructions with it. */
static uint32_t ea_expand(CPU *cpu, uint32_t ea, int opType, bool hasDse, uint32_t dseVal) {
    return hasDse ? cpu_g_expand_dse(cpu, ea, opType, dseVal) : cpu_g_expand(cpu, ea, opType);
}

/* YAGPC_EATRACE=<hexnia>[,<hexnia>...] prints the effective address a
 * named instruction computed, and what is there.  A register dump says
 * WHAT a wild branch went to; only the EA says WHERE the address came
 * from, which is the difference between "this table entry is wrong" and
 * "the table is being indexed wrong". */
static void cpu_ea_trace(CPU *cpu, uint32_t ea) {
    static int inited = 0;
    static long nia[8];
    static int count = 0;
    if (!inited) {
        inited = 1;
        const char *e = getenv("YAGPC_EATRACE");
        while (e != NULL && *e != '\0' && count < 8) {
            char *end = NULL;
            nia[count++] = strtol(e, &end, 16);
            e = (end != NULL && *end == ',') ? end + 1 : NULL;
        }
    }
    for (int i = 0; i < count; i++)
        if ((long)psw_get_nia(&cpu->psw) == nia[i])
            fprintf(stderr, "EATRACE nia=%05x ea=%05x mem16=%04x mem32=%08x "
                    "t=%.1f\n", (unsigned)psw_get_nia(&cpu->psw), (unsigned)ea,
                    (unsigned)membus_get16(cpu->ram, ea),
                    (unsigned)membus_get32(cpu->ram, ea), cpu->elapsedTimeUs);
}

/* YAGPC_EAWATCH=lo-hi[,max[,afterSec]] (halfword addresses in hex, max lines
 * decimal, default 2000; afterSec in EMULATED seconds, default 0): every
 * operand access whose effective address lands in the range, with the NIA of
 * the instruction that made it.
 *
 * This is EATRACE run backwards.  EATRACE answers "where did THIS instruction
 * read?", which needs the instruction's address to start from; EAWATCH
 * answers "WHICH instruction read this table?", which is the question you
 * have when a data structure was located by searching memory for its contents
 * and no link map exists to say what code owns it.  Finding DM6OPS from
 * DM6V_TR_TAB is exactly that: the table is identifiable by its initial
 * values, the code around it is not identifiable by anything. */
static void cpu_ea_watch(CPU *cpu, uint32_t ea) {
    static int inited = 0;
    static uint32_t lo = 1, hi = 0;
    static long left = 0;
    static double afterUs = 0.0;
    if (!inited) {
        inited = 1;
        const char *spec = getenv("YAGPC_EAWATCH");
        if (spec != NULL) {
            unsigned a = 0, b = 0; long m = 2000; double t = 0.0;
            if (sscanf(spec, "%x-%x,%ld,%lf", &a, &b, &m, &t) >= 2) {
                lo = a; hi = b; left = m; afterUs = t * 1.0e6;
            }
        }
    }
    if (left <= 0 || ea < lo || ea > hi) return;
    if (cpu->elapsedTimeUs < afterUs) return;
    left--;
    fprintf(stderr, "EAWATCH nia=%05x ea=%05x mem16=%04x t=%.1f\n",
            (unsigned)psw_get_nia(&cpu->psw), (unsigned)ea,
            (unsigned)membus_get16(cpu->ram, ea), cpu->elapsedTimeUs);
}

uint32_t cpu_g_ea(CPU *cpu, DInstr *v) {
    uint32_t ea;

    if (v->niaIncr == 2 && !df_has(v, 'I')) {
        uint32_t disp = df_get(v, 'd');
        uint32_t base = (df_get(v, 'b') == 3) ? 0 : (register_get32(cpu_r(cpu, (int)df_get(v, 'b'))) >> 16);
        uint32_t pea = base + disp;
        /* g_BASE_DSE(v, true): no DSE when there is no base field, or
         * when B2 == 11 selects no base addressing at all. */
        bool hasDse = df_has(v, 'b') && df_get(v, 'b') != 3;
        uint32_t dseVal = hasDse
            ? registerfile_get_dse(&cpu->regFiles[psw_get_reg_set(&cpu->psw)], (int)df_get(v, 'b'))
            : 0u;

        /* Every address formed with a NONZERO base-register DSE.  The
         * rule applying it is flagged above as inherited from gpc and
         * never independently re-verified, so when an operand lands in
         * the wrong sector this is the first thing to look at. */
        if (getenv("YAGPC_DSETRACE") && hasDse && dseVal != 0)
            fprintf(stderr, "DSE nia=%05x pea=%05x b=%u dse=%u\n",
                    (unsigned)psw_get_nia(&cpu->psw), pea,
                    (unsigned)df_get(v, 'b'), dseVal);
        if (df_has(v, 'i')) {
            uint32_t idx = df_get(v, 'i');
            if (idx == 0) {
                if (v->ii == 0 && v->ia == 0) {
                    /* Formed from the RAW 16-bit IC, and the RESULT is
                     * expanded as a branch address.  Adding the
                     * already-expanded NIA and never expanding -- what
                     * this did -- put the answer a sector out whenever
                     * the IC's own high bit was set. */
                    ea = cpu_g_expand(cpu, psw_get_ic16(&cpu->psw) + pea, OPTYPE_BRCH);
                } else if (v->ia == 0 && v->ii == 1) {
                    ea = cpu_g_expand(cpu, psw_get_ic16(&cpu->psw) - pea, OPTYPE_BRCH);
                } else if (v->ia == 1 && v->ii == 0) {
                    /* Timing: single-level indirection has no column of
                     * its own in section 17; the closest case is double
                     * indirection with XC=1 (nothing is post-indexed
                     * here) and C=0, i.e. column 3. */
                    cpu->xtCase = 3;
                    uint32_t indirectAddr = ea_expand(cpu, pea, OPTYPE_DATA, hasDse, dseVal);
                    uint32_t indirectHW = membus_get16(cpu->ram, indirectAddr);
                    ea = ea_expand(cpu, indirectHW, v->opType, hasDse, dseVal);
                } else {
                    cpu->xtCase = 5;   /* auto storage modification */
                    uint32_t indirectAddr = ea_expand(cpu, pea, OPTYPE_DATA, hasDse, dseVal);
                    uint32_t indirectFW = membus_get32(cpu->ram, indirectAddr);
                    /* "Then, AFTER the EA has been formed, storage
                     * modification is automatically performed... The
                     * modifier is added to the address and the resulting
                     * modified address replaces bits 0 through 15 of the
                     * indirect address word" (Step 6, Figure 2-15).  The
                     * access uses the address as it stands; the modified
                     * one is what the NEXT use of the pointer sees.  This
                     * used to add the modifier before forming the EA, so
                     * every auto-modified reference ran one step ahead of
                     * itself -- GPCIPL's DSE self-test at +0d88 read the
                     * wrong fullword back. */
                    uint32_t addr16 = (indirectFW >> 16) & 0xffff;
                    uint32_t modifier = indirectFW & 0xffff;
                    ea = ea_expand(cpu, addr16, v->opType, hasDse, dseVal);
                    uint32_t modifiedAddr = (addr16 + modifier) & 0xffff;
                    membus_set32(cpu->ram, indirectAddr,
                                 (modifiedAddr << 16) + modifier, true);
                }
            } else {
                Register *ri = cpu_r(cpu, (int)idx);
                if (v->ia == 0 && v->ii == 0) {
                    uint32_t regx = (register_get32(ri) >> 16) << (v->indexWidth - 1);
                    ea = ea_expand(cpu, pea + regx, v->opType, hasDse, dseVal);
                } else if (v->ia == 0 && v->ii == 1) {
                    cpu->xtCase = 6;   /* auto indexing */
                    uint32_t regx = (register_get32(ri) >> 16) << (v->indexWidth - 1);
                    uint32_t modifier = register_get32(ri) & 0xffff;
                    uint32_t ea16 = (pea + regx) & 0xffff;
                    ea = ea_expand(cpu, ea16, v->opType, hasDse, dseVal);
                    /* The modifier goes onto the index register's OWN
                     * address field, not onto the EA: "each modifier is
                     * added to the most significant 16 bits of the
                     * registers. The result replaces the most
                     * significant 16 bits" (instruction set, Step 8 and
                     * the RS-form auto-modify description). Adding it to
                     * ea16 instead folded the displacement and base into
                     * the write-back, so an auto-indexed walk drifted by
                     * the displacement on every step. Use the raw MS-16
                     * bits rather than regx -- regx is pre-aligned by
                     * addrWidth-1 for fullword operands. */
                    uint32_t modifiedAddr =
                        ((register_get32(ri) >> 16) + modifier) & 0xffff;
                    register_set32(ri, (modifiedAddr << 16) + modifier);
                } else if (v->ia == 1 && v->ii == 0) {
                    /* Timing: indirection WITH post-indexing; closest
                     * section-17 case is double indirection XC=0, C=0. */
                    cpu->xtCase = 1;
                    uint32_t indirectAddr = ea_expand(cpu, pea, OPTYPE_DATA, hasDse, dseVal);
                    uint32_t indirectHW = membus_get16(cpu->ram, indirectAddr);
                    uint32_t regx = (register_get32(ri) >> 16) << (v->indexWidth - 1);
                    ea = ea_expand(cpu, indirectHW + regx, v->opType, hasDse, dseVal);
                } else {
                    uint32_t indirectAddr = ea_expand(cpu, pea, OPTYPE_DATA, hasDse, dseVal);
                    uint32_t indirectFW = membus_get32(cpu->ram, indirectAddr);
                    uint32_t address16 = (indirectFW >> 16) & 0xffff;
                    uint32_t address15 = address16 & 0x7fff;
                    uint32_t xc = (indirectFW >> 11) & 1;
                    uint32_t c = (indirectFW >> 10) & 1;
                    /* Timing: true double indirection, column selected
                     * by the pointer's own XC/C bits. */
                    cpu->xtCase = (int)(1 + xc * 2 + c);
                    uint32_t cb = (indirectFW >> 9) & 1;
                    uint32_t cd = (indirectFW >> 8) & 1;
                    uint32_t ptrBSR = (indirectFW >> 4) & 0xF;
                    uint32_t ptrDSR = indirectFW & 0xF;
                    uint32_t regx = (register_get32(ri) >> 16) << (v->indexWidth - 1);

                    if (c == 1) {
                        if (cd == 1) psw_set_dsr(&cpu->psw, ptrDSR);
                        if (cb == 1) psw_set_bsr(&cpu->psw, ptrBSR);
                    }
                    uint32_t effDSR = (c == 0) ? ptrDSR : psw_get_dsr(&cpu->psw);
                    /* YAGPC_INDTRACE=lo-hi[,max[,afterSec]]: the whole
                     * fullword-indirect computation for instructions in the
                     * range -- the pointer as it actually stands, both
                     * candidate addresses, and what each one holds.
                     *
                     * A RANGE, not a single address, because the IC has
                     * already advanced by the time the EA is formed: matching
                     * one address exactly printed nothing at all.
                     *
                     * Which way round Xc goes cannot be read off the scanned
                     * Figure 2-17 (the OCR loses which arrow of the expansion
                     * flowchart carries the =1), and inverting it on a guess
                     * hangs every program in test_rtl.  So measure it. */
                    {
                        static int inited = 0;
                        static uint32_t lo = 0, hi = 0;
                        static long left = 0;
                        static double afterUs = 0.0;
                        if (!inited) {
                            inited = 1;
                            const char *spec = getenv("YAGPC_INDTRACE");
                            if (spec) {
                                unsigned a = 0, b = 0; long m = 40; double t = 0.0;
                                if (sscanf(spec, "%x-%x,%ld,%lf", &a, &b, &m, &t) >= 2) {
                                    lo = a; hi = b; left = m; afterUs = t * 1.0e6;
                                }
                            }
                        }
                        uint32_t here = psw_get_nia(&cpu->psw);
                        if (left > 0 && here >= lo && here <= hi &&
                            cpu->elapsedTimeUs >= afterUs) {
                            left--;
                            uint32_t noIdx = (effDSR << 15) + address15;
                            uint32_t withIdx = (effDSR << 15) + ((address15 + regx) & 0x7fff);
                            fprintf(stderr,
                                "INDTRACE nia=%05x pea=%05x ptr=%08x addr=%04x "
                                "xc=%u c=%u cb=%u cd=%u bsv=%u dsv=%u dsr=%u idx=%u "
                                "regx=%04x | noIdx=%05x holds %04x | withIdx=%05x holds %04x\n",
                                (unsigned)here, (unsigned)indirectAddr,
                                (unsigned)indirectFW, (unsigned)address16,
                                (unsigned)xc, (unsigned)c, (unsigned)cb, (unsigned)cd,
                                (unsigned)ptrBSR, (unsigned)ptrDSR,
                                (unsigned)psw_get_dsr(&cpu->psw), (unsigned)df_get(v, 'i'),
                                (unsigned)regx,
                                (unsigned)noIdx, (unsigned)membus_get16(cpu->ram, noIdx),
                                (unsigned)withIdx, (unsigned)membus_get16(cpu->ram, withIdx));
                        }
                    }
                    /* THE POINTER'S OWN HIGH BIT DECIDES WHETHER A SECTOR
                     * IS APPLIED AT ALL, exactly as it does for every other
                     * address (Sec. 2.9, and cpu_g_expand() right above).
                     * Figure 2-17 names bit 0 MSB, "Determines type of
                     * address expansion", and the expansion flowchart's own
                     * leaves are EXPAND USING DSR / DSV / DSE / *0000* --
                     * that last one is this case.  This used to shift the
                     * sector in unconditionally, so a pointer to sector 0
                     * read from sector DSV instead.
                     *
                     * PASS is where it showed: DCI#CON fetches display data
                     * through a ZCON that DCI#DATA declares as
                     *     DC  Z(,FCMCBLKS,8)
                     * -- flags byte 8, so Xc=1, C=0 -- and whose address half
                     * it fills in at run time.  Measured at 0x42845 the
                     * pointer reads 26f80801: address 0x26f8, DSV=1.  The
                     * high bit of 0x26f8 is CLEAR, so the datum is at 0x026f8,
                     * where the tape put CZ2V_MC_REQ.  Applying DSV anyway
                     * read 0x0a6f8, which nothing had written, and returned
                     * the C6C6 IPL fill.  Sign-extended by the SRA that
                     * follows, that is -14650 -- which is how GPC MEMORY came
                     * to show -0602, -50 and rows of FFFFFFFFFF.
                     *
                     * The addition is 16-bit and includes the high bit: "All
                     * EA/BA address calculations involve 16-bit operands and
                     * bit 0 of the fullword indirect address pointer is
                     * included in these address calculations" (the note under
                     * Figure 2-15).  Masking the index sum to 15 bits first,
                     * as this did, threw away a carry that is supposed to
                     * decide the expansion. */
                    uint32_t ea16 = (xc == 0) ? ((address16 + regx) & 0xffff)
                                              : address16;
                    if (ea16 & 0x8000) {
                        uint32_t sector = (v->opType == OPTYPE_BRCH)
                                        ? psw_get_bsr(&cpu->psw) : effDSR;
                        ea = (sector << 15) + (ea16 & 0x7fff);
                    } else {
                        ea = ea16;
                    }
                }
            }
        } else if (df_get(v, 'b') == 3 && v->opType != OPTYPE_BRCH) {
            /* AP-101S PoO Sec. 2.2.8 "RS Format Instructions", on the
             * EXTENDED form (AM = bit 13 = 0), second numbered difference
             * from SRS addressing:
             *
             *     "When B2 equals 11, base addressing is not performed.
             *      In this case, the displacement is instead used
             *      DIRECTLY AS THE EFFECTIVE ADDRESS."
             *
             * Directly as the EA -- so there is no 16-bit address left for
             * Sec. 2.9 to expand.  Sec. 2.9 governs turning a 16-bit
             * ADDRESS into a 19-bit EA; here the displacement already IS
             * the EA, and quoting 2.9's "high-order bit 1 selects DSR"
             * against this case is a category error (I made it once).
             *
             * Confirmed against the linked image: every such operand in
             * FCMSSYNC equals its symbol's address exactly, INCLUDING the
             * three whose bit 15 is set --
             *     FCMSNCSV 8252   FCMPLDSE 8bba   FCMSVCNM 8209
             *     TCVTRSSM 0166   TPSASOP  0058   TCVTSVCS 016a
             * Expanding them hides the defect whenever DSR happens to
             * match the operand's own sector, which is why the STORE at
             * FCMSSYNC's entry worked and only the matching LOAD failed:
             * DSR=1 at the ST gave (1<<15)+0x252 = 0x8252 by luck, DSR=0
             * at the L gave 0x0252, and the value read back there put
             * 0x0001 in R7's high half, so `BCR 7,R7` branched to address
             * 1.  That was the 0xc6c6 crash.
             *
             * gpc expands here too, so this is an INHERITED defect rather
             * than a porting slip -- the PoO and the linked image are the
             * authority, not the reference implementation.
             *
             * BRANCHES ARE EXCLUDED, and that exclusion is MEASURED, not
             * assumed.  Applying 2.2.8 literally to branch operands too
             * costs three further whole stages -- test_scheduler,
             * test_random and TEST_RTL, the real RTL assembly -- and drops
             * 111116 -> 111036 fixtures.  The reason is that a branch
             * target still has to reach sector 3: 16 bits cannot express
             * 0x197ab, so the branch address is expanded with BSR per Sec.
             * 2.9 even though no base was added.  For data operands the
             * linked image says the opposite, and it wins. */
            ea = pea & 0xffff;
        } else {
            ea = ea_expand(cpu, pea, v->opType, hasDse, dseVal);
        }
        if (v->addrWidth == 2 && (ea & 1) && getenv("YAGPC_RSALIGNTRACE"))
            fprintf(stderr, "RSALIGN A nia=%05x ea=%05x b=%d ia=%d ii=%d x=%d\n",
                    (unsigned)psw_get_nia(&cpu->psw), ea,
                    df_has(v,'b') ? (int)df_get(v,'b') : -1,
                    (int)v->ia, (int)v->ii,
                    df_has(v,'x') ? (int)df_get(v,'x') : -1);
    } else {
        uint32_t base = register_get32(cpu_r(cpu, (int)df_get(v, 'b'))) >> 16;
        uint32_t disp = df_get(v, 'd') << (v->addrWidth - 1);
        ea = base + disp;
        /* THE AP-101S DOES NOT MASK BIT 15 FOR FULLWORD OPERANDS.  The
         * AP-101S instruction set, section 2, says so as a deliberate
         * change from the machine the older POO describes:
         *
         *   "Unlike previous versions of this architecture, bit 15 of a
         *    base register is significant when addressing fullword data.
         *    Fullword storage operands may now be located on odd address
         *    boundaries.  Programs which utilize this feature will not be
         *    downward compatible."
         *
         * FCMINSSL uses exactly that feature: FCMCTXT1/FCMCTXT2 are DS 7H
         * back to back, so one of the two context structs always starts
         * odd, and FCMMOVE reads it with a fullword L.  Masking sent three
         * of phase 2's six above-128K load blocks to address 0.
         *
         * The superseded rule, kept because it is easy to re-derive from
         * the older manual and wrongly re-apply -- AP-101 C/M POO section
         * 2, the note to Figure 2-8 "SRS Fullword Addressing":
         *
         *   "Even though the addition of a base and the fullword
         *    displacement [results] in a halfword address, bit 15 is
         *    ignored when addressing fullword second operands.  As a
         *    result, the same fullword address is obtained regardless of
         *    the contents of base bit position 15."
         *
         * This mask was inherited from gpc with no citation and was under
         * suspicion, because it is what makes FCMINSSL's FCMMOVE read the
         * wrong fullword out of its odd-addressed context struct.  The POO
         * That note describes the C/M, NOT the S.  Both manuals agree on
         * the scaling above -- for fullwords the displacement's LSB aligns
         * with base bit 14, halfwords with bit 15, which is the
         * << (width-1) -- and differ only on whether bit 15 survives.
         *
         * 266 cpu EA/CC fixtures encode the masking and now fail; every
         * one is an "ea=<odd> expected <even>" case.  They are gpc-derived
         * and gpc implements the C/M rule, which this project documents as
         * non-authoritative.  See exec_ISPB, which had to change with it.
         */
        if (v->addrWidth == 2) {
            if ((ea & 1) && getenv("YAGPC_ALIGNTRACE"))
                fprintf(stderr, "ALIGN nia=%05x ea=%05x->%05x b=%u\n",
                        (unsigned)psw_get_nia(&cpu->psw), ea, ea & 0xfffe,
                        (unsigned)df_get(v, 'b'));
            /* AP-101S: NO MASK.  See the block comment below. */
        }
        /* g_BASE_DSE(v, FALSE) here, unlike the RS branch above: "when B2
         * equals 11, base addressing is not performed" is an RS-format
         * rule, so in SRS register 3 is an ordinary base register and its
         * own DSE applies like any other's.  Excluding it -- what this
         * did -- put every SRS reference through R3 a sector out. */
        if (df_has(v, 'b')) {
            uint32_t dseVal = registerfile_get_dse(&cpu->regFiles[psw_get_reg_set(&cpu->psw)], (int)df_get(v, 'b'));
            ea = cpu_g_expand_dse(cpu, ea, v->opType, dseVal);
        } else {
            ea = cpu_g_expand(cpu, ea, v->opType);
        }
    }
    return ea;
}

uint32_t cpu_g_ea_16(CPU *cpu, DInstr *v) {
    uint32_t ic16 = pb_get_field(register_get32(&cpu->psw.psw1), &cpu->psw.pack1.field[(unsigned char)'p']);
    uint32_t ea;

    if (v->niaIncr == 2 && !df_has(v, 'I')) {
        uint32_t disp = df_get(v, 'd');
        uint32_t base = (df_get(v, 'b') == 3) ? 0 : (register_get32(cpu_r(cpu, (int)df_get(v, 'b'))) >> 16);
        uint32_t pea = base + disp;

        if (df_has(v, 'i')) {
            uint32_t idx = df_get(v, 'i');
            if (idx == 0) {
                if (v->ii == 0 && v->ia == 0) {
                    ea = (ic16 + pea) & 0xffff;
                } else if (v->ia == 0 && v->ii == 1) {
                    ea = (ic16 - pea) & 0xffff;
                } else if (v->ia == 1 && v->ii == 0) {
                    cpu->xtCase = 3;   /* see cpu_g_ea's step 5 */
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectHW = membus_get16(cpu->ram, indirectAddr);
                    ea = indirectHW & 0xffff;
                } else {
                    cpu->xtCase = 5;   /* auto storage modification */
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectFW = membus_get32(cpu->ram, indirectAddr);
                    /* "Then, AFTER the EA has been formed, storage
                     * modification is automatically performed... The
                     * modifier is added to the address and the resulting
                     * modified address replaces bits 0 through 15 of the
                     * indirect address word" (Step 6, Figure 2-15).  The
                     * access uses the address as it stands; the modified
                     * one is what the NEXT use of the pointer sees.  This
                     * used to add the modifier before forming the EA, so
                     * every auto-modified reference ran one step ahead of
                     * itself -- GPCIPL's DSE self-test at +0d88 read the
                     * wrong fullword back. */
                    uint32_t modifier = indirectFW & 0xffff;
                    ea = (indirectFW >> 16) & 0xffff;
                    uint32_t modifiedAddr = (ea + modifier) & 0xffff;
                    membus_set32(cpu->ram, indirectAddr,
                                 (modifiedAddr << 16) + modifier, true);
                }
            } else {
                Register *ri = cpu_r(cpu, (int)idx);
                if (v->ia == 0 && v->ii == 0) {
                    uint32_t regx = (register_get32(ri) >> 16) << (v->indexWidth - 1);
                    ea = (pea + regx) & 0xffff;
                } else if (v->ia == 0 && v->ii == 1) {
                    cpu->xtCase = 6;   /* auto indexing */
                    uint32_t regx = (register_get32(ri) >> 16) << (v->indexWidth - 1);
                    uint32_t modifier = register_get32(ri) & 0xffff;
                    ea = (pea + regx) & 0xffff;
                    /* Index register's own address field, not the EA --
                     * see the 19-bit path above for the citation. */
                    uint32_t modifiedAddr =
                        ((register_get32(ri) >> 16) + modifier) & 0xffff;
                    register_set32(ri, (modifiedAddr << 16) + modifier);
                } else if (v->ia == 1 && v->ii == 0) {
                    cpu->xtCase = 1;   /* see cpu_g_ea's step 9 */
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectHW = membus_get16(cpu->ram, indirectAddr);
                    uint32_t regx = (register_get32(ri) >> 16) << (v->indexWidth - 1);
                    ea = (indirectHW + regx) & 0xffff;
                } else {
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectFW = membus_get32(cpu->ram, indirectAddr);
                    uint32_t address16 = (indirectFW >> 16) & 0xffff;
                    uint32_t xc = (indirectFW >> 11) & 1;
                    /* Timing only: the C bit of the ZCON pointer.  The
                     * 16-bit path has no use for it otherwise. */
                    cpu->xtCase = (int)(1 + xc * 2 + ((indirectFW >> 10) & 1));
                    uint32_t regx = (register_get32(ri) >> 16) << (v->indexWidth - 1);
                    ea = (xc == 0) ? ((address16 + regx) & 0xffff) : (address16 & 0xffff);
                }
            }
        } else {
            ea = pea & 0xffff;
        }
        if (v->addrWidth == 2 && (ea & 1) && getenv("YAGPC_RSALIGNTRACE"))
            fprintf(stderr, "RSALIGN B nia=%05x ea=%05x b=%d ia=%d ii=%d x=%d\n",
                    (unsigned)psw_get_nia(&cpu->psw), ea,
                    df_has(v,'b') ? (int)df_get(v,'b') : -1,
                    (int)v->ia, (int)v->ii,
                    df_has(v,'x') ? (int)df_get(v,'x') : -1);
    } else {
        uint32_t base = register_get32(cpu_r(cpu, (int)df_get(v, 'b'))) >> 16;
        uint32_t disp = df_get(v, 'd') << (v->addrWidth - 1);
        ea = base + disp;
        ea = ea & 0xffff;
    }
    return ea;
}

uint32_t cpu_g_eaf(CPU *cpu, DInstr *v, int extraOffset) {
    uint32_t ea = cpu_g_ea(cpu, v) + (uint32_t)extraOffset;
    uint32_t val = (membus_get16(cpu->ram, ea) << 16) + membus_get16(cpu->ram, ea + 1);
    /* YAGPC_WATCHRD=<hexaddr> traces every fullword CPU READ of that
     * address, with the reading NIA.  A poll loop is invisible to
     * YAGPC_WATCHHW, which only sees stores, so "what did the wait
     * actually see" needs its own hook. */
    cpu_ea_trace(cpu, ea);
    cpu_ea_watch(cpu, ea);
    {
        static int inited = 0;
        static long watch = -1;
        if (!inited) {
            const char *w = getenv("YAGPC_WATCHRD");
            if (w != NULL) watch = strtol(w, NULL, 16);
            inited = 1;
        }
        if (watch >= 0 && (long)ea == watch)
            fprintf(stderr, "WATCHRD addr=%05x val=%08x nia=%05x t=%.1f\n",
                    (unsigned)ea, (unsigned)val,
                    (unsigned)psw_get_nia(&cpu->psw), cpu->elapsedTimeUs);
    }
    return val;
}

uint32_t cpu_g_eah(CPU *cpu, DInstr *v) {
    uint32_t ea = cpu_g_ea(cpu, v);
    cpu_ea_trace(cpu, ea);
    cpu_ea_watch(cpu, ea);
    return membus_get16(cpu->ram, ea);
}

void cpu_s_eaf(CPU *cpu, DInstr *v, uint32_t value, int extraOffset) {
    cpu_store_fw(cpu, cpu_g_ea(cpu, v) + (uint32_t)extraOffset, value);
}

void cpu_s_eah(CPU *cpu, DInstr *v, uint32_t value) {
    cpu_store_hw(cpu, cpu_g_ea(cpu, v), value);
}

uint32_t cpu_g_shift_cnt(CPU *cpu, uint32_t hw1) {
    uint32_t insBits = (hw1 >> 2) & 0x3f;
    if (insBits > 55) {
        uint32_t srcReg = insBits - 56;
        return (register_get32(cpu_r(cpu, (int)srcReg)) >> 16) & 0x3f;
    }
    return insBits;
}

/* ---------------------------------------------------------------------
 * Reset / fetch-decode-execute
 * ------------------------------------------------------------------- */

/* ---------------------------------------------------------------------
 * IU store-conflict model (POO sect.15 DIAGNOSE, sect.16.8)
 *
 * "The actual detection circuitry uses the range of IC-1 to IC+23",
 * compared on "the 15 least significant bits of the logical address"
 * with 7FFF/0000 and FFFF/8000 contiguous.  Only the detection-OFF case
 * needs modelling, and it needs no IU file: keep the pre-store halfword
 * for the window the IU could have reached and hand it to the
 * instruction fetch instead of storage, until the next discontinuity
 * flushes it.  With detection ON -- the power-up state -- a conflict
 * purges the file, and a model that always refetches is
 * indistinguishable from one that purges, so none of this runs.
 * ------------------------------------------------------------------- */

#define IU_WINDOW_AHEAD 23

void cpu_iu_shadow_flush(CPU *cpu) { cpu->iuShadowCount = 0; }

static bool iu_shadow_lookup(const CPU *cpu, uint32_t addr, uint16_t *out) {
    for (int i = 0; i < cpu->iuShadowCount; i++) {
        if (cpu->iuShadow[i].addr == addr) { *out = cpu->iuShadow[i].val; return true; }
    }
    return false;
}

void cpu_shadow_iu_store(CPU *cpu, uint32_t addr) {
    if (cpu->diagIuStoreDetect) return;
    uint32_t d = (addr - cpu->curIC) & 0x7fffu;
    if (!(d <= IU_WINDOW_AHEAD || d == 0x7fffu)) return;   /* 0x7fff == IC-1 */
    uint16_t ignored;
    if (iu_shadow_lookup(cpu, addr, &ignored)) return;     /* first value wins */
    if (cpu->iuShadowCount == cpu->iuShadowCap) {
        int cap = cpu->iuShadowCap ? cpu->iuShadowCap * 2 : 32;
        IuShadowEntry *grown = realloc(cpu->iuShadow, (size_t)cap * sizeof *grown);
        if (!grown) return;   /* out of memory: behave as a machine that purged */
        cpu->iuShadow = grown;
        cpu->iuShadowCap = cap;
    }
    cpu->iuShadow[cpu->iuShadowCount].addr = addr;
    cpu->iuShadow[cpu->iuShadowCount].val = (uint16_t)membus_get16(cpu->ram, addr);
    cpu->iuShadowCount++;
}

/* YAGPC_WATCHHW=<hexaddr> traces every CPU store to that halfword address
 * (and to the fullword beginning there), with the storing NIA and the
 * simulated timestamp.  Used to order a CPU-side flag arm against the BCE's
 * #SST that is supposed to clear it. */
/* YAGPC_RINGTRIG=<hexaddr>:<hexhalfword> dumps the NIA ring the first time
 * that halfword is stored with that value.  A watchpoint says which
 * instruction wrote a bad value; only the ring says how execution got
 * there, which is the difference between "this store is wrong" and "the
 * caller handed this routine a wrong pointer". */
static void cpu_ring_trigger(CPU *cpu, uint32_t addr, uint32_t value) {
    static int inited = 0, fired = 0;
    static long trigAddr = -1, trigVal = -1;
    if (!inited) {
        inited = 1;
        const char *w = getenv("YAGPC_RINGTRIG");
        if (w != NULL) {
            char *end = NULL;
            trigAddr = strtol(w, &end, 16);
            trigVal = (end != NULL && *end == ':') ? strtol(end + 1, NULL, 16) : -1;
        }
    }
    if (fired || trigAddr < 0) return;
    if ((long)addr != trigAddr || (long)(value & 0xffff) != trigVal) return;
    fired = 1;
    fprintf(stderr, "RINGTRIG %05x=%04x t=%.1f\n", (unsigned)addr,
            (unsigned)(value & 0xffff), cpu->elapsedTimeUs);
    cpu_dump_nia_ring(cpu, "RINGTRIG", psw_get_nia(&cpu->psw));
}

static void cpu_watch_store(CPU *cpu, uint32_t addr, uint32_t value,
                            const char *kind) {
    cpu_ring_trigger(cpu, addr, value);
    static int inited = 0;
    static long lo = -1, hi = -1;
    if (!inited) {
        const char *w = getenv("YAGPC_WATCHHW");
        if (w != NULL) {
            char *end = NULL;
            lo = strtol(w, &end, 16);
            hi = (end != NULL && *end == '-') ? strtol(end + 1, NULL, 16)
                                              : lo + 1;
        }
        inited = 1;
    }
    if (lo < 0) return;
    if ((long)addr < lo || (long)addr > hi) return;
    /* The protect bit and the pre-store contents both matter: cpu_store_fw
     * tests protection BEFORE writing and returns without writing, so a
     * refused store is otherwise indistinguishable from one that took. */
    fprintf(stderr, "WATCHHW %s addr=%05x val=%08x was=%04x prot=%d%s "
                    "nia=%05x t=%.1f\n",
            kind, (unsigned)addr, (unsigned)value,
            (unsigned)membus_get16(cpu->ram, addr),
            (int)membus_get_store_protect(cpu->ram, addr),
            cpu->storeProtectOverride ? " ovr" : "",
            (unsigned)psw_get_nia(&cpu->psw), cpu->elapsedTimeUs);
}

bool cpu_store_hw(CPU *cpu, uint32_t addr, uint32_t value) {
    cpu_watch_store(cpu, addr, value, "hw");
    if (!cpu->diagIuStoreDetect) cpu_shadow_iu_store(cpu, addr);
    if (membus_set16(cpu->ram, addr, value, !cpu->storeProtectOverride)) return true;
    cpu->lastProtFaultAddr = addr;
    cpu_signal_protection_violation(cpu);
    return false;
}

bool cpu_store_fw(CPU *cpu, uint32_t addr, uint32_t value) {
    cpu_watch_store(cpu, addr, value, "fw");
    if (!cpu->diagIuStoreDetect) {
        cpu_shadow_iu_store(cpu, addr);
        cpu_shadow_iu_store(cpu, addr + 1);
    }
    /* Both protect bits are tested before either half is written, so a
     * fullword store that straddles a protection boundary leaves neither
     * half changed -- this used to write the high half and only then
     * discover the low half was protected.  The two halves go one at a
     * time, which is also how they are addressed: main storage is two
     * MCMs and only the halfword path routes between them. */
    if (!cpu->storeProtectOverride &&
        (membus_get_store_protect(cpu->ram, addr) ||
         membus_get_store_protect(cpu->ram, addr + 1))) {
        /* Record which halfword actually refused.  Without this a fullword
         * violation left lastProtFaultAddr holding whatever the last
         * HALFWORD violation had set, so YAGPC_INTTRACE reported a stale
         * address -- and a stale one from the self-test, which is exactly
         * the sort of plausible-looking wrong answer that costs an hour. */
        cpu->lastProtFaultAddr =
            membus_get_store_protect(cpu->ram, addr) ? addr : addr + 1;
        cpu_signal_protection_violation(cpu);
        return false;
    }
    membus_set16(cpu->ram, addr, (value >> 16) & 0xffff, false);
    membus_set16(cpu->ram, addr + 1, value & 0xffff, false);
    return true;
}

/* Print the recorded instruction addresses, oldest first.  Called from the
 * Instruction Monitor and from run.c's invalid-instruction stop, which are
 * the two ways a wild branch becomes visible. */
void cpu_dump_nia_ring(CPU *cpu, const char *why, uint32_t nia) {
    if (cpu == NULL || cpu->niaRing == NULL || cpu->niaRingFilled < 2) return;
    fprintf(stderr, "NIARING (oldest first) before %s at %05x:\n",
            why, (unsigned)nia);
    unsigned n = cpu->niaRingFilled;
    unsigned start = (cpu->niaRingPos + cpu->niaRingCap - n) % cpu->niaRingCap;
    for (unsigned i = 0; i < n; i++) {
        if (i % 8 == 0) fprintf(stderr, "   ");
        fprintf(stderr, " %05x",
                (unsigned)cpu->niaRing[(start + i) % cpu->niaRingCap]);
        if (i % 8 == 7) fprintf(stderr, "\n");
    }
    if (n % 8) fprintf(stderr, "\n");
    cpu->niaRingFilled = 0;
}

void cpu_reset(CPU *cpu) {
    cpu->storeProtectOverride = false;
    cpu->prevDiscont = false;
    cpu_iu_shadow_flush(cpu);
    cpu_load_psw(cpu, membus_get32(cpu->ram, 0x14), membus_get32(cpu->ram, 0x16));
}

/* Power-On is its OWN interrupt class with its OWN PSA vector, distinct
 * from System Reset -- AP-101S-instruction-set.txt Figure 2-20 lists all
 * three power-class entries separately:
 *
 *      00  Power  old PSW 0010   CPU Power Off (Microcode Put Away)
 *      01  Power  new PSW 0004   CPU Power On
 *      02  Power  new PSW 0014   CPU System Reset
 *
 * and MLIB80/PSA.asm, the flight software's own PSA, defines the two
 * start-up vectors as different symbols landing on different code:
 *
 *      SPWRONN  DC  Y(FAILEXEC)   POWER ON RESET-START UP PSW      (0x04)
 *      SRESINTN DC  Y(IOPHISAM)   SYSTEM RESET = START UP ENTRY POINT2 (0x14)
 *
 * Sec. 2.5.3.1's prose ("the second mode at power-on enters the run state
 * after the system reset is complete") is what previously led this file to
 * use 0x14 for both: it names the system reset *function* of Sec. 2.5.3.2
 * (clear pending interrupts, reset timers/status, zero the DSE registers),
 * which a power-on does perform -- NOT the System Reset *vector*. Entering
 * a real power-on at IOPHISAM skips whatever FAILEXEC does first, which is
 * exactly the failure that made GPCIPL's self-test wild-branch into
 * unfilled memory at a fixed instruction count no matter what content the
 * composed image actually carried. */
void cpu_power_on(CPU *cpu) {
    cpu->storeProtectOverride = false;
    cpu->prevDiscont = false;
    cpu_iu_shadow_flush(cpu);
    cpu_load_psw(cpu, membus_get32(cpu->ram, 0x04), membus_get32(cpu->ram, 0x06));
}

/* ---------------------------------------------------------------------
 * The wait state, paced against real time
 *
 * Instruction fetch is what the wait state suspends; everything else --
 * the interval timers, the IOP and its watchdog, a peripheral answering
 * on a bus -- keeps running, and one of them is what ends the wait.  A
 * runner that wants the machine to keep the SAME clock as an external
 * peripheral drives these from the wall clock rather than free-running
 * them; see rtpacer.h.
 * ------------------------------------------------------------------- */

/* The IOP is stepped at its slice rate, and time must advance WITH the
 * slices rather than in one jump before them: the IOP's two waiting
 * mechanisms are otherwise incommensurate.  A bus control element's
 * delay and time out are measured in simulated time, while a master
 * sequence controller's repeat instruction counts its own re-fetches.
 * A 1 ms step is about 2000 slices, so an @RAW waiting 848 repeats would
 * expire well inside a BCE's legitimate 10.7 ms #DLYI. */
#define IOP_SLICE_NS 500.0

bool cpu_can_wake(const CPU *cpu) {
    if (psw_get_int_mask(&cpu->psw) != 0) return true;
    /* The non-maskable classes, plus a machine check that is already
     * pending: nothing else can arrive with every system mask bit off. */
    return cpu->intPending.programCheck || cpu->intPending.svc ||
           cpu->intPending.machineCheck;
}

/* Ticks until counter n borrows past zero, which is (low + 1 + high *
 * 65536) away. */
static double timer_remaining_us(const CPU *cpu, int n) {
    uint32_t lo = (n == 2 ? cpu->counter2 : cpu->counter1) & 0xffffu;
    uint32_t hi = membus_get16(cpu->ram, n == 2 ? 0x00b1 : 0x00b0);
    return (double)lo + 1.0 + (double)hi * 65536.0;
}

double cpu_next_timer_ns(const CPU *cpu) {
    double best = 0.0;
    if (cpu->counter1Enabled) best = timer_remaining_us(cpu, 1);
    if (cpu->counter2Enabled) {
        double t = timer_remaining_us(cpu, 2);
        if (best == 0.0 || t < best) best = t;
    }
    if (best == 0.0) return 0.0;
    return best * 1000.0 - cpu->timerAccumUs * 1000.0;
}

double cpu_advance_idle_ns(CPU *cpu, double ns) {
    double done = 0.0;
    while (done < ns && psw_get_wait_state(&cpu->psw)) {
        /* Steps are at most 1 ms and are shortened to land exactly on the
         * next interval-timer expiry, so a wakeup is taken at its true
         * simulated time rather than a step late. */
        double step = ns - done;
        if (step > 1e6) step = 1e6;
        double tNs = cpu_next_timer_ns(cpu);
        if (tNs > 0.0 && tNs < step) step = tNs;
        if (step < 1.0) step = 1.0;   /* never stall on a zero step */
        done += step;

        /* The IOP's watchdog runs on wall time, not CPU instructions, so
         * it keeps counting through the wait state. */
        if (cpu->iop) iop_tick_watchdog(cpu->iop);

        if (cpu->iop && iop_any_processor_running(cpu->iop)) {
            double left = step;
            while (left > 0.0) {
                double slice = left < IOP_SLICE_NS ? left : IOP_SLICE_NS;
                cpu_advance_time_us(cpu, slice / 1000.0);
                left -= slice;
                cpu->idleIopNs += slice;
                while (cpu->idleIopNs >= IOP_SLICE_NS) {
                    cpu->idleIopNs -= IOP_SLICE_NS;
                    iop_exec_idle(cpu->iop);
                }
            }
        } else {
            cpu_advance_time_us(cpu, step / 1000.0);
            cpu->idleIopNs = 0.0;
        }
        cpu_check_interrupts(cpu);
    }
    return done;
}

void cpu_run(CPU *cpu) {
    while (!psw_get_wait_state(&cpu->psw)) {
        cpu_exec1(cpu);
    }
}

void cpu_exec1(CPU *cpu) {
    uint32_t nia = psw_get_nia(&cpu->psw);
    cpu->curIC = nia;
    uint32_t hw1 = membus_get16(cpu->ram, nia);
    uint32_t hw2 = membus_get16(cpu->ram, nia + 1);
    /* A halfword the IU already held when a store rewrote it, with
     * conflict detection off: the fetch sees what the IU has, not what
     * storage has.  See cpu_shadow_iu_store(). */
    if (cpu->iuShadowCount) {
        uint16_t held;
        if (iu_shadow_lookup(cpu, nia, &held)) hw1 = held;
        if (iu_shadow_lookup(cpu, nia + 1, &held)) hw2 = held;
    }

    DInstr v;
    memset(&v, 0, sizeof(v));
    const InstrDesc *desc = instr_decode(hw1, hw2, &v);
    if (!desc) {
        /* Unreachable from `gpc run`: cmd_run.coffee checks Instruction
         * .decode()'s result itself and reports "invalid instruction"
         * before ever calling exec1 (see gpc/cmd_run.coffee's run()).
         * Defensive no-op only. */
        return;
    }

    v.hw1 = hw1;
    v.hw2 = hw2;

    if (desc->pb.type == PB_TYPE_RS) {
        /* "0000000011111000" */
        if ((hw1 & 0xF8) == 0xF8) {
            if (!(hw1 & 4)) {
                df_set(&v, 'd', hw2);
            } else {
                df_set(&v, 'i', hw2 >> 13);
                v.hasIa = true;
                v.ia = (hw2 >> 12) & 1;
                v.hasIi = true;
                v.ii = (hw2 >> 11) & 1;
                /* "0000011111111111" */
                df_set(&v, 'd', hw2 & 0x7ff);
            }
        }
    }

    cpu_incr_nia(cpu, v.niaIncr);
    uint32_t seqNIA = psw_get_nia(&cpu->psw);  /* fall-through NIA */

    /* Instruction monitor: PSW bit 34 set and instruction unprotected.
     * gpc/cpu.coffee reads `@ram.protData[nia]` here directly — but
     * `@ram` is the CPU/IOP MemoryBus by the time exec1 runs (wired up
     * by AP101), and MemoryBus has no `protData` property of its own
     * (only mcm.coffee's per-MCM protData does); evaluating this would
     * throw in the real JS if PSW bit 34 were ever actually set. Since
     * `&&` short-circuits on the mask check, this is unreachable by any
     * program that doesn't set that mask bit, and no fixture in this
     * port's corpus does. Implemented here via the real accessor
     * (membus_get_store_protect) rather than reproducing the crash. */
    /* YAGPC_NIARING=<n>: remember the last n instruction addresses and dump
     * them when the Instruction Monitor fires.  A wild branch is invisible
     * to every other trace here -- the interrupt log shows only where
     * execution ARRIVED, and a full --trace over the ~200M instructions this
     * boot takes is not usable -- so the question "what branched into the
     * PSA" needs the few addresses immediately before it. */
    {
        static uint32_t *ring = NULL;
        static unsigned cap = 0, pos = 0, filled = 0;
        if (cap == 0) {
            const char *w = getenv("YAGPC_NIARING");
            char *end = NULL;
            long v = (w != NULL) ? strtol(w, &end, 10) : 0;
            cap = (w != NULL && end != w && *end == '\0' && v > 0 && v <= 4096)
                      ? (unsigned)v : 1u;
            ring = calloc(cap, sizeof *ring);
            if (ring == NULL) cap = 1;
        }
        if (ring != NULL && cap > 1) {
            ring[pos] = nia;
            pos = (pos + 1) % cap;
            if (filled < cap) filled++;
            cpu->niaRing = ring;
            cpu->niaRingCap = cap;
            cpu->niaRingPos = pos;
            cpu->niaRingFilled = filled;
        }
    }
    uint32_t intMask = psw_get_int_mask(&cpu->psw);
    if ((intMask & 0x20) && !membus_get_store_protect(cpu->ram, nia)) {
        cpu_dump_nia_ring(cpu, "the Instruction Monitor", nia);
        /* This is the Instruction Monitor, not a program check: it has
         * its own class, vector and mask bit (see cpu_check_interrupts),
         * and Figure 2-20 gives its interrupt code as N/A -- the 0x0009
         * this used to store is the exponent-underflow code. */
        cpu->intPending.instrMonitor = true;
    }

    /* Captured before execution -- some operands instr_time_us() needs
     * (e.g. MVH's count) aren't safe to re-read afterward. Computed
     * unconditionally now (previously only under --debug, in run.c's
     * batchrunner_step) so elapsedTimeUs stays meaningful whether or not
     * a debugger is attached -- see cpu.h's elapsedTimeUs comment. */
    cpu->xtCase = 0;
    uint32_t timePreN = instr_time_pre_n(cpu, desc, &v, hw1);

    if (desc->e) desc->e(cpu, &v);

    {
        bool branchTaken = psw_get_nia(&cpu->psw) != nia + (uint32_t)desc->pb.origLen;
        /* Through cpu_advance_time_us(), so this instruction's own
         * duration is what the interval timers advance by -- not one
         * flat tick per instruction, which is what this used to do. */
        cpu_advance_time_us(cpu, instr_time_us(cpu, desc, &v, timePreN, branchTaken));
    }

    cpu_check_interrupts(cpu);

    /* Sequential-fetch discontinuity (branch taken or interrupt swap):
     * the next instruction starts with an empty lookahead. */
    cpu->prevDiscont = psw_get_nia(&cpu->psw) != seqNIA;
    if (cpu->prevDiscont) cpu_iu_shadow_flush(cpu);
}

/* Counter decrement + interrupt dispatch, split out of cpu_exec1's tail so
 * a caller can advance it *without* fetching/decoding/executing a real
 * instruction -- needed for WAIT state (see run.c's batchrunner_step):
 * real hardware suspends instruction fetch while PSW bit 'w' is set, but
 * the clock/interrupt facility keeps running, and a still-armed Clock 1/2
 * (counter1Enabled/counter2Enabled) can independently underflow, go
 * pending, and (via cpu_check_interrupts, right here) swap in a new PSW
 * that clears the wait bit and resumes execution at the handler. Without
 * this split, a WAIT entered while a clock is armed can never wake up on
 * its own, because nothing ever calls this code again once the run loop
 * stops fetching instructions. */
/* Decrement one interval timer by `ticks` microseconds.
 *
 * The counter is 32 bits split across two places: the low halfword is the
 * hardware counter (cpu->counterN), the high halfword lives in main store
 * at hiAddr, which is what Read/Write Counter assemble their fullword
 * from.  On borrow the microcode decrements the high halfword -- writing
 * it directly, bypassing store protection, since no program asked for the
 * write.  When the high halfword is already zero at borrow time the count
 * has run out: the interrupt goes pending and the high halfword wraps to
 * FFFF, so the timer keeps running rather than stopping.
 *
 * ONLY WHEN THE INTERRUPT IS UNMASKED.  The borrow is an interrupt that
 * the microcode normally services invisibly, and the POO is explicit that
 * a masked one is not serviced at all: "When the low halfword (in the
 * hardware counter) passes from 0000 [to FFFF] an interrupt occurs which
 * CAN CAUSE the high halfword in main store [via] microcode to be
 * decremented by one....  [If the] interrupt is masked the high halfword
 * will not be decremented by [the microcode and the] low halfword
 * continues to count down."
 *
 * This used to decrement unconditionally, which is not a subtlety: the
 * high halfwords are PSA cells (00B0, 00B1) sitting in low store, and a
 * program that loads over them has every right to expect them to stay
 * put while it has the clocks masked off.  FCMBOOT does exactly that.
 * It reads GPCIPL's first load block -- 0x0000..0x3C21, which contains
 * 00B0 because GPCIPL supplies its own PSA -- and then checksums it with
 * clock interrupts masked, its own Clock 1 vector being a deliberate
 * wait-state PSW.  With the borrow carried through regardless, 00B0 drifted
 * five counts away from the value the tape had recorded between the load
 * and the sum, the checksum came out five short, and the bootstrap
 * rejected a block that was in fact perfect. */
/* One borrow out of the low halfword, applied to the high halfword in main
 * store -- and the PSW swap when that reaches zero. */
static void counter_borrow(CPU *cpu, uint32_t hiAddr, bool *pending) {
    uint32_t hi = membus_get16(cpu->ram, hiAddr);
    if (hi == 0) {
        membus_set16(cpu->ram, hiAddr, 0xffff, false);
        *pending = true;
        if (getenv("YAGPC_CLKTRACE"))
            fprintf(stderr, "CLK FIRE%d t=%.6f\n",
                    hiAddr == 0x00B0 ? 1 : 2, cpu->elapsedTimeUs / 1e6);
    } else {
        membus_set16(cpu->ram, hiAddr, hi - 1, false);
    }
}

static uint32_t tick_counter(CPU *cpu, uint32_t low, uint32_t hiAddr,
                             bool *pending, bool *deferred, uint32_t ticks) {
    /* Clock 1 is PSW mask bit 0x80, Clock 2 is 0x40 -- the same bits
     * cpu_check_interrupts tests before dispatching either. */
    uint32_t maskBit = (hiAddr == 0x00B0) ? 0x80u : 0x40u;
    bool unmasked = (psw_get_int_mask(&cpu->psw) & maskBit) != 0;

    /* A borrow that arrived while masked is owed, not forgotten: the
     * interrupt stayed pending, so unmasking pays it "without a loss of a
     * count".  Discarding it -- what this did -- ran both interval timers
     * slow by one wrap for every window a program masked them in. */
    if (unmasked && *deferred) {
        *deferred = false;
        counter_borrow(cpu, hiAddr, pending);
    }

    int32_t v = (int32_t)(low & 0xffff) - (int32_t)ticks;
    while (v < 0) {
        v += 0x10000;
        /* Masked: the low halfword goes on counting, the high one is left
         * alone, and the borrow is owed until the mask lifts.
         *
         * Except when the count has actually run out.  A borrow with the
         * high halfword already 0000 is not a decrement at all -- it is the
         * timeout, and the wrap to FFFF is how the hardware says so.  That
         * happens whether or not anyone is listening; masking only defers
         * the *interrupt*, which stays pending here either way.
         *
         * GPCIPL's own clock self-test (STM1 CLCK1000) is what settles
         * this.  It runs under SSM INHCLKS with both clock interrupts
         * masked, writes the counter, then adds 1 to the high halfword and
         * requires 0000 back.  Clock 1 is written FFFFFFFF and passes on
         * FFFF+1.  Clock 2 -- the loop never reloads R4, so it gets
         * whatever is left, 00000000 -- is written zero, times out on the
         * very next microsecond, and only reads back FFFF if that wrap is
         * allowed to happen while masked.  Defer it and the test reads
         * 0000, scores 0001, and reports error 206, "CLOCK2 CANNOT BE SET
         * TO ZEROS".  The reference emulator has no mask check at all and
         * so passes; deferring ordinary borrows is still needed here, or
         * FCMBOOT's 00B0 drifts out from under its own load. */
        if (!unmasked && membus_get16(cpu->ram, hiAddr) != 0) {
            *deferred = true;
            continue;
        }
        counter_borrow(cpu, hiAddr, pending);
    }
    return (uint32_t)v & 0xffffu;
}

/* The interval timers are 1 MHz hardware, so they advance with SIMULATED
 * TIME, not with instructions: a 2.8us instruction moves them nearly
 * three times as far as a 1us one.  This port decremented them once per
 * instruction instead, which made every instruction look equally long and
 * ran the timers at whatever rate the code being executed happened to
 * imply.  The per-instruction durations come from timing.c's HAL/S PASS2
 * model, so feeding them in here is what the accuracy of that model was
 * always for. */
void cpu_advance_time_us(CPU *cpu, double us) {
    cpu->elapsedTimeUs += us;
    cpu->timerAccumUs += us;
    if (cpu->timerAccumUs < 1.0) return;

    double whole = (double)(long)cpu->timerAccumUs;
    uint32_t ticks = (uint32_t)whole;
    cpu->timerAccumUs -= whole;
    if (ticks == 0) return;

    if (cpu->counter1Enabled) {
        cpu->counter1 = tick_counter(cpu, cpu->counter1, 0x00B0,
                                     &cpu->intPending.clk1,
                                     &cpu->counter1Deferred, ticks);
    }
    if (cpu->counter2Enabled) {
        cpu->counter2 = tick_counter(cpu, cpu->counter2, 0x00B1,
                                     &cpu->intPending.clk2,
                                     &cpu->counter2Deferred, ticks);
    }
}

/* One microsecond of wait-state time: the clock/interrupt facility keeps
 * running while instruction fetch is suspended, and one tick is the
 * timers' own resolution. */
void cpu_tick(CPU *cpu) {
    cpu_advance_time_us(cpu, 1.0);
    cpu_check_interrupts(cpu);
}
