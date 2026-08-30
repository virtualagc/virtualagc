#define _POSIX_C_SOURCE 200809L /* sigsuspend(), timer_create()/timer_settime() -- see batchrunner_pace_signal_setup() */
#include "run.h"

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "compat.h"
#include "cpu_instr.h"
#include "discretes.h"
#include "mtumodel.h"
#include "mmumodel.h"
#include "strfmt.h"
#include "trace.h"

static void halucp_error_cb(void *ctx, const char *msg) {
    (void)ctx;
    fprintf(stderr, "\n*** %s\n\n", msg);
}

/* Safety bound on batchrunner_step()'s "keep the clock ticking while
 * WAITing for an armed timer" loop (see its own comment) -- guards
 * against a clock that's armed but masked off, which for real hardware is
 * also a genuine deadlock, not something this emulator should spin on
 * forever. Matches the existing --debug maxSteps cap (see
 * batchrunner_init(), below) as the codebase's established "give a slow
 * but real case room, but still bound it" scale. */
#define WAIT_TICK_LIMIT 10000000L

/* Bus routing.  The mass memory model owns exactly one bus; everything
 * else goes wherever it would have gone with no model installed, so
 * --mmu-model composes with --bce-network and --deu-model rather than
 * displacing them. */
void bus_router_service(void *ctx, GpcServiceNumber svc,
                        const GpcServiceInput *in, GpcServiceOutput *out) {
    BusRouter *br = (BusRouter *)ctx;
    if (!br || !in || !out) return;
    if (br->mmu && in->busID == br->mmuBus) {
        mmumodel_service(br->mmu, svc, in, out);
        return;
    }
    if (br->mtu && mtumodel_owns_bus(in->busID)) {
        mtumodel_service(br->mtu, svc, in, out);
        return;
    }
    if (br->deu2 && in->busID == br->deu2Bus) {
        deumodel_service(br->deu2, svc, in, out);
        return;
    }
    if (br->fallback) {
        br->fallback(br->fallbackCtx, svc, in, out);
        return;
    }
    /* No peripheral on that bus, which is the truth. */
    switch (svc) {
    case GPC_SVC_XMIT_CMD:
    case GPC_SVC_XMIT_WORD: out->out.xmit.ok = true; break;
    case GPC_SVC_RECV_POLL: out->out.poll.available = false; break;
    case GPC_SVC_RECV_WORD: out->out.recv.available = false; break;
    default: break;
    }
}

void batchrunner_init(BatchRunner *r, const Options *opts) {
    memset(r, 0, sizeof(*r));
    r->opts = opts;
    r->maxSteps = atol(opts->maxSteps);
    /* 0 means "no limit", as `gpc run --max-steps 0` does -- which is how
     * a --real-time run against live peripherals is started, since there
     * is no sensible instruction count for "until I stop it". */
    if (r->maxSteps == 0) r->maxSteps = LONG_MAX;
    if (opts->breakAddr) {
        const char *s = opts->breakAddr;
        if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) s += 2;
        r->breakpoint = (uint32_t)strtoul(s, NULL, 16);
        r->hasBreakpoint = true;
    }
    r->watchLog = opts->watchLog;
    r->outputPath = opts->outputPath;
    r->dumpInterval = atol(opts->dumpInterval);
    r->traceEnabled = opts->trace;
    r->verbose = opts->verbose;
    r->interactive = opts->interactive;
    r->timeScale = atof(opts->timeScale);
    if (r->timeScale <= 0.0) {
        fprintf(stderr, "error: --time-scale must be > 0 (got '%s')\n", opts->timeScale);
        exit(1);
    }
    if (strcmp(opts->pacing, "burst") == 0) {
        r->pacingMode = PACING_BURST;
    } else if (strcmp(opts->pacing, "signal") == 0) {
        r->pacingMode = PACING_SIGNAL;
    } else {
        fprintf(stderr, "error: --pacing expects 'burst' or 'signal' (got '%s')\n", opts->pacing);
        exit(1);
    }

    r->realTime = opts->realTime;
    if (r->realTime) {
        /* Initialised here so the baseline starts with the run, not with
         * whatever setup precedes it. */
        rtpacer_init(&r->rtPacer, &r->age.gpc.cpu,
                     atof(opts->rtFactor), atof(opts->rtIdleTimeout));
    }

    r->debugMode = opts->debug;
    r->dbg = opts->debug ? debugger_create(opts) : NULL;
    if (opts->debug && strcmp(opts->maxSteps, "100000") == 0) {
        /* The batch default is too tight for an interactive debugging
         * session left running via 'continue' -- bump it to match
         * cmd_debug.coffee's own much larger default (10000000), unless
         * the user explicitly passed --max-steps themselves. */
        r->maxSteps = 10000000;
    }

    ageharness_init(&r->age);
    r->age.halUCP.verbose = r->verbose;
    r->age.halUCP.cbCtx = NULL;
    r->age.halUCP.errorCallback = halucp_error_cb;

    iohost_init_from_opts(&r->iohost, &r->age.halUCP, opts);

    GpcServicerFn base = NULL;
    void *baseCtx = NULL;

    /* BEFORE any socket is opened: every bus port derives from this base,
     * so a second emulation can be given its own range and run alongside
     * the first.  Bus n is base+n, the discrete bus base+80. */
    if (opts->portBase != NULL && *opts->portBase != '\0') {
        char *end = NULL;
        long v = strtol(opts->portBase, &end, 10);
        if (end == NULL || *end != '\0' || v <= 0 || v >= 65536 - 100) {
            fprintf(stderr, "--port-base: expected a port number, got \"%s\"\n",
                    opts->portBase);
            exit(1);
        }
        yagpc_set_port_base((int)v);
    }

    if (opts->deuModel) {
        /* Deliberately instead of, not alongside, the network servicer:
         * only one thing can sit on the far end of the bus, and the
         * point of this one is that no socket is involved. */
        /* In this process, so the socket-latency floor does not apply:
         * honour the bus program's own message timeout exactly. */
        iop_set_recv_timeout_floor_us(0.0);
        r->deuModel = deumodel_create(6);   /* DK1 */
        base = deumodel_service;
        baseCtx = r->deuModel;
    } else if (opts->bceNetwork) {
        r->bceTransport = bcenet_transport_create();
        r->bceFramer = bcenet_framer_create(r->bceTransport);
        base = bcenet_framer_service;
        baseCtx = r->bceFramer;
    }

    /* The mass memory model takes ONE bus and leaves the rest alone, so a
     * run can have a reproducible tape and still drive a real display
     * over --bce-network.  That is the difference from --deu-model, which
     * replaces the far end of everything. */
    /* The MTU answers on its own buses (20-22) and leaves the rest alone,
     * like the mass memory model.  PASS reads it to initialise its clock;
     * with nothing there the clock came out as 24 hours (see mtumodel.h). */
    /* A SECOND display unit, on a bus of its own.  The orbiter has several
     * DEUs; we modelled one, on DK1 -- which is the very bus PASS hands to
     * the BFS when the BFC CRT switch names CRT 1, so the only display we
     * had was the one PASS was obliged to give up.  GPCIPL still runs its
     * menu on DK1; this is the one PASS itself can drive. */
    if (opts->deuBus != NULL && *opts->deuBus != '\0') {
        long b = strtol(opts->deuBus, NULL, 10);
        if (b > 0 && b <= 24) {
            r->deuModel2 = deumodel_create((int)b);
            r->busRouter.deu2 = r->deuModel2;
            r->busRouter.deu2Bus = (int)b;
        }
    }

    if (opts->mtuModel) {
        r->mtuModel = mtumodel_create();
        if (r->mtuModel)
            mtumodel_set_clock(r->mtuModel, &r->age.gpc.cpu.elapsedTimeUs);
    }

    if (opts->mmuModelVolume || r->mtuModel || r->deuModel2) {
        long unit = opts->mmuModelUnit ? strtol(opts->mmuModelUnit, NULL, 10) : 1;
        r->mmuModel = opts->mmuModelVolume
                          ? mmumodel_create((int)unit, opts->mmuModelVolume)
                          : NULL;
        if (r->mmuModel || r->mtuModel || r->deuModel2) {
            if (r->mmuModel)
                mmumodel_set_clock(r->mmuModel, &r->age.gpc.cpu.elapsedTimeUs);
            if (base == NULL) iop_set_recv_timeout_floor_us(0.0);
            r->busRouter.mmu = r->mmuModel;
            r->busRouter.mmuBus = r->mmuModel ? mmumodel_bus(r->mmuModel) : -1;
            r->busRouter.mtu = r->mtuModel;
            r->busRouter.deu2 = r->deuModel2;
            r->busRouter.fallback = base;
            r->busRouter.fallbackCtx = baseCtx;
            ap101_set_servicer(&r->age.gpc, bus_router_service, &r->busRouter);
        } else if (base) {
            ap101_set_servicer(&r->age.gpc, base, baseCtx);
        }
    } else if (base) {
        ap101_set_servicer(&r->age.gpc, base, baseCtx);
    }

    /* Independent of the peripheral bus: discretes are their own bus, and
     * a run may want them with or without --bce-network.  Failing to open
     * is not fatal -- iop.c keeps deriving what it can. */
    if (opts->discretes) discretes_open();
}

void batchrunner_free(BatchRunner *r) {
    if (discretes_enabled()) {
        fprintf(stderr, "discretes: %lu message(s) applied\n",
                discretes_message_count());
        discretes_close();
    }
    if (r->mmuModel) {
        mmumodel_report(r->mmuModel);
        mmumodel_free(r->mmuModel);
        r->mmuModel = NULL;
    }
    if (r->deuModel) {
        deumodel_report(r->deuModel);
        deumodel_free(r->deuModel);
        r->deuModel = NULL;
    }
    if (r->deuModel2) {
        fprintf(stderr, "deu2 (bus %d): ", r->busRouter.deu2Bus);
        deumodel_report(r->deuModel2);
        deumodel_free(r->deuModel2);
        r->deuModel2 = NULL;
    }
    if (r->mtuModel) {
        mtumodel_report(r->mtuModel);
        mtumodel_free(r->mtuModel);
        r->mtuModel = NULL;
    }
    for (size_t i = 0; i < r->lineCount; i++) free(r->lines[i]);
    free(r->lines);
    iohost_free(&r->iohost);
    ageharness_free(&r->age);
    if (r->dbg) debugger_free(r->dbg);
    if (r->bceFramer) bcenet_framer_free(r->bceFramer);
    if (r->bceTransport) bcenet_transport_free(r->bceTransport);
    memset(r, 0, sizeof(*r));
}

