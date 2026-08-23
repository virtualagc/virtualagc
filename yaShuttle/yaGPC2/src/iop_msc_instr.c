/* MSC (Master Sequence Controller) instruction set, ported from
 * gpc/iop_msc_instr.coffee. Unlike BCEInstruction, MSCInstruction does
 * *not* extend PackedBits — it has its own hand-rolled descriptor parser
 * (_parseDesc) that builds mask/maskedVal via a direct per-character
 * numeric accumulation instead of util.coffee's getMask/getMaskedDescVal
 * (which round-trip through a string and `parseInt(str,2)` — the source
 * of the CPU/BCE "uppercase field letter truncates the mask" quirk).
 * MSCInstruction's own algorithm has no such quirk, so msc_parse_desc()
 * below is a separate, simpler port rather than a reuse of
 * pb_make_desc() — field extraction itself (mask/shift semantics) is
 * identical, so the resulting PBField/PBDesc shape from util.h is reused
 * as-is, along with pb_get_field().
 *
 * Decode/dispatch: exec() first checks the top nibble of hw1 for the
 * long-format prefix (0xf) before even attempting a 32-bit match; the
 * table is split into two arrays by *descriptor string length* (<=16 or
 * >16 chars) — not by runtime mask magnitude, unlike BCEInstruction — but
 * for MSC's actual instruction set the two criteria coincide (every
 * short-format descriptor is exactly 16 chars, every long-format one 32).
 * Unrecognized instructions advance NIA by 1 (unlike BCE's unrecognized
 * path, which leaves NIA untouched and logs to stdout instead). */
#include "iop.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cpu.h"
#include "instr.h"
#include "util.h"

static int32_t sign_extend(uint32_t val, int bits) {
    uint32_t mask = 1u << (bits - 1);
    if (val & mask) {
        return (int32_t)(val | (~0u << bits));
    }
    return (int32_t)val;
}

typedef struct {
    const char *nm;
    const char *pattern;
    IopInstrExecFn e;
} MscOpEntry;

/* ---------------------------------------------------------------------
 * ACCUMULATOR/MEMORY INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_L(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_ea(t, df_get(v, 'd'), df_get(v, 'i') != 0);
    uint32_t v1 = iop_g_eaf(t, ea);
    iopls_setACC(&t->ls, v1);
    iop_incr_nia(t, 1);
}

static void exec_Aacc(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_ea(t, df_get(v, 'd'), df_get(v, 'i') != 0);
    uint32_t v1 = iop_g_eaf(t, ea);
    uint32_t v2 = iopls_getACC(&t->ls);
    uint32_t v3 = v1 + v2;
    iopls_setACC(&t->ls, v3);
    iop_incr_nia(t, 1);
}

static void exec_N(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_ea(t, df_get(v, 'd'), df_get(v, 'i') != 0);
    uint32_t v1 = iop_g_eaf(t, ea);
    uint32_t v2 = iopls_getACC(&t->ls);
    iopls_setACC(&t->ls, v1 & v2);
    iop_incr_nia(t, 1);
}

static void exec_Xacc(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_ea(t, df_get(v, 'd'), df_get(v, 'i') != 0);
    uint32_t v1 = iop_g_eaf(t, ea);
    uint32_t v2 = iopls_getACC(&t->ls);
    iopls_setACC(&t->ls, v1 ^ v2);
    iop_incr_nia(t, 1);
}

static void exec_ST(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_ea(t, df_get(v, 'd'), df_get(v, 'i') != 0);
    uint32_t v2 = iopls_getACC(&t->ls);
    iop_s_eaf(t, ea, v2);
    iop_incr_nia(t, 1);
}

static void exec_LF(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t v1 = iop_g_eaf(t, ea);
    iopls_setACC(&t->ls, v1);
    iop_incr_nia(t, 1);
}

static void exec_LH(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t v1 = iop_g_eah(t, ea);
    iopls_setACC(&t->ls, v1);
    iop_incr_nia(t, 1);
}

static void exec_STF(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t v2 = iopls_getACC(&t->ls);
    iop_s_eaf(t, ea, v2);
    iop_incr_nia(t, 1);
}

static void exec_STH(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t v2 = register_get16(iopls_AL(&t->ls));
    iop_s_eah(t, ea, v2);
    iop_incr_nia(t, 1);
}

/* ---------------------------------------------------------------------
 * BRANCHING INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_BC(IOP *t, DInstr *v) {
    bool doBranch = false;
    int32_t v1 = (int32_t)iopls_getACC(&t->ls);
    uint32_t c = df_get(v, 'c');
    if (c & 0x4) {
        if (v1 == 0) doBranch = true;
    }
    if (c & 0x2) {
        if (v1 < 0) doBranch = true;
    }
    if (c & 0x1) {
        if (v1 > 0) doBranch = true;
    }
    if (doBranch) {
        /* The displacement is relative to the UPDATED PC -- the address
         * of the next sequential instruction -- so the branch is
         * 1 + disp, not disp.  Taking it as disp landed one halfword
         * early: GPCIPL's MSC program branches to @LXI/@INT/@WAT at
         * 14c8 and we arrived at 14c7, skipping the @INT that raises the
         * IOP interrupt to the CPU. */
        int32_t d8 = sign_extend(df_get(v, 'd'), 8);
        iop_incr_nia(t, 1 + d8);
    } else {
        iop_incr_nia(t, 1);
    }
}

