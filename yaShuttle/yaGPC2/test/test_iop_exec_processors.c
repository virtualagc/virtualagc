/* Integration-level coverage for iop_exec_processors() (src/iop.c) — the
 * per-tick fetch/dispatch/advance loop used by the real run() pipeline
 * (ap101.c calls iop_exec() -> iop_exec_processors() once per tick).
 *
 * Unlike the exec-fixture tests (test_iop_bce_exec.c / test_iop_msc_exec.c),
 * which call bce_instr_exec()/msc_instr_exec() directly and so cannot see
 * anything iop_exec_processors() itself gets wrong, these tests drive the
 * full per-tick loop across multiple ticks to confirm PC/NIA sequencing —
 * branches, multi-halfword instruction advances, and the intentional
 * "wait"/"stall" cases — actually take effect end-to-end. This exercises
 * two bugs found and fixed in iop_exec_processors():
 *
 * 1. PC was fetched/advanced via Register's 16-bit accessor while every
 *    instruction's own NIA update (iop_set_nia/iop_incr_nia, #BU/#BU@)
 *    uses the 32-bit accessor on the same register — for any address
 *    under 0x10000 (every real address in this system), the two
 *    accessors read/write different halfwords of the same register, so
 *    the fetch loop never saw what an instruction had just set.
 * 2. Independently, this function used to force BCE's PC to
 *    (pre-dispatch PC)+1 unconditionally after every dispatch, discarding
 *    whatever the matched instruction had actually set — so even with
 *    bug 1 fixed, branches and multi-halfword instructions still
 *    wouldn't have taken effect.
 *
 * Both are confirmed inherited from gpc/iop.coffee's execProcessors
 * (`@ls.PC().get16()`/`.set16(pc+1)` vs setNIA/incrNIA's `.get32()`),
 * not porting mistakes — see this project's problems.md.
 *
 * Also covers problems.md 1.5 (IOP.curPE never reassigned): `t->curPE`
 * ("MSC = 0, BCE = 1-24") is used throughout iop_bce_instr.c for
 * "2*curPE" addressing offsets and per-PE bit indexing, but was never
 * updated from its constructor-time 0 — every BCE beyond BCE 1 computed
 * those offsets as if it were BCE 0. Like 1.5's bugs, this can't be seen
 * by the exec-fixture tests (which call bce_instr_exec() directly, with
 * curPE fixed at whatever the harness leaves it) — only a full
 * multi-BCE run through iop_exec_processors() exercises it.
 */
#include <stdio.h>

#include "../src/cpu.h"
#include "../src/iop.h"

/* cpu.c references instr_decode() (normally cpu_instr.c) but nothing here
 * ever executes CPU instructions, only IOP/BCE/MSC ones — stub it out
 * rather than pulling in cpu_instr.c, matching test_iop_bce_exec.c and
 * test_iop_msc_exec.c's identical stub. */
const InstrDesc *instr_decode(uint32_t hw1, uint32_t hw2, DInstr *v) {
    (void)hw1; (void)hw2; (void)v;
    return NULL;
}

static int failures = 0;

static void check(const char *label, uint32_t got, uint32_t want) {
    if (got != want) {
        printf("FAIL %s: got 0x%x, want 0x%x\n", label, got, want);
        failures++;
    }
}

/* Runs iop_exec_processors() until `page` has been visited `visits` times
 * (the round-robin wheel only reaches a given BCE/MSC page on a fraction
 * of ticks), returning PC(page) after the last such visit. */
static uint32_t run_until_visits(IOP *iop, int page, int visits) {
    uint32_t pcAfter = 0;
    for (int seen = 0; seen < visits;) {
        iop_exec_processors(iop);
        if (iop->ls.curPage == page) {
            seen++;
            int save = iop->ls.curPage;
            iop->ls.curPage = page;
            pcAfter = register_get32(iopls_PC(&iop->ls));
            iop->ls.curPage = save;
        }
    }
    return pcAfter;
}

/* Per-processor status bits are IBM-numbered (iop.h), and regHalt is the
 * ENABLE direction -- a processor runs when its bit is SET -- so these
 * tests enable the processor they mean to run rather than relying on a
 * zeroed register meaning "not halted", which is what it used to mean. */
static void enable_proc(IOP *iop, int p) { iop_proc_set(&iop->regHalt, p, 1); }

static void setup(CPU *cpu, IOP *iop) {
    cpu_init(cpu);
    iop_init(iop, cpu);
}

