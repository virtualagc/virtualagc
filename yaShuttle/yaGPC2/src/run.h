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

#define DEU_EXTRA_MAX 3   /* built-in DK1 + 3 = the four DEUs PASS drives */

/* 64, the same ceiling --debug's own breakpoint table uses
 * (DEBUGGER_MAX_BREAKPOINTS, debugger.c).  --break, the third mechanism,
 * holds exactly one address and has no array at all. */
#define BATCHRUNNER_LM_MAX 64

/* THE CAPTURE TRIGGERS, PER COMPUTER.  YAGPC_DUMPSTATE_AT, _BUSY and
 * YAGPC_LANDMARKS were function-scope statics inside batchrunner_step,
 * which gave every GPC thread ONE shared set.  With more than one machine
 * that is silently wrong in three separate ways: the first thread to reach
 * a time consumed the cursor and the others never dumped at all; every
 * machine wrote the same path from the one --dump-state prefix, so a
 * capture that did happen twice overwrote itself; and a stopping landmark
 * stopped whichever computer arrived first while the rest ran on
 * un-snapshotted.  The result was a one-machine snapshot of a many-machine
 * vehicle, reported as a success.
 *
 * The parsed configuration is per-machine too, not merely the cursors.  It
 * costs about 6.6 KB a computer and buys two things: no initialisation
 * race (main() calls batchrunner_init for every machine before it starts a
 * single thread, so the parse happens single-threaded), and no shared
 * mutable state left in the per-instruction path at all. */
typedef struct {
    /* YAGPC_DUMPSTATE_AT=<sec>[,<sec>...] */
    double at[8];
    int nAt;
    int nextAt;               /* how many of them THIS computer has taken */
    /* YAGPC_DUMPSTATE_BUSY=<proc>[,<afterSec>] */
    int busyProc;             /* -1 when not armed */
    double busyAfterUs;
    int busyDone;             /* fired on THIS computer */
    /* YAGPC_LANDMARKS / _AFTER */
    int n;
    uint32_t addr[BATCHRUNNER_LM_MAX];
    char label[BATCHRUNNER_LM_MAX][32];
    long stop[BATCHRUNNER_LM_MAX];   /* 0 = never stop, N = stop on Nth hit */
    long hits[BATCHRUNNER_LM_MAX];   /* arrivals AT THIS COMPUTER */
    double afterUs;
    /* One test rejects almost every instruction: this check sits in the
     * per-instruction path, and a linear scan of 64 addresses there is not
     * free.  Indexed by the low 11 bits of the address; a set bit only
     * means "some landmark could have these low bits", and the scan then
     * confirms. */
    unsigned char maybe[2048 / 8];
} Triggers;

/* Routes one bus to the in-process mass memory and the rest to whatever
 * servicer would otherwise have been installed; see run.c. */