static void exec_BXC(IOP *t, DInstr *v) {
    bool doBranch = false;
    int32_t v1 = (int32_t)register_get32(iopls_X(&t->ls));
    uint32_t c = df_get(v, 'c');
    if (c & 0x4) {
        if (v1 == 0) doBranch = true;
    }
    if (c & 0x2) {
        if (v1 < 0) doBranch = true;
    }
    if (c & 0x1) {
        if (v1 > 0) doBranch = true;
    }
    if (doBranch) {
        /* The displacement is relative to the UPDATED PC -- the address
         * of the next sequential instruction -- so the branch is
         * 1 + disp, not disp.  Taking it as disp landed one halfword
         * early: GPCIPL's MSC program branches to @LXI/@INT/@WAT at
         * 14c8 and we arrived at 14c7, skipping the @INT that raises the
         * IOP interrupt to the CPU. */
        int32_t d8 = sign_extend(df_get(v, 'd'), 8);
        iop_incr_nia(t, 1 + d8);
    } else {
        iop_incr_nia(t, 1);
    }
}

static void exec_BU(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    iop_set_nia(t, ea);
}

static void exec_BU_at(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t addr = iop_g_eaf(t, ea);
    iop_set_nia(t, addr & 0x3ffffu);
}

static void exec_CALL(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t pc = register_get32(iopls_PC(&t->ls));
    uint32_t retAddr = (pc + df_get(v, 't')) & 0x3ffffu;
    iop_s_eaf(t, ea & 0x3fffeu, retAddr); /* store at even address */
    iop_set_nia(t, ea + 2);
}

static void exec_CALL_at(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t addr = iop_g_eaf(t, ea) & 0x3ffffu; /* indirect: read address from memory */
    uint32_t pc = register_get32(iopls_PC(&t->ls));
    uint32_t retAddr = (pc + df_get(v, 't')) & 0x3ffffu;
    iop_s_eaf(t, addr & 0x3fffeu, retAddr);
    iop_set_nia(t, addr + 2);
}

static void exec_REC(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_ea(t, df_get(v, 'd'), df_get(v, 'i') != 0);
    /* ECR value was stored at ea; saved regs follow at ea+2..ea+8 */
    uint32_t acc = iop_g_eaf(t, ea + 2);
    iopls_setACC(&t->ls, acc);
    uint32_t xval = iop_g_eaf(t, ea + 4);
    register_set32(iopls_X(&t->ls), xval & 0x3ffffu);
    uint32_t pcval = iop_g_eaf(t, ea + 6);
    iop_set_nia(t, pcval & 0x3ffffu);
    uint32_t stval = iop_g_eaf(t, ea + 8);
    register_set32(iopls_MST(&t->ls), stval & 0x3ffffu);
    if (stval & 0x00010000u) {
        iop_proc_set(&t->regProgExcept, PROC_MSC, 1); /* MSC to GO */
    } else {
        /* MSC to NO-GO: its bit is the top of the word, not the
         * bottom -- see iop.h's processor-numbering note. */
        iop_proc_set(&t->regProgExcept, PROC_MSC, 0);
    }
}

/* ---------------------------------------------------------------------
 * CONDITIONAL SKIP INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_TSZ(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_ea(t, df_get(v, 'd'), df_get(v, 'i') != 0);
    uint32_t v2 = iop_g_eaf(t, ea);
    v2 = v2 + 1;
    iop_s_eaf(t, ea, v2);
    if (v2 == 0) iop_incr_nia(t, 2);
    else iop_incr_nia(t, 1);
}

static void exec_CI(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    int32_t val = (int32_t)ea; /* immediate mode: EA is the value itself */
    int32_t acc = (int32_t)iopls_getACC(&t->ls);
    if (acc < val) iop_incr_nia(t, 2);
    else if (acc == val) iop_incr_nia(t, 3);
    else iop_incr_nia(t, 1);
}

