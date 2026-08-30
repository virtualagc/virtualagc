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
        /* R1 odd: still a FULL 32x32 multiply -- only the saving
         * differs.  POO 4.21: "Both multiplier and multiplicand are
         * 32-bit signed twos complement fractions.  The product is a
         * 64-bit ... fraction number and occupies an even/odd register
         * pair when the R1 field references an even-numbered general
         * register.  When R1 is odd, only the most significant 32 bits
         * of the product is saved in general register R1."  This did a
         * 16x16 halfword multiply of the two upper halves instead,
         * which is a different operation entirely -- that is MULTIPLY
         * HALFWORD (4.22), a different instruction. */
        Q31MulResult r = q31_mul32((int32_t)register_get32(R(t, v, 'x')), (int32_t)register_get32(R(t, v, 'y')));
        register_set32(R(t, v, 'x'), r.hi);
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
        /* R1 odd: still a FULL 32x32 multiply -- only the saving
         * differs.  POO 4.21: "Both multiplier and multiplicand are
         * 32-bit signed twos complement fractions.  The product is a
         * 64-bit ... fraction number and occupies an even/odd register
         * pair when the R1 field references an even-numbered general
         * register.  When R1 is odd, only the most significant 32 bits
         * of the product is saved in general register R1."  This did a
         * 16x16 halfword multiply of the two upper halves instead,
         * which is a different operation entirely -- that is MULTIPLY
         * HALFWORD (4.22), a different instruction. */
        Q31MulResult r = q31_mul32((int32_t)register_get32(R(t, v, 'x')), (int32_t)cpu_g_eaf(t, v, 0));
        register_set32(R(t, v, 'x'), r.hi);
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
        /* cpu_store_fw, not a raw set32: a protected location takes the
         * store protect violation and stops the instruction there
         * (POO 2.4). */
        if (!cpu_store_fw(t, v2ea + (uint32_t)(i * 2), register_get32(cpu_r(t, i)))) break;
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
    /* SNAPSHOT THE LINK BEFORE COMPUTING THE EA.  psw1 carries the caller's
     * BSR (bits 24-27) and DSR (28-31) alongside the return address, and
     * BCRE restores the pair from it -- FCMTRACE's own exit says so:
     *
     *     BCRE 7,R7   RETURN TO CALLING ROUTINE (BSR/DSR OF CALLING
     *                 ROUTINE WILL BE RESTORED BY THIS INSTRUCTION)
     *
     * But cpu_g_ea() can MODIFY the PSW on the way: a fullword indirect
     * address pointer with C=1 replaces DSR from its DSV and BSR from its
     * BSV (PoO Fig. 2-17, "MODIFY PSW ACTION"), which is exactly how a
     * `BAL@# R7,...ZCON` calls into another sector.  Reading psw1 after
     * that therefore saved the CALLEE's sectors, and BCRE then "restored"
     * the callee's DSR into the caller.
     *
     * Measured: FCMSSYNC calls FCMTRACE through the PSA trace ZCON at
     * 0x0000c = 98a0 0f33 (DSV=3, CD=1, byte-identical to the DASS
     * reference, so the ZCON is right).  DSR went 1 -> 3 across the call
     * and stayed 3.  FPMCLOSE then read TPCTFLGS through `USING TFPCT,R0`
     * with R0=827c: bit 15 set, so DSR expands it, and DSR=3 sent the read
     * to 0x182ab instead of 0x82ab.  The flags came back non-zero, the
     * `IF (TB,TPCTFLGS,X'00C0',Z),OR,...` took its ELSE, the PCT was never
     * freed, and it was re-dispatched on FPMFCLOS's re-issue PSW -- which
     * executes a constant, falls into FPMFRPCT, and spins forever in its
     * unguarded run-queue walk. */
    uint32_t link = register_get32(&t->psw.psw1);
    uint32_t branch = cpu_g_ea(t, v);
    register_set32(R(t, v, 'x'), link);
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

/* Shared by the conditional-branch family for YAGPC_BCTRACE (see exec_BC). */
static void cc_branch_fallthru_trace(CPU *t, uint32_t m1, uint32_t cc,
                                     const char *who) {
    static int inited = 0;
    static long lo = -1, hi = -1;
    if (!inited) {
        const char *w = getenv("YAGPC_BCTRACE");
        if (w != NULL) {
            char *end = NULL;
            lo = strtol(w, &end, 16);
            hi = (end != NULL && *end == '-') ? strtol(end + 1, NULL, 16) : lo;
        }
        inited = 1;
    }
    long nia = (long)psw_get_nia(&t->psw);
    if (lo >= 0 && nia >= lo && nia <= hi)
        fprintf(stderr, "BC-FALLTHRU %s nia=%05x m1=%u cc=%u t=%.1f\n",
                who, (unsigned)nia, (unsigned)m1, (unsigned)cc,
                t->elapsedTimeUs);
}

static void exec_BC(CPU *t, DInstr *v) {
    uint32_t m1 = df_get(v, 'x');
    uint32_t v2 = cpu_g_ea(t, v);
    uint32_t cc = psw_get_cc(&t->psw);
    bool take = (m1 & 4 && cc == 0) || (m1 & 2 && cc == 3) || (m1 & 1 && cc == 1);
    /* YAGPC_BCTRACE=lo[-hi] reports every BC in that window that does NOT
     * branch, with the mask and CC it decided on.  A poll loop exiting once
     * in eight million iterations is otherwise impossible to catch. */
    if (!take) {
        static int inited = 0;
        static long lo = -1, hi = -1;
        if (!inited) {
            const char *w = getenv("YAGPC_BCTRACE");
            if (w != NULL) {
                char *end = NULL;
                lo = strtol(w, &end, 16);
                hi = (end != NULL && *end == '-') ? strtol(end + 1, NULL, 16) : lo;
            }
            inited = 1;
        }
        long nia = (long)psw_get_nia(&t->psw);
        if (lo >= 0 && nia >= lo && nia <= hi)
            fprintf(stderr, "BC-FALLTHRU nia=%05x m1=%u cc=%u t=%.1f\n",
                    (unsigned)nia, (unsigned)m1, (unsigned)cc,
                    t->elapsedTimeUs);
    }
    if (take) psw_set_nia(&t->psw, v2);
}

static void exec_BCB(CPU *t, DInstr *v) {
    uint32_t m1 = df_get(v, 'x');
    uint32_t disp = df_get(v, 'd');
    uint32_t cc = psw_get_cc(&t->psw);
    if ((m1 & 4 && cc == 0) || (m1 & 2 && cc == 3) || (m1 & 1 && cc == 1)) {
        psw_set_nia(&t->psw, psw_get_nia(&t->psw) - disp);
    } else {
        cc_branch_fallthru_trace(t, m1, cc, "BCB");
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
    } else {
        cc_branch_fallthru_trace(t, m1, cc, "BCF");
    }
}

