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
/* WHICH REFERENCE, AND THE PATCHES TO IT (2026-09-22).  Generated against
 * the LIVE gpc -- YAGPC_REF_ROOT=~/donschmidt/nsts-sim-gpc, NODE_PATH set
 * to its node_modules, its tsconfig.json present so esbuild resolves
 * `com/lru` -- from a copy carrying the patches below, every one a place
 * where the reference is wrong and this emulator is right.  The patches are
 * checked in and applied by test/make_patched_ref.sh, which also documents
 * the regeneration commands; running it and regenerating reproduces this
 * header byte for byte.  They used to live only in a scratch copy under
 * /tmp, where losing them would have cost a day of re-derivation:
 *
 *   SVC: the effective address is 19 bits and the interrupt-code field is
 *   16, and AP-101S PoO 2.5.1.1 saves the 4-bit extension in the old PSW's
 *   bits 40-43 (DESC2's 'e').  The reference drops it, so FPMSVC rebuilds
 *   every parameter-list address issued from sector 2 or above one to
 *   seven sectors low -- see exec_SVC.  317 fixtures.
 *
 *   CVFX: a real CVFX completes and stores its result before any interrupt
 *   is taken; the reference returns without storing on a floating-point
 *   exception, leaving the destination register holding whatever it held
 *   before -- see exec_CVFX.  136 fixtures.
 *
 *   g_EA, B2 == 11: AP-101S PoO 2.2.8 on the extended RS form -- "When B2
 *   equals 11, base addressing is not performed.  In this case, the
 *   displacement is instead used DIRECTLY AS THE EFFECTIVE ADDRESS" -- so
 *   there is no 16-bit address left for 2.9 to expand.  cpu_g_ea carries
 *   the same rule with its evidence (every such operand in FCMSSYNC equals
 *   its symbol's address exactly, bit-15 ones included) and the note that
 *   gpc expands here, an inherited defect.  Branches are excluded.  About
 *   460 fixtures across two dozen instructions.
 *
 *   g_EA, FULLWORD-INDIRECT POST-INDEXING (ia=1, ii=1): the pointer's own
 *   high bit decides whether a sector is applied AT ALL -- Sec. 2.9, and
 *   Figure 2-17's expansion flowchart, whose leaves are EXPAND USING DSR /
 *   DSV / DSE / *0000*, that last one being this case -- and the index
 *   addition is 16-bit and includes that bit ("All EA/BA address
 *   calculations involve 16-bit operands and bit 0 of the fullword indirect
 *   address pointer is included", note under Figure 2-15).  The reference
 *   strips bit 15 and forces a sector unconditionally, so a pointer to
 *   sector 0 reads from sector DSV instead; cpu_g_ea carries the measured
 *   evidence (DCI#CON's ZCON at 0x42845, and the -0602 / FFFFFFFFFF that
 *   GPC MEMORY showed because of it).  24 fixtures.
 *
 *   BAL and SCAL, the LINK SNAPSHOT: psw1 carries the caller's BSR/DSR
 *   alongside the return address, and g_EA can replace both from a C=1
 *   fullword indirect pointer (Fig. 2-17, "MODIFY PSW ACTION") before it
 *   returns.  The reference reads psw1 AFTER g_EA and so saves the
 *   CALLEE's sectors, which BCRE then "restores" into the caller -- see
 *   exec_BAL for the FCMSSYNC/FCMTRACE measurement that found it.  Both
 *   snapshot before the EA here.  2 fixtures (BAL; no SCAL fixture drew
 *   the case, but the reference had the same defect and was patched too).
 *
 *   MVS: the result is the MIDVALUE of R1, R1+1 and storage; the
 *   reference clamps R1 between the other two, which differs whenever
 *   R1+1 < storage -- GMDRES's resolver fold, ledger #264.  109 fixtures.
 *   mvs_directed() below adds the flight-code case and every ordering.
 *
 * All 111363 fixtures pass.
 */
#include <stdio.h>
#include <string.h>

#include "../src/cpu_instr.h"
#include "../src/iop.h"
#include "cpu_instr_exec_fixtures.h"

static CPU cpu;
static IOP iop;
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
    /* Zero everything outside the tracked window — mirrors the JS
     * generator's restore(); see its comment for why this must match
     * exactly (otherwise a discarded-from-fixtures JS trial's leaked write
     * silently diverges from this replay-only-kept-fixtures C test). */
    memset(cpu.mainStorage.data + (size_t)4096 * 2, 0, (size_t)cpu.mainStorage.wordCount * 4 - (size_t)4096 * 2);
    register_set32(&cpu.psw.psw1, EXEC_BASELINE.psw1);
    register_set32(&cpu.psw.psw2, EXEC_BASELINE.psw2);
}