static void exec_C(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    int32_t val = (int32_t)iop_g_eaf(t, ea);
    int32_t acc = (int32_t)iopls_getACC(&t->ls);
    if (acc < val) iop_incr_nia(t, 2);
    else if (acc == val) iop_incr_nia(t, 3);
    else iop_incr_nia(t, 1);
}

static void exec_TMI(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t mask = ea; /* immediate value is the mask */
    uint32_t acc = iopls_getACC(&t->ls);
    if ((acc & mask) != 0) iop_incr_nia(t, 2);
    else iop_incr_nia(t, 1);
}

static void exec_TM(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t mask = iop_g_eaf(t, ea);
    uint32_t acc = iopls_getACC(&t->ls);
    if ((acc & mask) != 0) iop_incr_nia(t, 2);
    else iop_incr_nia(t, 1);
}

/* ---------------------------------------------------------------------
 * BCE REGISTER LOAD INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_LBB(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t bceNum = df_get(v, 'b');
    if (bceNum == 0) bceNum = iopls_getACC(&t->ls) & 0x1fu;
    if (bceNum > 0 && bceNum <= 24) {
        if (iop_proc_get(&t->regBusyWait, (int)bceNum) || !iop_proc_get(&t->regHalt, (int)bceNum)) {
            uint32_t st = register_get32(iopls_MST(&t->ls));
            st = st | (1u << (17 - 13));
            register_set32(iopls_MST(&t->ls), st);
            iop_proc_set(&t->regProgExcept, PROC_MSC, 0); /* MSC to NO-GO */
        } else {
            int savedPage = t->ls.curPage;
            t->ls.curPage = (int)bceNum;
            register_set32(iopls_BASE(&t->ls), ea & 0x3ffffu);
            t->ls.curPage = savedPage;
        }
    } else {
        uint32_t st = register_get32(iopls_MST(&t->ls));
        st = st | (1u << (17 - 13));
        register_set32(iopls_MST(&t->ls), st);
        iop_proc_set(&t->regProgExcept, PROC_MSC, 0); /* MSC to NO-GO */
    }
    iop_incr_nia(t, 1);
}

static void exec_LBB_at(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t val = iop_g_eaf(t, ea);
    ea = val & 0x3ffffu;
    uint32_t bceNum = df_get(v, 'b');
    if (bceNum == 0) bceNum = iopls_getACC(&t->ls) & 0x1fu;
    if (bceNum > 0 && bceNum <= 24) {
        if (iop_proc_get(&t->regBusyWait, (int)bceNum) || !iop_proc_get(&t->regHalt, (int)bceNum)) {
            uint32_t st = register_get32(iopls_MST(&t->ls));
            st = st | (1u << (17 - 13));
            register_set32(iopls_MST(&t->ls), st);
            iop_proc_set(&t->regProgExcept, PROC_MSC, 0); /* MSC to NO-GO */
        } else {
            int savedPage = t->ls.curPage;
            t->ls.curPage = (int)bceNum;
            register_set32(iopls_BASE(&t->ls), ea);
            t->ls.curPage = savedPage;
        }
    } else {
        uint32_t st = register_get32(iopls_MST(&t->ls));
        st = st | (1u << (17 - 13));
        register_set32(iopls_MST(&t->ls), st);
        iop_proc_set(&t->regProgExcept, PROC_MSC, 0); /* MSC to NO-GO */
    }
    iop_incr_nia(t, 1);
}

static void exec_LBP(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t bceNum = df_get(v, 'b');
    if (bceNum == 0) bceNum = iopls_getACC(&t->ls) & 0x1fu;
    if (bceNum > 0 && bceNum <= 24) {
        if (iop_proc_get(&t->regBusyWait, (int)bceNum) || !iop_proc_get(&t->regHalt, (int)bceNum)) {
            uint32_t st = register_get32(iopls_MST(&t->ls));
            st = st | (1u << (17 - 12));
            register_set32(iopls_MST(&t->ls), st);
            iop_proc_set(&t->regProgExcept, PROC_MSC, 0); /* MSC to NO-GO */
        } else {
            int savedPage = t->ls.curPage;
            t->ls.curPage = (int)bceNum;
            register_set32(iopls_PC(&t->ls), ea & 0x3ffffu);
            t->ls.curPage = savedPage;
        }
    } else {
        uint32_t st = register_get32(iopls_MST(&t->ls));
        st = st | (1u << (17 - 12));
        register_set32(iopls_MST(&t->ls), st);
        iop_proc_set(&t->regProgExcept, PROC_MSC, 0); /* MSC to NO-GO */
    }
    iop_incr_nia(t, 1);
}

