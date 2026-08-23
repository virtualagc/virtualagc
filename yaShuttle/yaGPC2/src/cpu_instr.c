/* CPU instruction set, ported from gpc/cpu_instr.coffee.
 *
 * Out of scope (never reached by `gpc run` — see cpu_instr.coffee):
 *   - `encode()`: used only by the assembler (gpc/lnkasm), never by run/
 *     decode/exec.
 *   - `toStr()`/`execInstr()`: toStr is ported separately in trace.c
 *     (Phase 9, disassembly-for-trace-output); execInstr is dead code
 *     (decodes but never dispatches).
 *   - `PackedBits`-derived scratch fields on the Instruction singleton
 *     (`rs_d`, `rs_ae`, `rs_ai`, `d_rs_ae`, `d_rs_ai`, the `argTypes`
 *     const): only referenced by `encode()`.
 *
 * Decode strategy: gpc/util.coffee's PackedBits#makeDesc + cpu_instr.coffee's
 * makeOpTbl parse each instruction's bit-pattern string into
 * (mask, maskedVal) once at startup; decode() tries candidate masks from
 * most-specific (highest numeric mask) to least, first exact
 * (hw1 & mask) == maskedVal match wins. Ported here as a flat table
 * sorted by mask descending at init time (cpu_instr_table_init), scanned
 * linearly — behaviorally identical to the JS's per-mask-then-hash
 * lookup (see this phase's dev notes: verified the real 135-instruction
 * mask set needs no lexicographic-vs-numeric-sort quirk-replication,
 * since both orderings coincide for the actual data). */
#include "cpu_instr.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "floatIBM.h"
#include "q31.h"
#include "strfmt.h"

/* ---------------------------------------------------------------------
 * Raw table: {name, bit-pattern, exec, addrWidth, opType}
 * ------------------------------------------------------------------- */

typedef struct {
    const char *nm;
    const char *pattern;
    InstrExecFn e;
    int addrWidth;
    int opType;
} OpEntry;

/* r(v.c) shorthand, matching the source's `t.r(v.x)` / `t.r(v.y)` etc. */
static inline Register *R(CPU *t, DInstr *v, char c) {
    return cpu_r(t, (int)df_get(v, c));
}

/* ---------------------------------------------------------------------
 * Exec bodies — data movement / fixed-point arithmetic batch
 * ------------------------------------------------------------------- */

static void exec_PC(CPU *t, DInstr *v) {
    if (!cpu_i_super(t)) return;
    /* R1 ('x') is the DATA register, R2 ('y') holds the control word --
     * instruction set Sec. 3.3: "transfers a fullword to or from the
     * general register specified by R1.  Direct I/O operations are
     * defined by a control word (CW) contained in the general register
     * specified by R2", and for input the channel "loads 32 bits of
     * information ... into general register R1".  The two were swapped
     * here, so the CW was read from R1: at GPCIPL's Group 1 interrupt
     * handler, PC 3,7 took R3 (0xffffffff, the just-loaded data) as the
     * CW, whose bit 0 made it look like an OUTPUT, so the input branch
     * never ran and R3 was left unwritten -- and the IOP was handed
     * 0xffffffff as a command. */
    uint32_t cmd = register_get32(R(t, v, 'y'));
    uint32_t data = register_get32(R(t, v, 'x'));
    cpu_send_to_iop(t, cmd, data);
    bool isOutput = (cmd >> 31) != 0;
    if (!isOutput) {
        register_set32(R(t, v, 'x'), cpu_recv_from_iop(t));
    }
    psw_set_cc(&t->psw, 0);
}

static void exec_AR(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = register_get32(R(t, v, 'y'));
    uint32_t result = cpu_add_fixed(t, v1, v2, 0);
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_arith(t, result, 0);
}

static void exec_A(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = cpu_g_eaf(t, v, 0);
    uint32_t result = cpu_add_fixed(t, v1, v2, 0);
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_arith(t, result, 0);
}

static void exec_AH(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = cpu_g_eah(t, v) << 16;
    uint32_t result = cpu_add_fixed(t, v1, v2, 0);
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_arith(t, result, 0);
}

static void exec_AHI(CPU *t, DInstr *v) {
    uint32_t v1 = df_get(v, 'I') << 16;
    uint32_t v2 = register_get32(R(t, v, 'y'));
    uint32_t result = cpu_add_fixed(t, v1, v2, 0);
    register_set32(R(t, v, 'y'), result);
    cpu_compute_cc_arith(t, result, 0);
}

static void exec_AST(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = cpu_g_eaf(t, v, 0);
    uint32_t result = cpu_add_fixed(t, v1, v2, 0);
    cpu_s_eaf(t, v, result, 0);
    cpu_compute_cc_arith(t, result, 0);
}

static void exec_CR(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = register_get32(R(t, v, 'y'));
    cpu_compute_cc_arith(t, v1, v2);
}

static void exec_C(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = cpu_g_eaf(t, v, 0);
    cpu_compute_cc_arith(t, v1, v2);
}

static void exec_CBL(CPU *t, DInstr *v) {
    uint32_t r1val = register_get32(R(t, v, 'x'));
    uint32_t r2val = register_get32(R(t, v, 'y'));
    uint32_t operandAddr = cpu_g_expand(t, (r1val >> 16) & 0xffff, OPTYPE_DATA);
    uint32_t limitsAddr = cpu_g_expand(t, (r2val >> 16) & 0xffff, OPTYPE_DATA);
    int32_t operand = (int32_t)(int16_t)(uint16_t)membus_get16(t->ram, operandAddr);
    int32_t upperLimit = (int32_t)(int16_t)(uint16_t)membus_get16(t->ram, limitsAddr);
    int32_t lowerLimit = (int32_t)(int16_t)(uint16_t)membus_get16(t->ram, limitsAddr + 1);
    if (operand < lowerLimit) psw_set_cc(&t->psw, 3);
    else if (operand > upperLimit) psw_set_cc(&t->psw, 1);
    else psw_set_cc(&t->psw, 0);
    uint32_t r1mod = r1val & 0xffff;
    uint32_t r1addr = ((r1val >> 16) + r1mod) & 0xffff;
    register_set32(R(t, v, 'x'), (r1addr << 16) | r1mod);
    uint32_t r2mod = r2val & 0xffff;
    uint32_t r2addr = ((r2val >> 16) + r2mod) & 0xffff;
    register_set32(R(t, v, 'y'), (r2addr << 16) | r2mod);
}

static void exec_CH(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = cpu_g_eah(t, v) << 16;
    cpu_compute_cc_arith(t, v1, v2);
}

static void exec_CHI(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'y'));
    uint32_t v2 = df_get(v, 'I') << 16;
    cpu_compute_cc_arith(t, v1, v2);
}

static void exec_CIST(CPU *t, DInstr *v) {
    uint32_t v1 = df_get(v, 'I');
    uint32_t v2 = cpu_g_eah(t, v);
    cpu_compute_cc_arith(t, v1, v2);
}

static void exec_DR(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    uint32_t hi = register_get32(R(t, v, 'x'));
    uint32_t lo = (x % 2) ? 0 : register_get32(cpu_r(t, (int)(x + 1)));
    Q31DivResult r = q31_div((int32_t)hi, (int32_t)lo, (int32_t)register_get32(R(t, v, 'y')));
    register_set32(R(t, v, 'x'), (uint32_t)r.quotient);
    if (r.overflow) psw_set_overflow(&t->psw, 1);
}

static void exec_D(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    uint32_t hi = register_get32(R(t, v, 'x'));
    uint32_t lo = (x % 2) ? 0 : register_get32(cpu_r(t, (int)(x + 1)));
    Q31DivResult r = q31_div((int32_t)hi, (int32_t)lo, (int32_t)cpu_g_eaf(t, v, 0));
    register_set32(R(t, v, 'x'), (uint32_t)r.quotient);
    if (r.overflow) psw_set_overflow(&t->psw, 1);
}

/* Exchange Upper and Lower Halfwords -- an EXCHANGE, with no XOR
 * anywhere in it, which is what this used to compute:
 *
 *     "The upper halfword of general register R1 is exchanged with the
 *     lower halfword of general register R2.  Bits 0 through 15 of
 *     general register R1 replace bits 16 through 31 of general register
 *     R2, while simultaneously bits 16 through 31 of general register R2
 *     replace bits 0 through 15 of general register R1."
 *
 * "Simultaneously" is what decides the R1 == R2 case: the register's own
 * two halves trade places.  The condition code, overflow and carry are
 * all left alone. */
static void exec_XUL(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = register_get32(R(t, v, 'y'));
    uint32_t hi1 = (v1 >> 16) & 0xffff;
    uint32_t lo2 = v2 & 0xffff;
    if (df_get(v, 'x') == df_get(v, 'y')) {
        register_set32(R(t, v, 'x'), (lo2 << 16) | hi1);
    } else {
        register_set32(R(t, v, 'x'), (lo2 << 16) | (v1 & 0xffff));
        register_set32(R(t, v, 'y'), (v2 & 0xffff0000u) | hi1);
    }
}

static void exec_IAL(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = cpu_g_ea_16(t, v);
    register_set32(R(t, v, 'x'), (v1 & 0xffff0000) | v2);
}

static void exec_IHL(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = cpu_g_eah(t, v);
    register_set32(R(t, v, 'x'), (v1 & 0xffff0000) | v2);
}

static void exec_LR(CPU *t, DInstr *v) {
    uint32_t val = register_get32(R(t, v, 'y'));
    register_set32(R(t, v, 'x'), val);
    cpu_compute_cc_arith(t, val, 0);
}

static void exec_L(CPU *t, DInstr *v) {
    uint32_t val = cpu_g_eaf(t, v, 0);
    register_set32(R(t, v, 'x'), val);
    cpu_compute_cc_arith(t, val, 0);
}

static void exec_LA(CPU *t, DInstr *v) {
    uint32_t ea = cpu_g_ea_16(t, v);
    register_set32(R(t, v, 'x'), ea << 16);
}

static void exec_LHI(CPU *t, DInstr *v) {
    register_set32(R(t, v, 'x'), df_get(v, 'I') << 16);
}

static void exec_LCR(CPU *t, DInstr *v) {
    uint32_t v2 = register_get32(R(t, v, 'y'));
    uint32_t result = cpu_sub_fixed(t, 0, v2);
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_arith(t, result, 0);
}

static void exec_LFXI(CPU *t, DInstr *v) {
    /* decodef() already applied the LFXI `y -= 2` display-value bias;
     * this `+2` undoes it to recover the raw 4-bit field for indexing —
     * intentional round-trip (see this phase's dev notes), not dead
     * code: toStr()/disassembly reads v.y *without* this correction. */
    static const uint32_t lits[16] = {
        0xfffe0000, 0xffff0000, 0x00000000, 0x00010000,
        0x00020000, 0x00030000, 0x00040000, 0x00050000,
        0x00060000, 0x00070000, 0x00080000, 0x00090000,
        0x000A0000, 0x000B0000, 0x000C0000, 0x000D0000,
    };
    uint32_t idx = df_get(v, 'y') + 2;
    register_set32(R(t, v, 'x'), lits[idx]);
}

static void exec_LH(CPU *t, DInstr *v) {
    uint32_t result = cpu_g_eah(t, v) << 16;
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_arith(t, result, 0);
}

