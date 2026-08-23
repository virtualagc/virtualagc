#include "cpu.h"

#include <stdio.h>
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
    cpu->counter1 = 0;
    cpu->counter2 = 0;
    cpu->counter1Enabled = false;
    cpu->counter2Enabled = false;
    cpu->fcosMode = false;
    cpu->elapsedTimeUs = 0.0;
    cpu->dateTimeAnchorEpochSec = 0.0; /* Unix epoch -- see cpu.h's own comment */
}

void cpu_free(CPU *cpu) {
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

void cpu_compute_cc_logical(CPU *cpu, uint32_t result) {
    psw_set_cc(&cpu->psw, result == 0 ? 0 : 3);
}

void cpu_swap_psw(CPU *cpu, uint32_t oldAddr, uint32_t newAddr) {
    membus_set32(cpu->ram, oldAddr, register_get32(&cpu->psw.psw1), true);
    membus_set32(cpu->ram, oldAddr + 2, register_get32(&cpu->psw.psw2), true);
    uint32_t p1 = membus_get32(cpu->ram, newAddr);
    uint32_t p2 = membus_get32(cpu->ram, newAddr + 2);
    psw_load(&cpu->psw, p1, p2);
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

void cpu_check_interrupts(CPU *cpu) {
    if (cpu->intPending.machineCheck) {
        if (psw_get_mach_check_mask(&cpu->psw)) {
            cpu->intPending.machineCheck = false;
            psw_set_int_code(&cpu->psw, 0x0008);
            cpu_swap_psw(cpu, 0x0040, 0x0044);
            return;
        }
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
        cpu_swap_psw(cpu, 0x0048, 0x004c);
        return;
    }

    if (cpu->intPending.svc) {
        cpu->intPending.svc = false;
        cpu_swap_psw(cpu, 0x0058, 0x005c);
        return;
    }

    uint32_t intMask = psw_get_int_mask(&cpu->psw);

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
    if (cpu->intPending.ext1 && (intMask & 0x02)) {
        cpu->intPending.ext1 = false;
        cpu_swap_psw(cpu, 0x0070, 0x0074);
        return;
    }
    if (cpu->intPending.iopGrp1 && (intMask & 0x10)) {
        cpu->intPending.iopGrp1 = false;
        cpu_swap_psw(cpu, 0x0078, 0x007c);
        return;
    }
    if (cpu->intPending.iopGrp2 && (intMask & 0x08)) {
        cpu->intPending.iopGrp2 = false;
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
}

void cpu_signal_fixed_overflow(CPU *cpu) {
    if (psw_get_fixed_pt_overflow(&cpu->psw)) {
        cpu->intPending.programCheck = true;
        cpu->intCode = 0x0002;
    }
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
    cpu->intPending.programCheck = true;
    cpu->intCode = 0x0007;
}

void cpu_signal_addressing_exception(CPU *cpu) {
    cpu->intPending.programCheck = true;
    cpu->intCode = 0x0003;
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

uint32_t cpu_g_ea(CPU *cpu, DInstr *v) {
    uint32_t ea;

    if (v->niaIncr == 2 && !df_has(v, 'I')) {
        uint32_t disp = df_get(v, 'd');
        uint32_t base = (df_get(v, 'b') == 3) ? 0 : (register_get32(cpu_r(cpu, (int)df_get(v, 'b'))) >> 16);
        uint32_t pea = base + disp;

        if (df_has(v, 'i')) {
            uint32_t idx = df_get(v, 'i');
            if (idx == 0) {
                if (v->ii == 0 && v->ia == 0) {
                    ea = psw_get_nia(&cpu->psw) + pea;
                } else if (v->ia == 0 && v->ii == 1) {
                    ea = psw_get_nia(&cpu->psw) - pea;
                } else if (v->ia == 1 && v->ii == 0) {
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectHW = membus_get16(cpu->ram, indirectAddr);
                    ea = cpu_g_expand(cpu, indirectHW, v->opType);
                } else {
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectFW = membus_get32(cpu->ram, indirectAddr);
                    uint32_t modifier = indirectFW & 0xffff;
                    ea = cpu_g_expand(cpu, indirectFW >> 16, v->opType);
                    ea = ea + modifier;
                    membus_set32(cpu->ram, indirectAddr, (ea << 16) + modifier, true);
                }
            } else {
                Register *ri = cpu_r(cpu, (int)idx);
                if (v->ia == 0 && v->ii == 0) {
                    uint32_t regx = (register_get32(ri) >> 16) << (v->addrWidth - 1);
                    ea = cpu_g_expand(cpu, pea + regx, v->opType);
                } else if (v->ia == 0 && v->ii == 1) {
                    uint32_t regx = (register_get32(ri) >> 16) << (v->addrWidth - 1);
                    uint32_t modifier = register_get32(ri) & 0xffff;
                    uint32_t ea16 = (pea + regx) & 0xffff;
                    ea = cpu_g_expand(cpu, ea16, v->opType);
                    uint32_t modifiedAddr = (ea16 + modifier) & 0xffff;
                    register_set32(ri, (modifiedAddr << 16) + modifier);
                } else if (v->ia == 1 && v->ii == 0) {
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectHW = membus_get16(cpu->ram, indirectAddr);
                    uint32_t regx = (register_get32(ri) >> 16) << (v->addrWidth - 1);
                    ea = cpu_g_expand(cpu, indirectHW + regx, v->opType);
                } else {
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectFW = membus_get32(cpu->ram, indirectAddr);
                    uint32_t address16 = (indirectFW >> 16) & 0xffff;
                    uint32_t address15 = address16 & 0x7fff;
                    uint32_t xc = (indirectFW >> 11) & 1;
                    uint32_t c = (indirectFW >> 10) & 1;
                    uint32_t cb = (indirectFW >> 9) & 1;
                    uint32_t cd = (indirectFW >> 8) & 1;
                    uint32_t ptrBSR = (indirectFW >> 4) & 0xF;
                    uint32_t ptrDSR = indirectFW & 0xF;
                    uint32_t regx = (register_get32(ri) >> 16) << (v->addrWidth - 1);

                    if (c == 1) {
                        if (cd == 1) psw_set_dsr(&cpu->psw, ptrDSR);
                        if (cb == 1) psw_set_bsr(&cpu->psw, ptrBSR);
                    }
                    uint32_t effDSR = (c == 0) ? ptrDSR : psw_get_dsr(&cpu->psw);
                    if (v->opType == OPTYPE_BRCH) {
                        if (xc == 0) {
                            ea = (address15 + regx) & 0x7fff;
                            ea = (psw_get_bsr(&cpu->psw) << 15) + ea;
                        } else {
                            ea = (psw_get_bsr(&cpu->psw) << 15) + address15;
                        }
                    } else {
                        if (xc == 0) {
                            ea = (address15 + regx) & 0x7fff;
                            ea = (effDSR << 15) + ea;
                        } else {
                            ea = (effDSR << 15) + address15;
                        }
                    }
                }
            }
        } else {
            ea = cpu_g_expand(cpu, pea, v->opType);
        }
    } else {
        uint32_t base = register_get32(cpu_r(cpu, (int)df_get(v, 'b'))) >> 16;
        uint32_t disp = df_get(v, 'd') << (v->addrWidth - 1);
        ea = base + disp;
        if (v->addrWidth == 2) ea = ea & 0xfffe;
        if (df_has(v, 'b') && df_get(v, 'b') != 3) {
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
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectHW = membus_get16(cpu->ram, indirectAddr);
                    ea = indirectHW & 0xffff;
                } else {
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectFW = membus_get32(cpu->ram, indirectAddr);
                    uint32_t modifier = indirectFW & 0xffff;
                    ea = (indirectFW >> 16) & 0xffff;
                    ea = (ea + modifier) & 0xffff;
                    membus_set32(cpu->ram, indirectAddr, (ea << 16) + modifier, true);
                }
            } else {
                Register *ri = cpu_r(cpu, (int)idx);
                if (v->ia == 0 && v->ii == 0) {
                    uint32_t regx = (register_get32(ri) >> 16) << (v->addrWidth - 1);
                    ea = (pea + regx) & 0xffff;
                } else if (v->ia == 0 && v->ii == 1) {
                    uint32_t regx = (register_get32(ri) >> 16) << (v->addrWidth - 1);
                    uint32_t modifier = register_get32(ri) & 0xffff;
                    ea = (pea + regx) & 0xffff;
                    uint32_t modifiedAddr = (ea + modifier) & 0xffff;
                    register_set32(ri, (modifiedAddr << 16) + modifier);
                } else if (v->ia == 1 && v->ii == 0) {
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectHW = membus_get16(cpu->ram, indirectAddr);
                    uint32_t regx = (register_get32(ri) >> 16) << (v->addrWidth - 1);
                    ea = (indirectHW + regx) & 0xffff;
                } else {
                    uint32_t indirectAddr = cpu_g_expand(cpu, pea, OPTYPE_DATA);
                    uint32_t indirectFW = membus_get32(cpu->ram, indirectAddr);
                    uint32_t address16 = (indirectFW >> 16) & 0xffff;
                    uint32_t xc = (indirectFW >> 11) & 1;
                    uint32_t regx = (register_get32(ri) >> 16) << (v->addrWidth - 1);
                    ea = (xc == 0) ? ((address16 + regx) & 0xffff) : (address16 & 0xffff);
                }
            }
        } else {
            ea = pea & 0xffff;
        }
    } else {
        uint32_t base = register_get32(cpu_r(cpu, (int)df_get(v, 'b'))) >> 16;
        uint32_t disp = df_get(v, 'd') << (v->addrWidth - 1);
        ea = base + disp;
        if (v->addrWidth == 2) ea = ea & 0xfffe;
        ea = ea & 0xffff;
    }
    return ea;
}

uint32_t cpu_g_eaf(CPU *cpu, DInstr *v, int extraOffset) {
    uint32_t ea = cpu_g_ea(cpu, v) + (uint32_t)extraOffset;
    return (membus_get16(cpu->ram, ea) << 16) + membus_get16(cpu->ram, ea + 1);
}

uint32_t cpu_g_eah(CPU *cpu, DInstr *v) {
    uint32_t ea = cpu_g_ea(cpu, v);
    return membus_get16(cpu->ram, ea);
}

void cpu_s_eaf(CPU *cpu, DInstr *v, uint32_t value, int extraOffset) {
    uint32_t ea = cpu_g_ea(cpu, v) + (uint32_t)extraOffset;
    if (!membus_set16(cpu->ram, ea, value >> 16, true)) {
        cpu_signal_protection_violation(cpu);
        return;
    }
    if (!membus_set16(cpu->ram, ea + 1, value & 0xffff, true)) {
        cpu_signal_protection_violation(cpu);
        return;
    }
}

void cpu_s_eah(CPU *cpu, DInstr *v, uint32_t value) {
    uint32_t ea = cpu_g_ea(cpu, v);
    if (!membus_set16(cpu->ram, ea, value, true)) {
        cpu_signal_protection_violation(cpu);
        return;
    }
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

void cpu_reset(CPU *cpu) {
    psw_load(&cpu->psw, membus_get32(cpu->ram, 0x14), membus_get32(cpu->ram, 0x16));
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
    psw_load(&cpu->psw, membus_get32(cpu->ram, 0x04), membus_get32(cpu->ram, 0x06));
}

void cpu_run(CPU *cpu) {
    while (!psw_get_wait_state(&cpu->psw)) {
        cpu_exec1(cpu);
    }
}

void cpu_exec1(CPU *cpu) {
    uint32_t nia = psw_get_nia(&cpu->psw);
    uint32_t hw1 = membus_get16(cpu->ram, nia);
    uint32_t hw2 = membus_get16(cpu->ram, nia + 1);

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
    uint32_t intMask = psw_get_int_mask(&cpu->psw);
    if ((intMask & 0x20) && !membus_get_store_protect(cpu->ram, nia)) {
        cpu->intPending.programCheck = true;
        cpu->intCode = 0x0009;
    }

    /* Captured before execution -- some operands instr_time_us() needs
     * (e.g. MVH's count) aren't safe to re-read afterward. Computed
     * unconditionally now (previously only under --debug, in run.c's
     * batchrunner_step) so elapsedTimeUs stays meaningful whether or not
     * a debugger is attached -- see cpu.h's elapsedTimeUs comment. */
    uint32_t timePreN = instr_time_pre_n(cpu, desc, &v, hw1);

    if (desc->e) desc->e(cpu, &v);

    {
        bool branchTaken = psw_get_nia(&cpu->psw) != nia + (uint32_t)desc->pb.origLen;
        cpu->elapsedTimeUs += instr_time_us(desc, &v, timePreN, branchTaken);
    }

    cpu_tick(cpu);
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
void cpu_tick(CPU *cpu) {
    if (cpu->counter1Enabled) {
        cpu->counter1--;
        if ((int32_t)cpu->counter1 <= 0) {
            cpu->counter1 = membus_get16(cpu->ram, 0x00B0) << 16;
            cpu->intPending.clk1 = true;
        }
    }
    if (cpu->counter2Enabled) {
        cpu->counter2--;
        if ((int32_t)cpu->counter2 <= 0) {
            cpu->counter2 = membus_get16(cpu->ram, 0x00B1) << 16;
            cpu->intPending.clk2 = true;
        }
    }

    cpu_check_interrupts(cpu);
}