static void exec_LBP_at(IOP *t, DInstr *v) {
    uint32_t ea = iop_msc_long_ea(t, df_get(v, 'a'), df_get(v, 'i') != 0);
    uint32_t val = iop_g_eaf(t, ea);
    ea = val & 0x3ffffu;
    uint32_t bceNum = df_get(v, 'b');
    if (bceNum == 0) bceNum = iopls_getACC(&t->ls) & 0x1fu;
    if (bceNum > 0 && bceNum <= 24) {
        if (iop_proc_get(&t->regBusyWait, (int)bceNum) || !iop_proc_get(&t->regHalt, (int)bceNum)) {
            uint32_t st = register_get32(iopls_MST(&t->ls));
            st = st | (1u << (17 - 12));
            register_set32(iopls_MST(&t->ls), st);
            iop_proc_set(&t->regProgExcept, PROC_MSC, 0); /* MSC to NO-GO */
        } else {
            int savedPage = t->ls.curPage;
            t->ls.curPage = (int)bceNum;
            register_set32(iopls_PC(&t->ls), ea);
            t->ls.curPage = savedPage;
        }
    } else {
        uint32_t st = register_get32(iopls_MST(&t->ls));
        st = st | (1u << (17 - 12));
        register_set32(iopls_MST(&t->ls), st);
        iop_proc_set(&t->regProgExcept, PROC_MSC, 0); /* MSC to NO-GO */
    }
    iop_incr_nia(t, 1);
}

/* ---------------------------------------------------------------------
 * REGISTER OPERATIONS
 * ------------------------------------------------------------------- */

static void exec_LAR(IOP *t, DInstr *v) {
    switch (df_get(v, 'd') & 3) {
        case 0: /* STAT1 - Program Exception (GO/NOGO) */
            iopls_setACC(&t->ls, register_get32(&t->regProgExcept));
            break;
        case 1: /* BCE-MSC Indicators */
            iopls_setACC(&t->ls, register_get32(&t->regIndicator));
            break;
        case 2: /* Fail Discretes */
            iopls_setACC(&t->ls, register_get32(&t->msc.regFailDisc));
            break;
        case 3: /* STAT4 - Busy/Wait */
            iopls_setACC(&t->ls, register_get32(&t->regBusyWait));
            break;
    }
    iop_incr_nia(t, 1);
}

static void exec_SFD(IOP *t, DInstr *v) {
    (void)v;
    uint32_t acc = iopls_getACC(&t->ls);
    uint32_t fd = register_get32(&t->msc.regFailDisc);
    fd = fd | (acc >> 27); /* top 5 bits of ACC */
    register_set32(&t->msc.regFailDisc, fd & 0x1fu);
    iop_incr_nia(t, 1);
}

static void exec_RFD(IOP *t, DInstr *v) {
    (void)v;
    uint32_t acc = iopls_getACC(&t->ls);
    uint32_t fd = register_get32(&t->msc.regFailDisc);
    uint32_t mask = (acc >> 27) & 0x1fu;
    fd = fd & ~mask;
    register_set32(&t->msc.regFailDisc, fd);
    iop_incr_nia(t, 1);
}

static void exec_LMS(IOP *t, DInstr *v) {
    (void)v;
    uint32_t st = register_get32(iopls_MST(&t->ls));
    iopls_setACC(&t->ls, st);
    iop_incr_nia(t, 1);
}

static void exec_SIO(IOP *t, DInstr *v) {
    (void)v;
    uint32_t acc = iopls_getACC(&t->ls);
    uint32_t bw = register_get32(&t->regBusyWait);
    uint32_t conflict = acc & bw & PROC_ALL_BCE;
    if (conflict) {
        uint32_t st = register_get32(iopls_MST(&t->ls));
        st = st | (1u << (17 - 11)) | (1u << (17 - 16));
        register_set32(iopls_MST(&t->ls), st);
        iop_proc_set(&t->regProgExcept, PROC_MSC, 0); /* MSC to NO-GO */
    }
    bw = bw | acc;
    register_set32(&t->regBusyWait, bw);
    iop_incr_nia(t, 1);
}

static void exec_XAX(IOP *t, DInstr *v) {
    (void)v;
    uint32_t acc = iopls_getACC(&t->ls);
    uint32_t xval = register_get32(iopls_X(&t->ls));
    register_set32(iopls_X(&t->ls), acc & 0x3ffffu);
    int32_t xSigned = sign_extend(xval, 18);
    iopls_setACC(&t->ls, (uint32_t)xSigned);
    iop_incr_nia(t, 1);
}

