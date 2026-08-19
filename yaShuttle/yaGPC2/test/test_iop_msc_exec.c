/* Cross-checks the 49-instruction MSC instruction set (msc_instr_exec(),
 * which does its own internal decode, fused just like BCEInstruction#exec
 * — see test_iop_bce_exec.c's header comment) against the real
 * gpc/iop_msc_instr.coffee, driven through the same entry point
 * iop.coffee's execProcessors() uses (MSC#exec -> MSCInstruction#exec).
 *
 * Fixtures regenerated via:
 *   node test/gen_iop_instr_exec_fixtures.cjs msc NAME... > fixtures.json
 *   python3 test/gen_iop_instr_exec_fixtures_header.py fixtures.json \
 *     YAGPC_TEST_IOP_MSC_EXEC_FIXTURES_H > test/iop_msc_exec_fixtures.h
 */
#include <stdio.h>
#include <string.h>

#include "../src/cpu.h"
#include "../src/iop.h"
#include "iop_msc_exec_fixtures.h"

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

static uint32_t reg_val(int idx) {
    switch (idx) {
        case 0: return register_get32(&iop.regXmitEna);
        case 1: return register_get32(&iop.regRecvEna);
        case 2: return register_get32(&iop.regProgExcept);
        case 3: return register_get32(&iop.regBusyWait);
        case 4: return register_get32(&iop.regHalt);
        case 5: return register_get32(&iop.regIndicator);
        case 6: return register_get32(&iop.msc.regFailDisc);
        case 7: return register_get32(&iop.msc.regIntProg);
        default: return 0;
    }
}

int main(void) {
    int failures = 0;
    long total = 0;

    cpu_init(&cpu);
    iop_init(&iop, &cpu);
    msc_instr_table_init();

    int nSets = (int)(sizeof(IOP_EXEC_FIXTURE_SETS) / sizeof(IOP_EXEC_FIXTURE_SETS[0]));
    for (int s = 0; s < nSets; s++) {
        const IopExecFixtureSet *set = &IOP_EXEC_FIXTURE_SETS[s];
        for (int i = 0; i < set->count; i++) {
            const IopExecFixture *fx = &set->fixtures[i];
            load_baseline();
            iop.ls.curPage = fx->page;

            total += fx->lsDiffCount + fx->memDiffCount + 9;

            msc_instr_exec(&iop, fx->hw1, fx->hw2);

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
                uint32_t got = reg_val(r);
                if (got != fx->regVal[r]) {
                    printf("FAIL %s [%04x,%04x]: reg[%d]=%u expected %u\n", set->nm, fx->hw1, fx->hw2, r, got, fx->regVal[r]);
                    ok = 0;
                }
            }
            if (cpu.intPending.iopProg != fx->iopProgAfter) {
                printf("FAIL %s [%04x,%04x]: iopProg=%d expected %d\n", set->nm, fx->hw1, fx->hw2,
                       cpu.intPending.iopProg, fx->iopProgAfter);
                ok = 0;
            }
            if (!ok) failures++;
        }
    }

    printf("%ld/%ld iop MSC instr exec fixtures passed\n", total - failures, total);
    return failures == 0 ? 0 : 1;
}