static void batchrunner_write(BatchRunner *r, const char *s) {
    if (r->outputPath) {
        if (r->lineCount >= r->lineCap) {
            r->lineCap = r->lineCap ? r->lineCap * 2 : 64;
            r->lines = realloc(r->lines, r->lineCap * sizeof(char *));
        }
        r->lines[r->lineCount++] = yagpc_strdup(s);
    } else {
        fputs(s, stdout);
        fputc('\n', stdout);
    }
}

static void batchrunner_info(BatchRunner *r, const char *s) {
    if (r->verbose) batchrunner_write(r, s);
}

static void batchrunner_flush(BatchRunner *r) {
    if (r->outputPath && r->lineCount > 0) {
        FILE *f = fopen(r->outputPath, "wb");
        if (f) {
            for (size_t i = 0; i < r->lineCount; i++) {
                fputs(r->lines[i], f);
                fputc('\n', f);
            }
            fclose(f);
        }
    }
    iohost_close(&r->iohost);
}

static void batchrunner_fatal(BatchRunner *r, const char *msg) {
    fprintf(stderr, "FATAL: %s\n", msg);
    /* Called both before the run starts (nothing buffered yet, harmless
     * no-op) and mid-run (e.g. a READ on a channel with no --infileN) --
     * in the latter case the program may already have unflushed WRITE
     * output on some other channel; same reasoning as run.c's other
     * halucp_flush_all_pending() call sites. */
    halucp_flush_all_pending(&r->age.halUCP);
    batchrunner_flush(r);
    exit(1);
}

static void reg_dump_lines(BatchRunner *r, long step, char lines[TRACE_REGDUMP_LINES][200]) {
    trace_format_reg_dump(&r->age.gpc.cpu, (int)step, &TRACE_COLOR_PLAIN, lines, sizeof(lines[0]));
}

static void write_reg_dump(BatchRunner *r, long step) {
    char lines[TRACE_REGDUMP_LINES][200];
    reg_dump_lines(r, step, lines);
    for (int i = 0; i < TRACE_REGDUMP_LINES; i++) batchrunner_write(r, lines[i]);
}

static void info_reg_dump(BatchRunner *r, long step) {
    char lines[TRACE_REGDUMP_LINES][200];
    reg_dump_lines(r, step, lines);
    for (int i = 0; i < TRACE_REGDUMP_LINES; i++) batchrunner_info(r, lines[i]);
}

static void batchrunner_format_trace_line(BatchRunner *r, long step, uint32_t nia, uint32_t hw1, uint32_t hw2,
                                           const char *disasm, int instrLen, const RegChange *changes, int changeCount,
                                           char *out, size_t outSize) {
    /* Elapsed time and wrapping are both --debug-only presentation
     * choices (see cpu.h's elapsedTimeUs comment and src/debugger.h) --
     * plain --trace passes NULL/0 here, so trace_format_debug_line()
     * omits the T= field and never wraps, same as before this was
     * extracted into a function shared with gpcops.c's embedded engine. */
    const double *timePtr = r->debugMode ? &r->age.gpc.cpu.elapsedTimeUs : NULL;
    int lineWidth = r->debugMode ? debugger_line_width(r->dbg) : 0;
    trace_format_debug_line(out, outSize, step, nia, hw1, hw2, disasm, instrLen, changes, changeCount,
                             r->age.sym.loaded ? &r->age.sym : NULL, timePtr, lineWidth);
}

static long batchrunner_load(BatchRunner *r) {
    ConfigureResult res;
    ageharness_configure_from_opts(&r->age, r->opts->fcmPath, r->opts, &res);
    /* With no .fcm there is nothing in store yet and so no entry point to
     * have: the bootstrap arrives when IPL is pressed, and the address it
     * starts at comes from its own System Reset PSW when HALT is released.
     * Demanding one here would be demanding it before it can exist. */
    if (!r->opts->fcmPath) return 0;
    if (!res.hasEntryPoint) {
        batchrunner_fatal(r, "No entry point: use --start=ADDR or provide a symbols file with a START symbol");
    }
    r->entryPoint = res.entryPoint;
    if (r->age.sym.loaded) {
        char msg[512];
        snprintf(msg, sizeof msg, "Symbols: %s (%d symbols, %d sections)",
                 r->age.lastSymbolsPath ? r->age.lastSymbolsPath : "", r->age.sym.symbolCount, r->age.sym.sectionCount);
        batchrunner_info(r, msg);
    }
    return res.byteCount;
}

/* channel==-1 -> "no channel" (used before HalUCP ever emits real
 * output); useRawStdout(6) always true regardless of @interactive per
 * `(not @interactive) or ch == '6'`. */
static bool use_raw_stdout(BatchRunner *r, int channel) {
    return (!r->interactive) || channel == 6;
}

static void batchrunner_handle_output(void *ctx, const char *text, int channel) {
    BatchRunner *r = ctx;
    if (channel >= 0 && channel < IOHOST_MAX_CHANNEL && r->iohost.outStreams[channel]) {
        fputs(text, r->iohost.outStreams[channel]);
        return;
    }
    if (use_raw_stdout(r, channel)) {
        fputs(text, stdout);
    } else {
        printf("OUTPUT(%d): %s\n", channel, text);
    }
}

static void batchrunner_init_io(BatchRunner *r) {
    iohost_init(&r->iohost, r->age.sym.loaded ? &r->age.sym : NULL);
    /* IOHost#init already wired halUCP.outputCallback to its own
     * handleOutput (file-write only); BatchRunner overrides it with the
     * combined (file XOR stdout) behavior — see run.h's header comment. */
    r->age.halUCP.cbCtx = r;
    r->age.halUCP.outputCallback = batchrunner_handle_output;
}

static const char *batchrunner_read_input_line(BatchRunner *r, int channel, int iocode) {
    if (!iohost_has_file_configured(&r->iohost, channel)) {
        char msg[256];
        snprintf(msg, sizeof msg, "Program requests input on channel %d (%s) but no --infile%d was provided",
                 channel, halucp_iocode_type_name(iocode), channel);
        batchrunner_fatal(r, msg);
    }
    return iohost_read_input_line(&r->iohost, channel);
}

static void batchrunner_input_cb(void *ctx, int channel, int iocode) {
    BatchRunner *r = ctx;
    const char *line = batchrunner_read_input_line(r, channel, iocode);
    if (line) {
        halucp_provide_input(&r->age.halUCP, line);
    } else {
        halucp_provide_eof(&r->age.halUCP);
    }
}

static void print_section_map(BatchRunner *r) {
    if (!r->age.sym.loaded) return;
    batchrunner_info(r, "=== SECTION MAP ===");
    for (int i = 0; i < r->age.sym.sectionCount; i++) {
        const Section *s = &r->age.sym.sections[i];
        char lo[16], hi[16], nameP[16], msg[256];
        as_hex(lo, sizeof lo, (long long)s->address, 4);
        as_hex(hi, sizeof hi, (long long)(s->address + s->size - 1), 4);
        str_rpad(nameP, sizeof nameP, s->name, " ", 12);
        snprintf(msg, sizeof msg, "  0x%s - 0x%s  %s (%s)", lo, hi, nameP, s->module ? s->module : "");
        batchrunner_info(r, msg);
    }
    char startHex[16], off[64], msg[256];
    as_hex(startHex, sizeof startHex, (long long)r->entryPoint, 4);
    symtable_format_section_offset(&r->age.sym, r->entryPoint, off, sizeof off);
    snprintf(msg, sizeof msg, "  Start: 0x%s (%s)", startHex, off);
    batchrunner_info(r, msg);
    batchrunner_info(r, "");
}

typedef struct {
    uint32_t *addrs;
    int count;
} WatchAddrs;

static WatchAddrs build_watch_addrs(const Options *opts) {
    WatchAddrs wa = {NULL, 0};
    if (opts->watchCount == 0) return wa;
    int cap = 16;
    wa.addrs = malloc((size_t)cap * sizeof(uint32_t));
    for (size_t i = 0; i < opts->watchCount; i++) {
        for (long c = 0; c < opts->watch[i].count; c++) {
            if (wa.count >= cap) {
                cap *= 2;
                wa.addrs = realloc(wa.addrs, (size_t)cap * sizeof(uint32_t));
            }
            wa.addrs[wa.count++] = (uint32_t)(opts->watch[i].addr + c);
        }
    }
    return wa;
}

static void format_watchpoint_msg(BatchRunner *r, uint32_t addr, uint16_t before, uint16_t after16,
                                   const char *disasm, uint32_t nia, long step, const RegSnapshot *after,
                                   char *out, size_t outSize) {
    char addrHex[16], beforeHex[16], afterHex[16], niaHex[16];
    as_hex(addrHex, sizeof addrHex, (long long)addr, 5);
    as_hex(beforeHex, sizeof beforeHex, (long long)before, 4);
    as_hex(afterHex, sizeof afterHex, (long long)after16, 4);
    as_hex(niaHex, sizeof niaHex, (long long)nia, 5);
    const char *section = symtable_get_section_at(&r->age.sym, nia);
    char sectionPart[80];
    if (section) snprintf(sectionPart, sizeof sectionPart, " (%s)", section);
    else sectionPart[0] = '\0';
    /* All eight, not a subset.  Chasing which value an instruction wrote
     * to a watched halfword means reading the register it came FROM, and a
     * trace that happens to omit that one is no use at all. */
    char regs[8][16], regPart[160];
    size_t used = 0;
    regPart[0] = '\0';
    for (int i = 0; i < 8; i++) {
        as_hex(regs[i], sizeof regs[i], (long long)after->r[i], 8);
        int n = snprintf(regPart + used, sizeof regPart - used, " R%d=%s", i, regs[i]);
        if (n < 0 || (size_t)n >= sizeof regPart - used) break;
        used += (size_t)n;
    }
    snprintf(out, outSize,
             "memory watchpoint: HW 0x%s changed 0x%s -> 0x%s by %s at NIA=0x%s step=%ld%s%s",
             addrHex, beforeHex, afterHex, disasm, niaHex, step, sectionPart, regPart);
}