static void exec_SEC(IOP *t, DInstr *v) {
    (void)v;
    uint32_t ecr = register_get32(iopls_ECR(&t->ls));
    if (ecr == 0) {
        iop_incr_nia(t, 1);
    } else {
        iop_s_eaf(t, ecr + 2, iopls_getACC(&t->ls));
        iop_s_eaf(t, ecr + 4, register_get32(iopls_X(&t->ls)));
        uint32_t pc = register_get32(iopls_PC(&t->ls));
        iop_s_eaf(t, ecr + 6, pc + 1);
        uint32_t st = register_get32(iopls_MST(&t->ls));
        uint32_t peBit = iop_proc_get(&t->regProgExcept, PROC_MSC);
        st = st | (peBit << 16);
        iop_s_eaf(t, ecr + 8, st);
        register_set32(iopls_MST(&t->ls), 0);
        iop_proc_set(&t->regProgExcept, PROC_MSC, 1); /* MSC to GO */
        register_set32(iopls_ECR(&t->ls), 0);
        iop_set_nia(t, ecr + 8);
    }
}

static void exec_RBI(IOP *t, DInstr *v) {
    iop_proc_set(&t->regIndicator, (int)df_get(v, 'b'), 0);
    iop_incr_nia(t, 1);
}

/* ---------------------------------------------------------------------
 * REGISTER IMMEDIATE INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_NIX(IOP *t, DInstr *v) {
    int32_t imm = sign_extend(df_get(v, 'i'), 8);
    int32_t acc = (int32_t)iopls_getACC(&t->ls);
    uint32_t xval = register_get32(iopls_X(&t->ls));
    if (acc == 0) {
        register_set32(iopls_X(&t->ls), 0);
    } else {
        for (;;) {
            acc = (int32_t)((uint32_t)acc << 1);
            xval = ((uint32_t)((int32_t)xval + imm)) & 0x3ffffu;
            if (acc & (int32_t)0x80000000u) break;
            if (acc == 0) break;
        }
        iopls_setACC(&t->ls, (uint32_t)acc);
        if (acc == 0) register_set32(iopls_X(&t->ls), 0);
        else register_set32(iopls_X(&t->ls), xval);
    }
    iop_incr_nia(t, 1);
}

static void exec_TAX(IOP *t, DInstr *v) {
    int32_t imm = sign_extend(df_get(v, 'i'), 8);
    uint32_t acc = iopls_getACC(&t->ls);
    uint32_t result = (acc + (uint32_t)imm) & 0x3ffffu;
    register_set32(iopls_X(&t->ls), result);
    iop_incr_nia(t, 1);
}

static void exec_TXI(IOP *t, DInstr *v) {
    int32_t imm = sign_extend(df_get(v, 'i'), 8);
    int32_t xval = sign_extend(register_get32(iopls_X(&t->ls)), 18);
    int32_t result = xval + imm;
    register_set32(iopls_X(&t->ls), (uint32_t)result & 0x3ffffu);
    if (result <= 0) iop_incr_nia(t, 2);
    else iop_incr_nia(t, 1);
}

static void exec_LXI(IOP *t, DInstr *v) {
    int32_t imm = sign_extend(df_get(v, 'i'), 8);
    register_set32(iopls_X(&t->ls), (uint32_t)imm & 0x3ffffu);
    iop_incr_nia(t, 1);
}

static void exec_TXA(IOP *t, DInstr *v) {
    int32_t imm = sign_extend(df_get(v, 'i'), 8);
    int32_t xval = sign_extend(register_get32(iopls_X(&t->ls)), 18);
    int32_t result = xval + imm;
    iopls_setACC(&t->ls, (uint32_t)result);
    iop_incr_nia(t, 1);
}

static void exec_TI(IOP *t, DInstr *v) {
    int32_t imm = sign_extend(df_get(v, 'i'), 8);
    uint32_t acc = iopls_getACC(&t->ls);
    uint32_t result = acc + (uint32_t)imm;
    iopls_setACC(&t->ls, result);
    iop_incr_nia(t, 1);
}

static void exec_SAI(IOP *t, DInstr *v) {
    int32_t imm = sign_extend(df_get(v, 'i'), 8);
    uint32_t acc = iopls_getACC(&t->ls);
    uint32_t result = (uint32_t)imm - acc;
    iopls_setACC(&t->ls, result);
    iop_incr_nia(t, 1);
}

static void exec_LI(IOP *t, DInstr *v) {
    int32_t imm = sign_extend(df_get(v, 'i'), 8);
    iopls_setACC(&t->ls, (uint32_t)imm);
    iop_incr_nia(t, 1);
}

/* ---------------------------------------------------------------------
 * REPEAT INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_RAI(IOP *t, DInstr *v) {
    uint32_t m = iopls_getACC(&t->ls) & PROC_ALL_BCE;
    iop_msc_repeat(t, v, (register_get32(&t->regIndicator) & m) == m);
}

static void exec_RAW(IOP *t, DInstr *v) {
    uint32_t m = iopls_getACC(&t->ls) & PROC_ALL_BCE;
    iop_msc_repeat(t, v, (register_get32(&t->regBusyWait) & m) == 0);
}

static void exec_RNI(IOP *t, DInstr *v) {
    uint32_t m = iopls_getACC(&t->ls) & PROC_ALL_BCE;
    iop_msc_repeat(t, v, (register_get32(&t->regIndicator) & m) != 0);
}

static void exec_RNW(IOP *t, DInstr *v) {
    uint32_t m = iopls_getACC(&t->ls) & PROC_ALL_BCE;
    iop_msc_repeat(t, v, ((~register_get32(&t->regBusyWait)) & m) != 0);
}

/* ---------------------------------------------------------------------
 * SPECIAL INSTRUCTIONS
 * ------------------------------------------------------------------- */

