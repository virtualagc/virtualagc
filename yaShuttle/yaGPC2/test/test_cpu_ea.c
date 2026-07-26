/* Cross-checks cpu.c's addressing/CC logic (g_EA, g_EA_16, g_EXPAND,
 * g_EXPAND_DSE, g_SHIFT_CNT, computeCCarith, computeCClogical) against
 * the real gpc/cpu.coffee, wired up exactly as `gpc run` does (via
 * ap101.coffee's CPU/IOP MemoryBus) so the addressing logic is exercised
 * under production-equivalent conditions.
 *
 * Fixtures regenerated via:
 *   node test/gen_cpu_ea_fixtures.cjs > fixtures.json
 *   python3 test/gen_cpu_ea_fixtures_header.py fixtures.json > test/cpu_ea_fixtures.h
 */
#include <stdio.h>
#include <string.h>

#include "../src/cpu.h"
#include "cpu_ea_fixtures.h"

/* Phase 5 (cpu_instr.c) isn't linked into this test; it never calls
 * exec1/instr_decode, so a trivial stub suffices to satisfy the linker.
 * iop_recv_from_cpu/iop_get_cc_data now come from the real src/iop.c
 * (Phase 6). */
const InstrDesc *instr_decode(uint32_t hw1, uint32_t hw2, DInstr *v) {
    (void)hw1; (void)hw2; (void)v;
    return NULL;
}

static CPU cpu;
static MCM iopMcm;
static MemoryBus bus;

static void load_baseline(void) {
    for (int bank = 0; bank < 3; bank++) {
        for (int i = 0; i <= 8; i++) {
            register_set32(registerfile_r(&cpu.regFiles[bank], i), CPU_BASELINE.regs[bank][i]);
        }
        for (int i = 0; i < 4; i++) {
            registerfile_set_dse(&cpu.regFiles[bank], i, CPU_BASELINE.dse[bank][i]);
        }
    }
    for (uint32_t a = 0; a < 4096; a++) {
        mcm_set16(&cpu.mainStorage, a, CPU_BASELINE.mem[a], false);
    }
    register_set32(&cpu.psw.psw1, CPU_BASELINE.psw1);
    register_set32(&cpu.psw.psw2, CPU_BASELINE.psw2);
}

static DInstr make_v(const VOpts *o) {
    DInstr v;
    memset(&v, 0, sizeof(v));
    v.niaIncr = o->niaIncr;
    v.opType = o->opType;
    v.addrWidth = o->addrWidth;
    if (o->hasI) df_set(&v, 'I', o->I);
    if (o->hasD) df_set(&v, 'd', o->d);
    if (o->hasB) df_set(&v, 'b', o->b);
    if (o->hasIdx) {
        df_set(&v, 'i', o->idx);
        v.hasIa = true; v.ia = o->ia;
        v.hasIi = true; v.ii = o->ii;
    }
    return v;
}

static int check_reg_diff(const char *label, int count, const RegDiff *diffs) {
    int failures = 0;
    for (int i = 0; i < count; i++) {
        uint32_t got = register_get32(registerfile_r(&cpu.regFiles[diffs[i].bank], diffs[i].idx));
        if (got != diffs[i].val) {
            printf("FAIL %s: reg[%d][%d] = %u, expected %u\n", label, diffs[i].bank, diffs[i].idx, got, diffs[i].val);
            failures++;
        }
    }
    return failures;
}

static int check_mem_diff(const char *label, int count, const MemDiff *diffs) {
    int failures = 0;
    for (int i = 0; i < count; i++) {
        uint32_t got = mcm_get16(&cpu.mainStorage, diffs[i].addr);
        if (got != diffs[i].val) {
            printf("FAIL %s: mem[%u] = %u, expected %u\n", label, diffs[i].addr, got, diffs[i].val);
            failures++;
        }
    }
    return failures;
}