static void exec_LM(CPU *t, DInstr *v) {
    uint32_t v2ea = cpu_g_ea(t, v);
    for (int i = 0; i <= 7; i++) {
        register_set32(cpu_r(t, i), membus_get32(t->ram, v2ea + (uint32_t)(i * 2)));
    }
}

static void exec_MSTH(CPU *t, DInstr *v) {
    uint32_t v1 = df_get(v, 'I') & 0xffff;
    uint32_t v2 = cpu_g_eah(t, v);
    uint32_t result = (v1 + v2) & 0xffff;
    cpu_s_eah(t, v, result);
    int32_t signed_ = (result & 0x8000) ? (int32_t)result - 0x10000 : (int32_t)result;
    cpu_compute_cc_arith(t, (uint32_t)signed_, 0);
}

static void exec_MR(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    if (x % 2 == 0) {
        Q31MulResult r = q31_mul32((int32_t)register_get32(R(t, v, 'x')), (int32_t)register_get32(R(t, v, 'y')));
        register_set32(R(t, v, 'x'), r.hi);
        register_set32(cpu_r(t, (int)(x + 1)), r.lo);
        if (r.overflow) psw_set_overflow(&t->psw, 1);
    } else {
        Q15MulResult r = q15_mul((int32_t)register_get32(R(t, v, 'x')) >> 16, (int32_t)register_get32(R(t, v, 'y')) >> 16);
        register_set32(R(t, v, 'x'), (uint32_t)r.result);
        if (r.overflow) psw_set_overflow(&t->psw, 1);
    }
}

static void exec_M(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    if (x % 2 == 0) {
        Q31MulResult r = q31_mul32((int32_t)register_get32(R(t, v, 'x')), (int32_t)cpu_g_eaf(t, v, 0));
        register_set32(R(t, v, 'x'), r.hi);
        register_set32(cpu_r(t, (int)(x + 1)), r.lo);
        if (r.overflow) psw_set_overflow(&t->psw, 1);
    } else {
        Q15MulResult r = q15_mul((int32_t)register_get32(R(t, v, 'x')) >> 16, (int32_t)cpu_g_eaf(t, v, 0) >> 16);
        register_set32(R(t, v, 'x'), (uint32_t)r.result);
        if (r.overflow) psw_set_overflow(&t->psw, 1);
    }
}

static void exec_MH(CPU *t, DInstr *v) {
    int32_t v1 = (int32_t)register_get32(R(t, v, 'x')) >> 16;
    uint32_t v2raw = cpu_g_eah(t, v);
    int32_t v2 = (v2raw & 0x8000) ? (int32_t)v2raw - 0x10000 : (int32_t)v2raw;
    Q15MulResult r = q15_mul(v1, v2);
    register_set32(R(t, v, 'x'), (uint32_t)r.result);
    if (r.overflow) psw_set_overflow(&t->psw, 1);
}

static void exec_MHI(CPU *t, DInstr *v) {
    uint32_t v1raw = df_get(v, 'I');
    int32_t v1 = (v1raw & 0x8000) ? (int32_t)v1raw - 0x10000 : (int32_t)v1raw;
    int32_t v2 = (int32_t)register_get32(R(t, v, 'y')) >> 16;
    Q15MulResult r = q15_mul(v1, v2);
    register_set32(R(t, v, 'y'), (uint32_t)r.result);
    if (r.overflow) psw_set_overflow(&t->psw, 1);
}

static void exec_MIH(CPU *t, DInstr *v) {
    int32_t v1 = (int32_t)register_get32(R(t, v, 'x')) >> 16;
    uint32_t v2raw = cpu_g_eah(t, v);
    int32_t v2 = (v2raw & 0x8000) ? (int32_t)v2raw - 0x10000 : (int32_t)v2raw;
    int32_t product = v1 * v2;
    register_set32(R(t, v, 'x'), ((uint32_t)product & 0xffff) << 16);
    int32_t check = product >> 15;
    if (check != 0 && check != -1) psw_set_overflow(&t->psw, 1);
}

static void exec_ST(CPU *t, DInstr *v) {
    cpu_s_eaf(t, v, register_get32(R(t, v, 'x')), 0);
}

static void exec_STH(CPU *t, DInstr *v) {
    cpu_s_eah(t, v, register_get32(R(t, v, 'x')) >> 16);
}

static void exec_STM(CPU *t, DInstr *v) {
    uint32_t v2ea = cpu_g_ea(t, v);
    for (int i = 0; i <= 7; i++) {
        membus_set32(t->ram, v2ea + (uint32_t)(i * 2), register_get32(cpu_r(t, i)), true);
    }
}

static void exec_SR(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = register_get32(R(t, v, 'y'));
    uint32_t result = cpu_sub_fixed(t, v1, v2);
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_arith(t, result, 0);
}

static void exec_S(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = cpu_g_eaf(t, v, 0);
    uint32_t result = cpu_sub_fixed(t, v1, v2);
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_arith(t, result, 0);
}

static void exec_SST(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = cpu_g_eaf(t, v, 0);
    uint32_t result = cpu_sub_fixed(t, v2, v1);
    cpu_s_eaf(t, v, result, 0);
    cpu_compute_cc_arith(t, result, 0);
}

static void exec_SH(CPU *t, DInstr *v) {
    uint32_t v1 = register_get32(R(t, v, 'x'));
    uint32_t v2 = cpu_g_eah(t, v) << 16;
    uint32_t result = cpu_sub_fixed(t, v1, v2);
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_arith(t, result, 0);
}

static void exec_TD(CPU *t, DInstr *v) {
    uint32_t result = (cpu_g_eah(t, v) - 1) & 0xffff;
    cpu_s_eah(t, v, result);
    int32_t signed_ = (result & 0x8000) ? (int32_t)result - 0x10000 : (int32_t)result;
    cpu_compute_cc_arith(t, (uint32_t)signed_, 0);
}

/* ---------------------------------------------------------------------
 * Exec bodies — branch / shift batch
 * ------------------------------------------------------------------- */

static void exec_BALR(CPU *t, DInstr *v) {
    /* "First, the branch address is computed.  Then, the first word of
     * the current PSW (bits 0 - 31) is loaded into general register R1."
     * That order is the whole instruction when R1 and R2 are the SAME
     * register: storing the link first overwrites the target with it, so
     * the branch goes to the return address and the call falls through.
     * GPCIPL does exactly that -- `LH 7,X'1c36'` then `BALR 7,7` -- so
     * its call never happened and MOVENV ran with a junk R7, looping on
     * its own return path forever. */
    bool taken = df_get(v, 'y') != 0;
    uint32_t branch = 0;
    if (taken) {
        branch = cpu_g_expand(t, register_get32(R(t, v, 'y')) >> 16, OPTYPE_BRCH);
    }
    register_set32(R(t, v, 'x'), register_get32(&t->psw.psw1));
    if (taken) {
        psw_set_nia(&t->psw, branch);
    }
}

static void exec_BAL(CPU *t, DInstr *v) {
    uint32_t branch = cpu_g_ea(t, v);
    register_set32(R(t, v, 'x'), register_get32(&t->psw.psw1));
    psw_set_nia(&t->psw, branch);
}

static void exec_BIX(CPU *t, DInstr *v) {
    uint32_t R1 = register_get32(R(t, v, 'x'));
    uint32_t index = R1 >> 16;
    /* JS keeps `count` as a small signed Number (range [-1,65534] after
     * the decrement) — the `count+1 > 0` test below relies on that, not
     * on the wrapped-to-uint16 value stored back into the register. */
    int32_t count = (int32_t)(R1 & 0xffff);
    uint32_t branch = cpu_g_ea(t, v);
    index = index + 1;
    count = count - 1;
    register_set32(R(t, v, 'x'), (index << 16) | ((uint32_t)count & 0xffff));
    if (count + 1 > 0) {
        psw_set_nia(&t->psw, branch);
    }
}

static void exec_BCR(CPU *t, DInstr *v) {
    uint32_t m1 = df_get(v, 'x');
    uint32_t v2 = cpu_g_expand(t, register_get32(R(t, v, 'y')) >> 16, OPTYPE_BRCH);
    uint32_t cc = psw_get_cc(&t->psw);
    if ((m1 & 4 && cc == 0) || (m1 & 2 && cc == 3) || (m1 & 1 && cc == 1)) {
        psw_set_nia(&t->psw, v2);
    }
}

static void exec_BC(CPU *t, DInstr *v) {
    uint32_t m1 = df_get(v, 'x');
    uint32_t v2 = cpu_g_ea(t, v);
    uint32_t cc = psw_get_cc(&t->psw);
    if ((m1 & 4 && cc == 0) || (m1 & 2 && cc == 3) || (m1 & 1 && cc == 1)) {
        psw_set_nia(&t->psw, v2);
    }
}

static void exec_BCB(CPU *t, DInstr *v) {
    uint32_t m1 = df_get(v, 'x');
    uint32_t disp = df_get(v, 'd');
    uint32_t cc = psw_get_cc(&t->psw);
    if ((m1 & 4 && cc == 0) || (m1 & 2 && cc == 3) || (m1 & 1 && cc == 1)) {
        psw_set_nia(&t->psw, psw_get_nia(&t->psw) - disp);
    }
}

static void exec_BCRE(CPU *t, DInstr *v) {
    uint32_t m1 = df_get(v, 'x');
    uint32_t ry = register_get32(R(t, v, 'y'));
    uint32_t branch = ry >> 16;
    uint32_t bsr = (ry >> 4) & 0xf;
    uint32_t dsr = ry & 0xf;
    uint32_t cc = psw_get_cc(&t->psw);
    if ((m1 & 4 && cc == 0) || (m1 & 2 && cc == 3) || (m1 & 1 && cc == 1)) {
        psw_set_nia(&t->psw, branch);
        psw_set_bsr(&t->psw, bsr);
        psw_set_dsr(&t->psw, dsr);
    }
}

static void exec_BCF(CPU *t, DInstr *v) {
    uint32_t m1 = df_get(v, 'x');
    uint32_t disp = df_get(v, 'd');
    uint32_t cc = psw_get_cc(&t->psw);
    if ((m1 & 4 && cc == 0) || (m1 & 2 && cc == 3) || (m1 & 1 && cc == 1)) {
        psw_set_nia(&t->psw, psw_get_nia(&t->psw) + disp);
    }
}

static void exec_BCTR(CPU *t, DInstr *v) {
    uint32_t r1val = register_get32(R(t, v, 'x'));
    uint32_t count = ((r1val >> 16) - 1) & 0xffff;
    register_set32(R(t, v, 'x'), (count << 16) | (r1val & 0xffff));
    if (count != 0) {
        uint32_t branch = cpu_g_expand(t, register_get32(R(t, v, 'y')) >> 16, OPTYPE_BRCH);
        psw_set_nia(&t->psw, branch);
    }
}

static void exec_BCT(CPU *t, DInstr *v) {
    uint32_t r1val = register_get32(R(t, v, 'x'));
    uint32_t count = ((r1val >> 16) - 1) & 0xffff;
    register_set32(R(t, v, 'x'), (count << 16) | (r1val & 0xffff));
    if (count != 0) {
        psw_set_nia(&t->psw, cpu_g_ea(t, v));
    }
}

static void exec_BCTB(CPU *t, DInstr *v) {
    uint32_t r1val = register_get32(R(t, v, 'x'));
    uint32_t count = ((r1val >> 16) - 1) & 0xffff;
    register_set32(R(t, v, 'x'), (count << 16) | (r1val & 0xffff));
    if (count != 0) {
        uint32_t disp = df_get(v, 'd');
        psw_set_nia(&t->psw, psw_get_nia(&t->psw) - disp);
    }
}