static void exec_WAT(IOP *t, DInstr *v) {
    (void)v;
    iop_proc_set(&t->regBusyWait, PROC_MSC, 0);
    uint32_t st = register_get32(iopls_MST(&t->ls));
    st = st & ~1u;
    register_set32(iopls_MST(&t->ls), st);
    iop_incr_nia(t, 1);
}

static void exec_DLY(IOP *t, DInstr *v) {
    (void)v;
    iop_incr_nia(t, 1);
}

static void exec_INT(IOP *t, DInstr *v) {
    uint32_t il = df_get(v, 'l') & 0xfffu;
    if (df_get(v, 'I')) {
        uint32_t xval = register_get32(iopls_X(&t->ls));
        il = il | (xval & 0xfffu);
    }
    /* "This instruction loads the 12 bit IOP Interrupt Register C and
     * causes an interrupt to the GPC to be set if at least one of the
     * bits is a 1."  Register C is what the CPU's own PCI X'0808'
     * (READ INTERRUPT REGISTER C) hands back, left-justified in the
     * 32-bit word.  Loading only regIntProg -- as this did -- raised
     * the interrupt but left the CPU reading 0 from register C, so
     * GPCIPL's handler at +09dd saw no source for the External 2 it
     * had just taken. */
    Register *intC = registerfile_r(&t->regInterrupts, 2);
    register_set32(intC, register_get32(intC) | (il << 20));
    register_set32(&t->msc.regIntProg, il);
    if (il != 0 && t->cpu) {
        t->cpu->intPending.iopProg = true;
    }
    iop_incr_nia(t, 1);
}

static void exec_STP(IOP *t, DInstr *v) {
    (void)v;
    /* MSC to GO.  Its bit is the top of the word (iop.h); this set the
     * bottom one, which is one of the unused bits above the self-test
     * processor. */
    iop_proc_set(&t->regProgExcept, PROC_MSC, 1);
    iop_incr_nia(t, 1);
}

/* ---------------------------------------------------------------------
 * Op table / descriptor parser / decode / dispatch
 * ------------------------------------------------------------------- */

