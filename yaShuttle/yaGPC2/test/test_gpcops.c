/* Verifies three pieces of the Shuttle-sim integration work (see
 * ../src/yaGpcIntegration.h and its plan-mode discussion history):
 *
 *  1. yaGPC2_ops (../src/gpcops.c) supports multiple fully independent
 *     GpcState instances in one process -- the concrete, checkable
 *     definition of "no hidden global state" for that refactor.
 *  2. The servicer wiring into iop.c's MIA stub round-trips real data
 *     both directions, exercising the same iop_queue_dma()/
 *     iop_exec_dma_queue()/mia_xmit_cmd() paths #TDS/#RDS/#CMD/#CMDI
 *     themselves use, while confirming the no-servicer-installed case
 *     is still byte-for-byte the original inert stub.
 *  3. yagpc2_engine() prints a trace line exactly when
 *     AGEHarness.htraceWanted is set (and nothing when it isn't) --
 *     the mechanism a driver relies on to get 'htrace'-equivalent
 *     output without owning any snapshot/diff/format logic itself.
 *
 * Run from the repo root (as `make test` does) -- fixture path below is
 * relative to that. */
#define _POSIX_C_SOURCE 200809L /* fileno(), dup(), dup2() -- see capture_engine_output_bytes() */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "../src/ageharness.h"
#include "../src/gpcops.h"

static int failures = 0;

#define CHECK(cond, msg)                                          \
    do {                                                          \
        if (!(cond)) {                                            \
            printf("FAIL: %s\n", msg);                            \
            failures++;                                           \
        }                                                         \
    } while (0)

/* ---------------------------------------------------------------------
 * 1. Two-instance independence
 * ------------------------------------------------------------------- */

static void test_two_instance_independence(void) {
    GpcState a = {.gpcID = 1}, b = {.gpcID = 2};
    CHECK(yaGPC2_ops.initializer(&a, "test/fixtures/hello.fcm", "test/fixtures/hello-lnk101.json"),
          "instance A initializer succeeded");
    CHECK(yaGPC2_ops.initializer(&b, "test/fixtures/hello.fcm", "test/fixtures/hello-lnk101.json"),
          "instance B initializer succeeded");
    CHECK(a.impl != NULL && b.impl != NULL, "both instances got a non-NULL impl");
    CHECK(a.impl != b.impl, "instances have distinct impl allocations");

    AGEHarness *ageA = (AGEHarness *)a.impl;
    AGEHarness *ageB = (AGEHarness *)b.impl;

    /* Step A ten times, B not at all; confirm B's state (registers,
     * memory, step count, elapsed time) stayed completely untouched --
     * the only way that's possible is if there's no shared/global state
     * between the two AP101 instances. */
    for (int i = 0; i < 10; i++) yaGPC2_ops.engine(&a);

    CHECK(a.elapsedTime > 0.0, "instance A accumulated elapsed time after stepping");
    CHECK(b.elapsedTime == 0.0, "instance B's elapsed time untouched by stepping A");
    CHECK(ageA->stepCount == 10, "instance A stepped 10 times");
    CHECK(ageB->stepCount == 0, "instance B step count untouched by stepping A");

    RegSnapshot snapA, snapB;
    ageharness_snapshot_regs(ageA, &snapA);
    ageharness_snapshot_regs(ageB, &snapB);
    CHECK(snapA.nia != snapB.nia, "instance A's NIA advanced away from B's (still at its own start)");

    /* Now step B past A's current step count and confirm A is
     * unaffected in the other direction too. */
    for (int i = 0; i < 20; i++) yaGPC2_ops.engine(&b);
    CHECK(ageB->stepCount == 20, "instance B stepped 20 times");
    CHECK(ageA->stepCount == 10, "instance A step count untouched by stepping B");

    RegSnapshot snapA2;
    ageharness_snapshot_regs(ageA, &snapA2);
    CHECK(snapA2.nia == snapA.nia, "instance A's NIA unchanged while B was stepped");

    ageharness_free(ageA);
    ageharness_free(ageB);
    free(ageA);
    free(ageB);
}

/* ---------------------------------------------------------------------
 * 2. Servicer round-trip
 * ------------------------------------------------------------------- */

typedef struct {
    uint32_t words[16];
    int count;
    uint32_t lastCmdWord;
    int lastCmdAddress;
    int lastBusID;
} FakeServicer;

static bool fake_servicer(GpcState *state, GpcServiceNumber svc, GpcServiceArgs *args) {
    FakeServicer *fs = (FakeServicer *)state->impl;
    fs->lastBusID = args->busID;
    switch (svc) {
        case GPC_SVC_XMIT_WORD:
            fs->words[fs->count++] = args->word;
            return true;
        case GPC_SVC_XMIT_CMD:
            fs->lastCmdWord = args->word;
            fs->lastCmdAddress = args->address;
            return true;
        case GPC_SVC_RECV_POLL:
            return fs->count > 0;
        case GPC_SVC_RECV_WORD:
            if (fs->count == 0) return false;
            args->word = fs->words[0];
            memmove(fs->words, fs->words + 1, (size_t)(--fs->count) * sizeof(uint32_t));
            return true;
    }
    return false;
}

