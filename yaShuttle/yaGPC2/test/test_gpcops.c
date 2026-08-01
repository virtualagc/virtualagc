/* Verifies six pieces of the Shuttle-sim integration work (see
 * ../src/yaGpcIntegration.h and its plan-mode discussion history):
 *
 *  1. yaGPC2_ops (../src/gpcops.c) supports multiple fully independent
 *     GpcState instances in one process -- the concrete, checkable
 *     definition of "no hidden global state" for that refactor.
 *  2. The servicer wiring into iop.c's MIA stub round-trips real data
 *     both directions, exercising the same iop_queue_dma()/
 *     iop_exec_dma_queue()/mia_xmit_cmd() paths #TDS/#RDS/#CMD/#CMDI
 *     themselves use, while confirming the no-servicer-installed case
 *     is still byte-for-byte the original inert stub -- and that
 *     GpcInitializerFn's servicer/servicerCtx parameters actually wire
 *     up (via yagpc2_initializer()'s ap101_set_servicer() call), not
 *     just the low-level iop_set_servicer() path.
 *  3. yagpc2_engine() prints a trace line exactly when
 *     AGEHarness.htraceWanted is set (and nothing when it isn't) --
 *     the mechanism a driver relies on to get 'htrace'-equivalent
 *     output without owning any snapshot/diff/format logic itself.
 *  4. yaGPC2_ops.release() (issue #79) actually flushes pending HalUCP
 *     output before freeing an instance, not just reclaims memory.
 *  5. yaGPC2_ops.debuggerStateCreate()/debuggerStateDestroy() (issue #79)
 *     work as a generic pair a driver can call without knowing this is
 *     yaGPC2 specifically (i.e. without reaching for debugger_create()/
 *     debugger_free() and an Options struct directly).
 *  6. yagpc2_engine()'s GpcEngineStatus return value correctly reports
 *     GPC_ENGINE_RUNNING while a program executes, GPC_ENGINE_HALTED_NORMAL
 *     at its own natural completion (confirmed against hello.fcm's real,
 *     empirically-verified halt point), and never RUNNING again once
 *     halted -- the fix for a real, confirmed gap (a driver had no way
 *     to know when to stop calling engine(), and calling it past a
 *     program's own halt decodes adjacent memory as garbage). Also
 *     confirms gpc_engine_status_message() returns real, non-empty text
 *     for every named code, so the "always available list of messages"
 *     requirement this whole scheme exists for is actually met.
 *
 * Run from the repo root (as `make test` does) -- fixture path below is
 * relative to that. */