static const MscOpEntry OPS[] = {
    {"@L", "0100iddddddddddd", exec_L},
    {"@A", "0101iddddddddddd", exec_Aacc},
    {"@N", "0110iddddddddddd", exec_N},
    {"@X", "0111iddddddddddd", exec_Xacc},
    {"@ST", "1000iddddddddddd", exec_ST},
    {"@LF", "1111i100000000aaaaaaaaaaaaaaaaaa", exec_LF},
    {"@LH", "1111i100000010aaaaaaaaaaaaaaaaaa", exec_LH},
    {"@STF", "1111i101000000aaaaaaaaaaaaaaaaaa", exec_STF},
    {"@STH", "1111i101000010aaaaaaaaaaaaaaaaaa", exec_STH},
    {"@BC", "00100cccdddddddd", exec_BC},
    {"@BXC", "00101cccdddddddd", exec_BXC},
    {"@BU", "1111i000_____0aaaaaaaaaaaaaaaaaa", exec_BU},
    {"@BU@", "1111i000_____1aaaaaaaaaaaaaaaaaa", exec_BU_at},
    {"@CALL", "1111i001ttttt0aaaaaaaaaaaaaaaaaa", exec_CALL},
    {"@CALL@", "1111i001ttttt1aaaaaaaaaaaaaaaaaa", exec_CALL_at},
    {"@REC", "1010iddddddddddd", exec_REC},
    {"@TSZ", "1001iddddddddddd", exec_TSZ},
    {"@CI", "1111i110_____0aaaaaaaaaaaaaaaaaa", exec_CI},
    {"@C", "1111i110_____1aaaaaaaaaaaaaaaaaa", exec_C},
    {"@TMI", "1111i111_____0aaaaaaaaaaaaaaaaaa", exec_TMI},
    {"@TM", "1111i111_____1aaaaaaaaaaaaaaaaaa", exec_TM},
    {"@LBB", "1111i010bbbbb0aaaaaaaaaaaaaaaaaa", exec_LBB},
    {"@LBB@", "1111i010bbbbb1aaaaaaaaaaaaaaaaaa", exec_LBB_at},
    {"@LBP", "1111i011bbbbb0aaaaaaaaaaaaaaaaaa", exec_LBP},
    {"@LBP@", "1111i011bbbbb1aaaaaaaaaaaaaaaaaa", exec_LBP_at},
    {"@LAR", "11100000dddddddd", exec_LAR},
    {"@SFD", "1110000100000000", exec_SFD},
    {"@RFD", "1110001000000000", exec_RFD},
    {"@LMS", "1110001100000000", exec_LMS},
    {"@SIO", "1110010000000000", exec_SIO},
    {"@XAX", "1110010100000000", exec_XAX},
    {"@SEC", "1110011000000000", exec_SEC},
    {"@RBI", "11100111bbbbb000", exec_RBI},
    {"@NIX", "11101000iiiiiiii", exec_NIX},
    {"@TAX", "11101001iiiiiiii", exec_TAX},
    {"@TXI", "11101010iiiiiiii", exec_TXI},
    {"@LXI", "11101011iiiiiiii", exec_LXI},
    {"@TXA", "11101100iiiiiiii", exec_TXA},
    {"@TI", "11101101iiiiiiii", exec_TI},
    {"@SAI", "11101110iiiiiiii", exec_SAI},
    {"@LI", "11101111iiiiiiii", exec_LI},
    {"@RAI", "1101i100dddddddd", exec_RAI},
    {"@RAW", "1101i000dddddddd", exec_RAW},
    {"@RNI", "1101i101dddddddd", exec_RNI},
    {"@RNW", "1101i001dddddddd", exec_RNW},
    {"@WAT", "0000100000000000", exec_WAT},
    {"@DLY", "1100iddddddddddd", exec_DLY},
    {"@INT", "0011Illlllllllll", exec_INT},
    {"@STP", "0001000000000000", exec_STP},
};

#define OPS_COUNT (int)(sizeof(OPS) / sizeof(OPS[0]))

typedef struct {
    const char *nm;
    PBDesc pb;
    IopInstrExecFn e;
} MscInstrDesc;

/* Direct port of MSCInstruction#_parseDesc: mask/maskedVal via a plain
 * per-character numeric accumulation (no parseInt/string round-trip, so
 * no truncation quirk to replicate), field mask/shift via "rightmost
 * occurrence wins for shift, OR in a bit for every occurrence" — same
 * result as util.coffee's getFieldShft/getFieldMask, computed
 * differently. '_' is a wildcard (contributes to neither mask nor any
 * field), matching the observable behavior — the source technically
 * tracks it as its own zero-effect "field" too, but nothing ever reads
 * v['_'], so that's omitted here as a no-op simplification. */
static PBDesc msc_parse_desc(const char *s) {
    PBDesc d;
    memset(&d, 0, sizeof(d));
    int len = (int)strlen(s);
    d.bitLen = len;
    d.len = 1;
    d.origLen = 1;
    d.type = PB_TYPE_NONE;

    uint32_t mask = 0, maskedVal = 0;
    bool present[128] = {false};
    for (int i = 0; i < len; i++) {
        char ch = s[i];
        mask = mask * 2 + ((ch == '0' || ch == '1') ? 1u : 0u);
        maskedVal = maskedVal * 2 + (ch == '1' ? 1u : 0u);
        if (ch != '0' && ch != '1' && ch != '_') present[(unsigned char)ch] = true;
    }
    d.mask = mask;
    d.maskedVal = maskedVal;

    for (int c = 0; c < 128; c++) {
        if (!present[c]) continue;
        int lastIdx = -1;
        for (int j = 0; j < len; j++) {
            if (s[j] == (char)c) lastIdx = j;
        }
        int shift = len - 1 - lastIdx;
        uint32_t fmask = 0;
        int bits = 0;
        for (int j = 0; j < len; j++) {
            if (s[j] == (char)c) {
                int bitpos = len - 1 - j;
                fmask += (1u << bitpos);
                bits++;
            }
        }
        d.field[c].present = true;
        d.field[c].shift = shift;
        d.field[c].mask = fmask;
        d.field[c].bitlen = bits;
    }
    return d;
}

