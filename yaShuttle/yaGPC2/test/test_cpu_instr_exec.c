/* Generic exec-body cross-check, reused across all 135 CPU instructions.
 * For each (hw1, hw2) fixture, re-decodes via instr_decode() (already
 * fully validated separately — see test_cpu_instr_decode.c) and calls
 * the matched InstrDesc's exec function directly (bypassing exec1/
 * interrupts/NIA-increment, which cpu.c's own tests cover), then checks
 * the resulting register/memory/PSW deltas against the real
 * gpc/cpu_instr.coffee.
 *
 * Fixtures regenerated via (NAME... = the instructions currently wired
 * into cpu_instr.c's OPS table):
 *   node test/gen_cpu_instr_exec_fixtures.cjs NAME... > fixtures.json
 *   python3 test/gen_cpu_instr_exec_fixtures_header.py fixtures.json > test/cpu_instr_exec_fixtures.h
 *
 * CVFX is a deliberate, hand-patched exception to "regenerated from
 * gpc": gpc's own fp_dispatch_exc (cpu.coffee) returns false for
 * CONVERT_OVERFLOW, so gpc's exec_CVFX bails out *before* writing the
 * result or updating CC -- confirmed (2026-08-01) to be the same root
 * cause as yagpc2-yahalmat2-issues.db's cvfx_overflow_truncation_rule
 * (issue #9): gpc's early-bail leaves stale state, which real Shuttle
 * flight software (FPMSDERR.asm) proved wrong to replicate, since
 * yaGPC2's exec_CVFX (src/cpu_instr.c) was deliberately fixed to always
 * store the result and always compute CC instead. The 300 raw
 * EXEC_FIXTURES_CVFX entries below still come from an unmodified gpc
 * run; of the entries whose gpc-recorded regDiffCount is 0 (i.e.
 * CONVERT_OVERFLOW cases gpc silently no-op'd), whichever ones actually
 * differ from what yaGPC2's own already-verified-correct exec_CVFX
 * produces (69 of 136 as of the 2026-08-19 PSW2-fix regeneration; the
 * other 67 already happened to match) have had their psw1After
 * hand-corrected from gpc's stale baseline-CC value. Regenerating CVFX
 * from gpc without reapplying this correction (`make test`'s failure
 * list names the exact (hw1,hw2) pairs) will silently reintroduce these
 * failures. */
#include <stdio.h>
#include <string.h>

#include "../src/cpu_instr.h"
#include "../src/iop.h"
#include "cpu_instr_exec_fixtures.h"

static CPU cpu;
static IOP iop;
static MCM iopMcm;
static MemoryBus bus;

/* PC is the only instruction that calls into the IOP so far. A real IOP
 * is wired up (cpu.iop) because EXEC_BASELINE's problem-state bit reads
 * as supervisor (see regmem.c's PSW2 field-layout fix), so PC's own
 * fixtures now genuinely reach cpu_send_to_iop instead of bailing out on
 * the privilege check beforehand -- without this, iop_recv_from_cpu
 * dereferences a NULL cpu->iop. */

static void load_baseline(void) {
    for (int bank = 0; bank < 3; bank++) {
        for (int i = 0; i <= 8; i++) {
            register_set32(registerfile_r(&cpu.regFiles[bank], i), EXEC_BASELINE.regs[bank][i]);
        }
        for (int i = 0; i < 4; i++) {
            registerfile_set_dse(&cpu.regFiles[bank], i, EXEC_BASELINE.dse[bank][i]);
        }
    }
    for (uint32_t a = 0; a < 4096; a++) {
        mcm_set16(&cpu.mainStorage, a, EXEC_BASELINE.mem[a], false);
    }
    /* Zero everything outside the tracked window (both MCMs) — mirrors
     * the JS generator's restore(); see its comment for why this must
     * match exactly (otherwise a discarded-from-fixtures JS trial's
     * leaked write silently diverges from this replay-only-kept-fixtures
     * C test). */
    memset(cpu.mainStorage.data + (size_t)4096 * 2, 0, (size_t)cpu.mainStorage.wordCount * 4 - (size_t)4096 * 2);
    memset(iopMcm.data, 0, (size_t)iopMcm.wordCount * 4);
    register_set32(&cpu.psw.psw1, EXEC_BASELINE.psw1);
    register_set32(&cpu.psw.psw2, EXEC_BASELINE.psw2);
}

int main(void) {
    int failures = 0;
    long total = 0;

    cpu_init(&cpu);
    iopMcm = mcm_create(24 * 1024);
    bus = membus_create(&cpu.mainStorage, &iopMcm);
    cpu.ram = &bus;
    iop_init(&iop, &cpu);
    cpu.iop = &iop;

    int nSets = (int)(sizeof(EXEC_FIXTURE_SETS) / sizeof(EXEC_FIXTURE_SETS[0]));
    for (int s = 0; s < nSets; s++) {
        const ExecFixtureSet *set = &EXEC_FIXTURE_SETS[s];
        for (int i = 0; i < set->count; i++) {
            const ExecFixture *fx = &set->fixtures[i];
            load_baseline();

            total += fx->regDiffCount + fx->memDiffCount + 2;

            DInstr v;
            const InstrDesc *desc = instr_decode(fx->hw1, fx->hw2, &v);
            if (!desc || !desc->e) {
                printf("FAIL %s [%04x,%04x]: decode/exec missing\n", set->nm, fx->hw1, fx->hw2);
                failures++;
                continue;
            }
            desc->e(&cpu, &v);

            int ok = 1;
            for (int j = 0; j < fx->regDiffCount; j++) {
                uint32_t got = register_get32(registerfile_r(&cpu.regFiles[fx->regDiff[j].bank], fx->regDiff[j].idx));
                if (got != fx->regDiff[j].val) {
                    printf("FAIL %s [%04x,%04x]: reg[%d][%d]=%u expected %u\n", set->nm, fx->hw1, fx->hw2,
                           fx->regDiff[j].bank, fx->regDiff[j].idx, got, fx->regDiff[j].val);
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
            uint32_t psw1 = register_get32(&cpu.psw.psw1);
            uint32_t psw2 = register_get32(&cpu.psw.psw2);
            if (psw1 != fx->psw1After) {
                printf("FAIL %s [%04x,%04x]: psw1=%u expected %u\n", set->nm, fx->hw1, fx->hw2, psw1, fx->psw1After);
                ok = 0;
            }
            if (psw2 != fx->psw2After) {
                printf("FAIL %s [%04x,%04x]: psw2=%u expected %u\n", set->nm, fx->hw1, fx->hw2, psw2, fx->psw2After);
                ok = 0;
            }
            if (!ok) failures++;
        }
    }

    printf("%ld/%ld cpu instr exec fixtures passed\n", total - failures, total);
    return failures == 0 ? 0 : 1;
}