/* Shared fetch/decode/execute step used by both batchrunner_run() and
 * batchrunner_run_interactive() — the single place a debugger hook can
 * be inserted (immediately before ap101_exec1(), before the HalUCP trap
 * check) with one integration point instead of two. Returns false if the
 * loop should stop (r->hasStopReason will be set), true to continue. */
/* Both defined further down; needed by the --real-time paced wait in
 * batchrunner_step(), which has to poll for Ctrl-C itself. */
static volatile sig_atomic_t g_sigint_received;
static void on_sigint(int sig);
static void interactive_report_and_exit(BatchRunner *r, const char *headerFmt, long step, int exitCode);

/* The GPC MODE switch -- HALT / STBY / RUN -- modelled as the reset line
 * it actually is.
 *
 * It is NOT a discrete input the software reads: FCMBOOT never tests these
 * bits, and grepping the whole module finds only a comment about them.  It
 * is hardware.  PASS User's Guide 2.3:
 *
 *   3.1  HALT mode - "the GPC is in a hardware RESET controlled state.  No
 *        software can be executed."
 *   3.2  STBY mode - "When entered from HALT, this mode causes the hardware
 *        to be released from the RESET state giving control to the
 *        software.  If IPL occurred, control will be given to the
 *        Bootstrap Loader program."
 *
 * Carrying it on the discrete bus regardless is deliberate.  It is the
 * panel switch a person actually throws; this emulator has to know its
 * position to honour it at all; and discrete register A already documents
 * bits 0-2 as exactly this switch, so there is a natural place to put it.
 * Modelling it "as something like a discrete input" is what makes the
 * state knowable rather than implicit in a command-line flag.
 *
 * Without --discretes nothing reads these bits at all and the machine runs
 * exactly as before, so this only ever takes effect when the run asked for
 * a crew panel.  WITH it, silence reads as HALT: see mode_switch_held. */
#define MODE_HALT 0x80000000u   /* IBM bit 0 */
#define MODE_STBY 0x40000000u   /* IBM bit 1 */
#define MODE_RUN  0x20000000u   /* IBM bit 2 */
#define MODE_IPL  0x10000000u   /* IBM bit 3 -- the GPC IPL pushbutton */
#define MODE_ANY  (MODE_HALT | MODE_STBY | MODE_RUN | MODE_IPL)

/* Which mass memory the IPL reads from: register A bits 4 and 5, "MM1 /
 * MM2 selected as the IPL source".  Same bits the crew panel drives and
 * Don's gpc documents in iop.coffee. */
#define MODE_SRC_MM1 0x08000000u
#define MODE_SRC_MM2 0x04000000u

/* The GPC IPL BOOTSTRAP COPY, per CON80's own MMUDAT1:
 *
 *     FMAIPL2  ALOCDESC,'GPC IPL BOOTSTRAP COPY';
 *     FMAIPL2  ALLOC,ADDR=44500,BLKS=72,INIT=C6C6,SYSID=SYS1;
 *
 * A CON80 card address is FTSBB -- FILE, TRACK, subfile, two-digit block;
 * the phase manifest fixes that order (card 43000 is track 3/file 4).  So
 * 44500 is file 4, track 4, subfile 5, block 0 -- which both digits being
 * 4 makes insensitive to the order, though other allocations are not.
 * The 72 is the
 * RESERVATION; how much of it the bootstrap actually occupies comes from
 * the tape, not from here (see mmumodel_read_blocks). */
#define BOOT_TRACK 4
#define BOOT_FILE 4
#define BOOT_SUBFILE 5
#define BOOT_BLOCK 0
#define BOOT_ALLOC_BLOCKS 72
#define MM_HALFWORDS_PER_BLOCK 512

/* Position last seen, so the HALT->STBY EDGE can be caught: it is the
 * transition, not the level, that releases reset and starts the
 * bootstrap. */
static uint32_t g_prevMode = 0;
static bool g_modeReported = false;

/* The firmware IPL, driven from the panel's IPL position.
 *
 * Only when no .fcm was named.  With one, the image came from a file and
 * reloading it off the tape would silently replace what the run was asked
 * to execute -- so that case behaves exactly as it always has.
 *
 * Table 2-2 splits what one might expect to be a single act across two
 * controls: step 10 (GPC IPL - P/R) fills memory and reads the bootstrap
 * in, and step 11 (GPC to STBY) is what releases reset and lets it run.
 * They are kept apart here for the same reason, which is not pedantry:
 * FCMBOOT's External Zero handler sets the WAIT bit in its own System
 * Reset PSW (FCMBOOT.asm, `OST R5,FCMBSYRS+2`), so a machine that has
 * already booted parks on the next release rather than re-running the
 * mover.  Re-executing is possible only because a fresh IPL puts a
 * pristine copy back.  Collapsing the two would make that unreachable. */
/* The mass memory's own interface address, and the command fields
 * mmumodel.c's on_command() decodes.  A command is 24 bits: IUA, then a
 * 4-bit opcode, then operands. */
#define MM_IUA 11
#define MM_OP_POSITION 0x0
#define MM_OP_EXTENDED_BLOCK 0x3
#define MM_OP_READ 0x9
#define MM_BUS_WORD_US 33.0     /* one word time; mmumodel.c's own figure */

static uint32_t mm_cmd(int opcode, uint32_t operands) {
    return ((uint32_t)MM_IUA << 19) | ((uint32_t)(opcode & 0xf) << 15) |
           (operands & 0x7fffu);
}

/* Everything below talks to the mass memory through THE INSTALLED
 * SERVICER, not to any particular implementation of one.
 *
 * The in-process model is not the only mass memory this has to work with:
 * Don's is a separate process on the far end of --bce-network, and a real
 * one is a separate box.  They are all reached the same way, which is the
 * point of the servicer -- run.c's own bus_router_service already sends
 * the MM bus to the model when there is one and to the network when there
 * is not.  Calling mmumodel_service() directly would have quietly made
 * this work with exactly one of them. */
static void mm_service(BatchRunner *r, GpcServiceNumber svc, int busID,
                       uint32_t word, GpcServiceOutput *out) {
    GpcServiceInput in;
    memset(&in, 0, sizeof in);
    memset(out, 0, sizeof *out);
    in.busID = busID;
    in.in.word = word;
    IOP *iop = &r->age.gpc.iop;
    if (iop->servicer) iop->servicer(iop->servicerCtx, svc, &in, out);
}

static void mm_send_cmd(BatchRunner *r, int busID, uint32_t cmd) {
    GpcServiceOutput out;
    mm_service(r, GPC_SVC_XMIT_CMD, busID, cmd, &out);
}

/* The firmware IPL, driven from the panel's IPL pushbutton.
 *
 * Only when no .fcm was named.  With one, the image came from a file and
 * reloading it off the tape would silently replace what the run was asked
 * to execute -- so that case behaves exactly as it always has.
 *
 * THIS GOES OVER THE BUS, like everything else that reaches the mass
 * memory.  The MMU is a separate box from the GPC and there is no other
 * path to it; the microcode is not running BCE programs out of GPC store,
 * but it still drives the same interface, issues the same POSITION and
 * READ, and collects the same words a bus program would.  Reading the
 * volume directly would model a wire that does not exist -- and it also
 * left the MM READY discrete undisturbed, so a load left no sign of
 * itself on the crew panel.  Going through the bus makes READY fall and
 * rise on its own, because it is derived from the very queue this drains.
 *
 * Table 2-2 splits what one might expect to be a single act across two
 * controls: step 10 (GPC IPL - P/R) fills memory and reads the bootstrap
 * in, and step 11 (GPC to STBY) releases reset and lets it run.  They are
 * kept apart here for the same reason, which is not pedantry: FCMBOOT's
 * External Zero handler sets the WAIT bit in its own System Reset PSW
 * (FCMBOOT.asm, `OST R5,FCMBSYRS+2`), so a machine that has already
 * booted parks on the next release rather than re-running the mover.
 * Re-executing is possible only because a fresh IPL puts a pristine copy
 * back.  Collapsing the two would make that unreachable. */