static MscInstrDesc DESCS[OPS_COUNT];
static const MscInstrDesc *SORTED16[OPS_COUNT];
static const MscInstrDesc *SORTED32[OPS_COUNT];
static int n16 = 0, n32 = 0;
static bool g_tableInit = false;

/* Replicates JS's default Array#sort() (lexicographic string compare),
 * then .reverse() — see iop_bce_instr.c's identical comment for why this
 * isn't assumed to coincide with numeric order. */
static int cmp_mask_lex_desc(const void *a, const void *b) {
    const MscInstrDesc *da = *(const MscInstrDesc **)a;
    const MscInstrDesc *db = *(const MscInstrDesc **)b;
    char sa[16], sb[16];
    snprintf(sa, sizeof sa, "%u", da->pb.mask);
    snprintf(sb, sizeof sb, "%u", db->pb.mask);
    return strcmp(sb, sa);
}

void msc_instr_table_init(void) {
    if (g_tableInit) return;
    n16 = 0;
    n32 = 0;
    bool isLong[OPS_COUNT];
    for (int i = 0; i < OPS_COUNT; i++) {
        DESCS[i].nm = OPS[i].nm;
        DESCS[i].pb = msc_parse_desc(OPS[i].pattern);
        DESCS[i].e = OPS[i].e;
        isLong[i] = (int)strlen(OPS[i].pattern) > 16;
    }
    /* Same shadowing rule as bce_instr_table_init (see its comment): a
     * later entry sharing an identical (mask, maskedVal) *within the same
     * bucket* (JS keeps _opTable16/_opTable32 as separate dicts, so a
     * collision only matters within one bucket) overwrites the dict slot
     * an earlier entry would have used. No such collision exists in the
     * current 49-instruction MSC set (verified against the live
     * CoffeeScript), but this stays exact-by-construction rather than
     * relying on that continuing to hold. */
    bool shadowed[OPS_COUNT] = {false};
    for (int i = 0; i < OPS_COUNT; i++) {
        for (int j = i + 1; j < OPS_COUNT; j++) {
            if (isLong[j] == isLong[i] && DESCS[j].pb.mask == DESCS[i].pb.mask &&
                DESCS[j].pb.maskedVal == DESCS[i].pb.maskedVal) {
                shadowed[i] = true;
                break;
            }
        }
    }
    for (int i = 0; i < OPS_COUNT; i++) {
        if (shadowed[i]) continue;
        if (isLong[i]) {
            SORTED32[n32++] = &DESCS[i];
        } else {
            SORTED16[n16++] = &DESCS[i];
        }
    }
    qsort(SORTED16, (size_t)n16, sizeof(SORTED16[0]), cmp_mask_lex_desc);
    qsort(SORTED32, (size_t)n32, sizeof(SORTED32[0]), cmp_mask_lex_desc);
    g_tableInit = true;
}

static void msc_decode(uint32_t word, const MscInstrDesc *d, DInstr *v) {
    memset(v, 0, sizeof(*v));
    v->nm = d->nm;
    for (int c = 0; c < DINSTR_FIELD_TABLE_SIZE; c++) {
        if (d->pb.field[c].present) {
            df_set(v, (char)c, pb_get_field(word, &d->pb.field[c]));
        }
    }
}

void msc_instr_exec(IOP *iop, uint32_t hw1, uint32_t hw2) {
    msc_instr_table_init();
    if ((hw1 >> 12) == 0xf) {
        uint32_t fullword = ((hw1 & 0xffffu) << 16) | (hw2 & 0xffffu);
        for (int i = 0; i < n32; i++) {
            const MscInstrDesc *d = SORTED32[i];
            if ((fullword & d->pb.mask) == d->pb.maskedVal) {
                DInstr v;
                msc_decode(fullword, d, &v);
                if (d->e) d->e(iop, &v);
                return;
            }
        }
    }

    uint32_t h1 = hw1 & 0xffffu;
    for (int i = 0; i < n16; i++) {
        const MscInstrDesc *d = SORTED16[i];
        if ((h1 & d->pb.mask) == d->pb.maskedVal) {
            DInstr v;
            msc_decode(h1, d, &v);
            if (d->e) d->e(iop, &v);
            return;
        }
    }

    /* Unrecognized instruction - no-op, advance PC */
    iop_incr_nia(iop, 1);
}
