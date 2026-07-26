/* Cross-checks the 29-instruction BCE instruction set (bce_instr_exec(),
 * which does its own internal decode — there's no standalone decode to
 * validate separately, unlike cpu_instr.c) against the real
 * gpc/iop_bce_instr.coffee, driven through the same entry point
 * iop.coffee's execProcessors() uses (BCE#exec -> BCEInstruction#exec).
 *
 * #MOUTC is intentionally excluded from the fixture set: it and #MINC
 * both parse to mask=0/maskedVal=0 (neither pattern has a single literal
 * '0'/'1' bit), so JS's `opByMask[0][0] = desc` dict-insertion overwrites
 * #MOUTC's entry with #MINC's — #MOUTC is permanently unreachable via any
 * input in the real implementation (verified directly against the live
 * CoffeeScript; see iop_bce_instr.c's bce_instr_table_init comment for
 * the C-side replication of this shadowing).
 *
 * Fixtures regenerated via:
 *   node test/gen_iop_instr_exec_fixtures.cjs bce NAME... > fixtures.json
 *   python3 test/gen_iop_instr_exec_fixtures_header.py fixtures.json \
 *     YAGPC_TEST_IOP_BCE_EXEC_FIXTURES_H > test/iop_bce_exec_fixtures.h
 */
#include <stdio.h>
#include <string.h>

#include "../src/cpu.h"
#include "../src/iop.h"
#include "iop_bce_exec_fixtures.h"

const InstrDesc *instr_decode(uint32_t hw1, uint32_t hw2, DInstr *v) {
    (void)hw1; (void)hw2; (void)v;
    return NULL;
}

static CPU cpu;
static IOP iop;

static void load_baseline(void) {
    for (int p = 0; p <= 24; p++) {
        for (int r = 0; r <= 16; r++) {
            register_set32(registerfile_r(&iop.ls.storePage[p], r), IOP_EXEC_BASELINE.ls[p][r]);
        }
    }
    for (uint32_t a = 0; a < 4096; a++) {
        mcm_set16(&cpu.mainStorage, a, IOP_EXEC_BASELINE.mem[a], false);
    }
    memset(cpu.mainStorage.data + (size_t)4096 * 2, 0, (size_t)cpu.mainStorage.wordCount * 4 - (size_t)4096 * 2);
    memset(iop.mainStorage.data, 0, (size_t)iop.mainStorage.wordCount * 4);

    register_set32(&iop.regXmitEna, IOP_EXEC_BASELINE.regXmitEna);
    register_set32(&iop.regRecvEna, IOP_EXEC_BASELINE.regRecvEna);
    register_set32(&iop.regProgExcept, IOP_EXEC_BASELINE.regProgExcept);
    register_set32(&iop.regBusyWait, IOP_EXEC_BASELINE.regBusyWait);
    register_set32(&iop.regHalt, IOP_EXEC_BASELINE.regHalt);
    register_set32(&iop.regIndicator, IOP_EXEC_BASELINE.regIndicator);
    register_set32(&iop.msc.regFailDisc, IOP_EXEC_BASELINE.regFailDisc);
    register_set32(&iop.msc.regIntProg, IOP_EXEC_BASELINE.regIntProg);
    cpu.intPending.iopProg = false;
}

static const uint32_t *reg_ptr_val(int idx) {
    static uint32_t v;
    switch (idx) {
        case 0: v = register_get32(&iop.regXmitEna); break;
        case 1: v = register_get32(&iop.regRecvEna); break;
        case 2: v = register_get32(&iop.regProgExcept); break;
        case 3: v = register_get32(&iop.regBusyWait); break;
        case 4: v = register_get32(&iop.regHalt); break;
        case 5: v = register_get32(&iop.regIndicator); break;
        case 6: v = register_get32(&iop.msc.regFailDisc); break;
        case 7: v = register_get32(&iop.msc.regIntProg); break;
        default: v = 0; break;
    }
    return &v;
}

int main(void) {
    int failures = 0;
    long total = 0;

    cpu_init(&cpu);
    iop_init(&iop, &cpu);
    bce_instr_table_init();

    int nSets = (int)(sizeof(IOP_EXEC_FIXTURE_SETS) / sizeof(IOP_EXEC_FIXTURE_SETS[0]));
    for (int s = 0; s < nSets; s++) {
        const IopExecFixtureSet *set = &IOP_EXEC_FIXTURE_SETS[s];
        for (int i = 0; i < set->count; i++) {
            const IopExecFixture *fx = &set->fixtures[i];
            load_baseline();
            iop.ls.curPage = fx->page;

            total += fx->lsDiffCount + fx->memDiffCount + 8;

            bce_instr_exec(&iop, fx->hw1, fx->hw2);

            int ok = 1;
            for (int j = 0; j < fx->lsDiffCount; j++) {
                uint32_t got = register_get32(registerfile_r(&iop.ls.storePage[fx->lsDiff[j].page], fx->lsDiff[j].reg));
                if (got != fx->lsDiff[j].val) {
                    printf("FAIL %s [%04x,%04x] page=%d: ls[%d][%d]=%u expected %u\n", set->nm, fx->hw1, fx->hw2,
                           fx->page, fx->lsDiff[j].page, fx->lsDiff[j].reg, got, fx->lsDiff[j].val);
                    ok = 0;
                }
            }
            for (int j = 0; j < fx->memDiffCount; j++) {
                uint32_t got = mcm_get16(&cpu.mainStorage, fx->memDiff[j].addr);
                if (got != fx->memDiff[j].val) {
                    printf("FAIL %s [%04x,%04x]: mem[%u]=%u expected %u\n", set->nm, fx->hw1, fx->hw2,
                           fx->memDiff[j].addr, got, fx->memDiff[j].val);
                    ok = 0;
                }
            }
            for (int r = 0; r < 8; r++) {
                if (!fx->regChanged[r]) continue;
                uint32_t got = *reg_ptr_val(r);
                if (got != fx->regVal[r]) {
                    printf("FAIL %s [%04x,%04x]: reg[%d]=%u expected %u\n", set->nm, fx->hw1, fx->hw2, r, got, fx->regVal[r]);
                    ok = 0;
                }
            }
            if (!ok) failures++;
        }
    }

    printf("%ld/%ld iop BCE instr exec fixtures passed\n", total - failures, total);
    return failures == 0 ? 0 : 1;
}