#define _POSIX_C_SOURCE 200809L /* fileno(), dup(), dup2() -- see capture_engine_output_bytes() */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "../src/ageharness.h"
#include "../src/yaGpcIntegration.h"

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
    CHECK(yaGPC2_ops.initializer(&a, "test/fixtures/hello.fcm", "test/fixtures/hello-lnk101.json", NULL, NULL, NULL, NULL, NULL),
          "instance A initializer succeeded");
    CHECK(yaGPC2_ops.initializer(&b, "test/fixtures/hello.fcm", "test/fixtures/hello-lnk101.json", NULL, NULL, NULL, NULL, NULL),
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

    yaGPC2_ops.release(&a);
    yaGPC2_ops.release(&b);
    CHECK(a.impl == NULL && b.impl == NULL, "release() clears impl on both instances");
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

/* Note the signature: no GpcState anywhere -- ctx is whatever opaque
 * context was registered via iop_set_servicer(), here just &fs
 * directly, no GpcState wrapper needed at all. */
static void fake_servicer(void *ctx, GpcServiceNumber svc, const GpcServiceInput *input, GpcServiceOutput *output) {
    FakeServicer *fs = (FakeServicer *)ctx;
    fs->lastBusID = input->busID;
    switch (svc) {
        case GPC_SVC_XMIT_WORD:
            fs->words[fs->count++] = input->in.word;
            output->out.xmit.ok = true;
            break;
        case GPC_SVC_XMIT_CMD:
            fs->lastCmdWord = input->in.word;
            fs->lastCmdAddress = input->address;
            output->out.xmit.ok = true;
            break;
        case GPC_SVC_RECV_POLL:
            output->out.poll.available = fs->count > 0;
            break;
        case GPC_SVC_RECV_WORD:
            if (fs->count == 0) {
                output->out.recv.available = false;
                break;
            }
            output->out.recv.available = true;
            output->out.recv.word = fs->words[0];
            memmove(fs->words, fs->words + 1, (size_t)(--fs->count) * sizeof(uint32_t));
            break;
    }
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
    iop_set_servicer(&iop, fake_servicer, &fs);

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

/* Proves GpcInitializerFn's servicer/servicerCtx parameters actually get
 * wired up (via yagpc2_initializer()'s internal ap101_set_servicer()
 * call) -- test_servicer_roundtrip() above exercises the low-level
 * iop_set_servicer() path directly; this exercises the black-box path a
 * real driver would use instead. */
static void test_servicer_via_initializer(void) {
    FakeServicer fs;
    memset(&fs, 0, sizeof fs);

    GpcState state = {.gpcID = 1};
    CHECK(yaGPC2_ops.initializer(&state, "test/fixtures/hello.fcm", "test/fixtures/hello-lnk101.json", fake_servicer,
                                  &fs, NULL, NULL, NULL),
          "servicer-via-initializer instance initializer succeeded");
    AGEHarness *age = (AGEHarness *)state.impl;

    uint32_t cmd = (0x07u << 19) | 0x0055u;
    mia_xmit_cmd(&age->gpc.iop, &age->gpc.iop.bce[0].mia, cmd);
    CHECK(fs.lastCmdWord == cmd, "servicer registered via the initializer receives real MIA traffic");
    CHECK(fs.lastCmdAddress == 7, "IUA decoded correctly through the initializer-installed servicer");

    yaGPC2_ops.release(&state);
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
    CHECK(yaGPC2_ops.initializer(&state, "test/fixtures/hello.fcm", "test/fixtures/hello-lnk101.json", NULL, NULL, NULL, NULL, NULL),
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

    yaGPC2_ops.release(&state);
}

/* ---------------------------------------------------------------------
 * 4. GpcOps lifecycle hooks (issue #79): release() and debuggerState
 *    create/destroy
 * ------------------------------------------------------------------- */

static char g_flushCapture[256];

static void capture_output_cb(void *ctx, const char *text, int channel) {
    (void)ctx;
    (void)channel;
    strncat(g_flushCapture, text, sizeof g_flushCapture - strlen(g_flushCapture) - 1);
}

/* Directly verifies yagpc2_release() actually flushes pending HalUCP
 * output (not just frees memory) -- the concrete fix for issue #79's
 * "release() needs to do the same flush-on-teardown the CLI's HALT/EOF
 * paths already have" finding. Simulates "a WRITE left text sitting in
 * lineBuf[ch], never finalized by SKIP/LINE/PAGE, before the driver
 * decided to tear the instance down" by poking the public lineBuf/
 * lineBufLen fields directly, same technique halucp_flush_all_pending()
 * itself is built to handle. */
static void test_release_flushes_pending_output(void) {
    GpcState state = {.gpcID = 1};
    CHECK(yaGPC2_ops.initializer(&state, "test/fixtures/hello.fcm", "test/fixtures/hello-lnk101.json", NULL, NULL, NULL, NULL, NULL),
          "release-flush instance initializer succeeded");
    AGEHarness *age = (AGEHarness *)state.impl;

    g_flushCapture[0] = '\0';
    age->halUCP.cbCtx = NULL;
    age->halUCP.outputCallback = capture_output_cb;

    const char *pending = "UNFLUSHED LINE";
    age->halUCP.lineBuf[6] = malloc(strlen(pending) + 1);
    strcpy(age->halUCP.lineBuf[6], pending);
    age->halUCP.lineBufLen[6] = strlen(pending);

    yaGPC2_ops.release(&state);

    CHECK(strstr(g_flushCapture, pending) != NULL, "release() flushed the pending unflushed line before freeing");
}

static void test_debugger_state_lifecycle(void) {
    void *dbgState = yaGPC2_ops.debuggerStateCreate(NULL);
    CHECK(dbgState != NULL, "debuggerStateCreate(NULL) returns a non-NULL session");
    yaGPC2_ops.debuggerStateDestroy(dbgState); /* must not crash */

    void *dbgState2 = yaGPC2_ops.debuggerStateCreate("test/fixtures/hello.srcmap.json");
    CHECK(dbgState2 != NULL, "debuggerStateCreate(sourceMapPath) returns a non-NULL session");
    yaGPC2_ops.debuggerStateDestroy(dbgState2);
}

/* ---------------------------------------------------------------------
 * 6. GpcEngineStatus: RUNNING -> HALTED, never RUNNING again
 * ------------------------------------------------------------------- */

/* Runs hello.fcm to its own real completion purely by watching
 * GpcEngineStatus -- no yaGPC2-specific wait-state check, exactly what a
 * black-box driver has to do. Confirms the status transitions correctly
 * and that calling engine() again post-halt never reports RUNNING (the
 * concrete guard against the "decodes adjacent memory as garbage" case
 * this was added to fix -- see yaGpcIntegration.h's GpcEngineFn comment
 * and the plan-mode discussion that found it). */
static void test_engine_status(void) {
    GpcState state = {.gpcID = 1};
    CHECK(yaGPC2_ops.initializer(&state, "test/fixtures/hello.fcm", "test/fixtures/hello-lnk101.json", NULL, NULL, NULL, NULL, NULL),
          "engine-status instance initializer succeeded");

    GpcEngineStatus status = yaGPC2_ops.engine(&state);
    CHECK(status == GPC_ENGINE_RUNNING, "first instruction reports GPC_ENGINE_RUNNING");

    long steps = 1;
    const long maxSteps = 20000; /* generous bound so a regression can't hang this test forever */
    while (status == GPC_ENGINE_RUNNING && steps < maxSteps) {
        status = yaGPC2_ops.engine(&state);
        steps++;
    }

    CHECK(status == GPC_ENGINE_HALTED_NORMAL,
          "hello.fcm reports GPC_ENGINE_HALTED_NORMAL at its own natural completion");
    CHECK(steps < maxSteps, "halted well within the generous step bound, not just cut off by it");
    CHECK(steps > 100, "didn't report halted implausibly early (sanity check)");

    GpcEngineStatus statusAfterHalt = yaGPC2_ops.engine(&state);
    CHECK(statusAfterHalt != GPC_ENGINE_RUNNING, "engine() called again after halt does not report RUNNING");

    yaGPC2_ops.release(&state);
}

/* gpc_engine_status_message() (src/yaGpcEngineStatus.c) is the "always
 * available list of messages" an integrator was asked not to have to
 * invent themselves -- confirms every named code has real, non-empty
 * text (not just a fallback "unknown status N"), and spot-checks a few
 * real entries from the shared HAL/S-runtime-error table (1000+N) match
 * the exact wording halucp.c's own svc_error_message() has carried since
 * before this scheme existed -- the whole point of sharing one table
 * instead of each side inventing its own. */
static void test_engine_status_messages(void) {
    const GpcEngineStatus namedCodes[] = {
        GPC_ENGINE_RUNNING,
        GPC_ENGINE_HALTED_NORMAL,
        GPC_ENGINE_HALTED_UNHANDLED_EOF,
        GPC_ENGINE_HALTED_STARVED,
        GPC_ENGINE_ERROR_INVALID_OPCODE,
        GPC_ENGINE_ERROR_UNHANDLED_TRAP,
        GPC_ENGINE_ERROR_BOUNDS,
        GPC_ENGINE_ERROR_STACK_DEPTH,
        GPC_ENGINE_ERROR_UNDEFINED_CALL,
        GPC_ENGINE_ERROR_INTERNAL,
    };
    for (size_t i = 0; i < sizeof(namedCodes) / sizeof(namedCodes[0]); i++) {
        const char *msg = gpc_engine_status_message(namedCodes[i]);
        CHECK(msg != NULL && msg[0] != '\0', "every named GpcEngineStatus has real message text");
        CHECK(strstr(msg, "unknown GpcEngineStatus") == NULL, "named code doesn't fall through to the unknown-status fallback");
    }

    CHECK(strcmp(gpc_engine_status_message((GpcEngineStatus)(GPC_ENGINE_WARNING_HAL_S_ERROR_BASE + 5)),
                 "SQRT HAS ARGUMENT < 0 ") == 0,
          "1005 gives the exact SQRT-negative message");
    CHECK(strcmp(gpc_engine_status_message((GpcEngineStatus)(GPC_ENGINE_WARNING_HAL_S_ERROR_BASE + 16)),
                 "DIVISION BY ZERO IN REMAINDER") == 0,
          "1016 gives the exact remainder-divide-by-zero message");

    const char *unknownPositive = gpc_engine_status_message((GpcEngineStatus)(GPC_ENGINE_WARNING_HAL_S_ERROR_BASE + 999));
    CHECK(unknownPositive != NULL && unknownPositive[0] != '\0', "an unreserved 1000+N still returns real text, not empty/NULL");
}

/* ---------------------------------------------------------------------
 * 7. Text I/O routing (WRITE/READ) via GpcInitializerFn's
 *    output/input/ioCtx
 * ------------------------------------------------------------------- */

/* Runs hello.fcm to its own natural halt, purely via GpcEngineStatus
 * (same pattern as test_engine_status()). Kept separate from that test
 * rather than merged into it -- this one is about output/input content,
 * not status transitions. */
static void run_hello_to_halt(GpcState *state) {
    GpcEngineStatus status = GPC_ENGINE_RUNNING;
    long steps = 0;
    const long maxSteps = 20000;
    while (status == GPC_ENGINE_RUNNING && steps < maxSteps) {
        status = yaGPC2_ops.engine(state);
        steps++;
    }
    CHECK(status == GPC_ENGINE_HALTED_NORMAL, "hello.fcm halted normally while its I/O was under test");
}

typedef struct {
    char buf[4096];
    int sawChannel6;
} CapturedOutput;

static void capture_output(void *ioCtx, int channel, const char *text) {
    CapturedOutput *co = (CapturedOutput *)ioCtx;
    if (channel == 6) co->sawChannel6 = 1;
    strncat(co->buf, text, sizeof co->buf - strlen(co->buf) - 1);
}

/* The direct regression test for the real bug this whole feature's
 * development turned up: yagpc2_engine() never called
 * halucp_check_trap() at all, so WRITE/READ silently executed as bare,
 * non-intercepted AP-101S object code -- outputCallback was correctly
 * wired but simply never reached, no matter what GpcInitializerFn was
 * given. Confirms real program text (not just "some bytes") reaches a
 * custom output callback, on the real HAL/S channel WRITE(6) targets. */
static void test_output_routing_via_initializer(void) {
    CapturedOutput co;
    memset(&co, 0, sizeof co);

    GpcState state = {.gpcID = 1};
    CHECK(yaGPC2_ops.initializer(&state, "test/fixtures/hello.fcm", "test/fixtures/hello-lnk101.json", NULL, NULL,
                                  capture_output, NULL, &co),
          "output-routing instance initializer succeeded");

    run_hello_to_halt(&state);

    CHECK(co.sawChannel6, "output callback saw text on HAL/S channel 6 (WRITE(6)'s own channel)");
    CHECK(strstr(co.buf, "HELLO, WORLD!") != NULL, "custom output callback captured the program's real WRITE text");
    CHECK(strstr(co.buf, "RON BURKEY SAYS ISN'T THIS FUN?") != NULL, "captured a second, distinct real WRITE line too");
    CHECK(strstr(co.buf, "THE END") != NULL, "captured output through to the program's own natural end");

    yaGPC2_ops.release(&state);
}

/* Redirects the real stdout file descriptor for the duration of a whole
 * hello.fcm run (unlike capture_engine_output() above, which only
 * covers one engine() call) -- the concrete check for GpcOutputFn's own
 * documented NULL behavior: falls back to connecting channel 6 (what
 * hello.fcm's own WRITE targets) to stdout, not to gpcops.c's old
 * silent-discard gap this parameter exists to close. */
static void test_output_defaults_to_stdout(void) {
    GpcState state = {.gpcID = 1};
    CHECK(yaGPC2_ops.initializer(&state, "test/fixtures/hello.fcm", "test/fixtures/hello-lnk101.json", NULL, NULL,
                                  NULL, NULL, NULL),
          "default-output instance initializer succeeded");

    fflush(stdout);
    FILE *tmp = tmpfile();
    int savedFd = dup(fileno(stdout));
    dup2(fileno(tmp), fileno(stdout));

    run_hello_to_halt(&state);

    fflush(stdout);
    dup2(savedFd, fileno(stdout));
    close(savedFd);
    char buf[4096];
    rewind(tmp);
    size_t got = fread(buf, 1, sizeof buf - 1, tmp);
    buf[got] = '\0';
    fclose(tmp);

    CHECK(strstr(buf, "HELLO, WORLD!") != NULL, "NULL output falls back to real WRITE text on actual stdout");
    CHECK(strstr(buf, "THE END") != NULL, "stdout fallback captured output through to the program's own end");

    yaGPC2_ops.release(&state);
}

/* No dedicated GpcInputFn test, and no test of default_output()'s
 * discard-on-non-6/EOF-on-non-5 behavior specifically: hello.fcm only
 * ever WRITEs to channel 6 and never READs at all, and none of this
 * repo's current fixtures READ or WRITE any other channel either, so
 * there's no fixture to exercise a custom input callback, the NULL
 * stdin-on-channel-5 default, or the NULL discard/EOF-on-other-channels
 * default directly -- a documented gap, not an oversight. Add one once
 * a suitable fixture exists. */

int main(void) {
    test_two_instance_independence();
    test_servicer_roundtrip();
    test_servicer_via_initializer();
    test_htrace_output();
    test_release_flushes_pending_output();
    test_debugger_state_lifecycle();
    test_engine_status();
    test_engine_status_messages();
    test_output_routing_via_initializer();
    test_output_defaults_to_stdout();
    if (failures == 0) {
        printf("all gpcops/servicer tests passed\n");
    } else {
        printf("%d gpcops/servicer test(s) FAILED\n", failures);
    }
    return failures == 0 ? 0 : 1;
}
