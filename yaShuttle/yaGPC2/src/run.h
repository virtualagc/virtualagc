/* BatchRunner, ported from gpc/cmd_run.coffee. Drives the actual
 * fetch/decode/execute loop for `gpc run`/`yaGPC <fcm>`.
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
#include "iohost.h"
#include "opts.h"

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