static void firmware_ipl(BatchRunner *r) {
    if (r->opts->fcmPath) return;
    if (!r->age.gpc.iop.servicer) {
        fprintf(stderr, "MODE: IPL, but no mass memory is attached; "
                        "nothing to read a bootstrap from\n");
        return;
    }
    /* The panel says which unit to IPL from -- register A bits 4 and 5 --
     * and that picks the BUS, MM1 being BCE 18 and MM2 BCE 19.  It is the
     * bus number rather than any local object that identifies the unit,
     * which is what lets the far end be Don's process or a real box.
     *
     * IPL SOURCE SELECT HAS AN OFF POSITION, and it is not decorative:
     * Table 2-2 step 14 turns it off after the IPL, to remove the mask and
     * let the software reach the MMU.  A panel driving those bits with
     * both clear is therefore saying "no source", and an IPL then has
     * nowhere to read from -- quietly falling back to MM1 would invent a
     * selection nobody made.  Bits nobody drives at all are a different
     * thing and still mean MM1, so a run with no crew panel is unchanged. */
    /* Read the source bits from the discrete register itself.  `mode` is
     * masked down to MODE_ANY -- the switch and the pushbutton -- so it
     * never carries bits 4 and 5, and testing them there always answers
     * "no": it would refuse every IPL, and before that it had been
     * silently choosing MM1 for an MM2 selection. */
    uint32_t srcDriven = 0, srcVal = 0;
    if (discretes_enabled()) {
        srcDriven = discretes_driven_mask(DISCRETES_REG_A)
                    & (MODE_SRC_MM1 | MODE_SRC_MM2);
        srcVal = discretes_value(DISCRETES_REG_A) & srcDriven;
    }
    if (srcDriven && !srcVal) {
        fprintf(stderr, "MODE: IPL, but IPL SOURCE SELECT is OFF; "
                        "no mass memory to read from\n");
        return;
    }
    int unit = (srcVal & MODE_SRC_MM2) ? 2 : 1;
    int busID = (unit == 2) ? 19 : 18;

    size_t nhw = (size_t)BOOT_ALLOC_BLOCKS * MM_HALFWORDS_PER_BLOCK;
    uint16_t *image = calloc(nhw, sizeof *image);
    if (!image) return;

    /* POSITION names the track, subfile and file; READ then names the
     * block and a 4-bit count, which EXTENDED BLOCK widens to 8 -- and
     * transfer_blocks() reads that as count+1, so 71 asks for 72. */
    mm_send_cmd(r, busID, mm_cmd(MM_OP_POSITION,
                                 ((uint32_t)BOOT_TRACK << 12) |
                                 ((uint32_t)BOOT_SUBFILE << 9) |
                                 ((uint32_t)BOOT_FILE << 1)));
    mm_send_cmd(r, busID, mm_cmd(MM_OP_EXTENDED_BLOCK, BOOT_ALLOC_BLOCKS - 1));
    mm_send_cmd(r, busID, mm_cmd(MM_OP_READ,
                                 ((uint32_t)BOOT_TRACK << 12) |
                                 ((uint32_t)BOOT_SUBFILE << 9) |
                                 ((uint32_t)BOOT_BLOCK << 4)));

    /* Collect the transfer.  The words are paced against the EMULATED
     * clock, which is not running: the CPU is held in reset, so nothing
     * is advancing it.  Time passes on a real machine while the tape
     * turns -- the firmware IPL is what leaves interval timer 1 running
     * in the first place -- so this advances it a word time at a time,
     * which is exactly what the transfer costs. */
    size_t got = 0;
    size_t guard = 0, guardMax = nhw * 4 + 4096;
    double startEmuUs = r->age.gpc.cpu.elapsedTimeUs;
    double startWall = yagpc_monotonic_seconds();
    double scale = (r->timeScale > 0.0) ? r->timeScale : 1.0;
    while (got < nhw && guard++ < guardMax) {
        GpcServiceOutput out;
        mm_service(r, GPC_SVC_RECV_WORD, busID, 0, &out);
        if (out.out.recv.available) {
            image[got++] = (uint16_t)(out.out.recv.word & 0xffff);
            /* Keep wall time alongside emulated time, a block at a time.
             *
             * Not decoration.  READY is what tells anyone at the panel
             * that the button did something, and a transfer drained flat
             * out drops it for about twenty milliseconds -- against a
             * panel that republishes every 250 ms, which is to say
             * invisibly.  The transfer really does take on the order of
             * two seconds of tape motion, so spending them is both what
             * makes the indicator readable and what the hardware does.
             * --time-scale still shortens it, as it does everywhere. */
            if ((got % MM_HALFWORDS_PER_BLOCK) == 0) {
                double owedSec = (r->age.gpc.cpu.elapsedTimeUs - startEmuUs)
                                 / 1e6 / scale;
                double spentSec = yagpc_monotonic_seconds() - startWall;
                if (owedSec > spentSec) yagpc_sleep_seconds(owedSec - spentSec);
                /* Only ours to drive.  A networked unit publishes its own
                 * READY, and overriding it from here would be this process
                 * asserting a discrete about somebody else's hardware. */
                if (r->mmuModel) mmumodel_publish_ready(r->mmuModel);
            }
            continue;
        }
        r->age.gpc.cpu.elapsedTimeUs += MM_BUS_WORD_US;
    }

    if (got == 0) {
        fprintf(stderr,
                "MODE: IPL, but this tape carries no bootstrap at the "
                "FMAIPL2 allocation (file %d/track %d/subfile %d/block %d).\n"
                "      tools/stamp_bootstrap_on_tape.py writes one there.\n",
                BOOT_FILE, BOOT_TRACK, BOOT_SUBFILE, BOOT_BLOCK);
        free(image);
        return;
    }
    ageharness_firmware_ipl(&r->age, image, (uint32_t)got);
    free(image);
    if (r->mmuModel) mmumodel_publish_ready(r->mmuModel);
    fprintf(stderr, "MODE: IPL; memory filled, bootstrap read from MM%d "
                    "(BCE %d) over the bus (%zu blocks, %zu halfwords) "
                    "to 0x00000\n",
            unit, busID, got / MM_HALFWORDS_PER_BLOCK, got);
}

/* True when the machine is held in reset and must not execute. */
static bool mode_switch_held(BatchRunner *r) {
    if (!discretes_enabled()) return false;
    discretes_poll();
    uint32_t driven = discretes_driven_mask(DISCRETES_REG_A);
    uint32_t mode = discretes_value(DISCRETES_REG_A) & driven & MODE_ANY;

    /* Silence is HALT, not RUN.  The mode switch is a three-position
     * switch somebody has to physically throw, it sits in HALT until they
     * do, and HALT holds the reset line -- so a GPC nobody has taken out
     * of HALT is a GPC that does not execute.  Reading "no publisher" as
     * "no position asserted, carry on" instead made the boot depend on
     * which process started first: bring the emulator up before the crew
     * panel and FCMBOOT had already run by the time the panel's first
     * HALT arrived.  It also meant closing the panel mid-run released the
     * machine 1.5 seconds later, when the bits went stale. */
    bool published = (driven & MODE_ANY) != 0;

    /* SILENCE HOLDS THE MACHINE, BUT IT IS NOT A SWITCH POSITION.
     *
     * This used to substitute MODE_HALT when nothing was being published
     * and then run the edge tests against it.  That manufactures a
     * HALT->STBY release out of nothing: lose one datagram, or let a Tk
     * panel fall behind DISCRETES_STALE_SEC once, and the next poll reads
     * "HALT" and the poll after that reads the panel's real STBY -- which
     * is an edge, so the CPU is reset.  It repeats for as long as the
     * gaps do, and a machine reset every second or two never gets
     * anywhere: this is why GPCIPL appeared not to run at all, and why
     * the terminal filled with mode changes nobody made at the panel.
     *
     * So edges are now taken ONLY between things the panel actually said.
     * A gap leaves the last known position standing, and when the panel
     * comes back saying what it always said, nothing has changed and
     * nothing happens -- which is the truth. */
    /* A switch is always SOMEWHERE.  The panel publishes one bit per
     * datagram, so between "clear the old position" and "set the new
     * one" there is an instant when no position is asserted at all -- and
     * polling every 2 ms lands in that instant often.  It is not a
     * position and must not be treated as a change; reporting it is what
     * put pairs of MODE lines in the terminal for a switch nobody
     * touched.  Hold, and wait for the panel to finish speaking. */
    if (published && !(mode & (MODE_HALT | MODE_STBY | MODE_RUN)))
        return true;

    if (!published) {
        if (!g_modeReported) {
            fprintf(stderr, "MODE: HALT; CPU held in reset "
                            "(no crew panel heard yet)\n");
            g_modeReported = true;
        }
        /* g_prevMode is deliberately left alone. */
        return true;
    }

    /* IPL IS NOT A MODE-SWITCH POSITION.  The mode switch is HALT / STBY /
     * RUN; the GPC IPL pushbutton is a SEPARATE momentary control, and it
     * is live only while the switch is in HALT -- Table 2-2 puts "GPC to
     * HALT mode" at step 4 and "GPC IPL - P/R" at step 10, with HALT still
     * standing.  So its bit is not exclusive of HALT's, it DEPENDS on it,
     * and the two are asserted together.  Pressing it in STBY or RUN is
     * not a thing the panel can do to a running machine. */
    if (mode != g_prevMode) {
        if (getenv("YAGPC_MODETRACE"))
            fprintf(stderr, "MODETRACE driven=%08x value=%08x mode=%08x prev=%08x\n",
                    driven, discretes_value(DISCRETES_REG_A), mode, g_prevMode);
        bool iplEdge = (mode & MODE_IPL) && !(g_prevMode & MODE_IPL);
        if (iplEdge && (mode & MODE_HALT)) {
            /* The pushbutton, on its press: pressing it again re-IPLs,
             * and holding it down does not repeat. */
            firmware_ipl(r);
        } else if (iplEdge) {
            fprintf(stderr, "MODE: IPL pressed but the mode switch is not "
                            "in HALT; ignored\n");
        } else if ((g_prevMode & MODE_HALT) && (mode & MODE_STBY)) {
            /* The release.  Reload the whole PSW pair from the System
             * Reset vector, which is what hands control to FCMBOOT. */
            cpu_reset(&r->age.gpc.cpu);
            fprintf(stderr, "MODE: HALT -> STBY; reset released, "
                            "starting at 0x%05x\n",
                    psw_get_nia(&r->age.gpc.cpu.psw));
        } else if (mode & MODE_HALT) {
            fprintf(stderr, "MODE: HALT; CPU held in reset\n");
        } else if (mode & (MODE_RUN | MODE_STBY)) {
            fprintf(stderr, "MODE: %s\n",
                    (mode & MODE_RUN) ? "RUN" : "STBY");
        }
        g_prevMode = mode;
        g_modeReported = true;
    }
    (void)g_modeReported;
    /* HALT alone decides this.  IPL cannot be pressed out of HALT, so a
     * machine being IPLed is already held by the switch itself. */
    return (mode & MODE_HALT) != 0;
}