static void exec_BCTR(CPU *t, DInstr *v) {
    /* The branch address is taken FIRST, before R1 is decremented -- POO:
     * "First, the branch address is computed. ... Then, the contents of
     * bits 0 through 15 of general register R1 are reduced by one."  The
     * order is only observable when R1 and R2 are the SAME register, and
     * that is exactly what every failing fixture was: d4e4, d3e3, d5e5,
     * d1e1 all have x == y.  Reading R2 after the decrement branched to
     * an address one short. */
    uint32_t branch = cpu_g_expand(t, register_get32(R(t, v, 'y')) >> 16, OPTYPE_BRCH);
    uint32_t r1val = register_get32(R(t, v, 'x'));
    uint32_t count = ((r1val >> 16) - 1) & 0xffff;
    register_set32(R(t, v, 'x'), (count << 16) | (r1val & 0xffff));
    if (count != 0) psw_set_nia(&t->psw, branch);
}

static void exec_BCT(CPU *t, DInstr *v) {
    /* Address FIRST, then the decrement -- POO: "First, the branch
     * address is computed. ... Then, the contents of bits 0 through 15 of
     * general register R1 are reduced by one."  Observable whenever R1 is
     * also the base register, which 38 of the 300 BCT fixtures are.
     *
     * DELIBERATELY NOT MATCHING THE REFERENCE, which decrements first and
     * whose fixtures therefore assert the wrong order -- the same call as
     * @LAR, where the POO's word wins over the oracle's. */
    uint32_t branch = cpu_g_ea(t, v);
    uint32_t r1val = register_get32(R(t, v, 'x'));
    uint32_t count = ((r1val >> 16) - 1) & 0xffff;
    register_set32(R(t, v, 'x'), (count << 16) | (r1val & 0xffff));
    if (count != 0) psw_set_nia(&t->psw, branch);
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
    /* The partner is (R1 + 1) MOD 8 -- POO 6.6: "the pair of general
     * registers (R1 and (R1+1)mod8)".  Plain R1+1 addressed a ninth
     * register the machine does not have whenever R1 was 7, so the
     * partner's half of every such shift went into limbo and register 0,
     * its real partner, was left untouched. */
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1);
    uint32_t x = df_get(v, 'x');
    uint32_t hi = register_get32(R(t, v, 'x'));
    uint32_t lo = register_get32(cpu_r(t, (int)((x + 1) % 8)));
    if (shiftCnt == 0) return;
    if (shiftCnt >= 64) {
        psw_set_carry(&t->psw, 0);
        register_set32(R(t, v, 'x'), 0);
        register_set32(cpu_r(t, (int)((x + 1) % 8)), 0);
    } else if (shiftCnt >= 32) {
        uint32_t s = shiftCnt - 32;
        if (s == 0) {
            psw_set_carry(&t->psw, (hi & 1) ? 1 : 0);
            register_set32(R(t, v, 'x'), lo);
        } else {
            psw_set_carry(&t->psw, (lo & (1u << (32 - s))) ? 1 : 0);
            register_set32(R(t, v, 'x'), lo << s);
        }
        register_set32(cpu_r(t, (int)((x + 1) % 8)), 0);
    } else {
        psw_set_carry(&t->psw, (hi & (1u << (32 - shiftCnt))) ? 1 : 0);
        uint32_t newHi = (hi << shiftCnt) | (lo >> (32 - shiftCnt));
        uint32_t newLo = lo << shiftCnt;
        register_set32(R(t, v, 'x'), newHi);
        register_set32(cpu_r(t, (int)((x + 1) % 8)), newLo);
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
    /* The partner is (R1 + 1) MOD 8 -- POO 6.6: "the pair of general
     * registers (R1 and (R1+1)mod8)".  Plain R1+1 addressed a ninth
     * register the machine does not have whenever R1 was 7, so the
     * partner's half of every such shift went into limbo and register 0,
     * its real partner, was left untouched. */
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1);
    if (shiftCnt == 0) return;
    uint32_t x = df_get(v, 'x');
    int32_t hi = (int32_t)register_get32(R(t, v, 'x'));
    uint32_t lo = register_get32(cpu_r(t, (int)((x + 1) % 8)));
    bool sign = (hi < 0);
    if (shiftCnt >= 64) {
        uint32_t fill = sign ? 0xffffffffu : 0u;
        register_set32(R(t, v, 'x'), fill);
        register_set32(cpu_r(t, (int)((x + 1) % 8)), fill);
    } else if (shiftCnt >= 32) {
        uint32_t s = shiftCnt - 32;
        register_set32(cpu_r(t, (int)((x + 1) % 8)), (s == 0) ? (uint32_t)hi : (uint32_t)(hi >> s));
        register_set32(R(t, v, 'x'), sign ? 0xffffffffu : 0u);
    } else {
        uint32_t newLo = (lo >> shiftCnt) | ((uint32_t)hi << (32 - shiftCnt));
        uint32_t newHi = (uint32_t)(hi >> shiftCnt);
        register_set32(R(t, v, 'x'), newHi);
        register_set32(cpu_r(t, (int)((x + 1) % 8)), newLo);
    }
}

