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
    bool halucpSvc;                 /* default true; false = the loaded image
                                     * has its own SVC handlers (real PASS) */
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

    /* Not part of gpc run's own option set -- yaGPC2-specific. Simulates
     * real AP-101S cold IPL's own memory-initialization step (USA-
     * documented AP-101S-instruction-set.txt Sec. 2.5.3.3 "IPL", quoted
     * verbatim): before any code is loaded, IOP microcode fills 0x0-
     * 0x1FFFF with 0xC9FB and CPU microcode fills 0x20000-and-up with
     * 0xC6C6, both regions marked store-protected -- so a program has to
     * explicitly unprotect (via ISPB) whatever it needs to write, exactly
     * like BILDNEW5/GPCIPL's own $POFF/$PON-generated UNPRT table does.
     * Default false: an ordinary standalone-compiled HAL/S test fixture
     * loaded directly by this harness never went through a real IPL and
     * has no ISPB-based bootstrap of its own -- turning this on
     * unconditionally breaks such fixtures (confirmed: they write to
     * their own data area with no unprotect step, since real FCOS would
     * have already unprotected it for them before ever handing them
     * control -- a step this minimal harness doesn't reproduce). Only a
     * genuine cold-boot run of hand-assembled, IPL-aware code like
     * BILDNEW5 should pass this. */
    bool ipl;                        /* default false */

    /* Not part of gpc run's own option set -- yaGPC2-specific. Real
     * AP-101S Power-On (AP-101S-instruction-set.txt Sec. 2.5.3.1,
     * distinct from IPL, Sec. 2.5.3.3, quoted in --ipl's own comment
     * above): "the second mode at power-on enters the run state after
     * the system reset is complete" -- i.e. it performs the system reset
     * *function* of Sec. 2.5.3.2, then runs. It does NOT enter through
     * the System Reset *vector*: Power On and System Reset are separate
     * interrupt classes with separate PSA vectors (0x04 vs 0x14, Figure
     * 2-20), landing on separate flight-software entry points (PSA.asm's
     * SPWRONN -> FAILEXEC vs SRESINTN -> IOPHISAM). This comment used to
     * say they were the same vector and cpu_reset() was used for both;
     * that was wrong, and it was the reason GPCIPL's self-test always
     * wild-branched. See cpu_power_on(). IPL's blanket store-*protection* is IPL-specific
     * per the manual's own section split, not a Power-On property --
     * confirmed to matter, not just textually distinct: a genuine
     * BILDNEW5/GPCIPL self-test run under --power-on (memory left
     * unprotected, only the loaded FCM image's own content plus the fill
     * below present) never trips the store-protect program-check loop
     * that the same image run under --ipl does (GPCIPL's own error-
     * logging path, SVCALT.asm's RECORDER/SAVENV, unconditionally writes
     * into sector 1/ENVIRONS -- real Phase-2-owned memory this standalone
     * self-test run never has backing for either way, but only --ipl's
     * blanket protection turns that into a fault). The C9FB/C6C6 fill
     * *content* itself, though, is still applied under --power-on (see
     * ageharness.c's mem_pattern_fill()) -- GPCIPL's self-test explicitly
     * checks for that pattern in at least one place, and skipping the
     * fill entirely (memory left zeroed) leaves the counter-arming code
     * downstream of that check unreached, stalling forever in a
     * Clock-armed SVCPWAIT spin. --ipl and --power-on both drive entry
     * via cpu_reset(); --ipl takes precedence if both are given (its
     * memory-init step is a superset that also performs a system
     * reset). */
    bool powerOn;                    /* default false */

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
    bool deuModel;                    /* default false */

    /* Subscribe to the discrete-input bus, so that devices publishing
     * discretes -- a mass memory asserting its own READY, the crew panel
     * in yaShuttle/discretePanel/ -- drive this machine's discrete
     * registers.  Bits nobody publishes keep the value iop.c derives or
     * holds for them, so this only ever adds sources of truth.  Default
     * false: no socket is opened and the registers behave as before. */
    bool discretes;                   /* default false */
    char *discreteA;                  /* hex override, default NULL */
    char *discreteB;                  /* hex override, default NULL */

    /* Serve the mass memory bus from an in-process model reading this
     * .mmv volume, instead of from whatever is on the wire.  Composes
     * with --bce-network and --deu-model: the mass memory bus goes to
     * the model, every other bus goes wherever it would have gone, so a
     * run can have a deterministic tape AND a real display.  See
     * mmumodel.h for why a second implementation of someone else's
     * device is worth having. */
    char *mmuModelVolume;             /* default NULL */
    char *mmuModelUnit;               /* "1" (MM1/BCE 18) or "2"; default 1 */

    /* Base of the UDP port range every bus socket derives from: bus n uses
     * base+n and the discrete bus base+80.  Default 6900, which reproduces
     * nsts-sim-gpc's own busConfig exactly.  Giving a second instance its
     * own base lets two emulations run side by side without fighting over
     * sockets -- MEDS and discretePanel.py take the same option. */
    char *portBase;                   /* decimal; default 6900 */

    /* --mtu-model: answer as the Master Timing Unit (device 22 on BCE
     * 20-22) so PASS can initialise its clock.  See src/mtumodel.h. */
    bool mtuModel;                    /* default false */

    /* --deu-bus <n>: install a SECOND display unit on bus n, alongside the
     * one --deu-model puts on DK1.  PASS masks whichever DK bus the BFC CRT
     * switch names, so a display it can actually drive has to be elsewhere. */
    char *deuBus;                     /* decimal bus number; default none */

    /* Not part of gpc run's own option set -- yaGPC2-specific. Which
     * instruction-timing model charges cpu->elapsedTimeUs, and through
     * it the interval timers: "poo" (the default) is the AP-101S
     * Principles of Operation section-17 table, i.e. the hardware
     * specification; "pass2" is the HAL/S-FC PASS2 compiler's own
     * static estimate of the same hardware, kept only because
     * comparing the two is informative. See timing.h. */
    /* Mirrors `gpc run`'s own --real-time/--rt-factor.  Paces the
     * simulation against the WALL CLOCK, including -- crucially -- while
     * the CPU sits in the wait state, where simulated time is advanced
     * FROM elapsed wall time rather than free-running.  That is what
     * keeps this machine's clock tied to an external peripheral's rather
     * than merely scaled by the same factor, and it is what a real MMU or
     * MEDS on the other end of --bce-network needs.  See rtpacer.h for
     * why this is a different thing from --time-scale. */
    bool realTime;                    /* default false */
    char *rtFactor;                   /* default "1"; parsed via atof */
    char *rtIdleTimeout;              /* default "10000" (ms) */

    char *timing;                     /* "poo" (default) or "pass2" */
} Options;

/* Parses argv (starting at argv[1]) exactly as `gpc run` would, except that
 * a leading literal "run" token is optional (skipped if present).  On any
 * parse error or --help, prints to stdout/stderr and calls exit(), matching
 * commander.js's behavior — this function never returns an error code. */
void opts_parse(int argc, char **argv, Options *opts);

#endif