static bool batchrunner_step(BatchRunner *r) {
    /* Before anything else: in HALT the machine executes nothing at all. */
    if (mode_switch_held(r)) {
        /* The peripherals are not in reset, though -- a mass memory sits
         * there READY with the GPC switched off, and its line says so.
         * Publishing it here as well as in the running path is what makes
         * a crew panel show something before the switch is ever moved,
         * which is the only sign a person has that this is running. */
        if (r->mmuModel) mmumodel_publish_ready(r->mmuModel);
        /* Nothing to do but wait for the switch to move; don't spin a
         * core doing it. */
        yagpc_sleep_seconds(0.002);
        return true;
    }

    RegSnapshot before, after;
    ageharness_snapshot_regs(&r->age, &before);
    uint32_t nia = psw_get_nia(&r->age.gpc.cpu.psw);

    if (r->traceEnabled && r->age.sym.loaded) {
        const char *currentSection = symtable_get_section_at(&r->age.sym, nia);
        if (currentSection && (!r->hasLastSection || strcmp(currentSection, r->lastSection) != 0)) {
            char line[300];
            snprintf(line, sizeof line, "--- ENTERING: %s ---", currentSection);
            batchrunner_write(r, line);
            r->hasLastSection = true;
            snprintf(r->lastSection, sizeof r->lastSection, "%s", currentSection);
        }
    }

    /* Under --debug, the debugger's own breakpoint table (seeded from
     * --break, if given -- see debugger_create()) replaces this single-
     * breakpoint mechanism rather than running alongside it as a second,
     * redundant check. */
    if (!r->debugMode && r->hasBreakpoint && nia == r->breakpoint) {
        char bpHex[16];
        as_hex(bpHex, sizeof bpHex, (long long)nia, 4);
        snprintf(r->stopReason, sizeof r->stopReason, "breakpoint at 0x%s", bpHex);
        r->hasStopReason = true;
        return false;
    }

    uint32_t hw1 = mcm_get16(&r->age.gpc.cpu.mainStorage, nia);
    uint32_t hw2 = mcm_get16(&r->age.gpc.cpu.mainStorage, nia + 1);

    char disasm[256];
    instr_to_str(hw1, hw2, disasm, sizeof disasm);
    DInstr v;
    const InstrDesc *d = instr_decode(hw1, hw2, &v);
    int instrLen = d ? d->pb.origLen : 1;

    bool traceWanted = r->traceEnabled || (r->debugMode && debugger_wants_htrace(r->dbg));

    if (!d) {
        if (traceWanted) {
            char line[400];
            batchrunner_format_trace_line(r, r->step, nia, hw1, hw2, "??? (invalid)", 1, NULL, 0, line, sizeof line);
            batchrunner_write(r, line);
        }
        char hexv[16];
        as_hex(hexv, sizeof hexv, (long long)hw1, 4);
        char niaHex[16];
        as_hex(niaHex, sizeof niaHex, (long long)nia, 4);
        cpu_dump_nia_ring(&r->age.gpc.cpu, "the invalid instruction", psw_get_nia(&r->age.gpc.cpu.psw));
        snprintf(r->stopReason, sizeof r->stopReason, "invalid instruction 0x%s at 0x%s", hexv, niaHex);
        r->hasStopReason = true;
        return false;
    }

    if (r->hasWatchpoints) {
        for (int i = 0; i < r->watchAddrCount; i++) {
            r->watchBefore[i] = (uint16_t)mcm_get16(&r->age.gpc.cpu.mainStorage, r->watchAddrs[i]);
        }
    }

    if (r->debugMode) {
        if (!debugger_hook(r->dbg, &r->age, nia, hw1, hw2, r->step)) return false;
        /* Re-derive traceWanted: debugger_hook()'s REPL (just run, above)
         * may have changed whether trace-style output is wanted for the
         * instruction about to execute -- e.g. dispatching 'step' turns
         * it on for exactly this instruction (see debugger_wants_htrace())
         * even though it read false when this function started, before
         * the command was dispatched. */
        traceWanted = r->traceEnabled || debugger_wants_htrace(r->dbg);
    }

    if (r->age.halUCP.active && halucp_is_trap_addr(&r->age.halUCP, nia)) {
        halucp_check_trap(&r->age.halUCP, nia); /* may synchronously block on stdin under --interactive */
    }

    ap101_exec1(&r->age.gpc);

    /* Drain the discrete bus periodically as well as on the reads
     * themselves.  The reads are what freshness actually depends on --
     * iop.c polls there, which is exactly when the value has to be
     * current -- but an image that seldom reads discretes would let
     * datagrams pile up in the socket buffer between reads, and would
     * show nothing at all under YAGPC_DISCRETETRACE while somebody was
     * flipping switches on a panel.  Every 1024 steps, so this is a
     * non-blocking syscall roughly a thousand times less often than an
     * instruction. */
    if (discretes_enabled() && (r->step & 0x3ff) == 0) {
        discretes_poll();
        /* And drive what this process's own devices put ON the bus.  The
         * mass memory's READY is a real line in the vehicle; publishing it
         * is what lets a crew panel show the tape working, and doubles as
         * the only outward sign that this emulator is running at all. */
        if (r->mmuModel) mmumodel_publish_ready(r->mmuModel);
    }

    /* Elapsed instruction time (cpu->elapsedTimeUs) is now accumulated
     * unconditionally inside cpu_exec1() itself, not just under --debug
     * -- see cpu.h's elapsedTimeUs comment. */

    /* --bce-network: flush whatever real-BCE-bus word traffic this one
     * instruction just generated as real UDP packets. Called here, once
     * per instruction unconditionally (not gated on --debug like
     * batchrunner_pace() below, which is a different concern) -- see
     * bcenet_framer.h's own comment on why per-tick flushing is the
     * right message-boundary signal. */
    if (r->bceFramer) bcenet_framer_flush_tick(r->bceFramer);

    ageharness_snapshot_regs(&r->age, &after);
    RegChange changes[REG_SNAPSHOT_MAX_CHANGES];
    int changeCount = ageharness_diff_regs(&before, &after, changes);
    int filteredCount = 0;
    RegChange filtered[REG_SNAPSHOT_MAX_CHANGES];
    for (int i = 0; i < changeCount; i++) {
        if (strcmp(changes[i].name, "NIA") != 0) filtered[filteredCount++] = changes[i];
    }

    if (traceWanted) {
        char line[2400];
        batchrunner_format_trace_line(r, r->step, nia, hw1, hw2, disasm, instrLen, filtered, filteredCount, line, sizeof line);
        batchrunner_write(r, line);
    }

    r->step++;

    if (r->traceEnabled && r->dumpInterval > 0 && r->step % r->dumpInterval == 0) {
        write_reg_dump(r, r->step);
        batchrunner_write(r, "");
    }

    if (r->hasWatchpoints) {
        for (int i = 0; i < r->watchAddrCount; i++) {
            uint16_t newVal = (uint16_t)mcm_get16(&r->age.gpc.cpu.mainStorage, r->watchAddrs[i]);
            if (newVal != r->watchBefore[i]) {
                char wmsg[512];
                format_watchpoint_msg(r, r->watchAddrs[i], r->watchBefore[i], newVal, disasm, nia, r->step, &after, wmsg, sizeof wmsg);
                if (r->watchLog) {
                    fprintf(stderr, "%s\n", wmsg);
                    r->watchBefore[i] = newVal;
                } else {
                    snprintf(r->stopReason, sizeof r->stopReason, "%s", wmsg);
                    r->hasStopReason = true;
                    break;
                }
            }
        }
        if (r->hasStopReason) return false;
    }

    if (psw_get_wait_state(&r->age.gpc.cpu.psw)) {
        /* Real hardware: entering WAIT suspends instruction fetch, but the
         * clock/interrupt facility keeps running underneath it -- an
         * already-armed Clock 1/2 (see cpu.h's counter1Enabled/
         * counter2Enabled) can independently underflow and fire, swapping
         * in a new PSW that clears the wait bit and resumes execution at
         * the handler (confirmed against BILDNEW5/GPCIPL's own real-time
         * setup sequence: LHI/ICR arms Clock 1 for 30us, SHW REALTIME,
         * then SSM WAITMASK enables the Clock 1 mask bit and enters WAIT
         * -- STM4010, the label right after, is real-time's own Clock-1
         * handler entry point per INTHNDLR.asm's own comments, so this is
         * a genuine "sleep until timer" idiom, not a stall). Advance the
         * clock via ap101_tick() (counter decrement + interrupt dispatch
         * + IOP step, no instruction fetch) until either the wait clears
         * or nothing armed could ever clear it -- the latter matches
         * every fixture in today's corpus, where wait state is really
         * just a HAL/S program's normal termination and neither counter
         * is ever enabled, so this loop does not even run for them. */
        /* A clock is not the only thing that can end a wait.  The IOP
         * keeps running (see ap101_tick), so an enabled processor still
         * working a bus -- or a real peripheral answering one through an
         * installed servicer -- can raise the interrupt that wakes the
         * CPU.  Ticking only while a counter happened to be armed gave up
         * immediately on exactly the case that matters: GPCIPL waiting on
         * the mass memory. */
        if (r->realTime) {
            /* Real time keeps flowing in the wait state: advance
             * SIMULATED time at the real-time rate until an interrupt
             * wakes the CPU.  This is the half that free-running the tick
             * loop below cannot do -- it advances the machine's clock as
             * fast as the host allows, which leaves any real peripheral
             * on the other end of a socket hopelessly behind.  See
             * rtpacer.h. */
            rtpacer_enter_idle(&r->rtPacer);
            RTPaceResult why;
            for (;;) {
                why = rtpacer_advance_idle(&r->rtPacer);
                /* The bus keeps running while the CPU waits, and its
                 * transmissions are paced against the wall clock, so they
                 * have to be released from here too -- the per-instruction
                 * flush below is never reached during a wait, which is
                 * where this machine spends most of its time. */
                if (r->bceFramer) bcenet_framer_flush_tick(r->bceFramer);
                if (why != RTPACE_WAITING) break;
                /* Ctrl-C has to be honoured here too: a paced wait can
                 * legitimately last seconds of wall time, and a loop that
                 * only checked between instructions would swallow it. */
                if (g_sigint_received) {
                    interactive_report_and_exit(r, "\n--- INTERRUPTED after %ld steps ---",
                                                r->step, 0);
                }
                yagpc_sleep_seconds(RTPACE_IDLE_POLL_SECONDS);
            }
            if (why != RTPACE_RESUMED) {
                snprintf(r->stopReason, sizeof r->stopReason,
                         "wait state (%s)", rtpacer_result_name(why));
                r->hasStopReason = true;
                return false;
            }
            return true;
        }

        long ticks = 0;
        while (psw_get_wait_state(&r->age.gpc.cpu.psw) &&
               (r->age.gpc.cpu.counter1Enabled || r->age.gpc.cpu.counter2Enabled ||
                iop_any_processor_running(&r->age.gpc.iop) ||
                iop_has_servicer(&r->age.gpc.iop)) &&
               ticks < WAIT_TICK_LIMIT) {
            ap101_tick(&r->age.gpc);
            ticks++;
        }
        if (psw_get_wait_state(&r->age.gpc.cpu.psw)) {
            snprintf(r->stopReason, sizeof r->stopReason, "wait state");
            r->hasStopReason = true;
            return false;
        }
    }

    return true;
}

/* How much virtual time (in cpu->elapsedTimeUs's own units, microseconds)
 * accumulates between wall-clock checks -- mirrors yaHALMAT2's own
 * HALMAT_REALTIME_BURST_MS (interp.c, same value: 50) exactly: "burst
 * execute some number of instructions, then sleep to let the operating
 * system do whatever else it needs to do, then execute a new burst ...
 * on a 50 or 100 millisecond cycle." A window this size keeps the
 * check-then-maybe-sleep overhead (one elapsedTimeUs subtraction per
 * step; the actual yagpc_monotonic_seconds() calls only happen once a
 * window's worth of virtual time has passed) negligible relative to
 * real instruction throughput, while staying tight enough that a human
 * watching the output can't tell it's not continuous. Shared by both
 * pacing implementations below (--pacing=burst/signal). */