static bool bvc_taken(uint32_t m1, uint32_t carry, uint32_t overflow) {
    uint32_t invert = m1 & 4;
    uint32_t testCarry = m1 & 2;
    uint32_t testOverflow = m1 & 1;
    if (invert) {
        if (testCarry && !carry) return true;
        if (testOverflow && !overflow) return true;
        if (!testCarry && !testOverflow) return true;
        return false;
    }
    if (testCarry && carry) return true;
    if (testOverflow && overflow) return true;
    return false;
}

static void exec_BVCR(CPU *t, DInstr *v) {
    uint32_t m1 = df_get(v, 'x');
    bool taken = bvc_taken(m1, psw_get_carry(&t->psw), psw_get_overflow(&t->psw));
    if (taken) {
        uint32_t branch = cpu_g_expand(t, register_get32(R(t, v, 'y')) >> 16, OPTYPE_BRCH);
        psw_set_nia(&t->psw, branch);
    }
    psw_set_overflow(&t->psw, 0);
}

static void exec_BVC(CPU *t, DInstr *v) {
    uint32_t m1 = df_get(v, 'x');
    bool taken = bvc_taken(m1, psw_get_carry(&t->psw), psw_get_overflow(&t->psw));
    if (taken) {
        psw_set_nia(&t->psw, cpu_g_ea(t, v));
    }
    psw_set_overflow(&t->psw, 0);
}

static void exec_BVCF(CPU *t, DInstr *v) {
    uint32_t m1 = df_get(v, 'x');
    bool taken = bvc_taken(m1, psw_get_carry(&t->psw), psw_get_overflow(&t->psw));
    if (taken) {
        uint32_t disp = df_get(v, 'd');
        psw_set_nia(&t->psw, psw_get_nia(&t->psw) + disp);
    }
    psw_set_overflow(&t->psw, 0);
}

static void exec_NCT(CPU *t, DInstr *v) {
    register_set32(R(t, v, 'x'), 0);
    uint32_t v2 = register_get32(R(t, v, 'y'));
    if (v2 == 0) {
        psw_set_carry(&t->psw, 0);
        return;
    }
    uint32_t count = 0;
    while (count < 32) {
        uint32_t bit0 = (v2 >> 31) & 1;
        uint32_t bit1 = (v2 >> 30) & 1;
        if (bit0 != bit1) break;
        v2 = v2 << 1;
        count++;
    }
    register_set32(R(t, v, 'y'), v2);
    register_set32(R(t, v, 'x'), count << 16);
    psw_set_carry(&t->psw, 1);
}

static void exec_SLL(CPU *t, DInstr *v) {
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1);
    uint32_t v1 = register_get32(R(t, v, 'x'));
    if (shiftCnt >= 32) {
        psw_set_carry(&t->psw, (shiftCnt == 32) ? ((v1 & 1) ? 1u : 0u) : 0u);
        register_set32(R(t, v, 'x'), 0);
    } else if (shiftCnt == 0) {
        return;
    } else {
        psw_set_carry(&t->psw, (v1 & (1u << (32 - shiftCnt))) ? 1 : 0);
        register_set32(R(t, v, 'x'), v1 << shiftCnt);
    }
}

static void exec_SLDL(CPU *t, DInstr *v) {
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1);
    uint32_t x = df_get(v, 'x');
    uint32_t hi = register_get32(R(t, v, 'x'));
    uint32_t lo = register_get32(cpu_r(t, (int)(x + 1)));
    if (shiftCnt == 0) return;
    if (shiftCnt >= 64) {
        psw_set_carry(&t->psw, 0);
        register_set32(R(t, v, 'x'), 0);
        register_set32(cpu_r(t, (int)(x + 1)), 0);
    } else if (shiftCnt >= 32) {
        uint32_t s = shiftCnt - 32;
        if (s == 0) {
            psw_set_carry(&t->psw, (hi & 1) ? 1 : 0);
            register_set32(R(t, v, 'x'), lo);
        } else {
            psw_set_carry(&t->psw, (lo & (1u << (32 - s))) ? 1 : 0);
            register_set32(R(t, v, 'x'), lo << s);
        }
        register_set32(cpu_r(t, (int)(x + 1)), 0);
    } else {
        psw_set_carry(&t->psw, (hi & (1u << (32 - shiftCnt))) ? 1 : 0);
        uint32_t newHi = (hi << shiftCnt) | (lo >> (32 - shiftCnt));
        uint32_t newLo = lo << shiftCnt;
        register_set32(R(t, v, 'x'), newHi);
        register_set32(cpu_r(t, (int)(x + 1)), newLo);
    }
}

static void exec_SRA(CPU *t, DInstr *v) {
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1);
    if (shiftCnt == 0) return;
    int32_t v1 = (int32_t)register_get32(R(t, v, 'x'));
    uint32_t result = (shiftCnt >= 32) ? ((v1 < 0) ? 0xffffffffu : 0u) : (uint32_t)(v1 >> shiftCnt);
    register_set32(R(t, v, 'x'), result);
}

static void exec_SRDA(CPU *t, DInstr *v) {
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1);
    if (shiftCnt == 0) return;
    uint32_t x = df_get(v, 'x');
    int32_t hi = (int32_t)register_get32(R(t, v, 'x'));
    uint32_t lo = register_get32(cpu_r(t, (int)(x + 1)));
    bool sign = (hi < 0);
    if (shiftCnt >= 64) {
        uint32_t fill = sign ? 0xffffffffu : 0u;
        register_set32(R(t, v, 'x'), fill);
        register_set32(cpu_r(t, (int)(x + 1)), fill);
    } else if (shiftCnt >= 32) {
        uint32_t s = shiftCnt - 32;
        register_set32(cpu_r(t, (int)(x + 1)), (s == 0) ? (uint32_t)hi : (uint32_t)(hi >> s));
        register_set32(R(t, v, 'x'), sign ? 0xffffffffu : 0u);
    } else {
        uint32_t newLo = (lo >> shiftCnt) | ((uint32_t)hi << (32 - shiftCnt));
        uint32_t newHi = (uint32_t)(hi >> shiftCnt);
        register_set32(R(t, v, 'x'), newHi);
        register_set32(cpu_r(t, (int)(x + 1)), newLo);
    }
}

static void exec_SRDL(CPU *t, DInstr *v) {
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1);
    if (shiftCnt == 0) return;
    uint32_t x = df_get(v, 'x');
    uint32_t hi = register_get32(R(t, v, 'x'));
    uint32_t lo = register_get32(cpu_r(t, (int)(x + 1)));
    if (shiftCnt >= 64) {
        register_set32(R(t, v, 'x'), 0);
        register_set32(cpu_r(t, (int)(x + 1)), 0);
    } else if (shiftCnt >= 32) {
        uint32_t s = shiftCnt - 32;
        register_set32(cpu_r(t, (int)(x + 1)), (s == 0) ? hi : (hi >> s));
        register_set32(R(t, v, 'x'), 0);
    } else {
        uint32_t newLo = (lo >> shiftCnt) | (hi << (32 - shiftCnt));
        uint32_t newHi = hi >> shiftCnt;
        register_set32(R(t, v, 'x'), newHi);
        register_set32(cpu_r(t, (int)(x + 1)), newLo);
    }
}

static void exec_SRL(CPU *t, DInstr *v) {
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1);
    if (shiftCnt == 0) return;
    uint32_t v1 = register_get32(R(t, v, 'x'));
    register_set32(R(t, v, 'x'), (shiftCnt >= 32) ? 0u : (v1 >> shiftCnt));
}

static void exec_SRR(CPU *t, DInstr *v) {
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1) % 32;
    if (shiftCnt == 0) return;
    uint32_t v1 = register_get32(R(t, v, 'x'));
    register_set32(R(t, v, 'x'), (v1 >> shiftCnt) | (v1 << (32 - shiftCnt)));
}

static void exec_SRDR(CPU *t, DInstr *v) {
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1) % 64;
    if (shiftCnt == 0) return;
    uint32_t x = df_get(v, 'x');
    uint32_t hi = register_get32(R(t, v, 'x'));
    uint32_t lo = register_get32(cpu_r(t, (int)(x + 1)));
    if (shiftCnt >= 32) {
        uint32_t s = shiftCnt - 32;
        if (s == 0) {
            register_set32(R(t, v, 'x'), lo);
            register_set32(cpu_r(t, (int)(x + 1)), hi);
        } else {
            uint32_t newHi = (lo >> s) | (hi << (32 - s));
            uint32_t newLo = (hi >> s) | (lo << (32 - s));
            register_set32(R(t, v, 'x'), newHi);
            register_set32(cpu_r(t, (int)(x + 1)), newLo);
        }
    } else {
        uint32_t newHi = (hi >> shiftCnt) | (lo << (32 - shiftCnt));
        uint32_t newLo = (lo >> shiftCnt) | (hi << (32 - shiftCnt));
        register_set32(R(t, v, 'x'), newHi);
        register_set32(cpu_r(t, (int)(x + 1)), newLo);
    }
}

/* ---------------------------------------------------------------------
 * Exec bodies — logical / misc fixed-point batch
 * ------------------------------------------------------------------- */

static void exec_NR(CPU *t, DInstr *v) {
    uint32_t result = register_get32(R(t, v, 'x')) & register_get32(R(t, v, 'y'));
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_logical(t, result);
}

static void exec_N(CPU *t, DInstr *v) {
    uint32_t result = register_get32(R(t, v, 'x')) & cpu_g_eaf(t, v, 0);
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_logical(t, result);
}

static void exec_NHI(CPU *t, DInstr *v) {
    uint32_t result = register_get32(R(t, v, 'y')) & (df_get(v, 'I') << 16);
    register_set32(R(t, v, 'y'), result);
    cpu_compute_cc_logical(t, result);
}

static void exec_NIST(CPU *t, DInstr *v) {
    uint32_t result = df_get(v, 'I') & cpu_g_eah(t, v);
    cpu_s_eah(t, v, result);
    cpu_compute_cc_logical(t, result);
}

static void exec_NST(CPU *t, DInstr *v) {
    uint32_t result = register_get32(R(t, v, 'x')) & cpu_g_eaf(t, v, 0);
    cpu_s_eaf(t, v, result, 0);
    cpu_compute_cc_logical(t, result);
}

static void exec_XR(CPU *t, DInstr *v) {
    uint32_t result = register_get32(R(t, v, 'x')) ^ register_get32(R(t, v, 'y'));
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_logical(t, result);
}

static void exec_X(CPU *t, DInstr *v) {
    uint32_t result = register_get32(R(t, v, 'x')) ^ cpu_g_eaf(t, v, 0);
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_logical(t, result);
}

static void exec_XHI(CPU *t, DInstr *v) {
    uint32_t result = (df_get(v, 'I') << 16) ^ register_get32(R(t, v, 'y'));
    register_set32(R(t, v, 'y'), result);
    cpu_compute_cc_logical(t, result);
}

static void exec_XIST(CPU *t, DInstr *v) {
    uint32_t result = df_get(v, 'I') ^ cpu_g_eah(t, v);
    cpu_s_eah(t, v, result);
    cpu_compute_cc_logical(t, result);
}