/* #BU (branch unconditional, opcode 0xF0) at halfword 0x10 targeting
 * 0x40; a marker word (a genuinely unrecognized BCE opcode) sits at the
 * target so a second visit's fetch is observable via the "no further
 * advance" stall behavior tested separately below — here we only check
 * that the branch itself took effect. */
static void test_bce_branch_takes_effect(void) {
    CPU cpu;
    IOP iop;
    setup(&cpu, &iop);

    uint32_t addr = 0x10, target = 0x40;
    uint32_t word = (0xF0u << 24) | (target & 0x3ffffu);
    mcm_set16(&cpu.mainStorage, addr, (word >> 16) & 0xffff, false);
    mcm_set16(&cpu.mainStorage, addr + 1, word & 0xffff, false);

    iop.ls.curPage = 1;
    register_set32(iopls_PC(&iop.ls), addr);
    iop.ls.curPage = 0;
    enable_proc(&iop, 1);
    iop_proc_set(&iop.regBusyWait, 1, 1);

    uint32_t pc = run_until_visits(&iop, 1, 1);
    check("bce_branch: PC after #BU", pc, target);
}

/* Two distinct #LTOI-style short instructions (BCE "load to output", a
 * single-halfword register instruction) at consecutive addresses, each
 * loading a different immediate into MTO so the two visits are
 * distinguishable. #LTOI: "10110ddddddddddd". */
static void test_bce_sequential_advance(void) {
    CPU cpu;
    IOP iop;
    setup(&cpu, &iop);

    uint32_t marker1 = 0x111, marker2 = 0x222;
    mcm_set16(&cpu.mainStorage, 0, (uint32_t)(0x16u << 11) | marker1, false);
    mcm_set16(&cpu.mainStorage, 1, (uint32_t)(0x16u << 11) | marker2, false);

    iop.ls.curPage = 1;
    register_set32(iopls_PC(&iop.ls), 0);
    iop.ls.curPage = 0;
    enable_proc(&iop, 1);
    iop_proc_set(&iop.regBusyWait, 1, 1);

    run_until_visits(&iop, 1, 1);
    iop.ls.curPage = 1;
    uint32_t mto1 = register_get32(iopls_MTO(&iop.ls));
    iop.ls.curPage = 0;
    check("bce_sequential: MTO after 1st #LTOI", mto1, marker1);

    uint32_t pc2 = run_until_visits(&iop, 1, 1);
    iop.ls.curPage = 1;
    uint32_t mto2 = register_get32(iopls_MTO(&iop.ls));
    iop.ls.curPage = 0;
    check("bce_sequential: PC after 2nd #LTOI", pc2, 2);
    check("bce_sequential: MTO after 2nd #LTOI", mto2, marker2);
}

/* #WIX ("Wait for Index"/Listen command, IBM-74-A31-016 Table 2-10) must
 * leave NIA untouched while genuinely waiting (regXmitEna clear, no MIA
 * listen data available — mia_data_available() is unconditionally false
 * in this port) — repeated visits must re-fetch the same #WIX
 * instruction, not silently advance past it. #WIX: "00100ddddddddddd". */
static void test_bce_wix_waits(void) {
    CPU cpu;
    IOP iop;
    setup(&cpu, &iop);

    mcm_set16(&cpu.mainStorage, 0x20, (uint32_t)(0x04u << 11), false);

    iop.ls.curPage = 1;
    register_set32(iopls_PC(&iop.ls), 0x20);
    iop_proc_set(&iop.regXmitEna, 1, 0);
    iop.ls.curPage = 0;
    enable_proc(&iop, 1);
    iop_proc_set(&iop.regBusyWait, 1, 1);

    uint32_t pc = run_until_visits(&iop, 1, 5);
    check("bce_wix: PC stays parked while waiting", pc, 0x20);
}

/* A BCE opcode word that matches no entry in the dispatch table must
 * leave NIA untouched (documented as intentionally asymmetric with MSC's
 * unrecognized-instruction handling — see iop_bce_instr.c/iop_msc_instr.c
 * comments) — this used to be masked by the very bug being tested here
 * (an external unconditional +1 that ran regardless of dispatch outcome). */
static void test_bce_unknown_instruction_stalls(void) {
    CPU cpu;
    IOP iop;
    setup(&cpu, &iop);

    mcm_set16(&cpu.mainStorage, 0x30, 0x0000, false); /* matches no BCE opcode */

    iop.ls.curPage = 1;
    register_set32(iopls_PC(&iop.ls), 0x30);
    iop.ls.curPage = 0;
    enable_proc(&iop, 1);
    iop_proc_set(&iop.regBusyWait, 1, 1);

    uint32_t pc = run_until_visits(&iop, 1, 3);
    check("bce_unknown: PC stays parked on unrecognized opcode", pc, 0x30);
}