int main(void) {
    int failures = 0;
    long total = 0;

    cpu_init(&cpu);
    iopMcm = mcm_create(24 * 1024);
    bus = membus_create(&cpu.mainStorage, &iopMcm);
    cpu.ram = &bus;

    int ne = (int)(sizeof(EA_FIXTURES) / sizeof(EA_FIXTURES[0]));
    for (int i = 0; i < ne; i++) {
        const EaFixture *fx = &EA_FIXTURES[i];
        load_baseline();
        DInstr v = make_v(&fx->opts);
        uint32_t ea = cpu_g_ea(&cpu, &v);
        total++;
        if (ea != fx->ea) {
            printf("FAIL g_EA[%d]: ea=%u expected %u\n", i, ea, fx->ea);
            failures++;
        }
        total += fx->regDiffCount + fx->memDiffCount + 2;
        failures += check_reg_diff("g_EA", fx->regDiffCount, fx->regDiff);
        failures += check_mem_diff("g_EA", fx->memDiffCount, fx->memDiff);
        uint32_t psw1 = register_get32(&cpu.psw.psw1);
        uint32_t psw2 = register_get32(&cpu.psw.psw2);
        if (psw1 != fx->psw1After) { printf("FAIL g_EA[%d]: psw1=%u expected %u\n", i, psw1, fx->psw1After); failures++; }
        if (psw2 != fx->psw2After) { printf("FAIL g_EA[%d]: psw2=%u expected %u\n", i, psw2, fx->psw2After); failures++; }
    }

    int n16 = (int)(sizeof(EA16_FIXTURES) / sizeof(EA16_FIXTURES[0]));
    for (int i = 0; i < n16; i++) {
        const Ea16Fixture *fx = &EA16_FIXTURES[i];
        load_baseline();
        DInstr v = make_v(&fx->opts);
        uint32_t ea = cpu_g_ea_16(&cpu, &v);
        total++;
        if (ea != fx->ea) {
            printf("FAIL g_EA_16[%d]: ea=%u expected %u\n", i, ea, fx->ea);
            failures++;
        }
        total += fx->regDiffCount + fx->memDiffCount;
        failures += check_reg_diff("g_EA_16", fx->regDiffCount, fx->regDiff);
        failures += check_mem_diff("g_EA_16", fx->memDiffCount, fx->memDiff);
    }

    load_baseline();
    int nx = (int)(sizeof(EXPAND_FIXTURES) / sizeof(EXPAND_FIXTURES[0]));
    total += nx;
    for (int i = 0; i < nx; i++) {
        const ExpandFixture *fx = &EXPAND_FIXTURES[i];
        uint32_t got = cpu_g_expand(&cpu, fx->ea, fx->bsrdsr);
        if (got != fx->result) {
            printf("FAIL g_EXPAND(%u,%d): %u != %u\n", fx->ea, fx->bsrdsr, got, fx->result);
            failures++;
        }
    }

    int nxd = (int)(sizeof(EXPAND_DSE_FIXTURES) / sizeof(EXPAND_DSE_FIXTURES[0]));
    total += nxd;
    for (int i = 0; i < nxd; i++) {
        const ExpandDseFixture *fx = &EXPAND_DSE_FIXTURES[i];
        uint32_t got = cpu_g_expand_dse(&cpu, fx->ea, fx->bsrdsr, fx->dseVal);
        if (got != fx->result) {
            printf("FAIL g_EXPAND_DSE(%u,%d,%u): %u != %u\n", fx->ea, fx->bsrdsr, fx->dseVal, got, fx->result);
            failures++;
        }
    }

    int ns = (int)(sizeof(SHIFTCNT_FIXTURES) / sizeof(SHIFTCNT_FIXTURES[0]));
    total += ns;
    for (int i = 0; i < ns; i++) {
        const ShiftCntFixture *fx = &SHIFTCNT_FIXTURES[i];
        uint32_t got = cpu_g_shift_cnt(&cpu, fx->hw1);
        if (got != fx->result) {
            printf("FAIL g_SHIFT_CNT(0x%x): %u != %u\n", fx->hw1, got, fx->result);
            failures++;
        }
    }

    int nca = (int)(sizeof(CCARITH_FIXTURES) / sizeof(CCARITH_FIXTURES[0]));
    total += nca;
    for (int i = 0; i < nca; i++) {
        const CcArithFixture *fx = &CCARITH_FIXTURES[i];
        cpu_compute_cc_arith(&cpu, fx->v1, fx->v2);
        int cc = (int)psw_get_cc(&cpu.psw);
        if (cc != fx->cc) {
            printf("FAIL computeCCarith(%u,%u): cc=%d expected %d\n", fx->v1, fx->v2, cc, fx->cc);
            failures++;
        }
    }

    int ncl = (int)(sizeof(CCLOGICAL_FIXTURES) / sizeof(CCLOGICAL_FIXTURES[0]));
    total += ncl;
    for (int i = 0; i < ncl; i++) {
        const CcLogicalFixture *fx = &CCLOGICAL_FIXTURES[i];
        cpu_compute_cc_logical(&cpu, fx->result);
        int cc = (int)psw_get_cc(&cpu.psw);
        if (cc != fx->cc) {
            printf("FAIL computeCClogical(%u): cc=%d expected %d\n", fx->result, cc, fx->cc);
            failures++;
        }
    }

    printf("%ld/%ld cpu EA/CC fixtures passed\n", total - failures, total);
    return failures == 0 ? 0 : 1;
}