typedef struct {
    /* BOTH mass memory units: MM1 on bus 18, MM2 on bus 19.  The vehicle
     * has two, shared by every computer, and one GPC can be loading from
     * one while another loads from the other. */
    struct MmuModel *mmu[2];
    int mmuBus[2];
    struct MtuModel *mtu;   /* buses 20-22, device 22; see mtumodel.h */
    struct IccModel *icc;   /* bus 24, the wire between the computers */
    /* --deu-bus: display units BEYOND the built-in one on DK1.  PASS drives
     * FOUR (DCICYC.asm: DCIS#DEU EQU 4; device IDs 5-8 per FIOERRLC.asm's
     * FIODEULW/FIODEUHI), so modelling one or two leaves the DK handler with
     * requests to units that never answer. */
    /* Simulated microseconds, for YAGPC_DKTRACE.  The router is the one
     * place that sees every bus command with a clock in reach. */
    const double *clockUs;
    /* Simulated microseconds this computer's pacer has written off -- see
     * mtumodel_set_clock_offset. */
    const double *writtenOffUs;
    /* The built-in display unit on DK1.  It is reached through `fallback`
     * rather than by bus number, so the router needs it by name to ask
     * whether it is mid-transfer -- see bus_router_service. */
    struct DeuModel *deu;
    struct DeuModel *deuExtra[DEU_EXTRA_MAX];
    int deuExtraBus[DEU_EXTRA_MAX];
    int nDeuExtra;
    /* WHICH COMPUTER EACH DISPLAY UNIT IS ATTACHED TO.  Two GPCs cannot drive
     * the same display: a display-keyboard bus has one commander, and a unit
     * hangs off one bus.  0 means "no particular computer", which is what a
     * single-machine run wants and what every command line before --gpcs
     * meant.  See vehicle.h. */
    int deuOwner;
    int deuExtraOwner[DEU_EXTRA_MAX];
    GpcServicerFn fallback;
    void *fallbackCtx;
    /* Which computer this router belongs to, and the vehicle whose shared
     * devices it reaches, so a service call can be serialised against the
     * other computers' -- see vehicle_bus_enter. */
    struct Vehicle *vehicle;
    int gpcId;
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
    /* THIS MACHINE'S identity and its discrete bus connection.  Both are per
     * computer, not per process: the id selects the machine's discrete
     * channel and its intercomputer (bus 24) port. */
    int gpcId;
    struct Discretes *discretes;
    /* The shared hardware this computer is plugged into.  Borrowed, not
     * owned -- see vehicle.h. */
    struct Vehicle *vehicle;
    /* What this machine's run returned, so a thread's joiner need not unpack
     * a void*.  See main.c. */
    int exitCode;
    /* The crew mode switch as this machine last saw it, and whether it has
     * reported a position yet.  Per computer: each has its own column on the
     * panel and its own HALT->STBY edge, and sharing these let one machine's
     * panel reading release another's reset. */
    uint32_t prevMode;
    /* The CAM diagonal's latch: two votes against this computer were seen.
     * Cleared when the mode switch goes to HALT, the nearest the emulator
     * has to the hardware latch's reset.  See DISCRETES_REG_CFAIL. */
    /* What rtPacer has written off, in simulated microseconds: the time of
     * day the timing unit adds back.  See batchrunner_resync. */
    double writtenOffUs;
    bool modeReported;
    /* mode_switch_held()'s memo, keyed on this machine's discrete bus
     * generation -- see the comment there. */
    unsigned modeHeldGen;
    unsigned modePollCalls;   /* gates the socket look -- see mode_switch_held */
    bool modeHeldLast;
    /* The crew panel gone quiet while this machine was running: it rides
     * through on its last position until YAGPC_DISCRETES_HOLD_SEC, then is
     * held (see mode_switch_held_uncached). */
    bool panelSilent;
    bool panelSilentHeld;
    /* Set while the mode switch holds this machine in reset, so the pacer can
     * be re-tied on the way out -- see batchrunner_step. */
    bool modeWasHeld;
    /* A SNAPSHOT PUT OFF because the set was mid-transfer -- see
     * vehicle_io_agrees.  Counted down in batchrunner_step; when it reaches
     * one the capture is asked for again. */
    long snapRetryIn;
    int snapRetries;
    /* When the bus sockets were last drained and flushed, in SIMULATED
     * microseconds -- see batchrunner_step()'s bus-service gate. */
    double busServiceUs;
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
    struct MmuModel *mmuModel[2];
    struct MtuModel *mtuModel;  /* --mtu-model: the in-process timing unit */
    struct DeuModel *deuModelExtra[DEU_EXTRA_MAX]; /* --deu-bus list */
    int nDeuModelExtra;
    BusRouter busRouter;   /* --deu-model: the in-process display unit */
    /* --dump-state's triggers, armed from the environment in
     * batchrunner_init.  Per computer -- see Triggers. */
    Triggers trig;
} BatchRunner;

void batchrunner_init(BatchRunner *r, const Options *opts,
                      struct Vehicle *vehicle, int gpcId);
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