static void exec_XST(CPU *t, DInstr *v) {
    uint32_t result = register_get32(R(t, v, 'x')) ^ cpu_g_eaf(t, v, 0);
    cpu_s_eaf(t, v, result, 0);
    cpu_compute_cc_logical(t, result);
}

static void exec_OR(CPU *t, DInstr *v) {
    uint32_t result = register_get32(R(t, v, 'x')) | register_get32(R(t, v, 'y'));
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_logical(t, result);
}

static void exec_O(CPU *t, DInstr *v) {
    uint32_t result = register_get32(R(t, v, 'x')) | cpu_g_eaf(t, v, 0);
    register_set32(R(t, v, 'x'), result);
    cpu_compute_cc_logical(t, result);
}

static void exec_OHI(CPU *t, DInstr *v) {
    uint32_t result = (df_get(v, 'I') << 16) | register_get32(R(t, v, 'y'));
    register_set32(R(t, v, 'y'), result);
    cpu_compute_cc_logical(t, result);
}

static void exec_OST(CPU *t, DInstr *v) {
    uint32_t result = register_get32(R(t, v, 'x')) | cpu_g_eaf(t, v, 0);
    cpu_s_eaf(t, v, result, 0);
    cpu_compute_cc_logical(t, result);
}

static void exec_SUM(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    uint32_t count = register_get32(R(t, v, 'y')) >> 16;

    uint32_t evenReg = x & 0xfe;
    uint32_t oddReg = evenReg | 1;

    uint32_t r1Val = register_get32(cpu_r(t, (int)evenReg));
    uint32_t arrayAddr = (r1Val >> 16) & 0xffff;
    uint32_t modifierRaw = r1Val & 0xffff;
    uint32_t modifier = (modifierRaw & 0x8000) ? (modifierRaw - 0x10000) : modifierRaw;

    uint32_t r1OddVal = register_get32(cpu_r(t, (int)oddReg));
    uint32_t mask = (r1OddVal >> 16) & 0xffff;
    uint32_t fieldValues = r1OddVal & 0xffff;
    uint32_t maskedFV = fieldValues & mask;

    uint32_t curAddr = arrayAddr;
    for (uint32_t i = 0; i < count; i++) {
        uint32_t ai = membus_get16(t->ram, cpu_g_expand(t, curAddr, OPTYPE_DATA));
        uint32_t maskedAi = ai & mask;
        if ((maskedAi ^ maskedFV) != 0) {
            r1Val = (curAddr << 16) | (r1Val & 0xffff);
            register_set32(cpu_r(t, (int)evenReg), r1Val);
            psw_set_cc(&t->psw, 3);
            return;
        }
        curAddr = (curAddr + modifier) & 0xffff;
    }

    r1Val = (curAddr << 16) | (r1Val & 0xffff);
    register_set32(cpu_r(t, (int)evenReg), r1Val);
    psw_set_cc(&t->psw, 0);
}

static void exec_SB(CPU *t, DInstr *v) {
    uint32_t result = df_get(v, 'I') | cpu_g_eah(t, v);
    cpu_s_eah(t, v, result);
    cpu_compute_cc_logical(t, result);
}

static void exec_SHW(CPU *t, DInstr *v) {
    cpu_s_eah(t, v, 0xffff);
}

static void exec_TB(CPU *t, DInstr *v) {
    uint32_t v1 = df_get(v, 'I');
    uint32_t testResult = v1 & cpu_g_eah(t, v);
    if (testResult == 0) psw_set_cc(&t->psw, 0);
    else if (testResult == v1) psw_set_cc(&t->psw, 1);
    else psw_set_cc(&t->psw, 3);
}

static void exec_TRB(CPU *t, DInstr *v) {
    uint32_t v1 = df_get(v, 'I') << 16;
    uint32_t testResult = v1 & register_get32(R(t, v, 'y'));
    if (testResult == 0) psw_set_cc(&t->psw, 0);
    else if (testResult == v1) psw_set_cc(&t->psw, 1);
    else psw_set_cc(&t->psw, 3);
}

static void exec_TH(CPU *t, DInstr *v) {
    uint32_t testResult = cpu_g_eah(t, v);
    if (testResult == 0) psw_set_cc(&t->psw, 0);
    else if (testResult == 0xffff) psw_set_cc(&t->psw, 1);
    else psw_set_cc(&t->psw, 3);
}

static void exec_ZB(CPU *t, DInstr *v) {
    uint32_t result = (~df_get(v, 'I')) & cpu_g_eah(t, v);
    cpu_s_eah(t, v, result);
    cpu_compute_cc_logical(t, result);
}

static void exec_ZRB(CPU *t, DInstr *v) {
    uint32_t mask = df_get(v, 'I') << 16;
    uint32_t result = register_get32(R(t, v, 'y')) & ~mask;
    register_set32(R(t, v, 'y'), result);
    cpu_compute_cc_logical(t, result);
}

static void exec_ZH(CPU *t, DInstr *v) {
    cpu_s_eah(t, v, 0);
}

/* ---------------------------------------------------------------------
 * Exec bodies — floating point batch
 * ------------------------------------------------------------------- */

static inline Register *F(CPU *t, DInstr *v, char c) {
    return cpu_f(t, (int)df_get(v, c));
}

static void write_fp_result_dp_cc(CPU *t, DInstr *v, const FloatIBM *result) {
    if (fibm_gfracbits(result) == 0) psw_set_cc(&t->psw, 0);
    else if (fibm_gsign(result) < 0) psw_set_cc(&t->psw, 3);
    else psw_set_cc(&t->psw, 1);
    uint32_t x = df_get(v, 'x');
    register_set32(cpu_f(t, (int)x), fibm_to64x(result));
    register_set32(cpu_f(t, (int)(x + 1)), fibm_to64y(result));
}

static void write_fp_result_sp_cc(CPU *t, DInstr *v, const FloatIBM *result) {
    if (fibm_gfracbits(result) == 0) psw_set_cc(&t->psw, 0);
    else if (fibm_gsign(result) < 0) psw_set_cc(&t->psw, 3);
    else psw_set_cc(&t->psw, 1);
    register_set32(F(t, v, 'x'), fibm_to32(result));
}

static void exec_AEDR(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x'), y = df_get(v, 'y');
    FloatIBM v1 = fibm_from64(register_get32(cpu_f(t, (int)x)), register_get32(cpu_f(t, (int)(x + 1))));
    FloatIBM v2 = fibm_from64(register_get32(cpu_f(t, (int)y)), register_get32(cpu_f(t, (int)(y + 1))));
    FloatIBMResult r = fibm_addE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    write_fp_result_dp_cc(t, v, &r.result);
}

static void exec_AED(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    FloatIBM v1 = fibm_from64(register_get32(cpu_f(t, (int)x)), register_get32(cpu_f(t, (int)(x + 1))));
    /* Two separate statements: C (unlike JS) doesn't guarantee argument
     * evaluation order, and g_EAF's g_EA call can have side effects
     * (indexed-with-modification addressing). */
    uint32_t v2hw1 = cpu_g_eaf(t, v, 0);
    uint32_t v2hw2 = cpu_g_eaf(t, v, 2);
    FloatIBM v2 = fibm_from64(v2hw1, v2hw2);
    FloatIBMResult r = fibm_addE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    write_fp_result_dp_cc(t, v, &r.result);
}

static void exec_AER(CPU *t, DInstr *v) {
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(register_get32(F(t, v, 'y')));
    FloatIBMResult r = fibm_addE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    write_fp_result_sp_cc(t, v, &r.result);
}

static void exec_AE(CPU *t, DInstr *v) {
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(cpu_g_eaf(t, v, 0));
    FloatIBMResult r = fibm_addE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    write_fp_result_sp_cc(t, v, &r.result);
}

static void exec_CER(CPU *t, DInstr *v) {
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(register_get32(F(t, v, 'y')));
    psw_set_cc(&t->psw, (uint32_t)fibm_compe_anomalous(&v1, &v2));
}

static void exec_CE(CPU *t, DInstr *v) {
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(cpu_g_eaf(t, v, 0));
    psw_set_cc(&t->psw, (uint32_t)fibm_compe_anomalous(&v1, &v2));
}

static void exec_CEDR(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x'), y = df_get(v, 'y');
    FloatIBM v1 = fibm_from64(register_get32(cpu_f(t, (int)x)), register_get32(cpu_f(t, (int)(x + 1))));
    FloatIBM v2 = fibm_from64(register_get32(cpu_f(t, (int)y)), register_get32(cpu_f(t, (int)(y + 1))));
    psw_set_cc(&t->psw, (uint32_t)fibm_compe_anomalous(&v1, &v2));
}

static void exec_CED(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    FloatIBM v1 = fibm_from64(register_get32(cpu_f(t, (int)x)), register_get32(cpu_f(t, (int)(x + 1))));
    uint32_t v2hw1 = cpu_g_eaf(t, v, 0);
    uint32_t v2hw2 = cpu_g_eaf(t, v, 2);
    FloatIBM v2 = fibm_from64(v2hw1, v2hw2);
    psw_set_cc(&t->psw, (uint32_t)fibm_compe_anomalous(&v1, &v2));
}

static void exec_CVFX(CPU *t, DInstr *v) {
    uint32_t rawIn = register_get32(F(t, v, 'y'));
    FloatIBM v2 = fibm_from32(rawIn);
    FloatIBMCvfxResult r = fibm_cvfx(&v2);
    uint32_t result;

    if (r.exc == FP_EXC_CONVERT_OVERFLOW && t->fcosMode) {
        /* Simulate FCOS's FPMCVFX program-check handler (source-
         * confirmed: workspace/PFS/OI340600/SSSRC/FPMSDERR.asm) --
         * patches the destination register to +32767/-32767 by the
         * source float's sign, then resumes. Modeling the net effect
         * directly rather than actually routing through a PSW swap to
         * an interrupt vector, since nothing else needs that
         * intermediate step simulated (see cpu.h's fcosMode comment).
         *
         * CVFX's own result convention (confirmed by tracing a normal,
         * in-range conversion: S2=7.2 -> CVFX gives 0x00073333, i.e.
         * 7.2*65536 truncated) is Q16.16 fixed point, not a plain
         * integer -- callers like RUNASM/ETOH.asm always follow CVFX
         * with a +0x7FFF rounding-bias add and an NHI-keep-upper-16-bits
         * step to extract the final rounded integer. The clamp value
         * must be pre-scaled by 0x10000 (65536) to survive that same
         * bias-and-extract sequence and still land on exactly
         * +32767/-32767, matching what FPMCVFX's own patched register
         * would produce once the resumed code runs that sequence on it. */
        result = (rawIn & 0x80000000u) ? 0x80010000u : 0x7FFF0000u;
        register_set32(R(t, v, 'x'), result);
        psw_set_cc(&t->psw, (rawIn & 0x80000000u) ? 3 : 1);
        return;
    }

    /* Unlike every other FP instruction's exc-then-bail pattern in this
     * file, a real CVFX always completes and stores *some* result before
     * any interrupt is taken -- software only gets a chance to patch the
     * register afterward (see fcosMode branch above). Bailing out before
     * the store here left the destination register as stale, unrelated
     * garbage on overflow whenever fcosMode is off, which is exactly what
     * an independent investigation (see yagpc2-yahalmat2-issues.db,
     * cvfx_overflow_truncation_rule) found made gpc's own CVFX-overflow
     * behavior "unreliable, context-dependent" -- not a deliberate
     * bare-hardware truncation semantic, just a bug losing an
     * already-computed value. Still signal the exception (so an
     * unhandled-program-check log fires, same as any other unserviced
     * program check) but always store what fibm_cvfx computed. */
    if (r.exc != FP_EXC_OK) cpu_fp_dispatch_exc(t, r.exc);
    result = (uint32_t)r.result;
    register_set32(R(t, v, 'x'), result);
    /* POO 8.13 anomaly: 41100000 converts to 0x00010000 but CC=00
     * (instead of the standard bits-0-15 rule's CC=01). */
    if (rawIn == 0x41100000) {
        psw_set_cc(&t->psw, 0);
        return;
    }
    uint32_t hi16 = (result >> 16) & 0xFFFF;
    if (hi16 == 0) psw_set_cc(&t->psw, 0);
    else if (result & 0x80000000) psw_set_cc(&t->psw, 3);
    else psw_set_cc(&t->psw, 1);
}