static void test_servicer_roundtrip(void) {
    CPU cpu;
    IOP iop;
    cpu_init(&cpu);
    iop_init(&iop, &cpu);

    /* No servicer installed: confirm the exact original inert-stub
     * behavior is still exactly what it was before this refactor. */
    CHECK(mia_data_available(&iop, &iop.bce[0].mia) == false, "no-servicer: data_available is false");
    CHECK(mia_get_data(&iop, &iop.bce[0].mia) == 0, "no-servicer: get_data is 0");
    mia_xmit_word(&iop, &iop.bce[0].mia, 0x1234); /* must not crash; no observable effect to check */
    mia_xmit_cmd(&iop, &iop.bce[0].mia, 0x1234);

    FakeServicer fs;
    memset(&fs, 0, sizeof fs);
    GpcState svcState = {.impl = &fs};
    iop_set_servicer(&iop, fake_servicer, &svcState);

    /* #CMD/#CMDI-style: mia_xmit_cmd, IUA in bits 19-23. */
    uint32_t cmd = (0x05u << 19) | 0x01234u;
    mia_xmit_cmd(&iop, &iop.bce[2].mia, cmd); /* bce[2] = BCE #3 */
    CHECK(fs.lastCmdWord == cmd, "servicer received the exact command word");
    CHECK(fs.lastCmdAddress == 5, "servicer decoded IUA=5 from the command word's top bits");
    CHECK(fs.lastBusID == 3, "servicer saw busID == BCE number (3)");

    /* #TDS-style: iop_queue_dma(DMA_READ) + iop_exec_dma_queue() is
     * exactly what exec_TDS/exec_TDL/exec_TDLI themselves do. */
    mcm_set16(&cpu.mainStorage, 100, 0xbeef, false);
    BCE *bce1 = &iop.bce[0]; /* BCE #1 */
    iop_queue_dma(&iop, 100, DMA_READ, bce1);
    iop_exec_dma_queue(&iop);
    CHECK(fs.count == 1 && fs.words[0] == 0xbeefu, "transmitted word round-tripped to the servicer");
    CHECK(fs.lastBusID == 1, "transmit-path servicer call saw busID == BCE number (1)");

    /* #RDS-style: iop_queue_dma(DMA_WRITE) + iop_exec_dma_queue() is
     * what exec_RDS/exec_RDL/exec_RDLI do; the pending word above (from
     * the servicer's own buffer) should land in main storage. */
    iop_queue_dma(&iop, 200, DMA_WRITE, bce1);
    iop_exec_dma_queue(&iop);
    uint32_t got = mcm_get16(&cpu.mainStorage, 200);
    CHECK(got == 0xbeefu, "received word round-tripped from the servicer into main storage");
    CHECK(fs.count == 0, "servicer's buffer drained by the receive");

    iop_free(&iop);
    cpu_free(&cpu);
}

/* ---------------------------------------------------------------------
 * 3. htraceWanted-driven engine output
 * ------------------------------------------------------------------- */

/* Redirects stdout to a tmpfile() for the duration of one yaGPC2_ops.engine()
 * call, capturing what it printed into out (NUL-terminated, truncated to
 * outSize-1 if longer); returns the number of bytes actually printed
 * (which may exceed what fit in out). */
static long capture_engine_output(GpcState *state, char *out, size_t outSize) {
    fflush(stdout);
    FILE *tmp = tmpfile();
    int savedFd = dup(fileno(stdout));
    dup2(fileno(tmp), fileno(stdout));

    yaGPC2_ops.engine(state);

    fflush(stdout);
    dup2(savedFd, fileno(stdout));
    close(savedFd);
    long size = ftell(tmp);
    rewind(tmp);
    size_t got = fread(out, 1, outSize - 1, tmp);
    out[got] = '\0';
    fclose(tmp);
    return size;
}

static void test_htrace_output(void) {
    GpcState state = {.gpcID = 1};
    CHECK(yaGPC2_ops.initializer(&state, "test/fixtures/hello.fcm", "test/fixtures/hello-lnk101.json"),
          "htrace-output instance initializer succeeded");
    AGEHarness *age = (AGEHarness *)state.impl;
    char buf[2400];

    CHECK(!age->htraceWanted, "htraceWanted starts false (no debugger attached)");

    /* Enabled before the very first step, so the trace line's NIA/section
     * are the known real entry point -- what yagpc2_debugger() would set
     * from debugger_wants_htrace()/debugger_line_width() after an
     * 'htrace on'/'set width 60'. */
    age->htraceWanted = true;
    age->htraceLineWidth = 60;
    long n = capture_engine_output(&state, buf, sizeof buf);
    CHECK(n > 0, "engine prints a trace line when htraceWanted is true");
    /* Content checks confirm this is really trace_format_debug_line()'s
     * full CLI-identical format (elapsed time + real NIA/disasm), not
     * just "some bytes" -- the fields a regression could plausibly drop
     * silently (e.g. passing a NULL elapsedTimeUs by mistake). */
    CHECK(strstr(buf, "T=") != NULL, "trace line includes the elapsed-time field");
    CHECK(strstr(buf, "10164") != NULL, "trace line includes the real starting NIA");
    CHECK(strstr(buf, "START") != NULL, "trace line includes the real section name from symbols");

    age->htraceWanted = false;
    CHECK(capture_engine_output(&state, buf, sizeof buf) == 0, "engine stops printing once htraceWanted is cleared again");

    ageharness_free(age);
    free(age);
}

int main(void) {
    test_two_instance_independence();
    test_servicer_roundtrip();
    test_htrace_output();
    if (failures == 0) {
        printf("all gpcops/servicer tests passed\n");
    } else {
        printf("%d gpcops/servicer test(s) FAILED\n", failures);
    }
    return failures == 0 ? 0 : 1;
}
