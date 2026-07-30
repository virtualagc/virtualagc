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
} Options;

/* Parses argv (starting at argv[1]) exactly as `gpc run` would, except that
 * a leading literal "run" token is optional (skipped if present).  On any
 * parse error or --help, prints to stdout/stderr and calls exit(), matching
 * commander.js's behavior — this function never returns an error code. */
void opts_parse(int argc, char **argv, Options *opts);

#endif