static void exec_CVFL(CPU *t, DInstr *v) {
    uint32_t u = register_get32(R(t, v, 'y'));
    int32_t s = (int32_t)u;
    FloatIBM result = fibm_cvfl(s);
    register_set32(F(t, v, 'x'), fibm_to32(&result));
    if (s == 0) psw_set_cc(&t->psw, 0);
    else if (s < 0) psw_set_cc(&t->psw, 3);
    else psw_set_cc(&t->psw, 1);
}

static void exec_DEDR(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x'), y = df_get(v, 'y');
    FloatIBM v1 = fibm_from64(register_get32(cpu_f(t, (int)x)), register_get32(cpu_f(t, (int)(x + 1))));
    FloatIBM v2 = fibm_from64(register_get32(cpu_f(t, (int)y)), register_get32(cpu_f(t, (int)(y + 1))));
    FloatIBMResult r = fibm_divE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    register_set32(cpu_f(t, (int)x), fibm_to64x(&r.result));
    register_set32(cpu_f(t, (int)(x + 1)), fibm_to64y(&r.result));
}

static void exec_DED(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    FloatIBM v1 = fibm_from64(register_get32(cpu_f(t, (int)x)), register_get32(cpu_f(t, (int)(x + 1))));
    uint32_t v2hw1 = cpu_g_eaf(t, v, 0);
    uint32_t v2hw2 = cpu_g_eaf(t, v, 2);
    FloatIBM v2 = fibm_from64(v2hw1, v2hw2);
    FloatIBMResult r = fibm_divE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    register_set32(cpu_f(t, (int)x), fibm_to64x(&r.result));
    register_set32(cpu_f(t, (int)(x + 1)), fibm_to64y(&r.result));
}

static void exec_DER(CPU *t, DInstr *v) {
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(register_get32(F(t, v, 'y')));
    FloatIBMResult r = fibm_divE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    register_set32(F(t, v, 'x'), fibm_to32(&r.result));
}

static void exec_DE(CPU *t, DInstr *v) {
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(cpu_g_eaf(t, v, 0));
    FloatIBMResult r = fibm_divE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    register_set32(F(t, v, 'x'), fibm_to32(&r.result));
}

static void exec_LED(CPU *t, DInstr *v) {
    /* g_EAF is called twice (extraOffset 0 then 2), matching the source
     * exactly — including calling g_EA twice, so any indexed-with-
     * modification side effect fires twice too, same as JS. */
    uint32_t val = cpu_g_eaf(t, v, 0);
    uint32_t x = df_get(v, 'x');
    register_set32(cpu_f(t, (int)x), val);
    register_set32(cpu_f(t, (int)(x + 1)), cpu_g_eaf(t, v, 2));
    if ((val & 0x00ffffff) == 0) psw_set_cc(&t->psw, 0);
    else if (val & 0x80000000) psw_set_cc(&t->psw, 3);
    else psw_set_cc(&t->psw, 1);
}

static void exec_LER(CPU *t, DInstr *v) {
    uint32_t val = register_get32(F(t, v, 'y'));
    register_set32(F(t, v, 'x'), val);
    if ((val & 0x00ffffff) == 0) psw_set_cc(&t->psw, 0);
    else if (val & 0x80000000) psw_set_cc(&t->psw, 3);
    else psw_set_cc(&t->psw, 1);
}

static void exec_LE(CPU *t, DInstr *v) {
    uint32_t val = cpu_g_eaf(t, v, 0);
    register_set32(F(t, v, 'x'), val);
    if ((val & 0x00ffffff) == 0) psw_set_cc(&t->psw, 0);
    else if (val & 0x80000000) psw_set_cc(&t->psw, 3);
    else psw_set_cc(&t->psw, 1);
}

static void exec_LECR(CPU *t, DInstr *v) {
    uint32_t result = register_get32(F(t, v, 'y')) ^ 0x80000000;
    register_set32(F(t, v, 'x'), result);
    if (result & 0x80000000) psw_set_cc(&t->psw, 3);
    else if ((result & 0x00ffffff) == 0) psw_set_cc(&t->psw, 0);
    else psw_set_cc(&t->psw, 1);
}

static void exec_LFXR(CPU *t, DInstr *v) {
    register_set32(R(t, v, 'x'), register_get32(F(t, v, 'y')));
}

static void exec_LFLI(CPU *t, DInstr *v) {
    register_set32(F(t, v, 'x'), 0x41000000 | (df_get(v, 'y') << 20));
}

static void exec_LFLR(CPU *t, DInstr *v) {
    register_set32(F(t, v, 'x'), register_get32(R(t, v, 'y')));
}

/* -1/0/1 per subE(a,b)'s result sign — MVS's compares never dispatch FP
 * exceptions (the source discards `exc` entirely: `{result} = subE(a,b)`). */
static int mvs_cmp(const FloatIBM *a, const FloatIBM *b) {
    FloatIBMResult r = fibm_subE(a, b);
    if (fibm_gfracbits(&r.result) == 0) return 0;
    return fibm_gsign(&r.result) < 0 ? -1 : 1;
}

static void exec_MVS(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    FloatIBM input = fibm_from32(register_get32(cpu_f(t, (int)x)));
    FloatIBM upper = fibm_from32(register_get32(cpu_f(t, (int)(x + 1))));
    FloatIBM lower = fibm_from32(cpu_g_eaf(t, v, 0));

    if (mvs_cmp(&input, &lower) < 0) {
        register_set32(cpu_f(t, (int)x), fibm_to32(&lower));
        psw_set_cc(&t->psw, 3);
    } else if (mvs_cmp(&input, &upper) > 0) {
        register_set32(cpu_f(t, (int)x), fibm_to32(&upper));
        psw_set_cc(&t->psw, 1);
    } else {
        psw_set_cc(&t->psw, 0);
    }
}

static void exec_MEDR(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x'), y = df_get(v, 'y');
    FloatIBM v1 = fibm_from64(register_get32(cpu_f(t, (int)x)), register_get32(cpu_f(t, (int)(x + 1))));
    FloatIBM v2 = fibm_from64(register_get32(cpu_f(t, (int)y)), register_get32(cpu_f(t, (int)(y + 1))));
    FloatIBMResult r = fibm_mulQeE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    register_set32(cpu_f(t, (int)x), fibm_to64x(&r.result));
    register_set32(cpu_f(t, (int)(x + 1)), fibm_to64y(&r.result));
}

static void exec_MED(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    FloatIBM v1 = fibm_from64(register_get32(cpu_f(t, (int)x)), register_get32(cpu_f(t, (int)(x + 1))));
    uint32_t v2hw1 = cpu_g_eaf(t, v, 0);
    uint32_t v2hw2 = cpu_g_eaf(t, v, 2);
    FloatIBM v2 = fibm_from64(v2hw1, v2hw2);
    FloatIBMResult r = fibm_mulQeE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    register_set32(cpu_f(t, (int)x), fibm_to64x(&r.result));
    register_set32(cpu_f(t, (int)(x + 1)), fibm_to64y(&r.result));
}

static void exec_MER(CPU *t, DInstr *v) {
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(register_get32(F(t, v, 'y')));
    FloatIBMResult r = fibm_mulE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    register_set32(F(t, v, 'x'), fibm_to32(&r.result));
}

static void exec_ME(CPU *t, DInstr *v) {
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(cpu_g_eaf(t, v, 0));
    FloatIBMResult r = fibm_mulE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    register_set32(F(t, v, 'x'), fibm_to32(&r.result));
}

static void exec_SEDR(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x'), y = df_get(v, 'y');
    FloatIBM v1 = fibm_from64(register_get32(cpu_f(t, (int)x)), register_get32(cpu_f(t, (int)(x + 1))));
    FloatIBM v2 = fibm_from64(register_get32(cpu_f(t, (int)y)), register_get32(cpu_f(t, (int)(y + 1))));
    FloatIBMResult r = fibm_subE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    write_fp_result_dp_cc(t, v, &r.result);
}

static void exec_SED(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    FloatIBM v1 = fibm_from64(register_get32(cpu_f(t, (int)x)), register_get32(cpu_f(t, (int)(x + 1))));
    uint32_t v2hw1 = cpu_g_eaf(t, v, 0);
    uint32_t v2hw2 = cpu_g_eaf(t, v, 2);
    FloatIBM v2 = fibm_from64(v2hw1, v2hw2);
    FloatIBMResult r = fibm_subE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    write_fp_result_dp_cc(t, v, &r.result);
}

static void exec_SER(CPU *t, DInstr *v) {
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(register_get32(F(t, v, 'y')));
    FloatIBMResult r = fibm_subE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    write_fp_result_sp_cc(t, v, &r.result);
}

static void exec_SE(CPU *t, DInstr *v) {
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(cpu_g_eaf(t, v, 0));
    FloatIBMResult r = fibm_subE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    write_fp_result_sp_cc(t, v, &r.result);
}

static void exec_STED(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    cpu_s_eaf(t, v, register_get32(cpu_f(t, (int)x)), 0);
    cpu_s_eaf(t, v, register_get32(cpu_f(t, (int)(x + 1))), 2);
}

static void exec_STE(CPU *t, DInstr *v) {
    cpu_s_eaf(t, v, register_get32(F(t, v, 'x')), 0);
}

/* ---------------------------------------------------------------------
 * Exec bodies — privileged / IO batch
 * ------------------------------------------------------------------- */

