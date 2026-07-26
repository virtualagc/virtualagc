/* CLI option parsing for `yaGPC` — mirrors `gpc run`'s commander.js option
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
    char *lineWidth;                /* default "132" */

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
} Options;

/* Parses argv (starting at argv[1]) exactly as `gpc run` would, except that
 * a leading literal "run" token is optional (skipped if present).  On any
 * parse error or --help, prints to stdout/stderr and calls exit(), matching
 * commander.js's behavior — this function never returns an error code. */
void opts_parse(int argc, char **argv, Options *opts);

#endif