/* MVS by hand: every ordering of three distinct values, and the exact
 * operands GMDRES hands it (F0 = -pi, F1 = dtheta, storage = +pi), where the
 * clamp the reference performs gave +pi and froze every IMU delta at -2pi. */
static int mvs_one(uint32_t r1, uint32_t r1p1, uint32_t mem, uint32_t want, uint32_t wantCC) {
    load_baseline();
    register_set32(cpu_f(&cpu, 0), r1);
    register_set32(cpu_f(&cpu, 1), r1p1);
    mcm_set16(&cpu.mainStorage, 0x100, mem >> 16, false);
    mcm_set16(&cpu.mainStorage, 0x101, mem & 0xffff, false);
    DInstr v;
    const InstrDesc *desc = instr_decode(0x60FB, 0x0100, &v);   /* MVS 0,X'0100' (B2 = 11: direct) */
    desc->e(&cpu, &v);
    uint32_t got = register_get32(cpu_f(&cpu, 0)), cc = psw_get_cc(&cpu.psw);
    uint32_t keep = register_get32(cpu_f(&cpu, 1));
    if (got != want || cc != wantCC || keep != r1p1) {
        printf("FAIL MVS directed (%08x,%08x,%08x): F0=%08x cc=%u F1=%08x, expected %08x cc=%u\n",
               r1, r1p1, mem, got, cc, keep, want, wantCC);
        return 1;
    }
    return 0;
}

static int mvs_directed(void) {
    const uint32_t NPI = 0xc13243f6, PPI = 0x413243f6, DTH = 0x3d648800;   /* -pi, +pi, 9.8e-5 */
    const uint32_t A = 0xc1100000, B = 0x41100000, C = 0x41200000;         /* -1, 1, 2 */
    int f = 0;
    f += mvs_one(NPI, DTH, PPI, DTH, 1);    /* GMDRES */
    f += mvs_one(B, C, A, B, 0);            /* limiter: within */
    f += mvs_one(C, B, A, B, 1);            /* limiter: above upper */
    f += mvs_one(A, C, B, B, 3);            /* limiter: below lower */
    f += mvs_one(A, B, C, B, 1);            /* inverted limits: midvalue in R1+1 */
    f += mvs_one(C, A, B, B, 3);            /* inverted limits: midvalue in storage */
    f += mvs_one(B, A, C, B, 0);            /* inverted limits: midvalue in R1 */
    f += mvs_one(B, B, A, B, 0);            /* tie goes to R1 */
    return f;
}

/* MR 4,6 with -1.0 x -1.0, the one product a Q31 multiply cannot hold.  The
 * overflow INDICATOR is set either way; the fixed-point-overflow program
 * check (code 0004) is taken only when the PSW's mask bit allows it -- POO
 * 4.21 lists "Fixed point overflow" under PROGRAM INTERRUPTS.  Multiply and
 * divide used to set the indicator alone, so the check was never taken
 * (ledger #265; upstream gpc c49530b). */
static int overflow_one(int mask) {
    load_baseline();
    register_set32(cpu_r(&cpu, 4), 0x80000000u);
    register_set32(cpu_r(&cpu, 6), 0x80000000u);
    psw_set_overflow(&cpu.psw, 0);
    psw_set_fixed_pt_overflow(&cpu.psw, (uint32_t)mask);
    cpu.intPending.programCheck = false;
    cpu.intCode = 0;
    DInstr v;
    const InstrDesc *desc = instr_decode(0x44E6, 0x0000, &v);   /* MR 4,6 */
    desc->e(&cpu, &v);
    int ind = (int)psw_get_overflow(&cpu.psw), pc = cpu.intPending.programCheck;
    if (ind != 1 || pc != mask || (mask && cpu.intCode != 0x0004)) {
        printf("FAIL MR overflow, mask %d: indicator %d, program check %d, code %04x\n",
               mask, ind, pc, cpu.intCode);
        return 1;
    }
    return 0;
}

int main(void) {
    int failures = 0;
    long total = 0;

    cpu_init(&cpu);
    bus = membus_create(&cpu.mainStorage);
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

    int mvsFail = mvs_directed();
    printf("%d/8 MVS directed cases passed\n", 8 - mvsFail);
    failures += mvsFail;
    int ovfFail = overflow_one(0) + overflow_one(1);
    printf("%d/2 multiply overflow interrupt cases passed\n", 2 - ovfFail);
    failures += ovfFail;

    printf("%ld/%ld cpu instr exec fixtures passed\n", total - failures, total);
    return failures == 0 ? 0 : 1;
}