static void exec_DIAG(CPU *t, DInstr *v) {
    /* Source body is `# XXX UNIMPL` -- genuinely empty. DIAG is a whole
     * family of manufacturer self-test microcode commands (H-bus wrap,
     * command-PLA test, arithmetic-interrupt test, ROS parity, machine-
     * check force, store-protect readback, ...) that real flight/HAL-S
     * code never issues, so none of it was ever needed before BILDNEW5/
     * GPCIPL's own hardware self test (STM1.asm's CPUTEST8 and friends)
     * started exercising it directly. Only the one command that self
     * test's own interrupt-priority section depends on is implemented
     * here; every other DIAG command remains a no-op, a known, separate
     * gap (STM1.asm names CPUTEST1/R/2/6/7/8/9/10, most still untested
     * here). */
    if (!cpu_i_super(t)) return;
    uint32_t regNum = (v->hw1 >> 8) & 0x7; /* "xxx" field, same position as ISPB's m1 */
    uint32_t data = register_get32(cpu_r(t, (int)regNum));
    uint32_t cmd = cpu_g_eah(t, v);
    if (cmd == 0x7001 && data == 0x90140000u) {
        /* "START INT PRIO MICRO TEST" (STM1.asm CPUIP150, DIAG R4,X'7001'
         * with R4=X'9014' preloaded). Per its own comment ("PERFORM DIAG
         * INSTR TO SET CLOCK1 & 2, EXTERNAL 0,1,2,3,4 AND AGE INTERRUPTS
         * PENDING") this stages all eight sources; the real CPU's own
         * existing priority-ordered dispatch (cpu_check_interrupts,
         * already strictly Clock1 > Clock2 > EX0 > EX1 > EX2 > EX3 > EX4)
         * then releases the highest-priority still-pending one each time
         * the test driver re-issues SSM to unmask everything, exactly
         * matching INTHNDLR.asm's own per-handler "IPRIOWD order" table
         * (0..6) -- no separate staged-queue tracking needed here, the
         * existing mask-gated dispatch already does it correctly once
         * all seven are simultaneously marked pending. AGE (order 7,
         * INTHNDLR.asm's EX1 handler distinguishing it from real EX1 by
         * interrupt code) is a known, separate gap -- cpu_instr.c's own
         * ICR "Read AGE" case already documents AGE as unsimulated. */
        t->intPending.clk1 = true;
        t->intPending.clk2 = true;
        t->intPending.iopGrp1 = true; /* EX0 */
        t->intPending.iopGrp2 = true; /* EX1 */
        t->intPending.iopProg = true; /* EX2 */
        t->intPending.ext3 = true;    /* EX3 */
        t->intPending.ext4 = true;    /* EX4 */
    }
}

static void exec_ISPB(CPU *t, DInstr *v) {
    if (!cpu_i_super(t)) return;
    uint32_t ea = cpu_g_ea(t, v);
    uint32_t m1 = (v->hw1 >> 8) & 0x7; /* bits 5-7 */
    switch (m1) {
        case 0:
            membus_set_store_protect(t->ram, ea, false);
            break;
        case 1: {
            uint32_t fwAddr = ea & 0xfffe;
            membus_set_store_protect(t->ram, fwAddr, false);
            membus_set_store_protect(t->ram, fwAddr + 1, false);
            break;
        }
        case 2:
            membus_set_store_protect(t->ram, ea, true);
            break;
        case 3: {
            uint32_t fwAddr = ea & 0xfffe;
            membus_set_store_protect(t->ram, fwAddr, true);
            membus_set_store_protect(t->ram, fwAddr + 1, true);
            break;
        }
        default:
            /* Illegal M1 (100-111): source sets `t.storeProtectOverride
             * = true`, a property never read anywhere else in the
             * codebase (grep-verified) — a genuine no-op, not ported. */
            break;
    }
}

static void exec_LPS(CPU *t, DInstr *v) {
    if (!cpu_i_super(t)) return;
    uint32_t eaw1 = cpu_g_ea(t, v);
    uint32_t eaw2 = eaw1 + 2;
    psw_load(&t->psw, membus_get32(t->ram, eaw1), membus_get32(t->ram, eaw2));
}

static void exec_MVH(CPU *t, DInstr *v) {
    uint32_t r1val = register_get32(R(t, v, 'x'));
    uint32_t r2val = register_get32(R(t, v, 'y'));
    uint32_t destAddr = (r1val >> 16) & 0xffff;
    uint32_t count = r1val & 0xffff;
    if (count & 0x8000) return; /* negative -> no-op */
    uint32_t srcAddr = (r2val >> 16) & 0x7fff;
    if (r2val & 0x80000000) {
        uint32_t dsr = r2val & 0xf;
        srcAddr = (dsr << 15) | srcAddr;
    }
    if (destAddr & 0x8000) {
        destAddr = (psw_get_dsr(&t->psw) << 15) | (destAddr & 0x7fff);
    }
    while (count > 0) {
        count--;
        uint32_t hw = membus_get16(t->ram, srcAddr + count);
        membus_set16(t->ram, destAddr + count, hw, true);
    }
    register_set32(R(t, v, 'x'), destAddr << 16);
}

static void exec_SPM(CPU *t, DInstr *v) {
    uint32_t bits = (register_get32(R(t, v, 'y')) >> 8) & 0xff;
    psw_set_cc(&t->psw, (bits >> 6) & 3);
    psw_set_carry(&t->psw, (bits >> 5) & 1);
    psw_set_overflow(&t->psw, (bits >> 4) & 1);
    psw_set_fixed_pt_overflow(&t->psw, (bits >> 3) & 1);
    psw_set_exponent_underflow(&t->psw, (bits >> 1) & 1);
    psw_set_significance_mask(&t->psw, bits & 1);
}

static void exec_SSM(CPU *t, DInstr *v) {
    if (!cpu_i_super(t)) return;
    uint32_t hwVal = cpu_g_eah(t, v);
    uint32_t psw2 = register_get32(&t->psw.psw2);
    psw2 = (hwVal << 16) | (psw2 & 0xffff);
    register_set32(&t->psw.psw2, psw2);
    /* External 0's "C/M Idle" cause used to be raised here, immediately
     * whenever its mask bit (0x10) was set -- but that fires whenever
     * ANY code broadly re-enables interrupts, not just when something
     * is genuinely arming and waiting for it. Now raised where the real
     * physical condition actually originates: exec_ICR's "Write
     * Discretes" case (0x0c), the last step of BILDNEW5/GPCIPL's own
     * MIAENBL subroutine's MIA transmitter enable/disable dance -- see
     * its own comment for why. */
}

static void exec_SCAL(CPU *t, DInstr *v) {
    uint32_t branchAddr = cpu_g_ea(t, v);
    uint32_t r1val = register_get32(R(t, v, 'x'));
    uint32_t ptr = (r1val >> 16) & 0xffff;
    uint32_t inc = r1val & 0xffff;
    uint32_t sa = (ptr + inc) & 0xffff;
    uint32_t psw1 = register_get32(&t->psw.psw1);
    membus_set16(t->ram, sa, psw1 >> 16, true);
    membus_set16(t->ram, sa + 1, psw1 & 0xffff, true);
    for (int i = 0; i <= 7; i++) {
        uint32_t regVal = register_get32(cpu_r(t, i));
        membus_set16(t->ram, sa + 2 + (uint32_t)i * 2, regVal >> 16, true);
        membus_set16(t->ram, sa + 2 + (uint32_t)i * 2 + 1, regVal & 0xffff, true);
    }
    register_set32(R(t, v, 'x'), (sa << 16) | 18);
    psw_set_nia(&t->psw, branchAddr);
}

static void exec_SRET(CPU *t, DInstr *v) {
    uint32_t m1 = df_get(v, 'x');
    uint32_t cc = psw_get_cc(&t->psw);
    if (!((m1 & 4 && cc == 0) || (m1 & 2 && cc == 3) || (m1 & 1 && cc == 1))) return;
    uint32_t ptr = (register_get32(R(t, v, 'y')) >> 16) & 0xffff;
    uint32_t psw1hi = membus_get16(t->ram, ptr);
    uint32_t psw1lo = membus_get16(t->ram, ptr + 1);
    uint32_t newPsw1 = (psw1hi << 16) | psw1lo;
    for (int i = 0; i <= 7; i++) {
        uint32_t hi = membus_get16(t->ram, ptr + 2 + (uint32_t)i * 2);
        uint32_t lo = membus_get16(t->ram, ptr + 2 + (uint32_t)i * 2 + 1);
        register_set32(cpu_r(t, i), (hi << 16) | lo);
    }
    register_set32(&t->psw.psw1, newPsw1);
}

static void exec_SVC(CPU *t, DInstr *v) {
    uint32_t ea = cpu_g_ea(t, v);
    uint32_t r1 = register_get32(cpu_r(t, 1));
    if (t->halUCP && t->halUCPHandleSVC && t->halUCPHandleSVC(t->halUCP, ea, r1)) {
        return;
    }
    psw_set_int_code(&t->psw, ea);
    membus_set32(t->ram, 0x58, register_get32(&t->psw.psw1), true);
    membus_set32(t->ram, 0x5a, register_get32(&t->psw.psw2), true);
    psw_load(&t->psw, membus_get32(t->ram, 0x5c), membus_get32(t->ram, 0x5e));
}

static void exec_TS(CPU *t, DInstr *v) {
    uint32_t ea = cpu_g_ea(t, v);
    uint32_t value = membus_get16(t->ram, ea);
    if (value == 0) psw_set_cc(&t->psw, 0);
    else if (value == 0xffff) psw_set_cc(&t->psw, 1);
    else psw_set_cc(&t->psw, 3);
    membus_set16(t->ram, ea, 0xffff, true);
}

static void exec_TSB(CPU *t, DInstr *v) {
    uint32_t mask = df_get(v, 'I');
    uint32_t ea = cpu_g_ea(t, v);
    uint32_t value = membus_get16(t->ram, ea);
    uint32_t selected = value & mask;
    if (mask == 0 || selected == 0) psw_set_cc(&t->psw, 0);
    else if (selected == mask) psw_set_cc(&t->psw, 1);
    else psw_set_cc(&t->psw, 3);
    membus_set16(t->ram, ea, value | mask, true);
}

static void exec_LDM(CPU *t, DInstr *v) {
    uint32_t fw = cpu_g_eaf(t, v, 0);
    uint32_t regSet = psw_get_reg_set(&t->psw);
    registerfile_set_dse(&t->regFiles[regSet], 0, (fw >> 28) & 0xf);
    registerfile_set_dse(&t->regFiles[regSet], 1, (fw >> 24) & 0xf);
    registerfile_set_dse(&t->regFiles[regSet], 2, (fw >> 20) & 0xf);
    registerfile_set_dse(&t->regFiles[regSet], 3, (fw >> 16) & 0xf);
}

static void exec_LXAR(CPU *t, DInstr *v) {
    uint32_t addrConst = register_get32(R(t, v, 'y'));
    uint32_t addr = (addrConst >> 16) & 0x7fff;
    uint32_t dseVal = addrConst & 0xf;
    register_set32(R(t, v, 'x'), addr << 16);
    registerfile_set_dse(&t->regFiles[psw_get_reg_set(&t->psw)], (int)df_get(v, 'x'), dseVal);
}

static void exec_LXA(CPU *t, DInstr *v) {
    uint32_t addrConst = cpu_g_eaf(t, v, 0);
    uint32_t addr = (addrConst >> 16) & 0x7fff;
    uint32_t dseVal = addrConst & 0xf;
    register_set32(R(t, v, 'x'), addr << 16);
    registerfile_set_dse(&t->regFiles[psw_get_reg_set(&t->psw)], (int)df_get(v, 'x'), dseVal);
}

static void exec_STXAR(CPU *t, DInstr *v) {
    /* Source body is a bare `return`. */
    (void)t;
    (void)v;
}

static void exec_STXA(CPU *t, DInstr *v) {
    /* Source computes addrConst/addr but never uses them — dead result.
     * The g_EAF call itself may still have addressing side effects
     * (indexed-with-modification), so it's still made and discarded. */
    (void)cpu_g_eaf(t, v, 0);
}

static void exec_STDM(CPU *t, DInstr *v) {
    uint32_t regSet = psw_get_reg_set(&t->psw);
    uint32_t fw = (registerfile_get_dse(&t->regFiles[regSet], 0) << 28) |
                  (registerfile_get_dse(&t->regFiles[regSet], 1) << 24) |
                  (registerfile_get_dse(&t->regFiles[regSet], 2) << 20) |
                  (registerfile_get_dse(&t->regFiles[regSet], 3) << 16);
    cpu_s_eaf(t, v, fw, 0);
}

