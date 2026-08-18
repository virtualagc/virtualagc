/* CLI option parsing for `yaGPC2` — mirrors `gpc run`'s commander.js option
 * set (AGEHarness.addOptions + IOHost.addOptions + cmd_run's own options).
 * See gpc/cmd_run.coffee, gpc/ageharness.coffee, gpc/iohost.coffee. */
#ifndef YAGPC_OPTS_H
#define YAGPC_OPTS_H

#include <stdbool.h>
#include <stddef.h>

#define OPTS_NUM_CHANNELS 8

typedef struct {
    long addr;   /* parsed hex */
    long count;  /* parsed decimal, default 1 */
} WatchSpec;

typedef struct {
    char *fcmPath;

    /* AGEHarness options */
    char *start;                    /* NULL if unset; hex string */
    char *symbols;                  /* NULL if unset */
    bool ebcdic;                    /* default false */
    bool trapSvcError;              /* default true */
    char *halucpFormatNumBlanks;    /* default "5" */
    char *lineWidth;                /* default "132"; only applied as a
                                      * uniform override if lineWidthSet */
    bool lineWidthSet;               /* true only if --line-width was
                                       * actually passed -- see halucp.c's
                                       * effective_line_width() for the
                                       * PAGED(132)/UNPAGED(80) default
                                       * split used otherwise (USA003090
                                       * Sec. 6.1.4) */

    /* IOHost options */
    char *infile[OPTS_NUM_CHANNELS];
    char *outfile[OPTS_NUM_CHANNELS];

    /* cmd_run options */
    char *maxSteps;                 /* default "100000" */
    char *breakAddr;                /* NULL if unset; hex string */
    WatchSpec *watch;
    size_t watchCount;
    char *outputPath;               /* NULL if unset */
    char *dumpInterval;             /* default "100" */
    bool trace;                     /* default false */
    bool verbose;                   /* default false */
    bool interactive;               /* default false */
    bool watchLog;                  /* default false */

    /* Not part of gpc run's own option set -- yaGPC2-specific, like
     * --fcos below. Enables the gdb-style interactive debugger (see
     * src/debugger.h); implies --interactive. */
    bool debug;                      /* default false */
    /* Optional HAL/S source-line map for --debug (see src/sourcemap.h
     * and tools/gen_source_map.py); NULL if not given -- the debugger
     * simply shows no source line at stops. */
    char *sourceMap;                 /* NULL if unset */

    /* Not part of gpc run's own option set -- yaGPC2-specific. Simulates
     * specific known FCOS (Shuttle flight-software OS) behaviors that a
     * bare-hardware/no-OS program never gets; see cpu.h's fcosMode
     * comment. Default false: an ordinary standalone-compiled HAL/S
     * program run without a real flight OS underneath it. */
    bool fcos;                       /* default false */

    /* Not part of gpc run's own option set -- yaGPC2-specific, mirroring
     * yaHALMAT2's own --time-scale exactly (same name, same semantics,
     * same default). Wall-clock pacing divisor for SCHEDULE/WAIT
     * real-time throttling in the standalone CLI's own instruction loop
     * (run.c's batchrunner_pace()) -- never touches ap101_exec1()/
     * cpu->elapsedTimeUs's own tick arithmetic, only how fast real time
     * elapses alongside it. Only meaningful for TASK/SCHEDULE/WAIT
     * programs; a program with no SCHEDULE/WAIT never accumulates
     * enough virtual time between pacing checks to trigger a sleep at
     * all. See run.h's own comment for why this lives in the CLI loop
     * and not the embeddable engine -- an integrator (e.g. a future
     * Shuttle simulator) owns its own pacing against the same
     * GpcState.elapsedTime this option paces the CLI against. */
    char *timeScale;                 /* default "1.0"; parsed via atof */

    /* Not part of gpc run's own option set -- yaGPC2-specific, mirroring
     * yaHALMAT2's own --pacing=MODE (same names/semantics/default): which
     * --time-scale pacing implementation run.c's batchrunner_pace() uses
     * -- "burst" (default, a polling design: check accumulated virtual
     * time periodically, sleep to catch up) or "signal" (a POSIX
     * real-time-timer/sigsuspend-driven design, added purely for direct
     * side-by-side comparison -- both implement the exact same pacing
     * contract and produce identical program output, only wall-clock
     * jitter/precision differs). "signal" requires this build to have
     * been compiled with POSIX real-time timer support (see Makefile's
     * HAVE_POSIX_TIMERS probe); fails loudly at startup if not
     * available, rather than silently falling back to "burst". */
    char *pacing;                     /* "burst" (default) or "signal" */

    /* Not part of gpc run's own option set -- yaGPC2-specific. Overrides
     * DATE()/CLOCKTIME()'s own wall-clock anchor (see cpu.h's
     * dateTimeAnchorEpochSec), a Unix epoch value (seconds since
     * 1970-01-01 UTC, e.g. via `date +%s`). Unset (NULL) by default,
     * meaning: use the real host machine's own current wall-clock time
     * (in its currently configured timezone) at program start, matching
     * the ad hoc "just run it and get a sensible answer" case. Set this
     * for reproducible test runs, where DATE()/CLOCKTIME()'s own output
     * must not depend on what real day/time the test happens to execute
     * -- exactly the concern every golden-file fixture in test/fixtures/
     * already has to avoid for any other reason. */
    char *dateTimeEpoch;              /* NULL by default; parsed via atof */

    /* Not part of gpc run's own option set -- yaGPC2-specific. Installs
     * the real-peripheral servicer bridge (src/bcenet_framer.c/
     * bcenet_transport.c) as the AP101's servicer, driving BCE bus
     * traffic over real multicast UDP matching nsts-sim-gpc's own wire
     * protocol (com/bus.civet) -- lets a real .fcm talk to Don Schmidt's
     * MEDS emulator (or anything else speaking the same protocol) from
     * the standalone CLI, not just through the GpcOps embedding API.
     * Default false: unchanged behavior, MIA stays an inert stub. */
    bool bceNetwork;                  /* default false */
} Options;

/* Parses argv (starting at argv[1]) exactly as `gpc run` would, except that
 * a leading literal "run" token is optional (skipped if present).  On any
 * parse error or --help, prints to stdout/stderr and calls exit(), matching
 * commander.js's behavior — this function never returns an error code. */
void opts_parse(int argc, char **argv, Options *opts);

#endif