#define PACING_WINDOW_MS 50.0

/* Wall-clock pacing for the standalone CLI's own instruction loop --
 * batchrunner_pace() (the shared dispatcher, below) is called after
 * every batchrunner_step() from both batchrunner_run() and
 * batchrunner_run_interactive(), skipped entirely under --debug (time
 * spent blocked on a debugger prompt must never count against real
 * time -- the same exclusion yaHALMAT2's interp_run_burst()/
 * interp_run_signal() make for their own debug_run()).
 *
 * Deliberately layered *outside* batchrunner_step()/ap101_exec1() rather
 * than baked into either: the CLI's own loop is just another consumer
 * of the same pure-virtual-time engine an embedding integrator (e.g. a
 * future Space Shuttle simulator, via yaGpcIntegration.h's GpcEngineFn)
 * would use, reading the exact same clock (cpu->elapsedTimeUs, exposed
 * to an integrator as GpcState.elapsedTime) an integrator would pace
 * itself against. This function's whole job is to demonstrate that
 * pattern, not to give the engine any wall-clock awareness of its own --
 * ap101_exec1()/yagpc2_engine() (gpcops.c) remain exactly as unaware of
 * real time as before.
 *
 * --pacing=burst (default): ref_wall/ref_virtual reset together every
 * time a window's worth of virtual time has accumulated since the last
 * check -- so the monotonic-clock read happens only ~20x/sec of
 * virtual-equivalent time, not once per instruction. This also
 * correctly handles sched_dispatch()'s own idle fast-forward
 * (schedule.c): a single batchrunner_step() call can jump
 * cpu->elapsedTimeUs a large amount at once when every task is
 * WAITING/DORMANT and nothing is immediately ready; that jump alone
 * crosses the window threshold, and the resulting sleep correctly
 * represents the real time equivalent to it -- no special-casing needed
 * here for that case.
 *
 * If a burst genuinely took longer in wall-clock terms than its
 * virtual-time equivalent (slow host, heavy/debug build, or a program
 * that's mostly real instruction execution rather than SCHEDULE/WAIT
 * fast-forwarding), target_wall_seconds > actual_wall_seconds is false,
 * nothing sleeps, and the reference pair simply resets to "now" -- no
 * catch-up/runaway-acceleration debt ever accumulates across windows. */
static void batchrunner_pace_burst(BatchRunner *r) {
    double elapsedVirtualUs = r->age.gpc.cpu.elapsedTimeUs - r->pacingRefVirtualUs;
    double windowUs = PACING_WINDOW_MS * 1000.0;
    if (elapsedVirtualUs < windowUs) return;

    double targetWallSeconds = (elapsedVirtualUs / 1e6) / r->timeScale;
    double actualWallSeconds = yagpc_monotonic_seconds() - r->pacingRefWallSeconds;
    if (targetWallSeconds > actualWallSeconds) {
        yagpc_sleep_seconds(targetWallSeconds - actualWallSeconds);
    }

    r->pacingRefWallSeconds = yagpc_monotonic_seconds();
    r->pacingRefVirtualUs = r->age.gpc.cpu.elapsedTimeUs;
}

/* --pacing=signal: the alternative, signal/timer-notification-driven
 * pacing implementation, added purely for direct side-by-side comparison
 * against batchrunner_pace_burst() above (both implement the exact same
 * pacing contract -- see PacingMode's own comment; select with
 * --pacing=signal). Where burst mode periodically *asks* "how much
 * wall-clock time has elapsed?" (a design whose reaction granularity is
 * bounded by how often it happens to check, i.e. PACING_WINDOW_MS), this
 * implementation is *notified*: a POSIX per-process real-time timer
 * (CLOCK_MONOTONIC, same clock source as burst mode -- must not be
 * affected by wall-clock/NTP adjustments) delivers a real-time signal on
 * a fixed schedule, and the CLI blocks (sigsuspend(), never a busy-poll)
 * until notified, rather than discovering drift only at its next
 * scheduled check. Ported from yaHALMAT2's own interp_run_signal()
 * (interp.c) essentially line-for-line -- same rationale throughout,
 * same window size, same idle-fast-forward special case below.
 *
 * SIGRTMIN+2 (a real-time signal), not SIGALRM: real-time signals queue
 * rather than coalescing multiple pending instances into one, so if a
 * batchrunner_step() call occasionally takes a while (a genuinely slow
 * instruction, or the idle-fast-forward case below) no tick
 * notifications are silently lost while the CLI is busy -- they are
 * delivered/counted once it catches up. (+2 rather than bare SIGRTMIN
 * on the untested-but-plausible theory that SIGRTMIN itself is the
 * first one anything else sharing this process might reach for --
 * matching yaHALMAT2's own reasoning exactly.)
 *
 * The signal handler (pacing_signal_handler, below) does *only*
 * `pacing_flag = 1` -- a static volatile sig_atomic_t, nothing else
 * touched, no calls into interpreter/CPU state -- the same async-
 * signal-safe pattern yaHALMAT2 uses. Race-free wait: the signal is
 * blocked up front (sigprocmask), then sigsuspend() atomically unblocks
 * it and sleeps until *some* unblocked signal arrives, closing the
 * check-then-sleep missed-wakeup window a naive "if (!pacing_flag)
 * sleep()" loop would leave open.
 *
 * Budget accounting: each timer firing grants
 * HALMAT_TICKS_PER_SECOND-equivalent budget (this codebase's
 * elapsedTimeUs is already in microseconds, so the "ticks" here are
 * just microseconds directly -- no separate ticks-per-second constant
 * needed) of PACING_WINDOW_MS * 1000 * timeScale microseconds -- exactly
 * batchrunner_pace_burst()'s own per-window virtual-time budget, for an
 * apples-to-apples comparison.
 *
 * Idle-fast-forward special case: sched_dispatch()'s own fast-forward
 * (schedule.c) can jump cpu->elapsedTimeUs far ahead in a single
 * batchrunner_step() call when every task is WAITING/DORMANT and
 * nothing is immediately ready. batchrunner_pace_burst() handles this
 * for free (its check is purely "how much virtual time has elapsed",
 * regardless of how it accumulated) -- but naively letting this fall
 * through here would mean looping on sigsuspend() through however many
 * real timer firings the gap represents (a 10-second idle gap at a 50ms
 * window is ~200 firings): correct, but needlessly granular for a jump
 * the CLI already knows about in one shot from a single elapsedTimeUs
 * read. Instead, once a step's consumed-virtual-time delta exceeds a
 * whole window's worth, this computes the equivalent real-time gap
 * directly (the same computation batchrunner_pace_burst() already does)
 * and sleeps that directly, then resumes normal signal-driven pacing for
 * the next window. */
#ifdef HAVE_POSIX_TIMERS

/* SIGRTMIN is not a compile-time constant on Linux glibc (it's a function
 * call, to allow for kernel-reserved real-time signals) -- fine, this is
 * only ever evaluated at runtime, never in a preprocessor conditional. */
#define YAGPC_PACING_RT_SIGNAL (SIGRTMIN + 2)

/* File-scope, not a BatchRunner field: only one BatchRunner is ever
 * paced per process (matches g_sigint_received's own existing pattern
 * in this file), and a signal handler can only safely touch static
 * storage duration objects anyway. */
static volatile sig_atomic_t g_pacing_flag = 0;
static timer_t g_pacing_timer;
static sigset_t g_pacing_old_mask;
static struct sigaction g_pacing_old_sa;
static double g_pacing_budget_us = 0.0;

static void pacing_signal_handler(int signo) {
    (void)signo;
    g_pacing_flag = 1;
}

/* Called once, before the run loop starts (batchrunner_run()/
 * batchrunner_run_interactive()) -- installs the signal handler, blocks
 * the real-time signal (only ever transiently unblocked inside
 * sigsuspend() below), and arms a repeating POSIX timer at
 * PACING_WINDOW_MS. Exits the process on any setup failure, matching
 * this codebase's "fail loudly, don't silently degrade" discipline
 * (mirrors yaHALMAT2's own fail()-and-return-error-code, adapted to
 * this codebase's exit()-on-fatal-error convention throughout run.c). */
static void batchrunner_pace_signal_setup(BatchRunner *r) {
    (void)r;
    g_pacing_flag = 0;
    g_pacing_budget_us = 0.0;

    sigset_t rtSet;
    sigemptyset(&rtSet);
    sigaddset(&rtSet, YAGPC_PACING_RT_SIGNAL);

    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = pacing_signal_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    if (sigaction(YAGPC_PACING_RT_SIGNAL, &sa, &g_pacing_old_sa) != 0) {
        fprintf(stderr, "error: --pacing=signal: sigaction failed: %s\n", strerror(errno));
        exit(1);
    }

    if (sigprocmask(SIG_BLOCK, &rtSet, &g_pacing_old_mask) != 0) {
        fprintf(stderr, "error: --pacing=signal: sigprocmask failed: %s\n", strerror(errno));
        sigaction(YAGPC_PACING_RT_SIGNAL, &g_pacing_old_sa, NULL);
        exit(1);
    }

    struct sigevent sev;
    memset(&sev, 0, sizeof(sev));
    sev.sigev_notify = SIGEV_SIGNAL;
    sev.sigev_signo = YAGPC_PACING_RT_SIGNAL;
    sev.sigev_value.sival_ptr = &g_pacing_timer;
    if (timer_create(CLOCK_MONOTONIC, &sev, &g_pacing_timer) != 0) {
        fprintf(stderr, "error: --pacing=signal: timer_create failed: %s\n", strerror(errno));
        sigprocmask(SIG_SETMASK, &g_pacing_old_mask, NULL);
        sigaction(YAGPC_PACING_RT_SIGNAL, &g_pacing_old_sa, NULL);
        exit(1);
    }

    double windowSeconds = PACING_WINDOW_MS / 1000.0;
    struct itimerspec its;
    its.it_value.tv_sec = (time_t)windowSeconds;
    its.it_value.tv_nsec = (long)((windowSeconds - (double)its.it_value.tv_sec) * 1e9);
    its.it_interval = its.it_value;
    if (timer_settime(g_pacing_timer, 0, &its, NULL) != 0) {
        fprintf(stderr, "error: --pacing=signal: timer_settime failed: %s\n", strerror(errno));
        timer_delete(g_pacing_timer);
        sigprocmask(SIG_SETMASK, &g_pacing_old_mask, NULL);
        sigaction(YAGPC_PACING_RT_SIGNAL, &g_pacing_old_sa, NULL);
        exit(1);
    }
}