static void exec_ICR(CPU *t, DInstr *v) {
    if (!cpu_i_super(t)) return;
    uint32_t cw = register_get32(R(t, v, 'y'));
    uint32_t cmd = (cw >> 27) & 0x1f;
    switch (cmd) {
        case 0x00: { /* Read Counter 1 */
            uint32_t hi = membus_get16(t->ram, 0x00b0);
            uint32_t lo = t->counter1;
            register_set32(R(t, v, 'x'), (hi << 16) | (lo & 0xffff));
            break;
        }
        case 0x01: { /* Read Counter 2 */
            uint32_t hi = membus_get16(t->ram, 0x00b1);
            uint32_t lo = t->counter2;
            register_set32(R(t, v, 'x'), (hi << 16) | (lo & 0xffff));
            break;
        }
        case 0x08: { /* Write Counter 1 */
            uint32_t r1 = register_get32(R(t, v, 'x'));
            membus_set16(t->ram, 0x00b0, (r1 >> 16) & 0xffff, true);
            t->counter1 = r1 & 0xffff;
            /* Writing a countdown value to a real hardware timer starts
             * it counting -- cpu_exec1's per-instruction decrement (and
             * the Clock 1 interrupt it fires on underflow) was declared
             * and fully wired but nothing anywhere ever set this flag,
             * so no ICR-armed delay (e.g. BILDNEW5/GPCIPL's own
             * CLK2DELY) could ever complete; confirmed no other call
             * site sets it either. */
            t->counter1Enabled = true;
            break;
        }
        case 0x09: { /* Write Counter 2 */
            uint32_t r1 = register_get32(R(t, v, 'x'));
            membus_set16(t->ram, 0x00b1, (r1 >> 16) & 0xffff, true);
            t->counter2 = r1 & 0xffff;
            t->counter2Enabled = true; /* see Write Counter 1's comment */
            break;
        }
        case 0x05: /* Read AGE — not simulated, returns 0 */
            register_set32(R(t, v, 'x'), 0);
            break;
        case 0x0c:
            /* Write Discretes: source sets `t.discretes = ...`, a
             * property never read anywhere else (grep-verified) — the
             * value itself is still a genuine no-op, not ported.
             *
             * External 0's "C/M Idle" cause (AP-101S-instruction-set.txt
             * row 50) is raised here instead of on every SSM that leaves
             * its mask bit set (the earlier approach, which mis-fired
             * whenever unrelated code broadly re-enabled interrupts for
             * its own reasons -- confirmed against BILDNEW5/GPCIPL's own
             * boot sequence, where that repeated firing corrupted a
             * self-test region it re-entered). A discrete write via ICR
             * is what BILDNEW5's own MIAENBL subroutine issues as the
             * *last* step of its transmitter enable/disable dance ("ICR
             * R7,R3 ENABLE ICR LINE"), i.e. the point at which the real
             * MIA chip has just finished reconfiguring and genuinely can
             * go idle -- a physically-motivated trigger instead of a
             * mask-transition heuristic. This emulator has no ongoing
             * IOP activity between instructions to keep the chip "busy"
             * afterward, so the condition is simply pending from here
             * until EX0 is unmasked, exactly like Clock1/Clock2/EX1-4
             * already work. */
            t->intPending.iopGrp1 = true;
            break;
        case 0x0d: /* Write AGE — not simulated, no-op */
            return;
        case 0x10:
            /* Channel Reset: source calls `t.iop?.reset?()` — iop.coffee
             * has no `reset` method (grep-verified), so this is a no-op
             * even once IOP is ported. */
            break;
        default:
            if ((cmd & 0x10) == 0) {
                /* Source calls `t.i_ILLEGAL()`, a method that doesn't
                 * exist anywhere on CPU (grep-verified) — would throw in
                 * the real JS if ever reached. Implemented here as the
                 * evident intent (cpu.coffee's signalIllegalOp) rather
                 * than reproducing the crash. */
                cpu_signal_illegal_op(t);
            }
            /* else: 1xxxx other than 10000 -> channel reset, no-op here too. */
            break;
    }
}

static OpEntry OPS[] = {
    { "PC", "11011xxx11101yyy", exec_PC, 2, 1 },
    { "AR", "00000xxx11100yyy", exec_AR, 2, 1 },
    { "A", "00000xxxddddddbb", exec_A, 2, 1 },
    { "AH", "10000xxxddddddbb", exec_AH, 1, 1 },
    { "AHI", "1011000011100yyy/I", exec_AHI, 1, 1 },
    { "AST", "00000xxx11111abb/X", exec_AST, 2, 1 },
    { "CR", "00010xxx11100yyy", exec_CR, 2, 1 },
    { "C", "00010xxxddddddbb", exec_C, 2, 1 },
    { "CBL", "00001xxx11101yyy", exec_CBL, 2, 1 },
    { "CH", "10010xxxddddddbb", exec_CH, 1, 1 },
    { "CHI", "1011010111100yyy/I", exec_CHI, 1, 1 },
    { "CIST", "10110101ddddddbb/I", exec_CIST, 1, 1 },
    { "DR", "01001xxx11100yyy", exec_DR, 2, 1 },
    { "D", "01001xxxddddddbb", exec_D, 2, 1 },
    { "XUL", "00000xxx11101yyy", exec_XUL, 2, 1 },
    { "IAL", "11100xxxddddddbb", exec_IAL, 1, 1 },
    { "IHL", "10000xxx11111abb/X", exec_IHL, 1, 1 },
    { "LR", "00011xxx11100yyy", exec_LR, 2, 1 },
    { "L", "00011xxxddddddbb", exec_L, 2, 1 },
    { "LA", "11101xxxddddddbb", exec_LA, 1, 1 },
    { "LHI", "11101xxx11110011/I", exec_LHI, 1, 1 },
    { "LCR", "11101xxx11101yyy", exec_LCR, 2, 1 },
    { "LFXI", "10111xxx1110yyyy", exec_LFXI, 2, 1 },
    { "LH", "10011xxxddddddbb", exec_LH, 1, 1 },
    { "LM", "1100110011111abb/X", exec_LM, 2, 1 },
    { "MSTH", "10110000ddddddbb/I", exec_MSTH, 1, 1 },
    { "MR", "01000xxx11100yyy", exec_MR, 2, 1 },
    { "M", "01000xxxddddddbb", exec_M, 2, 1 },
    { "MH", "10101xxxddddddbb", exec_MH, 1, 1 },
    { "MHI", "1011011111100yyy/I", exec_MHI, 1, 1 },
    { "MIH", "10011xxx11111abb/X", exec_MIH, 1, 1 },
    { "ST", "00110xxxddddddbb", exec_ST, 2, 1 },
    { "STH", "10111xxxddddddbb", exec_STH, 1, 1 },
    { "STM", "1100100011111abb/X", exec_STM, 2, 1 },
    { "SR", "00001xxx11100yyy", exec_SR, 2, 1 },
    { "S", "00001xxxddddddbb", exec_S, 2, 1 },
    { "SST", "00001xxx11111abb/X", exec_SST, 2, 1 },
    { "SH", "10001xxxddddddbb", exec_SH, 1, 1 },
    { "TD", "10100000ddddddbb", exec_TD, 1, 1 },
    { "BALR", "11100xxx11100yyy", exec_BALR, 2, 2 },
    { "BAL", "11100xxx11110abb/X", exec_BAL, 1, 2 },
    { "BIX", "11011xxx11110abb/X", exec_BIX, 1, 2 },
    { "BCR", "11000xxx11100yyy", exec_BCR, 2, 2 },
    { "BC", "11000xxx11110abb/X", exec_BC, 1, 2 },
    { "BCB", "11011xxxdddddd10", exec_BCB, 1, 2 },
    { "BCRE", "11000xxx11101yyy", exec_BCRE, 2, 2 },
    { "BCF", "11011xxxdddddd00", exec_BCF, 1, 2 },
    { "BCTR", "11010xxx11100yyy", exec_BCTR, 2, 2 },
    { "BCT", "11010xxx11110abb/X", exec_BCT, 1, 2 },
    { "BCTB", "11011xxxdddddd11", exec_BCTB, 1, 2 },
    { "BVCR", "11001xxx11100yyy", exec_BVCR, 2, 2 },
    { "BVC", "11001xxx11110abb/X", exec_BVC, 1, 2 },
    { "BVCF", "11011xxxdddddd01", exec_BVCF, 1, 2 },
    { "NCT", "11100xxx11101yyy", exec_NCT, 2, 1 },
    { "SLL", "11110xxxdddddd00", exec_SLL, 2, 4 },
    { "SLDL", "11111xxxdddddd00", exec_SLDL, 2, 4 },
    { "SRA", "11110xxxdddddd01", exec_SRA, 2, 4 },
    { "SRDA", "11111xxxdddddd01", exec_SRDA, 2, 4 },
    { "SRDL", "11111xxxdddddd10", exec_SRDL, 2, 4 },
    { "SRL", "11110xxxdddddd10", exec_SRL, 2, 4 },
    { "SRR", "11110xxxdddddd11", exec_SRR, 2, 4 },
    { "SRDR", "11111xxxdddddd11", exec_SRDR, 2, 4 },
    { "NR", "00100xxx11100yyy", exec_NR, 2, 1 },
    { "N", "00100xxxddddddbb", exec_N, 2, 1 },
    { "NHI", "1011011011100yyy/I", exec_NHI, 1, 1 },
    { "NIST", "10110110ddddddbb/I", exec_NIST, 1, 1 },
    { "NST", "00100xxx11111abb/X", exec_NST, 2, 1 },
    { "XR", "01110xxx11100yyy", exec_XR, 2, 1 },
    { "X", "01110xxxddddddbb", exec_X, 2, 1 },
    { "XHI", "1011010011100yyy/I", exec_XHI, 1, 1 },
    { "XIST", "10110100ddddddbb/I", exec_XIST, 1, 1 },
    { "XST", "01110xxx11111abb/X", exec_XST, 2, 1 },
    { "OR", "00101xxx11100yyy", exec_OR, 2, 1 },
    { "O", "00101xxxddddddbb", exec_O, 2, 1 },
    { "OHI", "1011001011100yyy/I", exec_OHI, 1, 1 },
    { "OST", "00101xxx11111abb/X", exec_OST, 2, 1 },
    { "SUM", "10011xxx11101yyy", exec_SUM, 2, 1 },
    { "SB", "10110010ddddddbb/I", exec_SB, 1, 1 },
    { "SHW", "10100010ddddddbb", exec_SHW, 1, 1 },
    { "TB", "10110011ddddddbb/I", exec_TB, 1, 1 },
    { "TRB", "1011001111100yyy/I", exec_TRB, 2, 1 },
    { "TH", "10100011ddddddbb", exec_TH, 1, 1 },
    { "ZB", "10110001ddddddbb/I", exec_ZB, 1, 1 },
    { "ZRB", "1011000111100yyy/I", exec_ZRB, 2, 1 },
    { "ZH", "10100001ddddddbb", exec_ZH, 1, 1 },
    { "AEDR", "01010xxx11101yyy", exec_AEDR, 2, 1 },
    { "AED", "01010xxx11111abb/X", exec_AED, 3, 1 },
    { "AER", "01010xxx11100yyy", exec_AER, 1, 1 },
    { "AE", "01010xxxddddddbb", exec_AE, 2, 1 },
    { "CER", "01001xxx11101yyy", exec_CER, 1, 1 },
    { "CE", "01001xxx11111abb/X", exec_CE, 2, 1 },
    { "CEDR", "00011xxx11101yyy", exec_CEDR, 1, 1 },
    { "CED", "00011xxx11111abb/X", exec_CED, 3, 1 },
    { "CVFX", "00111xxx11100yyy", exec_CVFX, 2, 1 },
    { "CVFL", "00111xxx11101yyy", exec_CVFL, 2, 1 },
    { "DEDR", "00010xxx11101yyy", exec_DEDR, 1, 1 },
    { "DED", "00010xxx11111abb/X", exec_DED, 3, 1 },
    { "DER", "01101xxx11100yyy", exec_DER, 1, 1 },
    { "DE", "01101xxxddddddbb", exec_DE, 2, 1 },
    { "LED", "01111xxx11111abb/X", exec_LED, 3, 1 },
    { "LER", "01111xxx11100yyy", exec_LER, 2, 1 },
    { "LE", "01111xxxddddddbb", exec_LE, 2, 1 },
    { "LECR", "01111xxx11101yyy", exec_LECR, 2, 1 },
    { "LFXR", "00100xxx11101yyy", exec_LFXR, 2, 1 },
    { "LFLI", "10001xxx1110yyyy", exec_LFLI, 2, 1 },
    { "LFLR", "00101xxx11101yyy", exec_LFLR, 2, 1 },
    { "MVS", "01100xxx11111abb/X", exec_MVS, 2, 1 },
    { "MEDR", "00110xxx11101yyy", exec_MEDR, 2, 1 },
    { "MED", "00110xxx11111abb/X", exec_MED, 3, 1 },
    { "MER", "01100xxx11100yyy", exec_MER, 2, 1 },
    { "ME", "01100xxxddddddbb", exec_ME, 2, 1 },
    { "SEDR", "01011xxx11101yyy", exec_SEDR, 2, 1 },
    { "SED", "01011xxx11111abb/X", exec_SED, 3, 1 },
    { "SER", "01011xxx11100yyy", exec_SER, 2, 1 },
    { "SE", "01011xxxddddddbb", exec_SE, 2, 1 },
    { "STED", "00111xxx11111abb/X", exec_STED, 3, 1 },
    { "STE", "00111xxxddddddbb", exec_STE, 2, 1 },
    { "DIAG", "11000xxx11111abb/X", exec_DIAG, 1, 1 },
    { "ISPB", "11101xxx11111abb/X", exec_ISPB, 1, 1 },
    { "LPS", "1100110111111abb/X", exec_LPS, 2, 1 },
    { "MVH", "01101xxx11101yyy", exec_MVH, 2, 1 },
    { "SPM", "1100100011101yyy", exec_SPM, 2, 1 },
    { "SSM", "1000100011111abb/X", exec_SSM, 2, 1 },
    { "SCAL", "11010xxx11111abb/X", exec_SCAL, 1, 2 },
    { "SRET", "10010xxx11101yyy", exec_SRET, 2, 1 },
    { "SVC", "1100100111111abb/X", exec_SVC, 1, 1 },
    { "TS", "1011100011111abb/X", exec_TS, 2, 1 },
    { "TSB", "10110111ddddddbb/I", exec_TSB, 1, 1 },
    { "LDM", "0110100011111abb/X", exec_LDM, 2, 1 },
    { "LXAR", "01000xxx11101yyy", exec_LXAR, 2, 1 },
    { "LXA", "01000xxx11111abb/X", exec_LXA, 2, 1 },
    { "STXAR", "10100xxx11101yyy", exec_STXAR, 2, 1 },
    { "STXA", "10100xxx11111abb/X", exec_STXA, 2, 1 },
    { "STDM", "1001000011111abb/X", exec_STDM, 2, 1 },
    { "ICR", "11011xxx11100yyy", exec_ICR, 2, 1 },
};

