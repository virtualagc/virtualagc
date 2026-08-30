/* BatchRunner, ported from gpc/cmd_run.coffee. Drives the actual
 * fetch/decode/execute loop for `gpc run`/`yaGPC2 <fcm>`.
 *
 * NOTE: BatchRunner has its own `_formatTraceLine`/`formatSectionOffset`
 * that is subtly different from gpc/trace.coffee's exported
 * `formatTraceLine` (different default field widths, uppercase section
 * names, different offset digit count, no ANSI color codes at all) —
 * trace.coffee's `formatTraceLine` is actually an unused import in
 * cmd_run.coffee (only `formatRegVal` and `formatRegDump` are actually
 * called from there). This port keeps them as two genuinely separate
 * functions (trace.c's trace_format_line vs run.c's own
 * batchrunner_format_trace_line) rather than unifying them, matching
 * the source's own (seemingly accidental) duplication exactly. */
#ifndef YAGPC_RUN_H
#define YAGPC_RUN_H

#include <stdbool.h>
#include <stdint.h>

#include "ageharness.h"
#include "rtpacer.h"
#include "bcenet_framer.h"
#include "deumodel.h"
#include "bcenet_transport.h"
#include "debugger.h"
#include "iohost.h"
#include "opts.h"

/* Mirrors yaHALMAT2's halmat_pacing_mode_t exactly (same two variants,
 * same default) -- see run.c's batchrunner_pace_burst()/
 * batchrunner_pace_signal(). */
typedef enum { PACING_BURST, PACING_SIGNAL } PacingMode;

/* Routes one bus to the in-process mass memory and the rest to whatever
 * servicer would otherwise have been installed; see run.c. */
typedef struct {
    struct MmuModel *mmu;
    int mmuBus;
    struct MtuModel *mtu;   /* buses 20-22, device 22; see mtumodel.h */
    struct DeuModel *deu2;  /* --deu-bus: a SECOND display unit */
    int deu2Bus;
    GpcServicerFn fallback;
    void *fallbackCtx;
} BusRouter;

typedef struct {
    const Options *opts;

    long maxSteps;
    bool hasBreakpoint;
    uint32_t breakpoint;
    bool watchLog;
    const char *outputPath;
    long dumpInterval;
    bool traceEnabled;
    bool verbose;
    bool interactive;

    AGEHarness age;
    IOHost iohost;

    /* @lines — buffered output when --output is set (flushed to a file
     * at the end); otherwise write() goes straight to stdout. */
    char **lines;
    size_t lineCount, lineCap;

    uint32_t entryPoint;

    long step;
    bool hasStopReason;
    char stopReason[600];
    bool hasLastSection;
    char lastSection[256];

    /* Memory watchpoints (from --watch/--watch-log), checked every step.
     * Populated by both batchrunner_run() and batchrunner_run_interactive()
     * via the shared batchrunner_step() so the feature works the same way
     * in either mode. */
    bool hasWatchpoints;
    uint32_t *watchAddrs;
    int watchAddrCount;
    uint16_t *watchBefore;

    /* --debug: see src/debugger.h. NULL/false unless --debug was passed
     * -- zero cost otherwise, since debugger_hook() is then never
     * called. */
    bool debugMode;
    Debugger *dbg;

    /* --time-scale wall-clock pacing (see run.c's batchrunner_pace()).
     * The CLI's own instruction loop is deliberately just another
     * consumer of the same pure-virtual-time engine an embedding
     * integrator would use (ap101_exec1(), via batchrunner_step()) --
     * pacing is layered on top of it here, in the driver, exactly the
     * way a real integrator (e.g. a future Space Shuttle simulator) is
     * expected to pace itself against GpcState.elapsedTime. The engine
     * itself never knows this is happening. Skipped entirely under
     * --debug: time spent blocked on debugger input must never count
     * against real time. */
    double timeScale;

    /* --pacing: which implementation of the contract above to use --
     * see run.c's batchrunner_pace_burst()/batchrunner_pace_signal(),
     * mirroring yaHALMAT2's own --pacing=MODE (interp_run_burst()/
     * interp_run_signal()) byte-for-byte. Both fields below are burst
     * mode's own state; signal mode's platform-specific resources
     * (POSIX timer/signal-mask handles) live as file-scope statics in
     * run.c instead, matching g_sigint_received's own existing pattern
     * there (only one BatchRunner is ever paced per process). */
    PacingMode pacingMode;
    /* --real-time: paces against the wall clock, and (unlike
     * --time-scale) drives simulated time FROM it while the CPU waits.
     * NULL unless --real-time was given.  See rtpacer.h. */
    bool realTime;
    RTPacer rtPacer;

    double pacingRefWallSeconds;
    double pacingRefVirtualUs;

    /* --bce-network: NULL/NULL unless the flag was passed (see
     * batchrunner_init()/batchrunner_free() and bcenet_framer_flush_tick()'s
     * own call site in batchrunner_step()). bceTransport is owned by
     * bceFramer's caller (here), not by the framer itself -- same
     * lifetime discipline as bcenet_framer.h documents. */
    BceNetTransport *bceTransport;
    BceNetFramer *bceFramer;
    struct DeuModel *deuModel;
    /* In-process mass memory, and the routing that lets it own one bus
     * while everything else still reaches whatever else is installed. */
    struct MmuModel *mmuModel;
    struct MtuModel *mtuModel;  /* --mtu-model: the in-process timing unit */
    struct DeuModel *deuModel2; /* --deu-bus: a second display unit */
    BusRouter busRouter;   /* --deu-model: the in-process display unit */
} BatchRunner;

void batchrunner_init(BatchRunner *r, const Options *opts);
void batchrunner_free(BatchRunner *r);

/* Ported from BatchRunner#run. Returns the process exit code (0 or 1 —
 * matches the source's process.exit(1) on any non-"wait state" stop, 0
 * implicitly otherwise since run() only ever calls process.exit on the
 * error path). */
int batchrunner_run(BatchRunner *r);

/* Ported from BatchRunner#runInteractive/promptInput/execLoop, but
 * restructured as a single synchronous loop (blocking on stdin when
 * input is needed) instead of JS's async readline-callback/event-loop
 * re-entry style — same observable behavior for a single-threaded CLI
 * tool reading from a real terminal or a piped file, since nothing else
 * can run "in between" prompts either way. SIGINT is handled the same
 * way (print final state, flush, exit 0). */
int batchrunner_run_interactive(BatchRunner *r);

#endif