static void batchrunner_pace_signal_teardown(BatchRunner *r) {
    (void)r;
    timer_delete(g_pacing_timer);
    sigprocmask(SIG_SETMASK, &g_pacing_old_mask, NULL);
    sigaction(YAGPC_PACING_RT_SIGNAL, &g_pacing_old_sa, NULL);
}

/* Called after every batchrunner_step() (same call site as burst mode).
 * Accounts this step's just-consumed virtual time against the current
 * window's budget; once exhausted, blocks for the next timer firing
 * (or handles an idle-fast-forward step directly -- see this section's
 * own header comment) before the *following* step is allowed to run. */
static void batchrunner_pace_signal(BatchRunner *r) {
    double windowBudgetUs = PACING_WINDOW_MS * 1000.0 * r->timeScale;
    if (windowBudgetUs < 1.0) windowBudgetUs = 1.0;

    double consumedUs = r->age.gpc.cpu.elapsedTimeUs - r->pacingRefVirtualUs;
    r->pacingRefVirtualUs = r->age.gpc.cpu.elapsedTimeUs;

    if (consumedUs > windowBudgetUs) {
        double gapSeconds = (consumedUs / 1e6) / r->timeScale;
        yagpc_sleep_seconds(gapSeconds);
        g_pacing_budget_us = 0.0;
        return;
    }

    g_pacing_budget_us -= consumedUs;
    if (g_pacing_budget_us <= 0.0) {
        while (!g_pacing_flag) {
            sigsuspend(&g_pacing_old_mask);
        }
        g_pacing_flag = 0;
        g_pacing_budget_us += windowBudgetUs;
    }
}

#else

/* Neither HAVE_POSIX_TIMERS (Makefile's build-time probe) nor a known
 * alternative: this target has no known reliable periodic-timer-plus-
 * notification primitive available (notably, real per-process interval
 * timers via timer_create()/timer_settime() have historically been
 * unreliable or absent on some BSD-family systems, including macOS).
 * Fail loudly and specifically rather than silently falling back to
 * --pacing=burst's behavior or crashing -- matches yaHALMAT2's own
 * HAVE_POSIX_TIMERS-gated stub and this project's established "fail
 * loudly, don't silently degrade" discipline. */
static void batchrunner_pace_signal_setup(BatchRunner *r) {
    (void)r;
    fprintf(stderr,
            "error: this build was compiled without POSIX real-time timer support -- "
            "rebuild with HAVE_POSIX_TIMERS, or use --pacing=burst\n");
    exit(1);
}
static void batchrunner_pace_signal_teardown(BatchRunner *r) { (void)r; }
static void batchrunner_pace_signal(BatchRunner *r) { (void)r; }

#endif

/* Shared dispatcher, called after every batchrunner_step() from both
 * batchrunner_run() and batchrunner_run_interactive(). */
static void batchrunner_pace(BatchRunner *r) {
    if (r->debugMode) {
        /* The debugger stops the machine for arbitrary wall time while
         * the world outside keeps running.  Re-tie the clocks on the way
         * back rather than repaying the gap -- see rtpacer.h. */
        if (r->realTime) rtpacer_resync(&r->rtPacer);
        return;
    }
    if (r->realTime) {
        /* Only every 256th step: the check is a clock read, and paying
         * for one per instruction would itself distort the pacing. */
        if ((r->step & 255) == 0) rtpacer_pace(&r->rtPacer);
        return;
    }
    if (r->pacingMode == PACING_SIGNAL) {
        batchrunner_pace_signal(r);
    } else {
        batchrunner_pace_burst(r);
    }
}

/* Called once, before either run loop starts -- --pacing=signal needs
 * process-wide setup (timer/signal handler); --pacing=burst and --debug
 * (which skips pacing entirely -- see batchrunner_pace() above) need
 * none. Always safe to call even when pacing will never actually fire
 * (--debug): setup happens unconditionally so a mid-run 'set pacing'-
 * style toggle isn't a concern this codebase has to worry about (no
 * such toggle exists), matching batchrunner_pace()'s own simplicity. */
static void batchrunner_pace_setup(BatchRunner *r) {
    if (r->debugMode) return;
    if (r->pacingMode == PACING_SIGNAL) batchrunner_pace_signal_setup(r);
}

static void batchrunner_pace_teardown(BatchRunner *r) {
    if (r->debugMode) return;
    if (r->pacingMode == PACING_SIGNAL) batchrunner_pace_signal_teardown(r);
}

/* Shared by both loops so --watch/--watch-log behave identically in
 * batch and interactive mode. */
static void batchrunner_init_watchpoints(BatchRunner *r) {
    WatchAddrs wa = build_watch_addrs(r->opts);
    r->hasWatchpoints = wa.count > 0;
    r->watchAddrs = wa.addrs;
    r->watchAddrCount = wa.count;
    r->watchBefore = r->hasWatchpoints ? malloc((size_t)wa.count * sizeof(uint16_t)) : NULL;
}

static void batchrunner_free_watchpoints(BatchRunner *r) {
    free(r->watchBefore);
    free(r->watchAddrs);
    r->watchBefore = NULL;
    r->watchAddrs = NULL;
}

/* Shared end-of-run reporting/exit-code logic for both loops. */
static int batchrunner_report_stop(BatchRunner *r) {
    /* Every stop reason, not only max-steps: a run that ends on a halt or
     * a wait state is precisely the one whose processor state matters, and
     * hooking this to the max-steps branch alone hid it. */
    if (getenv("YAGPC_PROCDUMP")) {
        /* The CPU half matters as much as the IOP half: a parked BCE is
         * only half a deadlock, and which of them is waiting on the other
         * is decided by where the CPU stopped. */
        CPU *c = &r->age.gpc.cpu;
        fprintf(stderr, "cpu: nia=%05x t=%.1f", (unsigned)psw_get_nia(&c->psw),
                c->elapsedTimeUs);
        for (int i = 0; i < 8; i++)
            fprintf(stderr, " R%d=%08x", i, (unsigned)register_get32(cpu_r(c, i)));
        fprintf(stderr, "\n");
        iop_dump_procs(&r->age.gpc.iop);
    }
        /* YAGPC_MEMDUMP=lo[-hi] prints main storage over that halfword
     * range at the end of a run.  The flight software builds its BCE
     * programs at run time, so the only way to see what a given
     * address actually holds is to look after the fact. */
    {
        const char *w = getenv("YAGPC_MEMDUMP");
        if (w != NULL) {
            char *end = NULL;
            long lo = strtol(w, &end, 16);
            long hi = (end != NULL && *end == '-') ? strtol(end + 1, NULL, 16)
                                                   : lo + 15;
            for (long a = lo; a <= hi; a++)
                fprintf(stderr, "MEM %05x = %04x\n", (unsigned)a,
                        (unsigned)membus_get16(r->age.gpc.cpu.ram, (uint32_t)a));
        }
    if (!r->hasStopReason) {
        snprintf(r->stopReason, sizeof r->stopReason, "max steps reached (%ld)", r->maxSteps);
        }
        r->hasStopReason = true;
    }

    char msg[700];
    snprintf(msg, sizeof msg, "--- STOPPED after %ld steps (reason: %s) ---", r->step, r->stopReason);
    batchrunner_info(r, msg);
    /* Simulated AP-101S time, so a run can be compared against another
     * simulator's (or against the real hardware's own duty-cycle
     * figures) without attaching a debugger to read elapsedTimeUs.
     * Which model produced it matters -- see timing.h and --timing. */
    snprintf(msg, sizeof msg, "--- SIMULATED TIME: %.3f ms (%.1f us, %s model) ---",
             r->age.gpc.cpu.elapsedTimeUs / 1000.0, r->age.gpc.cpu.elapsedTimeUs,
             r->age.gpc.cpu.timingPass2 ? "pass2" : "poo");
    batchrunner_info(r, msg);
    batchrunner_info(r, "--- FINAL REGISTERS ---");
    info_reg_dump(r, r->step);

    batchrunner_flush(r);

    if (strcmp(r->stopReason, "wait state") != 0) {
        fprintf(stderr, "ERROR: %s\n", r->stopReason);
        return 1;
    }
    return 0;
}