#define OPS_COUNT (int)(sizeof(OPS) / sizeof(OPS[0]))

static InstrDesc DESCS[OPS_COUNT];
static const InstrDesc *SORTED[OPS_COUNT];
static bool g_tableInit = false;

static int cmp_mask_desc(const void *a, const void *b) {
    const InstrDesc *da = *(const InstrDesc **)a;
    const InstrDesc *db = *(const InstrDesc **)b;
    if (da->pb.mask > db->pb.mask) return -1;
    if (da->pb.mask < db->pb.mask) return 1;
    return 0;
}

void cpu_instr_table_init(void) {
    if (g_tableInit) return;
    for (int i = 0; i < OPS_COUNT; i++) {
        DESCS[i].nm = OPS[i].nm;
        DESCS[i].pb = pb_make_desc(OPS[i].pattern);
        DESCS[i].e = OPS[i].e;
        DESCS[i].addrWidth = OPS[i].addrWidth;
        DESCS[i].opType = OPS[i].opType;
        SORTED[i] = &DESCS[i];
    }
    qsort(SORTED, OPS_COUNT, sizeof(SORTED[0]), cmp_mask_desc);
    g_tableInit = true;
}

/* ---------------------------------------------------------------------
 * decode() + decodef()
 * ------------------------------------------------------------------- */

static void decodef(const InstrDesc *desc, uint32_t hw1, uint32_t hw2, DInstr *v) {
    v->nm = desc->nm;
    v->hw1 = hw1;
    v->hw2 = hw2;

    for (int c = 0; c < DINSTR_FIELD_TABLE_SIZE; c++) {
        if (desc->pb.field[c].present) {
            df_set(v, (char)c, pb_get_field(hw1, &desc->pb.field[c]));
        }
    }

    v->niaIncr = desc->pb.len; /* == origLen */
    v->addrWidth = desc->addrWidth;
    v->opType = desc->opType;

    if (desc->pb.type == PB_TYPE_RI || desc->pb.type == PB_TYPE_SI) {
        df_set(v, 'I', hw2);
    }

    /* `desc.longdisp?` (source) is never set by any real instruction —
     * dead code, not ported (see cpu.h's instr_decode doc comment). */

    if (strcmp(desc->nm, "LFXI") == 0) {
        df_set(v, 'y', df_get(v, 'y') - 2);
    }

    if (desc->pb.type == PB_TYPE_RS) {
        if (df_has(v, 'd')) {
            df_set(v, 'd', ((hw1 >> 2) & 0x3f) - 2);
        } else {
            v->niaIncr = 2;
            v->extended = true;
            if (df_get(v, 'a') == 0) {
                df_set(v, 'd', hw2);
            } else {
                df_set(v, 'i', hw2 >> 13);
                v->hasIa = true;
                v->ia = (hw2 >> 12) & 1;
                v->hasIi = true;
                v->ii = (hw2 >> 11) & 1;
                df_set(v, 'd', hw2 & 0x7ff);
            }
        }
    }

    if (desc->pb.type == PB_TYPE_SRS && desc->opType != OPTYPE_SHFT) {
        uint32_t dval = df_get(v, 'd');
        bool isIAL = strcmp(desc->nm, "IAL") == 0;
        if (dval == 0x3c || (isIAL && dval == 0x3e)) {
            v->extended = true;
            df_set(v, 'd', hw2);
            v->niaIncr = 2;
        } else if (dval == 0x3d || (isIAL && dval == 0x3f)) {
            v->extended = true;
            df_set(v, 'i', hw2 >> 13);
            v->hasIa = true;
            v->ia = (hw2 >> 12) & 1;
            v->hasIi = true;
            v->ii = (hw2 >> 11) & 1;
            df_set(v, 'd', hw2 & 0x7ff);
            v->niaIncr = 2;
        }
    }

    v->addrWidth = desc->addrWidth;
    v->opType = desc->opType;
}

const InstrDesc *instr_decode(uint32_t hw1, uint32_t hw2, DInstr *v) {
    cpu_instr_table_init();
    memset(v, 0, sizeof(*v));

    const InstrDesc *found = NULL;
    for (int i = 0; i < OPS_COUNT; i++) {
        const InstrDesc *d = SORTED[i];
        if ((hw1 & d->pb.mask) == d->pb.maskedVal) {
            found = d;
            break;
        }
    }
    if (!found) return NULL;

    decodef(found, hw1, hw2, v);
    return found;
}

/* ---------------------------------------------------------------------
 * toStr() — disassembly text (Phase 10: --trace output, watchpoint
 * messages). Field values are read as signed (int32_t) before formatting
 * — decodef can store an underflowed small negative displacement as a
 * wrapped uint32_t (e.g. RS-format `d = ((hw1>>2)&0x3f) - 2`, or LFXI's
 * `y -= 2`), and the JS source's plain `"#{v.x}"`/`.asHex()` would show
 * that as a genuine negative number, not a huge unsigned one.
 * ------------------------------------------------------------------- */

void instr_to_str(uint32_t hw1, uint32_t hw2, char *out, size_t outSize) {
    DInstr v;
    const InstrDesc *d = instr_decode(hw1, hw2, &v);
    if (!d) {
        snprintf(out, outSize, "UNDEFINED");
        return;
    }

    char s[160];
    size_t pos = 0;
    char nmPadded[16];
    str_rpad(nmPadded, sizeof nmPadded, v.nm, " ", 5);
    pos += (size_t)snprintf(s + pos, sizeof s - pos, "%s", nmPadded);

    if (df_has(&v, 'x')) {
        pos += (size_t)snprintf(s + pos, sizeof s - pos, "%d,", (int32_t)df_get(&v, 'x'));
    }
    if (df_has(&v, 'y')) {
        pos += (size_t)snprintf(s + pos, sizeof s - pos, "%d", (int32_t)df_get(&v, 'y'));
        if (df_has(&v, 'I')) {
            pos += (size_t)snprintf(s + pos, sizeof s - pos, ",");
        }
    }
    if (df_has(&v, 'I') && d->pb.type == PB_TYPE_RI) {
        char hex[16];
        as_hex(hex, sizeof hex, (long long)(int32_t)df_get(&v, 'I'), 4);
        pos += (size_t)snprintf(s + pos, sizeof s - pos, "X'%s'", hex);
    }
    if (df_has(&v, 'd')) {
        char hex[16];
        as_hex(hex, sizeof hex, (long long)(int32_t)df_get(&v, 'd'), 4);
        pos += (size_t)snprintf(s + pos, sizeof s - pos, "X'%s'", hex);
    }
    if (df_has(&v, 'b')) {
        int32_t bval = (int32_t)df_get(&v, 'b');
        if (df_has(&v, 'i') && df_get(&v, 'i') != 0) {
            pos += (size_t)snprintf(s + pos, sizeof s - pos, "(%d,", (int32_t)df_get(&v, 'i'));
            if (!(v.extended && bval == 3)) {
                pos += (size_t)snprintf(s + pos, sizeof s - pos, "%d", bval);
            }
            pos += (size_t)snprintf(s + pos, sizeof s - pos, ")");
        } else if (!(v.extended && bval == 3)) {
            pos += (size_t)snprintf(s + pos, sizeof s - pos, "(%d)", bval);
        }
    }
    if (df_has(&v, 'I') && d->pb.type == PB_TYPE_SI) {
        char hex[16];
        as_hex(hex, sizeof hex, (long long)(int32_t)df_get(&v, 'I'), 4);
        pos += (size_t)snprintf(s + pos, sizeof s - pos, ",X'%s'", hex);
    }

    snprintf(out, outSize, "%s", s);
}