static void exec_SRDL(CPU *t, DInstr *v) {
    /* The partner is (R1 + 1) MOD 8 -- POO 6.6: "the pair of general
     * registers (R1 and (R1+1)mod8)".  Plain R1+1 addressed a ninth
     * register the machine does not have whenever R1 was 7, so the
     * partner's half of every such shift went into limbo and register 0,
     * its real partner, was left untouched. */
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1);
    if (shiftCnt == 0) return;
    uint32_t x = df_get(v, 'x');
    uint32_t hi = register_get32(R(t, v, 'x'));
    uint32_t lo = register_get32(cpu_r(t, (int)((x + 1) % 8)));
    if (shiftCnt >= 64) {
        register_set32(R(t, v, 'x'), 0);
        register_set32(cpu_r(t, (int)((x + 1) % 8)), 0);
    } else if (shiftCnt >= 32) {
        uint32_t s = shiftCnt - 32;
        register_set32(cpu_r(t, (int)((x + 1) % 8)), (s == 0) ? hi : (hi >> s));
        register_set32(R(t, v, 'x'), 0);
    } else {
        uint32_t newLo = (lo >> shiftCnt) | (hi << (32 - shiftCnt));
        uint32_t newHi = hi >> shiftCnt;
        register_set32(R(t, v, 'x'), newHi);
        register_set32(cpu_r(t, (int)((x + 1) % 8)), newLo);
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
    /* The partner is (R1 + 1) MOD 8 -- POO 6.6: "the pair of general
     * registers (R1 and (R1+1)mod8)".  Plain R1+1 addressed a ninth
     * register the machine does not have whenever R1 was 7, so the
     * partner's half of every such shift went into limbo and register 0,
     * its real partner, was left untouched. */
    uint32_t shiftCnt = cpu_g_shift_cnt(t, v->hw1) % 64;
    if (shiftCnt == 0) return;
    uint32_t x = df_get(v, 'x');
    uint32_t hi = register_get32(R(t, v, 'x'));
    uint32_t lo = register_get32(cpu_r(t, (int)((x + 1) % 8)));
    if (shiftCnt >= 32) {
        uint32_t s = shiftCnt - 32;
        if (s == 0) {
            register_set32(R(t, v, 'x'), lo);
            register_set32(cpu_r(t, (int)((x + 1) % 8)), hi);
        } else {
            uint32_t newHi = (lo >> s) | (hi << (32 - s));
            uint32_t newLo = (hi >> s) | (lo << (32 - s));
            register_set32(R(t, v, 'x'), newHi);
            register_set32(cpu_r(t, (int)((x + 1) % 8)), newLo);
        }
    } else {
        uint32_t newHi = (hi >> shiftCnt) | (lo << (32 - shiftCnt));
        uint32_t newLo = (lo >> shiftCnt) | (hi << (32 - shiftCnt));
        register_set32(R(t, v, 'x'), newHi);
        register_set32(cpu_r(t, (int)((x + 1) % 8)), newLo);
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
    FloatIBMResult r = fibm_mulQeS(&v1, &v2);
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
    FloatIBMResult r = fibm_mulQeS(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    register_set32(cpu_f(t, (int)x), fibm_to64x(&r.result));
    register_set32(cpu_f(t, (int)(x + 1)), fibm_to64y(&r.result));
}

static void exec_MER(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(register_get32(F(t, v, 'y')));
    FloatIBMResult r = fibm_mulE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    /* Multiply Short develops a double-length product: the high half
     * goes to R1 and the LOW half to R1+1, "unless R1 is odd" -- an odd
     * R1 has no pair to hold it and the extension is discarded.  We
     * wrote only the high half, so GPCIPL's own floating-point self-test
     * at +0bcc saw a stale FP7. */
    register_set32(cpu_f(t, (int)x), fibm_to64x(&r.result));
    if (!(x % 2)) register_set32(cpu_f(t, (int)(x + 1)), fibm_to64y(&r.result));
}

static void exec_ME(CPU *t, DInstr *v) {
    uint32_t x = df_get(v, 'x');
    FloatIBM v1 = fibm_from32(register_get32(F(t, v, 'x')));
    FloatIBM v2 = fibm_from32(cpu_g_eaf(t, v, 0));
    FloatIBMResult r = fibm_mulE(&v1, &v2);
    if (!cpu_fp_dispatch_exc(t, r.exc)) return;
    /* Multiply Short develops a double-length product: the high half
     * goes to R1 and the LOW half to R1+1, "unless R1 is odd" -- an odd
     * R1 has no pair to hold it and the extension is discarded.  We
     * wrote only the high half, so GPCIPL's own floating-point self-test
     * at +0bcc saw a stale FP7. */
    register_set32(cpu_f(t, (int)x), fibm_to64x(&r.result));
    if (!(x % 2)) register_set32(cpu_f(t, (int)(x + 1)), fibm_to64y(&r.result));
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

/* Effective addresses the POO's sect.15 lists as self tests: microcode
 * runs them and reports through the interrupt page's scan register,
 * which a fault-free machine leaves zero.  All of them pass here. */
static const uint16_t DIAG_SELFTEST[] = {
    0x0000, 0x0100, 0x0200, 0x0300, 0x0400, 0x0401,   /* CPU hardcore 0-4, 8 */
    0x0500, 0x0600, 0x0700,                           /* constant PROM, memory, RTCC */
    0x2000, 0x2001,                                   /* local store CPU / constant sector */
    0x3000, 0x4000, 0x4100,                           /* (reserved-adjacent self-tests) */
    0x8000, 0x8100, 0x8200, 0x8400, 0x8500,           /* interrupt page command PLA 0-4 */
    0x9000,                                           /* interrupt page arithmetic capture */
    0xA000,                                           /* EU ROS parity check circuit */
    0xC200, 0xC201, 0xC202,                           /* monolithic memory read/write */
    0xD000, 0xD001, 0xD010, 0xD011,                   /* EDAC soft / hard error */
    0xF100,                                           /* ENDOP timer */
};
#define DIAG_PASS 0
#define DIAG_FAIL 3

/* The interrupt page's Internal I/O commands.  DIAG 7000/7001 put an IIO
 * command and its data on the H-BUS; sect.15 lists "the hexadecimal value
 * for the H-BUS IIO command required to select each of the micro
 * sequences".  Only the ones with an externally visible effect are
 * modelled: the page's own self tests report through the scan register,
 * which stays zero on a machine with no faults. */
static void diag_iio(CPU *t, uint32_t cmd, uint32_t data) {
    switch (cmd) {
        case 0x9014:
            /* START INTERRUPT PRIORITY MICROCODE TEST.  "Sets all of the
             * valid interrupts in the External Pending Interrupt
             * Register.  Also, the two interval timers are set pending.
             * Interrupt processing will then proceed in the normal
             * manner.  Any pending interrupts will be lost when this
             * command is executed."  The six externals are External 0-4
             * and AGE; the timers go into the I/O interrupt register, and
             * "Timer A and B interrupts only become macro interrupts if
             * location B0 and B1, respectively, equal zero".
             *
             * The pending register is cleared first, and the two timers
             * are conditional; doing neither (and raising all seven
             * unconditionally) is what this used to do. */
            memset(&t->intPending, 0, sizeof(t->intPending));
            t->intPending.iopGrp1 = true;  /* External 0 */
            t->intPending.iopGrp2 = true;  /* External 1 */
            t->intPending.iopProg = true;  /* External 2 */
            t->intPending.ext3 = true;
            t->intPending.ext4 = true;
            t->intPending.age = true;      /* the sixth external */
            if (membus_get16(t->ram, 0x00b0) == 0) t->intPending.clk1 = true;
            if (membus_get16(t->ram, 0x00b1) == 0) t->intPending.clk2 = true;
            break;
        case 0x900c:
            /* RESET PENDING INTERRUPTS.  Software uses this after an
             * operation whose side effects it does not want delivered: an
             * IOP master reset sets C/M idle, which is an External 0 the
             * code that ordered the reset is not waiting for. */
            memset(&t->intPending, 0, sizeof(t->intPending));
            break;
        case 0x9013:
            /* SET/RESET INTERRUPT PAGE DIAGNOSE MODE.  "When in diagnose
             * mode, the interrupt page will not reset the computer when
             * it detects a crash interrupt condition.  Also, the ROS
             * parity error, and the Endop Timeout machine check
             * interrupts will not be generated."  Nonzero data sets the
             * mode.  This machine never resets itself, so the flag is
             * readback state only. */
            t->diagInterruptPageDiagnoseMode = (data != 0);
            break;
        default:
            break;   /* 0x9011 and the page's own micro tests: no effect */
    }
}

static void exec_DIAG(CPU *t, DInstr *v) {
    /* DIAG is a whole family of manufacturer self-test microcode commands
     * (H-bus wrap, command-PLA test, arithmetic-interrupt test, ROS
     * parity, machine-check force, store-protect readback, ...) that real
     * flight/HAL-S code never issues, so none of it was needed before
     * BILDNEW5/GPCIPL's own hardware self test started exercising it.
     *
     * The command is the EFFECTIVE ADDRESS ITSELF, not the halfword at
     * it: "all effective addresses not described here are reserved".
     * Reading storage at the EA, as this used to, decoded whatever
     * happened to be there. */
    if (!cpu_i_super(t)) return;
    uint32_t cmd = cpu_g_ea_16(t, v) & 0xffffu;
    uint32_t x = df_get(v, 'x');
    Register *r1 = cpu_r(t, (int)x);
    Register *r1n = cpu_r(t, (int)((x + 1) & 7));

    for (size_t i = 0; i < sizeof DIAG_SELFTEST / sizeof DIAG_SELFTEST[0]; i++) {
        if (cmd == DIAG_SELFTEST[i]) { psw_set_cc(&t->psw, DIAG_PASS); return; }
    }

    switch (cmd) {
        case 0x1000: {
            /* READ PROGRAM AND SYSTEM MASK: PSW bits 16-47 into R1 bits
             * 0-31.  Bits 16-31 are PSW1's low halfword, 32-47 PSW2's
             * high halfword.  CC is explicitly not altered. */
            uint32_t lo = register_get32(&t->psw.psw1) & 0xffffu;
            uint32_t hi = (register_get32(&t->psw.psw2) >> 16) & 0xffffu;
            register_set32(r1, (lo << 16) | hi);
            break;
        }
        case 0x7000:
        case 0x7001:
            /* H-BUS READ / WRITE: "allows any Internal I/O (IIO) command
             * to be written [read].  Bits 0-15 of register R1 shall
             * contain the Internal Bus command.  Bits 16-31 of register
             * R1 shall contain the data to be written." */
            diag_iio(t, (register_get32(r1) >> 16) & 0xffffu,
                        register_get32(r1) & 0xffffu);
            psw_set_cc(&t->psw, DIAG_PASS);
            break;

        case 0x7100:
        case 0x7101:
            /* DETECT / DISREGARD STORES INTO IU FILE: sets or resets B
             * STAT bit 6.  Set is what the machine does anyway -- a
             * conflict purges the file, and a model that always refetches
             * is indistinguishable from one that purges.  Reset is not:
             * the pipeline is not purged and the stale halfword executes.
             * See cpu.c's cpu_shadow_iu_store(). */
            t->diagIuStoreDetect = (cmd == 0x7100);
            /* Turning detection back on purges: "when conflicts are
             * detected, the file is purged", and every conflict is
             * detected from here on. */
            if (t->diagIuStoreDetect) cpu_iu_shadow_flush(t);
            psw_set_cc(&t->psw, DIAG_PASS);
            break;

        case 0x9100: {
            /* INTERRUPT PAGE H-BUS WRAP ASSIST: the pattern in R1 bits
             * 0-15 goes out on the H-BUS; what comes back on the H-BUS
             * lands in R1 bits 16-31 and what comes back on the INBUS in
             * R1+1 bits 0-15.  A good page wraps both. */
            uint32_t pattern = (register_get32(r1) >> 16) & 0xffffu;
            register_set32(r1, (pattern << 16) | pattern);
            register_set32(r1n, (pattern << 16) | (register_get32(r1n) & 0xffffu));
            break;
        }

        case 0xC000: {
            /* MONOLITHIC CHECKSUM ASSIST: sum halfwords from the 19-bit
             * address in R1 through the one in R1+1 inclusive,
             * accumulating into R1+2 bits 0-15.  R1 is left equal to the
             * end address; R1+1 is not altered. */
            Register *r1n2 = cpu_r(t, (int)((x + 2) & 7));
            uint32_t start = register_get32(r1) & 0x7ffffu;
            uint32_t end = register_get32(r1n) & 0x7ffffu;
            uint32_t sum = (register_get32(r1n2) >> 16) & 0xffffu;
            for (uint32_t a = start; a <= end; a++)
                sum = (sum + membus_get16(t->ram, a)) & 0xffffu;
            register_set32(r1, end);
            register_set32(r1n2, (sum << 16) | (register_get32(r1n2) & 0xffffu));
            break;
        }

        case 0xD100: {
            /* READ MONOLITHIC STORE PROTECT BITS.  R1 holds the 19-bit
             * physical address, right-justified, on an even fullword
             * boundary.  R1+1 receives the two halfwords' bits: 13-15 the
             * redundant triple for the even halfword, 22-24 the same for
             * the odd one, everything else undefined.  The triple is
             * redundant because the hardware stores three copies and
             * votes; a healthy machine reads all three alike.  The bits
             * read back ACTIVE LOW: a protected halfword reads 000, an
             * unprotected one 111. */
            uint32_t addr = register_get32(r1) & 0x7fffeu;
            uint32_t ev = membus_get_store_protect(t->ram, addr) ? 0u : 7u;
            uint32_t od = membus_get_store_protect(t->ram, addr + 1) ? 0u : 7u;
            register_set32(r1n, (ev << 16) | (od << 7));
            break;
        }

        case 0xE300:
        case 0xE301:
            /* EA SCAN 5 ASSIST: read the interrupt page's 32-bit scan
             * register into R1, then clear it.  It doubles as the page's
             * Diagnose Error register, which is why the self-test reads
             * it once to clear before a page test and again after to see
             * what was caught.  No modelled fault ever sets a bit. */
            register_set32(r1, t->diagScanReg);
            t->diagScanReg = 0;
            break;

        case 0xF300:
            /* FORCE ROS PARITY ERROR ASSIST: "The ROS parity error will
             * only be forced if bits 0-15 of register R1 contain
             * X'0001'."  It reports as a microstore parity machine check
             * (Figure 2-20 row 04, code 0005).  PSW bit 45 masks it, and
             * a masked one "will not remain pending" -- already how a
             * masked machine check is treated.  On real hardware an
             * unmasked, non-diagnose-mode ROS parity error also RESETS
             * the computer; that part is deliberately not modelled, since
             * the point of the assist is to exercise the interrupt path. */
            if (((register_get32(r1) >> 16) & 0xffffu) == 0x0001u) {
                t->mcCode = 0x0005;   /* CPU Microstore Parity */
                t->intPending.machineCheck = true;
            }
            psw_set_cc(&t->psw, DIAG_PASS);
            break;

        default:
            /* "All effective addresses not described here are reserved
             * and shall not be used.  The result of using a reserved
             * effective address is indeterminate." */
            psw_set_cc(&t->psw, DIAG_FAIL);
            break;
    }
}

/* YAGPC_ISPB_ALIGN=1 makes the ISPB fullword forms honour the POO rule
 * "When M1 is 001 or 011, the low-order bit of the EA should be 0 and
 * will be ignored", i.e. act on the containing even-aligned pair.  The
 * D100 READSP diagnose corroborates the hardware organisation: its
 * address "must be an even fullword boundary", returning bits for the
 * even HW at R1 and the odd HW at R1+1.
 *
 * IT IS NOT THE DEFAULT, BECAUSE IT BREAKS THE BOOT: the load stops
 * after phase 10 with 55 blocks instead of 281.  The conflict is not
 * resolved, and the odd-EA cases are systematic rather than incidental.
 * Measured over a full IPL there are exactly 60 of them, from just three
 * instructions in GPCIPL: nia=007ac (M1=1) and nia=007c2 (M1=3) sweep
 * ea=x7ffd once per 32K sector (07ffd, 17ffd, 27ffd, 37ffd, 47ffd), and
 * nia=0074d does ea=40001/48001.  A sector's last fullword is x7ffe/x7fff,
 * which NEITHER reading reaches from x7ffd -- ours takes 7ffd/7ffe, the
 * aligned one 7ffc/7ffd.  That points at our EA being off by one in this
 * path, with fwAddr = ea papering over it.  Settle the EA before
 * settling this. */
static bool ispb_align(void) {
    static int inited = 0, on = 0;
    if (!inited) { on = getenv("YAGPC_ISPB_ALIGN") != NULL; inited = 1; }
    return on != 0;
}

static void exec_ISPB(CPU *t, DInstr *v) {
    if (!cpu_i_super(t)) {
        /* Silently discarded in problem state.  Worth seeing: an ISPB that
         * vanishes leaves storage protected that the program believes it
         * has just unprotected, and the fault then lands somewhere else
         * entirely. */
        if (getenv("YAGPC_ISPBTRACE"))
            fprintf(stderr, "ISPB SKIPPED (problem state) nia=%05x t=%.1f\n",
                    (unsigned)psw_get_nia(&t->psw), t->elapsedTimeUs);
        return;
    }
    uint32_t ea = cpu_g_ea(t, v);
    uint32_t m1 = (v->hw1 >> 8) & 0x7; /* bits 5-7 */
    /* YAGPC_ISPBTRACE=lo[-hi] reports every ISPB whose EA falls in that
     * window, with its M1 and the NIA that issued it -- which is how a
     * region that ends up protected when the flight software meant it
     * loadable gets traced back to the instruction responsible. */
    {
        static int inited = 0;
        static long lo = -1, hi = -1;
        if (!inited) {
            const char *w = getenv("YAGPC_ISPBTRACE");
            if (w != NULL) {
                char *end = NULL;
                lo = strtol(w, &end, 16);
                hi = (end != NULL && *end == '-') ? strtol(end + 1, NULL, 16) : lo;
            }
            inited = 1;
        }
        if (lo >= 0 && (long)ea >= lo && (long)ea <= hi) {
            uint32_t r1 = register_get32(cpu_r(t, 1));
            uint32_t zc = (r1 >> 16) & 0xffffu;   /* the Z-CON's address */
            fprintf(stderr, "ISPB ea=%05x m1=%u hw=%04x/%04x "
                            "R1=%08x R2=%08x zcon=%04x/%04x nia=%05x t=%.1f\n",
                    (unsigned)ea, (unsigned)m1,
                    (unsigned)v->hw1, (unsigned)v->hw2, (unsigned)r1,
                    (unsigned)register_get32(cpu_r(t, 2)),
                    (unsigned)membus_get16(t->ram, zc),
                    (unsigned)membus_get16(t->ram, zc + 1),
                    (unsigned)psw_get_nia(&t->psw), t->elapsedTimeUs);
        }
    }
    switch (m1) {
        case 0:   /* reset protect bit for the halfword at EA */
            t->storeProtectOverride = false;
            membus_set_store_protect(t->ram, ea, false);
            break;
        case 1: { /* reset both halfwords of the fullword */
            /* POO, ISPB: "When M1 is 001 or 011, the low-order bit of
             * the EA should be 0 and WILL BE IGNORED."  So the fullword
             * forms act on the containing EVEN-ALIGNED pair, never on
             * (EA, EA+1) at an odd EA.  The D100 READSP diagnose
             * corroborates the hardware organisation: its address "must
             * be an even fullword boundary" and it returns the bits for
             * "address in R1 (even HW)" and "R1 plus one (odd HW)".
             *
             * TWO BUGS WERE PREVIOUSLY CONFLATED HERE.  The old code
             * masked with 0xfffe, a 16-BIT mask applied to an EA already
             * expanded to 19 bits, which threw the sector bits away and
             * hit the same offset in sector 0 (3032a -> 0032a) -- that
             * diagnosis was correct.  But the fix chosen was to abandon
             * alignment altogether, when the actual repair is to mask
             * only the low bit and leave the sector alone.  Measured over
             * a full IPL, the fullword forms are issued with an odd EA
             * 60 times (35 M1=1, 25 M1=3), and all 60 were mis-targeted. */
            uint32_t fwAddr = ispb_align() ? (ea & ~1u) : ea;
            t->storeProtectOverride = false;
            membus_set_store_protect(t->ram, fwAddr, false);
            membus_set_store_protect(t->ram, fwAddr + 1, false);
            break;
        }
        case 2:   /* set protect bit for the halfword at EA */
            t->storeProtectOverride = false;
            membus_set_store_protect(t->ram, ea, true);
            break;
        case 3: { /* set both halfwords of the fullword */
            /* Even-aligned pair, sector bits preserved -- see M1=001. */
            uint32_t fwAddr = ispb_align() ? (ea & ~1u) : ea;
            t->storeProtectOverride = false;
            membus_set_store_protect(t->ram, fwAddr, true);
            membus_set_store_protect(t->ram, fwAddr + 1, true);
            break;
        }
        default:
            /* Illegal M1 (100-111) leaves the store protect override ON:
             * protected locations can then be written without a violation
             * until the next valid ISPB clears it.  No illegal operation
             * interrupt.  This was dismissed as a no-op on the grounds
             * that nothing read the flag -- true of the reference at the
             * time, but the store path reads it now (cpu_store_hw /
             * cpu_store_fw). */
            t->storeProtectOverride = true;
            break;
    }
}

static void exec_LPS(CPU *t, DInstr *v) {
    if (!cpu_i_super(t)) return;
    uint32_t eaw1 = cpu_g_ea(t, v);
    uint32_t eaw2 = eaw1 + 2;
    cpu_load_psw(t, membus_get32(t->ram, eaw1), membus_get32(t->ram, eaw2));
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
    /* AP-101S instruction set, 9.4 MOVE HALFWORD OPERANDS: "Bits 1 through
     * 15 of the general register specified by R1 contain the offset of the
     * destination address within a specified sector.  When bit 0 in R1 is
     * a one, the destination address is determined by concatenating the
     * DSR value in the PSW with the offset.  WHEN BIT 0 IN R1 IS A ZERO,
     * THE DESTINATION ADDRESS IS DETERMINED BY CONCATENATING THE VALUE IN
     * THE CORRESPONDING DSE REGISTER WITH THE OFFSET."
     *
     * The DSE arm was missing: a zero bit 0 used the bare 16-bit offset,
     * i.e. an implied sector 0.  That is what sent FCMINSSL's FCMMOVE to
     * 0x00000 instead of sector 8 -- it does `LXAR R3,R3  SET DSE TO
     * REQUIRED SECTOR` precisely to put the target sector in R3's DSE, and
     * then MVH ignored it.  (The R2/source arm below already followed the
     * same section's rule for the source and is unchanged.)
     *
     * This fix was tried once before and reverted as unsupported: DSE(R1)
     * measured zero at the failing move.  It measured zero because the
     * parameters FCMMOVE had loaded were themselves corrupt, so LXAR was
     * handed a zero constant.  The premise is sound; the earlier evidence
     * was downstream of a different defect. */
    if (destAddr & 0x8000) {
        destAddr = (psw_get_dsr(&t->psw) << 15) | (destAddr & 0x7fff);
    } else {
        uint32_t dse = registerfile_get_dse(
            &t->regFiles[psw_get_reg_set(&t->psw)], (int)df_get(v, 'x'));
        destAddr = (dse << 15) | (destAddr & 0x7fff);
    }
    /* YAGPC_MVHTRACE reports each MOVE HALFWORD with its resolved source,
     * destination and count, and says whether it ran to completion.  A move
     * that stops early on a store-protect violation leaves R1's count
     * intact by design, so from outside it is indistinguishable from one
     * that never started. */
    uint32_t mvhCount = count, mvhDest = destAddr, mvhSrc = srcAddr;
    bool mvhDone = true;
    while (count > 0) {
        count--;
        uint32_t hw = membus_get16(t->ram, srcAddr + count);
        /* A violation terminates the instruction (Forced ENDOP), so R1
         * is not updated either. */
        if (!cpu_store_hw(t, destAddr + count, hw)) { mvhDone = false; break; }
    }
    if (getenv("YAGPC_MVHTRACE"))
        fprintf(stderr, "MVH dest=%05x src=%05x count=%u %s left=%u "
                        "nia=%05x t=%.1f\n",
                (unsigned)mvhDest, (unsigned)mvhSrc, (unsigned)mvhCount,
                mvhDone ? "ok" : "PROTFAULT", (unsigned)count,
                (unsigned)psw_get_nia(&t->psw), t->elapsedTimeUs);
    if (!mvhDone) return;
    /* Only the COUNT is consumed.  The POO's programming notes for MOVE
     * HALFWORD say "the count in R1 is modified [to] the number of
     * halfwords remaining to be moved", and that the instruction "will
     * not modify the DSR" -- the ADDRESS half is left alone.  It has to
     * be: MVH is designed to be interruptible, it copies from the end
     * backwards (the loop above), and a restart works only because the
     * address still points at the start while the count says how much is
     * left.
     *
     * This used to write back `destAddr << 16`, the EXPANDED address,
     * which is wrong twice over.  destAddr is 19 bits once expanded, so
     * the shift overflows and throws the sector away: FCMBOOT's move
     * into sector 6 left R2 = 0x01800000 instead of 0x81800000, losing
     * the X'8000' bit that the source calls "STARTING ADDRESS WITH HIGH
     * BIT ON TO USE SECT 6 BSR AND DSR".  FCMBOOT then re-protects its
     * relocated copy with `ISPB 3,0(R5,R2)`, so the protection landed on
     * sector 0 instead of sector 6 -- and the moment it jumped into
     * sector 6 the Instruction Monitor fired on the very first
     * instruction, executing out of storage that was never protected.
     * Its own vectors being deliberate wait-state PSWs, the machine then
     * simply stopped. */
    register_set32(R(t, v, 'x'), r1val & 0xffff0000u);
}

static void exec_SPM(CPU *t, DInstr *v) {
    uint32_t bits = (register_get32(R(t, v, 'y')) >> 8) & 0xff;
    psw_set_cc(&t->psw, (bits >> 6) & 3);
    psw_set_carry(&t->psw, (bits >> 5) & 1);
    psw_set_overflow(&t->psw, (bits >> 4) & 1);
    psw_set_fixed_pt_overflow(&t->psw, (bits >> 3) & 1);
    psw_set_exponent_underflow(&t->psw, (bits >> 1) & 1);
    psw_set_significance_mask(&t->psw, bits & 1);
    /* Setting the indicator and its mask together is the Note 1 case:
     * the interrupt occurs (POO 2.5.2.3). */
    cpu_test_fixed_overflow(t);
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
    /* Same ordering rule as exec_BAL, and for the same reason: psw1 is the
     * RETURN PSW that SRET pops back, so it must be the CALLER's -- address
     * and BSR/DSR both.  cpu_g_ea() can replace DSR/BSR from a fullword
     * indirect pointer with C=1 (PoO Fig. 2-17), so reading psw1 after it
     * stacked the CALLEE's sectors; SRET then returned with the wrong BSR
     * and expanded the 16-bit return address into the wrong sector.
     *
     * Measured: DPLLIGHT's SRET at 0x101f4 (97e8) returned to 0x16b8f,
     * which is FILL in our image and in the DASS reference alike -- so the
     * real machine would fault there too, i.e. the target was wrong, not
     * missing.  The instruction words at 101f0..101f4 are byte-identical to
     * the reference, so this was execution, not the link. */
    uint32_t psw1 = register_get32(&t->psw.psw1);
    uint32_t branchAddr = cpu_g_ea(t, v);
    uint32_t r1val = register_get32(R(t, v, 'x'));
    uint32_t ptr = (r1val >> 16) & 0xffff;
    uint32_t inc = r1val & 0xffff;
    uint32_t sa = (ptr + inc) & 0xffff;
    if (!cpu_store_fw(t, sa, psw1)) return;
    for (int i = 0; i <= 7; i++) {
        if (!cpu_store_fw(t, sa + 2 + (uint32_t)i * 2, register_get32(cpu_r(t, i)))) return;
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
    cpu_load_psw(t, membus_get32(t->ram, 0x5c), membus_get32(t->ram, 0x5e));
}

static void exec_TS(CPU *t, DInstr *v) {
    uint32_t ea = cpu_g_ea(t, v);
    uint32_t value = membus_get16(t->ram, ea);
    if (value == 0) psw_set_cc(&t->psw, 0);
    else if (value == 0xffff) psw_set_cc(&t->psw, 1);
    else psw_set_cc(&t->psw, 3);
    cpu_store_hw(t, ea, 0xffff);
}

static void exec_TSB(CPU *t, DInstr *v) {
    uint32_t mask = df_get(v, 'I');
    uint32_t ea = cpu_g_ea(t, v);
    uint32_t value = membus_get16(t->ram, ea);
    uint32_t selected = value & mask;
    if (mask == 0 || selected == 0) psw_set_cc(&t->psw, 0);
    else if (selected == mask) psw_set_cc(&t->psw, 1);
    else psw_set_cc(&t->psw, 3);
    cpu_store_hw(t, ea, value | mask);
}

static void exec_LDM(CPU *t, DInstr *v) {
    uint32_t fw = cpu_g_eaf(t, v, 0);
    uint32_t regSet = psw_get_reg_set(&t->psw);
    /* Sec. 9.13's own operand layout: each DSE is the LOW nibble of one
     * byte -- bits 4-7, 12-15, 20-23, 28-31, with the high nibble of
     * each byte reserved zero.  Reading four adjacent nibbles out of the
     * high halfword instead, as this did, put R2's and R3's DSE in R0's
     * and R1's bytes and dropped the low halfword entirely. */
    registerfile_set_dse(&t->regFiles[regSet], 0, (fw >> 24) & 0xf);
    registerfile_set_dse(&t->regFiles[regSet], 1, (fw >> 16) & 0xf);
    registerfile_set_dse(&t->regFiles[regSet], 2, (fw >>  8) & 0xf);
    registerfile_set_dse(&t->regFiles[regSet], 3, (fw      ) & 0xf);
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

/* Sec. 9.14, STORE EXTENDED ADDRESS: "Bit 0 of the second operand is
 * set to one, bits 1 through 15 are replaced by bits 1 through 15 of R1,
 * bits 28 through 31 are replaced by the contents of R1 DSE, bits 16
 * through 19 are set to zero, and bits 20 through 27 are unchanged and
 * ignored." */
static uint32_t stxa_word(uint32_t src, uint32_t dst, uint32_t dse) {
    return 0x80000000u          /* bit 0, always set */
         | (src & 0x7fff0000u)  /* bits 1-15, the address */
                                /* bits 16-19 zeroed by omission */
         | (dst & 0x00000ff0u)  /* bits 20-27, the destination's own */
         | (dse & 0xfu);        /* bits 28-31, R1's DSE */
}

static void exec_STXAR(CPU *t, DInstr *v) {
    uint32_t dse = registerfile_get_dse(&t->regFiles[psw_get_reg_set(&t->psw)],
                                        (int)df_get(v, 'x'));
    register_set32(R(t, v, 'y'),
                   stxa_word(register_get32(R(t, v, 'x')),
                             register_get32(R(t, v, 'y')), dse));
}

static void exec_STXA(CPU *t, DInstr *v) {
    /* The EA is taken ONCE: an auto-modifying address form must not be
     * evaluated twice, so the read and the write share it rather than
     * going through cpu_g_eaf()/cpu_s_eaf(). */
    uint32_t ea = cpu_g_ea(t, v);
    uint32_t cur = ((uint32_t)membus_get16(t->ram, ea) << 16)
                 | membus_get16(t->ram, ea + 1);
    uint32_t dse = registerfile_get_dse(&t->regFiles[psw_get_reg_set(&t->psw)],
                                        (int)df_get(v, 'x'));
    uint32_t val = stxa_word(register_get32(R(t, v, 'x')), cur, dse);
    cpu_store_fw(t, ea, val);
}

static void exec_STDM(CPU *t, DInstr *v) {
    uint32_t regSet = psw_get_reg_set(&t->psw);
    uint32_t fw = (registerfile_get_dse(&t->regFiles[regSet], 0) << 24) |
                  (registerfile_get_dse(&t->regFiles[regSet], 1) << 16) |
                  (registerfile_get_dse(&t->regFiles[regSet], 2) <<  8) |
                  (registerfile_get_dse(&t->regFiles[regSet], 3)      );
    cpu_s_eaf(t, v, fw, 0);
}

static void exec_ICR(CPU *t, DInstr *v) {
    if (!cpu_i_super(t)) return;
    uint32_t cw = register_get32(R(t, v, 'y'));
    uint32_t cmd = (cw >> 27) & 0x1f;
    /* POO p.10-3 gives each command its own execution time; the table's
     * single ICR row is only a fallback.  Without these the counter a
     * program reads back straight after loading it was two ticks low. */
    switch (cmd) {
        case 0x00: t->timePooOverrideUs = 5.5;  break;  /* read counter 1 */
        case 0x01: t->timePooOverrideUs = 5.75; break;  /* read counter 2 */
        case 0x08: t->timePooOverrideUs = 3.5;  break;  /* load counter 1 */
        case 0x09: t->timePooOverrideUs = 3.75; break;  /* load counter 2 */
        case 0x05: t->timePooOverrideUs = 20.25; break; /* read AGE */
        case 0x0d: t->timePooOverrideUs = 20.0;  break; /* load AGE */
        default: break;
    }
    switch (cmd) {
        case 0x00: { /* Read Counter 1 */
            /* The read comes back TWO counts high -- the value the
             * counter will have had by the time the read completes. */
            uint32_t hi = membus_get16(t->ram, 0x00b0);
            uint32_t lo = t->counter1;
            register_set32(R(t, v, 'x'), ((hi << 16) | (lo & 0xffff)) + 2);
            break;
        }
        case 0x01: { /* Read Counter 2 */
            uint32_t hi = membus_get16(t->ram, 0x00b1);
            uint32_t lo = t->counter2;
            register_set32(R(t, v, 'x'), ((hi << 16) | (lo & 0xffff)) + 2);
            break;
        }
        case 0x08: { /* Write Counter 1 */
            uint32_t r1 = register_get32(R(t, v, 'x'));
            /* The PSA half is written PAST store protect: 00B0/00B1 are
             * on the POO's own list of locations that must not be
             * protected (2.5.2.4), and the write is the timer hardware's,
             * not the program's. */
            membus_set16(t->ram, 0x00b0, (r1 >> 16) & 0xffff, false);
            t->counter1 = r1 & 0xffff;
            t->intPending.clk1 = false;  /* the load resets the latch */
            t->counter1Deferred = false; /* ...and cancels any owed borrow */
            /* Writing a countdown value to a real hardware timer starts
             * it counting -- cpu_exec1's per-instruction decrement (and
             * the Clock 1 interrupt it fires on underflow) was declared
             * and fully wired but nothing anywhere ever set this flag,
             * so no ICR-armed delay (e.g. BILDNEW5/GPCIPL's own
             * CLK2DELY) could ever complete; confirmed no other call
             * site sets it either. */
            t->counter1Enabled = true;
            if (getenv("YAGPC_CLKTRACE"))
                fprintf(stderr, "CLK ARM1 t=%.6f val=%08x (%.6f s)\n",
                        t->elapsedTimeUs / 1e6, (unsigned)r1, (double)r1 / 1e6);
            break;
        }
        case 0x09: { /* Write Counter 2 */
            uint32_t r1 = register_get32(R(t, v, 'x'));
            membus_set16(t->ram, 0x00b1, (r1 >> 16) & 0xffff, false);
            t->counter2 = r1 & 0xffff;
            t->intPending.clk2 = false;  /* see Write Counter 1 */
            t->counter2Deferred = false;
            t->counter2Enabled = true; /* see Write Counter 1's comment */
            if (getenv("YAGPC_CLKTRACE"))
                fprintf(stderr, "CLK ARM2 t=%.6f val=%08x (%.6f s)\n",
                        t->elapsedTimeUs / 1e6, (unsigned)r1, (double)r1 / 1e6);
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
            /* Channel Reset zeroes the IOP's interrupt registers.  This
             * was a no-op on the grounds that the reference had no such
             * method; it has one now. */
            if (t->iop) iop_channel_reset(t->iop);
            break;
        default:
            /* "Command codes which are not defined in this document are
             * illegal and should not be used.  Unlike previous versions
             * of this architecture, ONLY the command 10000 causes a
             * channel reset, not the general case 1XXXX." (sect.10
             * programming notes) -- so 1xxxx other than 10000 is illegal
             * too, where this used to let it pass silently. */
            cpu_signal_illegal_op(t);
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
    { "SSM", "1000100011111abb/X", exec_SSM, 1, 1 },  /* halfword operand */
    { "SCAL", "11010xxx11111abb/X", exec_SCAL, 1, 2 },
    { "SRET", "10010xxx11101yyy", exec_SRET, 2, 1 },
    { "SVC", "1100100111111abb/X", exec_SVC, 1, 1 },
    { "TS", "1011100011111abb/X", exec_TS, 1, 1 },  /* halfword operand */
    { "TSB", "10110111ddddddbb/I", exec_TSB, 1, 1 },
    /* The three register bits are part of the encoding, exactly as in LXA
     * just below, and the assembler emits whatever register the source
     * named: the flight code's own `LDM R1,EXTDATA1` is 69F8 and
     * `LDM R3,...` is 6BF8, neither of which matched while these bits were
     * fixed at 000.  DE (01101xxxddddddbb) then took them, being the only
     * remaining match, and decoded a 4-byte instruction as a 2-byte one --
     * so every instruction after the first LDM was fetched at the wrong
     * offset.  Both opcodes still ignore the register itself: LDM loads,
     * and STDM stores, all four DSEs regardless (sec. 9.13). */
    { "LDM", "01101xxx11111abb/X", exec_LDM, 2, 1 },
    { "LXAR", "01000xxx11101yyy", exec_LXAR, 2, 1 },
    { "LXA", "01000xxx11111abb/X", exec_LXA, 2, 1 },
    { "STXAR", "10100xxx11101yyy", exec_STXAR, 2, 1 },
    { "STXA", "10100xxx11111abb/X", exec_STXA, 2, 1 },
    { "STDM", "10010xxx11111abb/X", exec_STDM, 2, 1 },
    { "ICR", "11011xxx11100yyy", exec_ICR, 2, 1 },
};

#define OPS_COUNT (int)(sizeof(OPS) / sizeof(OPS[0]))

static InstrDesc DESCS[OPS_COUNT];
static const InstrDesc *SORTED[OPS_COUNT];
static bool g_tableInit = false;

static int popcount32(uint32_t v) {
    int n = 0;
    while (v) { n += (int)(v & 1u); v >>= 1; }
    return n;
}

/* Most specific pattern first, and specificity is HOW MANY bits the
 * pattern fixes -- not the numeric value of the mask.  Sorting by value
 * alone put SHW (mask ff00, 8 fixed bits) ahead of STXA (mask f8f8, 10),
 * so every STXA whose R1 field happened to read 010 decoded as a
 * one-halfword SHW and the halfword after it as a separate instruction.
 * Ties break on the mask value, as gpc's own ordering does. */
static int cmp_mask_desc(const void *a, const void *b) {
    const InstrDesc *da = *(const InstrDesc **)a;
    const InstrDesc *db = *(const InstrDesc **)b;
    int na = popcount32(da->pb.mask), nb = popcount32(db->pb.mask);
    if (na != nb) return nb - na;
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
        /* POO 14.1: "no automatic index alignment" -- LM, STM and LPS
         * address fullword operands but take the index register as a
         * plain halfword count.  Scaling their index like the operand,
         * as this used to, doubled it: GPCIPL's SSM at +0cea landed 8
         * halfwords past its mask table and read the C9FB fill instead
         * of a system mask, so it unmasked the wrong interrupts.
         * (ISPB is the fourth instruction the POO exempts, but its
         * operand is already halfword-addressed, so it needs no entry.) */
        DESCS[i].indexWidth = OPS[i].addrWidth;
        if (!strcmp(OPS[i].nm, "LM") || !strcmp(OPS[i].nm, "STM") ||
            !strcmp(OPS[i].nm, "LPS"))
            DESCS[i].indexWidth = 1;
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
    v->indexWidth = desc->indexWidth;
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
    v->indexWidth = desc->indexWidth;
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

/* Mode marker that precedes the displacement of an extended-form operand:
 *   *+d / *-d   IC-relative forward / backward  (X2=0, A=0)
 *   @d          indirect through d              (A=1)
 *   @@d(x)      ZCON fullword pointer, double   (A=1, I=1, X2/=0)
 *   ...+        auto-modification writes back   (I=1)
 * None of this was rendered before, so an indirect or auto-modifying
 * operand disassembled identically to a plain one. */
static const char *ext_addr_prefix(const DInstr *v) {
    if (!v->hasIa) return "";
    uint32_t i = df_get(v, 'i');
    if (i == 0 && v->ia == 0) return (v->ii == 1) ? "*-" : "*+";
    if (v->ia == 1) return (v->ii == 1 && i != 0) ? "@@" : "@";
    return "";
}

/* Trailing marker for the extended forms that write a modified address
 * back to the pointer (step 6) or to the index register (step 8). */
static const char *ext_addr_suffix(const DInstr *v) {
    if (!v->hasIa || v->ii != 1) return "";
    uint32_t i = df_get(v, 'i');
    if (i == 0 && v->ia == 1) return "+";
    if (i != 0 && v->ia == 0) return "+";
    return "";
}

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
        pos += (size_t)snprintf(s + pos, sizeof s - pos, "%sX'%s'",
                                ext_addr_prefix(&v), hex);
    }
    if (df_has(&v, 'b')) {
        /* Index and base are joined with a comma only when BOTH are
         * shown -- an omitted base used to leave a dangling "(7," . */
        int32_t bval = (int32_t)df_get(&v, 'b');
        char parts[32];
        size_t pp = 0;
        if (df_has(&v, 'i') && df_get(&v, 'i') != 0) {
            pp += (size_t)snprintf(parts + pp, sizeof parts - pp, "%d",
                                   (int32_t)df_get(&v, 'i'));
        }
        if (!(v.extended && bval == 3)) {
            pp += (size_t)snprintf(parts + pp, sizeof parts - pp, "%s%d",
                                   pp ? "," : "", bval);
        }
        if (pp) pos += (size_t)snprintf(s + pos, sizeof s - pos, "(%s)", parts);
    }
    if (df_has(&v, 'd')) {
        pos += (size_t)snprintf(s + pos, sizeof s - pos, "%s", ext_addr_suffix(&v));
    }
    if (df_has(&v, 'I') && d->pb.type == PB_TYPE_SI) {
        char hex[16];
        as_hex(hex, sizeof hex, (long long)(int32_t)df_get(&v, 'I'), 4);
        pos += (size_t)snprintf(s + pos, sizeof s - pos, ",X'%s'", hex);
    }

    snprintf(out, outSize, "%s", s);
}