/* @L (MSC "load", opcode 0100) at halfwords 0 and 1 with distinct
 * PC-relative displacements, each loading ACC from a distinct marker
 * memory location — confirms MSC's fetch address actually advances
 * (rather than being frozen at its initial value forever, which is what
 * the 16-vs-32-bit accessor bug caused: MSC has no default-increment
 * fallback at all, so that bug was a *complete* stall, worse than BCE's
 * "just free-runs on a fake counter" symptom). */
static void test_msc_sequential_advance(void) {
    CPU cpu;
    IOP iop;
    setup(&cpu, &iop);

    mcm_set16(&cpu.mainStorage, 0, 0x400au, false); /* @L d=10 (non-indexed) */
    mcm_set16(&cpu.mainStorage, 1, 0x4013u, false); /* @L d=19 (non-indexed) */
    mcm_set16(&cpu.mainStorage, 10, 0xAAAA, false); /* marker for addr 0's load (ea=0+10) */
    /* ea=1+19=20 (must be even: mcm_get32 masks the low address bit for
     * word-aligned fullword access, per gpc/mcm.coffee's get32 doing the
     * same `addr & 0x7fffe` — confirmed real, not a bug, while writing
     * this test). */
    mcm_set16(&cpu.mainStorage, 20, 0xBBBB, false); /* marker for addr 1's load (ea=1+19) */

    iop.ls.curPage = 0;
    register_set32(iopls_PC(&iop.ls), 0);
    enable_proc(&iop, 0);
    iop_proc_set(&iop.regBusyWait, 0, 1);

    run_until_visits(&iop, 0, 1);
    uint32_t acc1 = iopls_getACC(&iop.ls) >> 16;
    check("msc_sequential: ACC after 1st @L", acc1, 0xAAAA);

    uint32_t pc2 = run_until_visits(&iop, 0, 1);
    uint32_t acc2 = iopls_getACC(&iop.ls) >> 16;
    check("msc_sequential: PC after 2nd @L", pc2, 2);
    check("msc_sequential: ACC after 2nd @L", acc2, 0xBBBB);
}

/* #LTO ("load to output", opcode 0x17) on BCE #3 (curPage=3): its address
 * is the UPDATED PC plus the displacement plus 2*curPE, forced even. With
 * curPE correctly tracking the running BCE (3), d=4, PC=0x10, the true ea
 * is (0x10+1+4+6) & ~1 = 0x1A; the bug's constant curPE=0 would instead
 * read 0x14. Markers at both addresses distinguish the two outcomes
 * conclusively rather than just checking "some value changed."
 *
 * #LTO reads a FULLWORD and keeps the low 18 bits, a local store word
 * being 18 bits wide, so each marker goes in the SECOND halfword of its
 * fullword -- the first would be masked away. #LTO: "10111ddddddddddd". */
static void test_bce_curpe_addressing(void) {
    CPU cpu;
    IOP iop;
    setup(&cpu, &iop);

    uint32_t d = 4, addr = 0x10, bcePage = 3;
    uint32_t word = (uint32_t)(0x17u << 11) | d;
    mcm_set16(&cpu.mainStorage, addr, word, false);
    mcm_set16(&cpu.mainStorage, 0x15, 0xDEAD, false); /* what curPE=0 (the bug) would read */
    mcm_set16(&cpu.mainStorage, 0x1B, 0xCCCC, false); /* what curPE=3 (correct) should read */

    iop.ls.curPage = (int)bcePage;
    register_set32(iopls_PC(&iop.ls), addr);
    iop.ls.curPage = 0;
    enable_proc(&iop, (int)bcePage);
    iop_proc_set(&iop.regBusyWait, (int)bcePage, 1);

    run_until_visits(&iop, (int)bcePage, 1);
    iop.ls.curPage = (int)bcePage;
    uint32_t mto = register_get32(iopls_MTO(&iop.ls));
    iop.ls.curPage = 0;
    check("bce_curpe: curPE used for #LTO's addressing offset", mto, 0xCCCC);
}

int main(void) {
    test_bce_branch_takes_effect();
    test_bce_sequential_advance();
    test_bce_wix_waits();
    test_bce_unknown_instruction_stalls();
    test_msc_sequential_advance();
    test_bce_curpe_addressing();

    if (failures == 0) {
        printf("iop_exec_processors integration tests: all passed\n");
    } else {
        printf("iop_exec_processors integration tests: %d FAILURE(S)\n", failures);
    }
    return failures == 0 ? 0 : 1;
}