int batchrunner_run(BatchRunner *r) {
    long byteCount = batchrunner_load(r);
    batchrunner_init_io(r);

    r->age.halUCP.cbCtx = r;
    r->age.halUCP.inputCallback = batchrunner_input_cb;

    char msg[700];
    batchrunner_info(r, "=== GPC Batch Simulator ===");
    snprintf(msg, sizeof msg, "FCM: %s (%ld bytes)", r->opts->fcmPath, byteCount);
    batchrunner_info(r, msg);
    char epHex[16];
    as_hex(epHex, sizeof epHex, (long long)r->entryPoint, 4);
    snprintf(msg, sizeof msg, "Entry: 0x%s", epHex);
    batchrunner_info(r, msg);
    snprintf(msg, sizeof msg, "Max steps: %ld", r->maxSteps);
    batchrunner_info(r, msg);
    snprintf(msg, sizeof msg, "Trace: %s", r->traceEnabled ? "on" : "off");
    batchrunner_info(r, msg);
    if (r->hasBreakpoint) {
        char bpHex[16];
        as_hex(bpHex, sizeof bpHex, (long long)r->breakpoint, 4);
        snprintf(msg, sizeof msg, "Breakpoint: 0x%s", bpHex);
        batchrunner_info(r, msg);
    }
    batchrunner_info(r, "");

    print_section_map(r);

    r->step = 0;
    r->hasStopReason = false;
    r->stopReason[0] = '\0';
    r->hasLastSection = false;
    r->lastSection[0] = '\0';

    batchrunner_init_watchpoints(r);

    /* YAGPC_NIASAMPLE=<ms>: print where the CPU is, every <ms> of WALL time.
     * A run that neither faults nor halts otherwise reveals nothing about
     * itself -- the NIA ring only dumps on a fault, and the end-of-run report
     * only arrives at the end.  When the question is "it is clearly executing,
     * but doing WHAT?", this is the cheapest answer, and it needs no ptrace
     * (Yama blocks gdb from attaching here). */
    double sampleEvery = 0.0, sampleNext = 0.0;
    {
        const char *sv = getenv("YAGPC_NIASAMPLE");
        if (sv != NULL && *sv != '\0') {
            sampleEvery = strtod(sv, NULL) / 1000.0;
            sampleNext = yagpc_monotonic_seconds() + sampleEvery;
        }
    }

    /* A batch run is normally ended from OUTSIDE, by `timeout -s INT`.  With
     * the default disposition that kills the process outright, so the mmu/deu
     * counters, the memory dump and the stop reason -- exactly the state one
     * needs -- are never printed.  Setting a stop reason instead makes SIGINT
     * land in the same reporting path as a fault. */
    signal(SIGINT, on_sigint);

    r->pacingRefWallSeconds = yagpc_monotonic_seconds();
    r->pacingRefVirtualUs = r->age.gpc.cpu.elapsedTimeUs;
    batchrunner_pace_setup(r);
    while (r->step < r->maxSteps) {
        if (sampleEvery > 0.0) {
            double nowS = yagpc_monotonic_seconds();
            if (nowS >= sampleNext) {
                sampleNext = nowS + sampleEvery;
                CPU *sc = &r->age.gpc.cpu;
                fprintf(stderr, "NIASAMPLE step=%-12ld nia=%05x t=%.0fus wait=%d",
                        r->step, (unsigned)psw_get_nia(&sc->psw),
                        sc->elapsedTimeUs, psw_get_wait_state(&sc->psw) ? 1 : 0);
                for (int i = 0; i < 8; i++)
                    fprintf(stderr, " R%d=%08x", i,
                            (unsigned)register_get32(cpu_r(sc, i)));
                fprintf(stderr, "\n");
            }
        }
        if (g_sigint_received) {
            snprintf(r->stopReason, sizeof r->stopReason,
                     "interrupted (SIGINT) after %ld steps", r->step);
            r->hasStopReason = true;
            break;
        }
        if (!batchrunner_step(r)) break;
        batchrunner_pace(r);
    }
    batchrunner_pace_teardown(r);

    /* Whatever reason the loop stopped for -- max-steps exhausted, a
     * breakpoint, a watchpoint -- flush any still-buffered, not-yet-
     * newline-terminated WRITE output (see halucp_flush_all_pending()'s
     * own comment). The program's own HALT/EOF paths already do this
     * internally; this covers every other way the loop can end, which
     * previously had no equivalent flush at all. Safe/idempotent if a
     * HALT/EOF already flushed everything. */
    halucp_flush_all_pending(&r->age.halUCP);

    batchrunner_free_watchpoints(r);

    return batchrunner_report_stop(r);
}

/* ---------------------------------------------------------------------
 * runInteractive() / execLoop() / promptInput()
 *
 * Restructured from JS's async readline-callback + event-loop-reentry
 * style into a single synchronous loop: when HalUCP needs input, this
 * port just blocks on a stdin read right there instead of returning out
 * of the loop and waiting to be re-entered from a callback — there's
 * nothing else that could run "in between" in a single-threaded CLI tool
 * either way, so the observable behavior (prompts, output ordering,
 * final state) is the same. See run.h's header comment.
 * ------------------------------------------------------------------- */

static volatile sig_atomic_t g_sigint_received = 0;

static void on_sigint(int sig) {
    (void)sig;
    g_sigint_received = 1;
}

static void interactive_report_and_exit(BatchRunner *r, const char *headerFmt, long step, int exitCode) {
    /* A third distinct way the run loop can end besides max-steps and the
     * program's own HALT/EOF -- Ctrl-C -- and this calls exit() directly,
     * bypassing batchrunner_run_interactive()'s own post-loop flush. Same
     * "don't silently drop a still-buffered WRITE line" reasoning. */
    halucp_flush_all_pending(&r->age.halUCP);
    char msg[128];
    snprintf(msg, sizeof msg, headerFmt, step);
    batchrunner_info(r, msg);
    batchrunner_info(r, "--- FINAL REGISTERS ---");
    info_reg_dump(r, step);
    batchrunner_flush(r);
    exit(exitCode);
}

/* Prompts on stdout (matching promptInput's column-6 newline + " INPUT(ch): "
 * / "" prompt logic) and blocks for one line of stdin input. */
static void prompt_and_provide_input(BatchRunner *r, int channel) {
    /* Was `if (column[6] > 1) fputs("\n", stdout)` -- a raw, unbuffered
     * newline that predates problems.md 2.5's per-channel line-buffering
     * rewrite and was never updated for it: channel 6's current line may
     * still be sitting unflushed in lineBuf[6] at this point (WRITE
     * doesn't flush until something actually advances the line), so a
     * bare "\n" here silently discarded whatever text was buffered,
     * instead of the real newline it was supposed to represent --
     * confirmed via the "Programming in HAL/S" sweep, where several
     * `WRITE(6) 'A'; WRITE(6) 'B'; READ(5) ...;` (unhandled-EOF) programs
     * printed an extra blank line before 'B' instead of 'B' itself.
     * halucp_flush_channel() flushes the same way the SVC-0x0015/
     * READ-EOF halt paths already do. */
    if (r->age.halUCP.lineBufLen[6] > 0) {
        halucp_flush_channel(&r->age.halUCP, 6);
    }
    if (channel != 5) {
        printf(" INPUT(%d): ", channel);
    }
    fflush(stdout);

    char line[4096];
    if (!fgets(line, sizeof line, stdin)) {
        if (g_sigint_received) {
            interactive_report_and_exit(r, "\n--- INTERRUPTED after %ld steps ---", r->step, 0);
        }
        halucp_provide_eof(&r->age.halUCP);
        return;
    }
    size_t len = strlen(line);
    while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r')) line[--len] = '\0';
    halucp_provide_input(&r->age.halUCP, line);
    halucp_notify_interactive_input(&r->age.halUCP, 6);
}

/* Fixes problems.md 1.2 in full. The JS reference (gpc/cmd_run.coffee's
 * inputCallback in runInteractive) has two compounding bugs: (a)
 * IOHost#hasFileInput is true only while unread lines remain, so once a
 * --infileN channel's lines run out, exhaustion is indistinguishable
 * from "no file was ever configured for this channel" and it falls
 * into the terminal-prompt branch instead of signaling EOF for that
 * channel; (b) that terminal-prompt branch (promptInput ->
 * readline's rl.question()) never resolves on real EOF either — its
 * callback only fires on a 'line' event, so an exhausted/closed stdin
 * just stalls forever, and the process silently exits 0 without ever
 * reaching HalUCP#provideEof() or the program's ON ERROR handler.
 *
 * (b) is fixed here because prompt_and_provide_input() below uses a
 * blocking fgets(), which correctly returns EOF and calls
 * halucp_provide_eof(). But an earlier version of this port fixed only
 * (b): a --infileN channel that ran dry under --interactive still fell
 * through to prompt_and_provide_input() and would incorrectly block on
 * real stdin instead of reporting EOF on its own channel — the same
 * structural bug as (a), just with a different symptom than gpc's
 * silent truncation. Checking iohost_has_file_configured() here closes
 * that gap: an exhausted-but-configured channel reports EOF directly,
 * exactly like batch mode's batchrunner_input_cb does; only a channel
 * with no file configured at all falls through to the real terminal
 * prompt. */
static void interactive_input_cb(void *ctx, int channel, int iocode) {
    BatchRunner *r = ctx;
    (void)iocode;
    if (iohost_has_file_input(&r->iohost, channel)) {
        const char *line = iohost_read_input_line(&r->iohost, channel);
        if (line) {
            halucp_provide_input(&r->age.halUCP, line);
        } else {
            halucp_provide_eof(&r->age.halUCP);
        }
    } else if (iohost_has_file_configured(&r->iohost, channel)) {
        halucp_provide_eof(&r->age.halUCP);
    } else {
        prompt_and_provide_input(r, channel);
    }
}

int batchrunner_run_interactive(BatchRunner *r) {
    long byteCount = batchrunner_load(r);
    batchrunner_init_io(r);

    r->age.halUCP.cbCtx = r;
    r->age.halUCP.inputCallback = interactive_input_cb;

    char msg[700];
    batchrunner_info(r, "=== GPC Interactive Simulator ===");
    snprintf(msg, sizeof msg, "FCM: %s (%ld bytes)", r->opts->fcmPath, byteCount);
    batchrunner_info(r, msg);
    char epHex[16];
    as_hex(epHex, sizeof epHex, (long long)r->entryPoint, 4);
    snprintf(msg, sizeof msg, "Entry: 0x%s", epHex);
    batchrunner_info(r, msg);
    snprintf(msg, sizeof msg, "Trace: %s", r->traceEnabled ? "on" : "off");
    batchrunner_info(r, msg);
    batchrunner_info(r, "(Ctrl-C to halt)");
    batchrunner_info(r, "");

    print_section_map(r);

    r->step = 0;
    r->hasStopReason = false;
    r->stopReason[0] = '\0';
    r->hasLastSection = false;
    r->lastSection[0] = '\0';

    batchrunner_init_watchpoints(r);

    signal(SIGINT, on_sigint);

    r->pacingRefWallSeconds = yagpc_monotonic_seconds();
    r->pacingRefVirtualUs = r->age.gpc.cpu.elapsedTimeUs;
    batchrunner_pace_setup(r);
    while (r->step < r->maxSteps) {
        if (g_sigint_received) {
            interactive_report_and_exit(r, "\n--- INTERRUPTED after %ld steps ---", r->step, 0);
        }
        if (!batchrunner_step(r)) break;
        batchrunner_pace(r);
    }
    batchrunner_pace_teardown(r);

    /* See batchrunner_run()'s own identical call for the reasoning --
     * max-steps/breakpoint/watchpoint stops here need the same flush the
     * program's own HALT/EOF paths (and interactive_report_and_exit()'s
     * Ctrl-C path, above) already have. */
    halucp_flush_all_pending(&r->age.halUCP);

    batchrunner_free_watchpoints(r);

    return batchrunner_report_stop(r);
}
