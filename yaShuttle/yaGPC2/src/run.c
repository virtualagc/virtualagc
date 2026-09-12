#define _POSIX_C_SOURCE 200809L /* sigsuspend(), timer_create()/timer_settime() -- see batchrunner_pace_signal_setup() */
#include "run.h"

#include <errno.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "compat.h"
#include "cpu_instr.h"
#include "vehicle.h"
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
/* A display unit belongs to one computer -- see vehicle.h.  0 is "anyone",
 * which is what a single-machine run uses. */
static bool deu_owned_by(int owner, int gpcId) {
    return owner == 0 || owner == gpcId;
}

void bus_router_service(void *ctx, GpcServiceNumber svc,
                        const GpcServiceInput *in, GpcServiceOutput *out) {
    BusRouter *br = (BusRouter *)ctx;
    if (!br || !in || !out) return;
    /* YAGPC_DKTRACE: every command issued on a display-keyboard bus, with the
     * simulated time.  The IOQE a DK request holds is not released until the
     * transfer completes, so how long one takes is what decides whether an
     * OPS repaint -- about two dozen 100-word transfers issued at once --
     * fits inside the 25-entry free pool or runs it dry.  Nothing else
     * reports that interval: the DEU model has no clock of its own and
     * YAGPC_DEUTRACE only counts calls. */
    if (svc == GPC_SVC_XMIT_CMD && br->clockUs != NULL &&
        in->busID >= 6 && in->busID <= 9 && getenv("YAGPC_DKTRACE"))
        fprintf(stderr, "DK bus=%d cmd=%06x t=%.6f\n", in->busID,
                (unsigned)(in->in.word & 0xffffffu), *br->clockUs / 1e6);
    /* YAGPC_DKSTALL: per-second census of what the DK buses are DOING, which
     * is the only way to tell a long transfer from a long wait.  A DEU
     * transaction that holds its bus for 1052.6 ms while moving ~100 words
     * (33 us each, so ~3.3 ms of wire time) is idle for 99.7% of the hold --
     * but "idle" could be the GPC never transmitting or the peripheral never
     * answering, and those are opposite bugs.  Counting transmits against
     * polls that found nothing separates them. */
    if (br->clockUs != NULL && in->busID >= 6 && in->busID <= 9) {
        static int dsInit = 0, dsOn = 0, lastSec = -1;
        static long xmitC, xmitW, pollY, pollN, recvY, recvN;
        if (!dsInit) { dsInit = 1; dsOn = getenv("YAGPC_DKSTALL") != NULL; }
        if (dsOn) {
            int sec = (int)(*br->clockUs / 1e6);
            if (lastSec >= 0 && sec != lastSec) {
                fprintf(stderr, "DKSTALL t=%d xmitCmd=%ld xmitWord=%ld "
                        "pollHit=%ld pollMiss=%ld recvHit=%ld recvMiss=%ld\n",
                        lastSec, xmitC, xmitW, pollY, pollN, recvY, recvN);
                xmitC = xmitW = pollY = pollN = recvY = recvN = 0;
            }
            lastSec = sec;
            switch (svc) {
            case GPC_SVC_XMIT_CMD:  xmitC++; break;
            case GPC_SVC_XMIT_WORD: xmitW++; break;
            default: break;
            }
        }
    }
    /* YAGPC_DKRATE: per-TRANSACTION word count and duration on a DK bus, so
     * the emulator's actual per-word rate can be compared with the hardware's.
     * The hardware number is not in doubt -- IBM-74-A31-016: 28 bits at 1 MHz
     * = 28 us per word plus a 5 us minimum interword gap, so 33 us/word, and
     * a 510-word DEU fill is 16.83 ms.  But BUS_WORD_US lives only in
     * mmumodel.c: the DK path has NO bus-rate pacing, so its speed is
     * whatever the IOP round-robin yields (one BCE instruction per 16.5 us
     * wheel revolution, times the instructions per word the bus program
     * spends).  This prints what that actually is. */
    if (br->clockUs != NULL && in->busID >= 6 && in->busID <= 9) {
        static int drInit = 0, drOn = 0;
        static double startUs[10];
        static long words[10];
        if (!drInit) { drInit = 1; drOn = getenv("YAGPC_DKRATE") != NULL; }
        if (drOn) {
            int b = in->busID;
            if (svc == GPC_SVC_XMIT_CMD) {
                if (words[b] > 0) {
                    double d = *br->clockUs - startUs[b];
                    fprintf(stderr, "DKRATE bus=%d words=%ld dur=%.1f us "
                            "perword=%.1f us t=%.6f\n", b, words[b], d,
                            d / (double)words[b], startUs[b] / 1e6);
                }
                startUs[b] = *br->clockUs; words[b] = 0;
            } else if (svc == GPC_SVC_XMIT_WORD) {
                words[b]++;
            }
        }
    }
    /* YAGPC_BUSLOG=<path>: a COMPLETE binary record of every bus event, for
     * the whole run, decoded afterwards by gpc-buslog.py.
     *
     * WHY.  There are 43 separate YAGPC_*TRACE variables, each answering ONE
     * question and each costing a fresh run of the same scenario -- so any
     * question not thought of in advance is unanswerable without running
     * again.  A whole ~1000 s run moves about 1.49 million bus words, which
     * at 12 bytes an event is under 18 MB: complete capture is cheaper than
     * one re-run, and it turns "guess which trace to enable, then re-run"
     * into "run once, query afterwards".
     *
     * Record: uint32 t_us, uint8 bus, uint8 kind, uint16 aux, uint32 value.
     * Little-endian, 12 bytes, no header -- the decoder knows the shape. */
    if (br->clockUs != NULL) {
        static int blInit = 0;
        static FILE *bl = NULL;
        if (!blInit) {
            blInit = 1;
            const char *path = getenv("YAGPC_BUSLOG");
            if (path != NULL && *path != '\0') {
                bl = fopen(path, "wb");
                if (bl == NULL)
                    fprintf(stderr, "buslog: cannot write %s\n", path);
                else
                    setvbuf(bl, NULL, _IOFBF, 1 << 20);
            }
        }
        if (bl != NULL) {
            unsigned char rec[12];
            uint32_t t = (uint32_t)(*br->clockUs);
            uint32_t v = (uint32_t)(in->in.word & 0xffffffffu);
            uint16_t aux = (uint16_t)(in->address & 0xffffu);
            rec[0] = t & 0xff; rec[1] = (t >> 8) & 0xff;
            rec[2] = (t >> 16) & 0xff; rec[3] = (t >> 24) & 0xff;
            rec[4] = (unsigned char)(in->busID & 0xff);
            rec[5] = (unsigned char)(svc & 0xff);
            rec[6] = aux & 0xff; rec[7] = (aux >> 8) & 0xff;
            rec[8] = v & 0xff; rec[9] = (v >> 8) & 0xff;
            rec[10] = (v >> 16) & 0xff; rec[11] = (v >> 24) & 0xff;
            fwrite(rec, 1, sizeof rec, bl);
            /* FLUSH ONCE PER SIMULATED SECOND.  The 1 MB buffer holds ~87,000
             * events, and a run ended by SIGINT -- which is how every healthy
             * run ends, on the harness timeout -- never wrote its last
             * buffer.  When bus traffic COLLAPSES, which is the very thing
             * this log exists to catch, the whole collapse fits in that
             * buffer and vanishes: two runs measured on 2026-09-10 ended
             * their logs at 273 s and 292 s of a 404 s run, and the missing
             * tail was the answer.  One fflush a second costs nothing. */
            static uint32_t blSec = 0;
            if (t / 1000000u != blSec) { blSec = t / 1000000u; fflush(bl); }
        }
    }
    /* A DEVICE FOLLOWS THE CLOCK OF WHOEVER IS TALKING TO IT.  The models
     * pace against simulated time -- the mass memory releases a word per word
     * time as the tape turns -- and a transfer is a conversation with ONE
     * computer.  Pointing them at a vehicle-wide clock is wrong in both
     * directions: at one machine's clock, the tape stands still while a
     * DIFFERENT computer IPLs from it; at the furthest-advanced machine's,
     * the tape appears to have run past the words this one is reading and
     * they are dropped as stale.  The router is per machine, so it knows. */
    /* THE SHARED DEVICES ARE SHARED.  Each is one instance answering
     * whichever computer commands it, so with several machines two threads
     * can be inside one model's state machine at once.  The lock stops that
     * corrupting it, and counts the times a computer walked into another's
     * transfer -- which is a finding, not a condition to handle.  See
     * vehicle.h.  With one machine it is a bounds check and nothing more. */
    for (int u = 0; u < 2; u++) {
        if (br->mmu[u] && in->busID == br->mmuBus[u]) {
            vehicle_bus_enter(br->vehicle, in->busID, br->gpcId,
                              mmumodel_in_transfer(br->mmu[u]));
            mmumodel_set_clock(br->mmu[u], br->clockUs);
            mmumodel_service(br->mmu[u], svc, in, out);
            vehicle_bus_leave(br->vehicle, in->busID);
            return;
        }
    }
    if (br->mtu && mtumodel_owns_bus(in->busID)) {
        /* The timing unit rewrites its whole reply on every command and has
         * no transfer to walk into, so there is nothing to count here -- only
         * the two threads to keep out of each other's way. */
        vehicle_bus_enter(br->vehicle, in->busID, br->gpcId, false);
        mtumodel_set_clock(br->mtu, br->clockUs);
        mtumodel_service(br->mtu, svc, in, out);
        vehicle_bus_leave(br->vehicle, in->busID);
        return;
    }
    for (int d = 0; d < br->nDeuExtra; d++) {
        if (br->deuExtra[d] && in->busID == br->deuExtraBus[d]) {
            /* Somebody's unit is on this bus.  If it is not THIS computer's,
             * this computer is not on that bus at all and finds nothing
             * there -- it does not get to share it. */
            if (!deu_owned_by(br->deuExtraOwner[d], br->gpcId)) break;
            vehicle_bus_enter(br->vehicle, in->busID, br->gpcId,
                              deumodel_in_transfer(br->deuExtra[d]));
            deumodel_service(br->deuExtra[d], svc, in, out);
            vehicle_bus_leave(br->vehicle, in->busID);
            return;
        }
    }
    /* The built-in display unit answers through `fallback`, so ownership has
     * to be checked before getting there -- otherwise every computer that
     * was not given a unit would drive the first computer's. */
    if (br->deu != NULL && !deu_owned_by(br->deuOwner, br->gpcId)) {
        switch (svc) {
        case GPC_SVC_XMIT_CMD:
        case GPC_SVC_XMIT_WORD: out->out.xmit.ok = true; break;
        case GPC_SVC_RECV_POLL: out->out.poll.available = false; break;
        case GPC_SVC_RECV_WORD: out->out.recv.available = false; break;
        default: break;
        }
        return;
    }

    if (br->fallback) {
        /* The built-in display unit on DK1 arrives here, and it is a shared
         * device like the rest -- one accumulator, one reply cursor.  Its
         * mid-transfer state is the DEU's own: measured, two computers told
         * to drive the same display abandoned 477 transfers between them and
         * no keystroke ever reached the flight software, with nothing but a
         * counter in the closing report to say so. */
        vehicle_bus_enter(br->vehicle, in->busID, br->gpcId,
                          deumodel_in_transfer(br->deu));
        br->fallback(br->fallbackCtx, svc, in, out);
        vehicle_bus_leave(br->vehicle, in->busID);
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

/* iop.h's peerWait, for --bce-network: a bus whose far end is a process
 * reached over a socket may hold the machine until that process answers (see
 * bcenet_framer_peer_wait).  A bus an in-process model owns never holds --
 * the model answers in simulated time, which is the point of it.  A long
 * hold leaves the simulated clock behind the wall clock; re-base the pacer
 * rather than let it run the machine flat out to repay the gap, which would
 * only bring the next reply in late again (rtpacer.c, STALL_REBASE_MS). */
#define PEER_HOLD_REBASE_MS 20.0
/* Per-machine stderr, defined below: see mode_log. */
static void mode_log(const BatchRunner *r, const char *fmt, ...);

static bool run_peer_wait(void *ctx, int busID, bool gotAny) {
    BatchRunner *r = ctx;
    const BusRouter *br = &r->busRouter;
    if (r->bceFramer == NULL) return false;
    for (int u = 0; u < 2; u++)
        if (br->mmu[u] && busID == br->mmuBus[u]) return false;
    if (br->mtu && mtumodel_owns_bus(busID)) return false;
    for (int d = 0; d < br->nDeuExtra; d++)
        if (br->deuExtra[d] && busID == br->deuExtraBus[d]) return false;
    double heldMs = 0.0;
    bool got = bcenet_framer_peer_wait(r->bceFramer, busID, gotAny, &heldMs);
    if (heldMs > 0.0 && r->realTime)
        rtpacer_note_peer_hold(&r->rtPacer, heldMs / 1000.0, got);
    /* A peer that answered slowly is not a stall either -- the wait state
     * the machine drops into next will make the time up (rtpacer.c).  This
     * used to rebase past PEER_HOLD_REBASE_MS and write the hold off. */
    if (heldMs > 0.0 && getenv("YAGPC_TIMEOUT_TRACE"))
        fprintf(stderr, "BCE%d PEER HOLD %.2f ms wall -> %s\n", busID, heldMs,
                got ? "reply" : "none");
    return got;
}

void batchrunner_init(BatchRunner *r, const Options *opts, Vehicle *veh,
                      int gpcId) {
    memset(r, 0, sizeof(*r));
    r->vehicle = veh;
    if (veh != NULL) veh->nMachines++;
    /* BUILD THE DECODE TABLES BEFORE ANY MACHINE RUNS.  Each is an unguarded
     * check-then-build on a file-scope flag, which is safe when one machine
     * builds them on its first instruction and a race once several do.  They
     * are read-only afterwards and shared by every machine, which is correct
     * -- the instruction set does not vary by computer. */
    cpu_instr_table_init();
    bce_instr_table_init();
    msc_instr_table_init();
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

    r->gpcId = gpcId;
    /* NOT the zero memset leaves: generation 0 is a real value, and a memo
     * that matched it would answer "not held" before the panel had ever been
     * heard -- releasing the machine from reset on nothing at all. */
    r->modeHeldGen = ~0u;
    r->modeHeldLast = true;

    if (opts->deuModel) {
        /* Deliberately instead of, not alongside, the network servicer:
         * only one thing can sit on the far end of the bus, and the
         * point of this one is that no socket is involved. */
        /* In this process, so the socket-latency floor does not apply:
         * honour the bus program's own message timeout exactly. */
        iop_set_recv_timeout_floor_us(&r->age.gpc.iop, 0.0);
        if (!veh->built) {
            veh->deu = deumodel_create(6);   /* DK1 */
            /* The built-in unit goes to the computer that created it, which
             * is the first one named.  Unconditionally, and NOT gated on
             * there being more than one machine: nMachines is still 1 here
             * even in a five-computer run, because the others have not
             * reached batchrunner_init yet.  Gating on it left the unit
             * owned by nobody and every computer drove it -- 184 clashes on
             * bus 6 in a two-computer run that was supposed to have none.
             * With one machine the owner is that machine, so nothing
             * changes. */
            veh->deuOwner = gpcId;
        }
        r->deuModel = veh->deu;
        base = deumodel_service;
        baseCtx = r->deuModel;
    } else if (opts->bceNetwork) {
        /* ONE transport for the process: see vehicle.h.  The framer, and so
         * the per-bus receive queues, stay per machine. */
        if (!veh->built) veh->transport = bcenet_transport_create(r->gpcId);
        r->bceTransport = veh->transport;
        r->bceFramer = bcenet_framer_create(r->bceTransport, r->gpcId);
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
    /* --deu-bus takes a LIST: "7", or "7,8,9".  PASS drives four DEUs
     * (DCICYC.asm DCIS#DEU EQU 4, device IDs 5-8 per FIOERRLC.asm), and the
     * DK handler keeps a request outstanding to each.  A unit with nothing on
     * its bus never completes, and its IOQE is never returned to the pool of
     * 25 (FIOCBLKS.asm GENERATE ... NIOQE=25).  Run the pool dry and FIOSVC
     * pops the free list's deliberate sentinel -- a pointer to the PROTECTED
     * SVC table (GENERATE.asm:335) -- so the next store takes a store-protect
     * program check.  That is FCOS's queue-overflow detector working exactly
     * as designed, and it is fatal here: taken inside the Clock 2 handler it
     * stops FPMIHPC2 before its CALL FPMITUPD, the only code that re-arms
     * Clock 2, after which no TQE ever expires again. */
    if (opts->deuBus != NULL && *opts->deuBus != '\0') {
        const char *p = opts->deuBus;
        while (*p != '\0' && r->nDeuModelExtra < DEU_EXTRA_MAX) {
            char *end = NULL;
            long b = strtol(p, &end, 10);
            if (end == p) break;
            /* "<gpc>:<bus>" attaches the unit to one computer; a bare bus
             * number attaches it to whoever has the built-in one, which is
             * what it meant before there was more than one computer. */
            int owner = 0;
            if (*end == ':') {
                owner = (int)b;
                p = end + 1;
                b = strtol(p, &end, 10);
                if (end == p) break;
                if (owner < 1 || owner > 5) owner = 0;
            }
            if (b > 0 && b <= 24) {
                int k = r->nDeuModelExtra;
                if (!veh->built) {
                    veh->deuExtra[k] = deumodel_create((int)b);
                    veh->deuExtraBus[k] = (int)b;
                    veh->deuExtraOwner[k] = owner ? owner : veh->deuOwner;
                    veh->nDeuExtra = k + 1;
                }
                r->deuModelExtra[k] = veh->deuExtra[k];
                if (r->deuModelExtra[k] != NULL) {
                    r->busRouter.deuExtra[k] = r->deuModelExtra[k];
                    r->busRouter.deuExtraBus[k] = (int)b;
                    r->busRouter.deuExtraOwner[k] = veh->deuExtraOwner[k];
                    r->nDeuModelExtra = k + 1;
                    r->busRouter.nDeuExtra = k + 1;
                }
            }
            p = (*end == ',') ? end + 1 : end;
        }
    }

    if (opts->mtuModel) {
        if (!veh->built) veh->mtu = mtumodel_create();
        r->mtuModel = veh->mtu;
        if (r->mtuModel) {
            mtumodel_set_clock(r->mtuModel, &veh->clockUs);
            mtumodel_set_epoch(r->mtuModel, &r->age.gpc.cpu.dateTimeAnchorEpochSec);
        }
    }

    if (opts->mmuVolume[0] || opts->mmuVolume[1] || r->mtuModel ||
        r->nDeuModelExtra > 0) {
        for (int u = 0; u < 2; u++) {
            if (!veh->built)
                veh->mmu[u] = opts->mmuVolume[u]
                                  ? mmumodel_create(u + 1, opts->mmuVolume[u])
                                  : NULL;
            r->mmuModel[u] = veh->mmu[u];
        }
        if (r->mmuModel[0] || r->mmuModel[1] || r->mtuModel ||
            r->nDeuModelExtra > 0) {
            for (int u = 0; u < 2; u++) {
                if (r->mmuModel[u] == NULL) continue;
                mmumodel_set_clock(r->mmuModel[u], &veh->clockUs);
    /* The DEU models get the same clock, so YAGPC_DEUKEYS_SIMTIME can gate
     * a keystroke batch on simulated time. */
    if (r->deuModel != NULL)
        deumodel_set_clock(r->deuModel, &veh->clockUs);
    for (int d = 0; d < r->nDeuModelExtra; d++)
        deumodel_set_clock(r->deuModelExtra[d], &veh->clockUs);
                /* Tell the IOP this mass memory is PRESENT, by setting its
                 * READY bit in the stored discrete.  iop_discrete_in_a()
                 * computes the bit rather than storing it -- ready means
                 * "present and not moving data" -- but it computes it only
                 * for a unit whose stored bit is set, which otherwise
                 * nothing ever sets: --discrete-a is the only writer and
                 * defaults to zero.
                 *
                 * The model does publish READY on the discrete bus, but a
                 * publisher's own bits are excluded from the driven mask on
                 * purpose (discretes_driven_mask: honouring our own
                 * multicast would replace in-process state with the same
                 * state a socket round trip later), so publishing cannot
                 * inform us -- it informs the crew panel, which is what it
                 * is for.
                 *
                 * Nothing noticed because the IPL bootstrap is read by the
                 * harness rather than by executing FCMBOOT, and GPCIPL
                 * never asks.  BSL1's BSRDYDI is the first real flight code
                 * to test it, reached only by selecting PFS from the GPCIPL
                 * menu, and it spun there until ERROR 115 MMU WILL NOT GO
                 * READY. */
                uint32_t readyBit = (u == 1) ? 0x01000000u : 0x02000000u;
                iop_set_discrete_in(&r->age.gpc.iop, DISCRETES_REG_A,
                                    iop_discrete_in_a_stored(&r->age.gpc.iop) | readyBit);
            }
            if (base == NULL) iop_set_recv_timeout_floor_us(&r->age.gpc.iop, 0.0);
            for (int u = 0; u < 2; u++) {
                r->busRouter.mmu[u] = r->mmuModel[u];
                r->busRouter.mmuBus[u] =
                    r->mmuModel[u] ? mmumodel_bus(r->mmuModel[u]) : -1;
                veh->mmuBus[u] = r->busRouter.mmuBus[u];
            }
            r->busRouter.mtu = r->mtuModel;
            for (int d = 0; d < r->nDeuModelExtra; d++)
                r->busRouter.deuExtra[d] = r->deuModelExtra[d];
            r->busRouter.nDeuExtra = r->nDeuModelExtra;
            r->busRouter.clockUs = &r->age.gpc.cpu.elapsedTimeUs;
            r->busRouter.vehicle = veh;
            r->busRouter.gpcId = gpcId;
            r->busRouter.deu = r->deuModel;
            r->busRouter.deuOwner = veh->deuOwner;
            for (int d = 0; d < r->nDeuModelExtra; d++)
                r->busRouter.deuExtraOwner[d] = veh->deuExtraOwner[d];
            r->busRouter.fallback = base;
            r->busRouter.fallbackCtx = baseCtx;
            ap101_set_servicer(&r->age.gpc, bus_router_service, &r->busRouter);
        } else if (base) {
            ap101_set_servicer(&r->age.gpc, base, baseCtx);
        }
    } else if (base) {
        ap101_set_servicer(&r->age.gpc, base, baseCtx);
    }

    if (r->bceFramer) iop_set_peer_wait(&r->age.gpc.iop, run_peer_wait, r);

    /* Independent of the peripheral bus: discretes are their own bus, and
     * a run may want them with or without --bce-network.  Failing to open
     * is not fatal -- iop.c keeps deriving what it can. */
    /* Whatever this machine created above belongs to the vehicle now; the
     * next machine borrows it rather than making its own. */
    veh->built = true;

    if (opts->discretes) {
        r->discretes = discretes_create(r->gpcId);
        iop_set_discretes(&r->age.gpc.iop, r->discretes);
        vehicle_add_machine(veh, r->gpcId, r->discretes);
        /* A mass memory is wired to every computer; with one machine that
         * is one channel. */
        for (int u = 0; u < 2; u++)
            if (r->mmuModel[u])
                mmumodel_set_discretes(r->mmuModel[u], r->discretes);
    }
}

void batchrunner_free(BatchRunner *r) {
    /* This machine is done; the others must not wait on its stopped clock. */
    vehicle_barrier_leave(r->vehicle, r->gpcId);
    if (discretes_enabled(r->discretes)) {
        fprintf(stderr, "discretes: %lu message(s) applied\n",
                discretes_message_count(r->discretes));
    }
    discretes_free(r->discretes);
    r->discretes = NULL;
    /* The device models and the bus transport belong to the vehicle and are
     * reported and released by vehicle_free -- they are shared, and with
     * several machines only one set of reports should be printed. */
    for (size_t i = 0; i < r->lineCount; i++) free(r->lines[i]);
    free(r->lines);
    iohost_free(&r->iohost);
    ageharness_free(&r->age);
    if (r->dbg) debugger_free(r->dbg);
    if (r->bceFramer) bcenet_framer_free(r->bceFramer);   /* per machine */
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
    /* Same rule as the router: the tape turns on the clock of the machine
     * reading it.  This path is the firmware IPL's own bootstrap read. */
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
    /* "IPL first causes a system reset function" (POO 2.5.3.3), and "the
     * use of the IPL function is independent of the prior state of the
     * system".  Without it an IPL of a machine that had been running kept
     * that machine's pending interrupts, timers and whole IOP -- see
     * cpu_system_reset() and iop_system_reset(). */
    ap101_system_reset(&r->age.gpc);
    if (!r->age.gpc.iop.servicer) {
        mode_log(r, "MODE: IPL, but no mass memory is attached; "
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
    if (discretes_enabled(r->discretes)) {
        srcDriven = discretes_driven_mask(r->discretes, DISCRETES_REG_A)
                    & (MODE_SRC_MM1 | MODE_SRC_MM2);
        srcVal = discretes_value(r->discretes, DISCRETES_REG_A) & srcDriven;
    }
    if (srcDriven && !srcVal) {
        mode_log(r, "MODE: IPL, but IPL SOURCE SELECT is OFF; "
                        "no mass memory to read from\n");
        return;
    }
    int unit = (srcVal & MODE_SRC_MM2) ? 2 : 1;
    int busID = (unit == 2) ? 19 : 18;

    /* Whatever the unit still holds for the LAST transaction is not the
     * bootstrap.  A reply the running software never collected -- a BITE
     * STATUS answer, say -- stays queued (mmumodel.c keeps replies across a
     * new command, as a unit would), and the collection loop below would
     * take it as the bootstrap's first word and shift the whole image.  A
     * real receiver is inhibited outside a commanded transfer; discard it. */
    {
        GpcServiceOutput stale;
        size_t dropped = 0;
        for (;;) {
            mm_service(r, GPC_SVC_RECV_WORD, busID, 0, &stale);
            if (!stale.out.recv.available || ++dropped > 65536) break;
        }
        if (dropped > 0)
            mode_log(r, "MODE: IPL; discarded %zu word(s) MM%d still held "
                            "from before\n", dropped, unit);
    }

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
                for (int u = 0; u < 2; u++)
            if (r->mmuModel[u]) mmumodel_publish_ready(r->mmuModel[u]);
            }
            continue;
        }
        r->age.gpc.cpu.elapsedTimeUs += MM_BUS_WORD_US;
        /* The tape is paced by the VEHICLE's clock, and this loop runs
         * outside batchrunner_step -- so carry it forward here too, or the
         * mass memory releases one word and then waits for a clock that
         * nothing is advancing. */
        if (r->vehicle != NULL)
            vehicle_note_time(r->vehicle, r->age.gpc.cpu.elapsedTimeUs);
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
    for (int u = 0; u < 2; u++)
            if (r->mmuModel[u]) mmumodel_publish_ready(r->mmuModel[u]);
    mode_log(r, "MODE: IPL; memory filled, bootstrap read from MM%d "
                    "(BCE %d) over the bus (%zu blocks, %zu halfwords) "
                    "to 0x00000\n",
            unit, busID, got / MM_HALFWORDS_PER_BLOCK, got);
}

/* True when the machine is held in reset and must not execute.  Called once
 * per INSTRUCTION, through the caching wrapper below. */
/* "GPC2: " when several computers are running, "" when only one is.  Every
 * line below describes one machine, and with five of them on one stderr an
 * untagged line says nothing.  A single-computer run is left exactly as it
 * was, so existing logs and the harnesses that grep them do not move. */
static const char *batchrunner_tag(const BatchRunner *r) {
    static char buf[5][16];
    if (r == NULL || r->vehicle == NULL || !vehicle_multi(r->vehicle)) return "";
    int i = (r->gpcId >= 1 && r->gpcId <= 5) ? r->gpcId - 1 : 0;
    snprintf(buf[i], sizeof buf[i], "GPC%d: ", r->gpcId);
    return buf[i];
}

/* One fprintf, so a line from one machine does not interleave with another's
 * halfway through.  vsnprintf first, then a single write. */
static void mode_log(const BatchRunner *r, const char *fmt, ...) {
    char buf[512];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(buf, sizeof buf, fmt, ap);
    va_end(ap);
    fprintf(stderr, "%s%s", batchrunner_tag(r), buf);
}

static bool mode_switch_held_uncached(BatchRunner *r) {
    uint32_t driven = discretes_driven_mask(r->discretes, DISCRETES_REG_A);
    uint32_t mode = discretes_value(r->discretes, DISCRETES_REG_A) & driven & MODE_ANY;

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
        if (!r->modeReported) {
            mode_log(r, "MODE: HALT; CPU held in reset "
                            "(no crew panel heard yet)\n");
            r->modeReported = true;
        }
        /* r->prevMode is deliberately left alone. */
        return true;
    }

    /* IPL IS NOT A MODE-SWITCH POSITION.  The mode switch is HALT / STBY /
     * RUN; the GPC IPL pushbutton is a SEPARATE momentary control, and it
     * is live only while the switch is in HALT -- Table 2-2 puts "GPC to
     * HALT mode" at step 4 and "GPC IPL - P/R" at step 10, with HALT still
     * standing.  So its bit is not exclusive of HALT's, it DEPENDS on it,
     * and the two are asserted together.  Pressing it in STBY or RUN is
     * not a thing the panel can do to a running machine. */
    if (mode != r->prevMode) {
        if (getenv("YAGPC_MODETRACE"))
            fprintf(stderr, "MODETRACE driven=%08x value=%08x mode=%08x prev=%08x\n",
                    driven, discretes_value(r->discretes, DISCRETES_REG_A), mode, r->prevMode);
        bool iplEdge = (mode & MODE_IPL) && !(r->prevMode & MODE_IPL);
        if (iplEdge && (mode & MODE_HALT)) {
            /* The pushbutton, on its press: pressing it again re-IPLs,
             * and holding it down does not repeat. */
            firmware_ipl(r);
        } else if (iplEdge) {
            mode_log(r, "MODE: IPL pressed but the mode switch is not "
                            "in HALT; ignored\n");
        } else if ((r->prevMode & MODE_HALT) && (mode & MODE_STBY)) {
            /* The release.  Reload the whole PSW pair from the System
             * Reset vector, which is what hands control to FCMBOOT. */
            cpu_reset(&r->age.gpc.cpu);
            mode_log(r, "MODE: HALT -> STBY; reset released, "
                            "starting at 0x%05x\n",
                    psw_get_nia(&r->age.gpc.cpu.psw));
        } else if (mode & MODE_HALT) {
            mode_log(r, "MODE: HALT; CPU held in reset\n");
        } else if (mode & (MODE_RUN | MODE_STBY)) {
            mode_log(r, "MODE: %s\n",
                    (mode & MODE_RUN) ? "RUN" : "STBY");
        }
        r->prevMode = mode;
        r->modeReported = true;
    }
    (void)r->modeReported;
    /* HALT alone decides this.  IPL cannot be pressed out of HALT, so a
     * machine being IPLed is already held by the switch itself. */
    return (mode & MODE_HALT) != 0;
}

/* YAGPC_RANGETRACE=lo-hi[,max[,afterSec]] (halfword addresses in hex, max
 * lines decimal, default 200000; afterSec in EMULATED seconds, default 0):
 * every instruction executed with NIA inside the range, disassembled, with
 * R0-R7 as they stand AFTER it.
 *
 * --trace traces everything, which for flight software means the routine of
 * interest arrives a hundred million steps in and buried.  A range is what
 * makes a single subroutine readable: run to the display cycle, and read
 * back the twenty instructions that built the field that came out wrong.
 *
 * afterSec is what makes it usable on flight software that calls the routine
 * every display cycle from initialisation onwards: the interesting call is
 * the one happening NOW, on the page in front of you, and without a start
 * time the budget is spent on the first few seconds of the boot instead. */
/* Whether YAGPC_RANGETRACE is set at all.  range_trace() parses the spec
 * lazily on its first call, but batchrunner_step() has to know BEFORE the
 * instruction runs whether to do the work the trace consumes. */
/* The pacing instrumentation costs two clock reads per use, so it is only
 * paid for when YAGPC_PACETRACE is actually asking for the numbers. */
/* How much SIMULATED time may pass between drains of the bus sockets. */
#define BUS_SERVICE_US_DEFAULT 2.0
static double bus_service_us(void) {
    static int inited = 0;
    static double us = BUS_SERVICE_US_DEFAULT;
    if (!inited) {
        const char *e = getenv("YAGPC_BUS_SERVICE_US");
        if (e != NULL) { double v = atof(e); if (v >= 0.0) us = v; }
        inited = 1;
    }
    return us;
}

static bool pace_trace_enabled(void) {
    static int v = -1;
    if (v < 0) v = getenv("YAGPC_PACETRACE") != NULL;
    return v != 0;
}

static bool range_trace_enabled(void) {
    static int v = -1;
    if (v < 0) v = getenv("YAGPC_RANGETRACE") != NULL;
    return v != 0;
}

static void range_trace(BatchRunner *r, uint32_t nia, uint32_t hw1,
                        uint32_t hw2, const char *disasm,
                        const RegSnapshot *after) {
    static int inited = 0;
    static uint32_t lo = 0, hi = 0;
    static long left = 0;
    static double afterUs = 0.0;
    if (!inited) {
        inited = 1;
        const char *spec = getenv("YAGPC_RANGETRACE");
        if (spec) {
            unsigned a = 0, b = 0; long m = 200000; double t = 0.0;
            if (sscanf(spec, "%x-%x,%ld,%lf", &a, &b, &m, &t) >= 2) {
                lo = a; hi = b; left = m; afterUs = t * 1.0e6;
            }
        }
    }
    if (left <= 0 || nia < lo || nia > hi) return;
    if (r->age.gpc.cpu.elapsedTimeUs < afterUs) return;
    left--;
    fprintf(stderr, "RT %05x %04x %04x  %-28s "
            "R0=%08x R1=%08x R2=%08x R3=%08x "
            "R4=%08x R5=%08x R6=%08x R7=%08x\n",
            (unsigned)nia, (unsigned)hw1, (unsigned)hw2, disasm,
            (unsigned)after->r[0], (unsigned)after->r[1],
            (unsigned)after->r[2], (unsigned)after->r[3],
            (unsigned)after->r[4], (unsigned)after->r[5],
            (unsigned)after->r[6], (unsigned)after->r[7]);
}

/* The whole of main storage as raw big-endian halfwords, 524,288 of them.
 * Paired with a state dump so the two describe ONE machine -- see the
 * -busy path's comment, which makes the same point and is the reason this
 * is a shared helper rather than a second copy.
 *
 * It exists because "did phase N actually load" cannot be answered from
 * any log the emulator writes: the MMU model's "read N block(s)" line is
 * emitted at QUEUE time inside do_read, before a single word has left for
 * the bus, and the bus log records service calls rather than delivered
 * words.  Only the memory contents settle it, compared against the blocks
 * on the tape. */
static void dump_main_storage(BatchRunner *r, const char *path) {
    FILE *mf = fopen(path, "wb");
    if (mf == NULL) {
        fprintf(stderr, "dump: cannot write %s\n", path);
        return;
    }
    uint32_t nhw = (uint32_t)(r->age.gpc.cpu.mainStorage.wordCount * 2);
    /* Buffered and written in one go.  A byte-at-a-time fputc loop over a
     * megabyte takes long enough to matter: the run is paced to real time,
     * so a slow dump makes the emulator fall behind the wall clock, which
     * moves the simulated instant a wall-gated DEU keystroke lands on. */
    unsigned char *buf = (unsigned char *)malloc((size_t)nhw * 2);
    if (buf == NULL) { fclose(mf); fprintf(stderr, "dump: out of memory\n"); return; }
    for (uint32_t a = 0; a < nhw; a++) {
        uint32_t v = membus_get16(r->age.gpc.cpu.ram, a);
        buf[2 * a] = (unsigned char)((v >> 8) & 0xff);
        buf[2 * a + 1] = (unsigned char)(v & 0xff);
    }
    fwrite(buf, 1, (size_t)nhw * 2, mf);
    free(buf);
    fclose(mf);
    fprintf(stderr, "dump: memory (%u hw) -> %s  t=%.1f us\n",
            (unsigned)nhw, path, r->age.gpc.cpu.elapsedTimeUs);
}

/* Everything below the poll depends only on the discrete bus state, so if
 * nothing has been published since the last call the answer is the one
 * already computed -- and no edge can have been missed, because an edge IS a
 * change in that state. */
static bool mode_switch_held(BatchRunner *r) {
    if (!discretes_enabled(r->discretes)) return false;
    /* ONE DATAGRAM AT A TIME, evaluating after each.  The pushbutton is a
     * pulse: draining the socket and looking once would let a press and its
     * release arrive together and cancel out.  See discretes_poll_one. */
    while (discretes_poll_one(r->discretes)) {
        unsigned g = discretes_generation(r->discretes);
        if (g == r->modeHeldGen) continue;
        r->modeHeldGen = g;
        r->modeHeldLast = mode_switch_held_uncached(r);
    }
    return r->modeHeldLast;
}

static bool batchrunner_step(BatchRunner *r) {
    /* Before anything else: in HALT the machine executes nothing at all. */
    if (mode_switch_held(r)) {
        /* The peripherals are not in reset, though -- a mass memory sits
         * there READY with the GPC switched off, and its line says so.
         * Publishing it here as well as in the running path is what makes
         * a crew panel show something before the switch is ever moved,
         * which is the only sign a person has that this is running. */
        for (int u = 0; u < 2; u++)
            if (r->mmuModel[u]) mmumodel_publish_ready(r->mmuModel[u]);
        /* And out of the simulated-time barrier while it is held: this
         * machine's clock has stopped, and a stopped clock is the slowest
         * there is -- leaving it in would halt the whole vehicle. */
        vehicle_barrier_leave(r->vehicle, r->gpcId);
        r->modeWasHeld = true;
        /* Nothing to do but wait for the switch to move; don't spin a
         * core doing it. */
        yagpc_sleep_seconds(0.002);
        return true;
    }

    /* JUST RELEASED FROM RESET.  A computer in HALT executes nothing, so its
     * simulated clock stood still while the wall clock ran; to the pacer that
     * looks like a machine that has fallen minutes behind and owes the time,
     * and it lets it run flat out until the debt is repaid.  But the debt is
     * not real -- the computer was switched off, and a computer powered up
     * now starts from now.  Re-tie the clocks rather than repaying the gap,
     * which is exactly what rtpacer.h says a resync is for and what the
     * debugger already does for its own stalls.
     *
     * Measured in a two-computer run: with GPC2's switch moved nine seconds
     * after GPC1's, GPC2 sprinted through nine seconds of simulated time on
     * release, and the simulated-time barrier -- which correctly refuses to
     * let one machine run ahead of the other -- then had to hold it for 46 s
     * of a 60 s run.  With this, the sprint does not happen. */
    if (r->modeWasHeld) {
        r->modeWasHeld = false;
        if (r->realTime) rtpacer_resync(&r->rtPacer);
    }

    /* YAGPC_DUMPSTATE_AT=<sec>[,<sec>...] writes --dump-state's JSON the
     * first time simulated time passes each <sec>, without stopping the
     * run.  --dump-state alone fires only when the machine stops, and the
     * state worth having is often mid-flight: a BCE is only RUNNING
     * between the MSC's START I/O and the end of its bus program, so a
     * capture taken at an arbitrary stop finds every BCE idle and
     * busyWait naming the MSC alone.  Pick a time just after a
     * YAGPC_SIOTRACE line that names the processor you care about. */
    if (r->opts != NULL && r->opts->dumpState != NULL) {
        static int dsInit = 0;
        static double dsAt[8];
        static int dsN = 0, dsNext = 0;
        if (!dsInit) {
            dsInit = 1;
            const char *e = getenv("YAGPC_DUMPSTATE_AT");
            while (e != NULL && *e != '\0' && dsN < 8) {
                dsAt[dsN++] = atof(e);
                const char *c = strchr(e, ',');
                if (c == NULL) break;
                e = c + 1;
            }
        }
        /* YAGPC_DUMPSTATE_BUSY=<proc> instead catches the machine WHILE
         * that processor is running: 0 is the MSC, 1-24 are BCE 1-24.
         * Time cannot do this.  A display transaction is a START I/O
         * followed by a bus program lasting microseconds, after which the
         * BCE clears its own busy bit and its enable -- measured, a dump
         * taken 124 us after a BCE7 SIO already shows halt=MSC alone.
         * Firing on the busy bit is the only way to capture a BCE that is
         * actually mid-transfer. */
        static int dsBusyInit = 0, dsBusyProc = -1, dsBusyDone = 0;
        static double dsBusyAfterUs = 0.0;
        if (!dsBusyInit) {
            dsBusyInit = 1;
            const char *b = getenv("YAGPC_DUMPSTATE_BUSY");
            if (b != NULL && *b != '\0') {
                dsBusyProc = atoi(b);
                /* ",<afterSec>": the FIRST time a processor goes busy is
                 * not usually the one wanted.  GPCIPL's own IOP init
                 * starts every BCE at once (acc=7fffff80, t=6.1 s), long
                 * before the flight software's display transactions
                 * (acc=81000000, from t=109.7 s).  Without a floor the
                 * capture is of the loader, not of PASS. */
                const char *c = strchr(b, ',');
                if (c != NULL) dsBusyAfterUs = atof(c + 1) * 1e6;
            }
        }
        if (dsBusyProc >= 0 && !dsBusyDone &&
            r->age.gpc.cpu.elapsedTimeUs >= dsBusyAfterUs &&
            iop_proc_get(&r->age.gpc.iop.regBusyWait, dsBusyProc) &&
            iop_proc_get(&r->age.gpc.iop.regHalt, dsBusyProc)) {
            char path[512];
            snprintf(path, sizeof path, "%s-busy%d.json",
                     r->opts->dumpState, dsBusyProc);
            ageharness_dump_state(&r->age, path);
            /* AND THE MEMORY, AT THE SAME INSTANT.  A state and a snapshot
             * taken at two different times do not describe one machine:
             * the PSW, the registers and the BCE program counters all
             * refer to memory as it was when they were read.  Pairing them
             * here is what makes a resume reproduce the captured machine
             * rather than an average of two. */
            snprintf(path, sizeof path, "%s-busy%d.mem.bin",
                     r->opts->dumpState, dsBusyProc);
            dump_main_storage(r, path);
            dsBusyDone = 1;
        }
        if (dsNext < dsN &&
            r->age.gpc.cpu.elapsedTimeUs >= dsAt[dsNext] * 1e6) {
            char path[512];
            snprintf(path, sizeof path, "%s-%g.json",
                     r->opts->dumpState, dsAt[dsNext]);
            ageharness_dump_state(&r->age, path);
            snprintf(path, sizeof path, "%s-%g.mem.bin",
                     r->opts->dumpState, dsAt[dsNext]);
            dump_main_storage(r, path);
            dsNext++;
        }
    }

    /* DISASSEMBLING AND SNAPSHOTTING EVERY INSTRUCTION COSTS MORE THAN
     * EXECUTING IT.  instr_to_str() formats a string, the register file is
     * snapshotted twice and then diffed with a strcmp per register -- all
     * of it discarded unless a trace, a watchpoint or the debugger reads
     * it.  With it unconditional the emulator executed AP-101S code at
     * about half real time, so the simulated clock could not keep up with
     * the wall clock and the MEDS header clock lost a third of real time
     * (measured: 61 s of wall outside the wait state delivering 27 s of
     * simulated time).  Nothing here changes what the machine COMPUTES --
     * only whether it also narrates it. */
    const bool wantDetail = r->traceEnabled || r->debugMode ||
                            r->hasWatchpoints || range_trace_enabled();
    RegSnapshot before, after;
    if (wantDetail) ageharness_snapshot_regs(&r->age, &before);
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

    /* YAGPC_LANDMARKS: named addresses whose ARRIVAL is the result.
     *
     *     YAGPC_LANDMARKS="1c9f2:overlay-complete!,80ce:ioqe-sentinel!,\
     *                      80a8:cpu-idle" YAGPC_LANDMARKS_AFTER=380
     *
     * Each entry is <hex>[:label][!]; a trailing '!' means STOP THE RUN on
     * arrival.  YAGPC_LANDMARKS_AFTER=<sec> ignores every hit before that
     * simulated second, which is what makes the mechanism usable at all --
     * FPMIDLE, FIOCMPLT and the program-check handler are all reached
     * thousands of times during IPL, long before the question being asked.
     *
     * WHY.  The investigation this serves has spent whole 12-minute runs
     * producing a log from which a verdict then had to be INFERRED, and
     * the inferences have been wrong in both directions: a "read N blocks"
     * line that turned out to be emitted before any word left for the bus,
     * and six runs read as "transitioned and failed" that had in fact
     * never transitioned.  Arrival at a known address is not an inference.
     * Reaching the code that requests phase 18 means phase 8 finished,
     * whatever the logs look like.
     *
     * Every landmark's first arrival is reported with its simulated time
     * whether or not it stops the run, so one run yields the whole
     * sequence of landmarks passed, not just the first terminal one.  With
     * --dump-state, a stopping landmark dumps state AND memory at that
     * instant, which is the moment worth having. */
    {
        /* 64, the same ceiling --debug's own breakpoint table uses
         * (DEBUGGER_MAX_BREAKPOINTS, debugger.c).  --break, the third
         * mechanism, holds exactly one address and has no array at all. */
        enum { LM_MAX = 64 };
        static int lmInit = 0, lmN = 0;
        static uint32_t lmAddr[LM_MAX];
        static char lmLabel[LM_MAX][32];
        static long lmStop[LM_MAX];   /* 0 = never stop, N = stop on Nth hit */
        static long lmHits[LM_MAX];
        static double lmAfterUs = 0.0;
        /* Room for LM_MAX entries at a generous 48 chars each, so a full
         * set cannot be truncated mid-entry -- silent truncation would
         * leave a half-parsed hex address armed at the wrong place. */
        static char lmBuf[LM_MAX * 48];
        /* One test rejects almost every instruction: this check sits in the
         * per-instruction path, and a linear scan of 64 addresses there is
         * not free.  Indexed by the low 11 bits of the address; a set bit
         * only means "some landmark could have these low bits", and the
         * scan below then confirms. */
        static unsigned char lmMaybe[2048 / 8];
        if (!lmInit) {
            lmInit = 1;
            const char *e = getenv("YAGPC_LANDMARKS");
            const char *a = getenv("YAGPC_LANDMARKS_AFTER");
            if (a != NULL) lmAfterUs = atof(a) * 1e6;
            if (e != NULL) {
                if (strlen(e) >= sizeof lmBuf) {
                    fprintf(stderr, "landmarks: *** YAGPC_LANDMARKS is %zu "
                                    "bytes, over the %zu-byte limit -- "
                                    "REFUSING, none armed\n",
                            strlen(e), sizeof lmBuf - 1);
                    e = NULL;
                }
            }
            if (e != NULL) {
                snprintf(lmBuf, sizeof lmBuf, "%s", e);
                for (char *p = lmBuf; *p != '\0'; ) {
                    if (lmN >= LM_MAX) {
                        fprintf(stderr, "landmarks: *** more than %d given; "
                                        "the rest are NOT armed, starting at "
                                        "\"%s\"\n", LM_MAX, p);
                        break;
                    }
                    char *comma = p;
                    while (*comma != '\0' && *comma != ',') comma++;
                    char save = *comma;
                    *comma = '\0';
                    char *colon = strchr(p, ':');
                    const char *label = "";
                    if (colon != NULL) { *colon = '\0'; label = colon + 1; }
                    /* "<label>!"  stop on the first arrival
                     * "<label>!2" stop on the SECOND, and so on.  The Nth
                     * form is the one that matters here: FTRMGPOV is
                     * reached once when phase 3's overlay completes and
                     * again for phase 8, so "overlay-complete!2" is
                     * precisely the success condition. */
                    size_t ll = strlen(label);
                    long stop = 0;
                    const char *bang = strchr(label, '!');
                    if (bang != NULL) {
                        stop = (bang[1] != '\0') ? strtol(bang + 1, NULL, 10) : 1;
                        if (stop < 1) stop = 1;
                        ll = (size_t)(bang - label);
                    }
                    lmAddr[lmN] = (uint32_t)strtoul(p, NULL, 16);
                    snprintf(lmLabel[lmN], sizeof lmLabel[lmN], "%.*s",
                             (int)ll, label);
                    if (lmLabel[lmN][0] == '\0')
                        snprintf(lmLabel[lmN], sizeof lmLabel[lmN], "%05x",
                                 (unsigned)lmAddr[lmN]);
                    lmStop[lmN] = stop;
                    lmHits[lmN] = 0;
                    lmMaybe[(lmAddr[lmN] & 0x7ff) >> 3] |=
                        (unsigned char)(1u << (lmAddr[lmN] & 7));
                    lmN++;
                    p = (save == ',') ? comma + 1 : comma;
                }
                fprintf(stderr, "landmarks: %d of %d armed, ignored before "
                                "%.1f s\n", lmN, LM_MAX, lmAfterUs / 1e6);
                for (int i = 0; i < lmN; i++)
                    fprintf(stderr, "landmarks:   %05x %-24s %s\n",
                            (unsigned)lmAddr[i], lmLabel[i],
                            lmStop[i] ? "STOPS" : "logs only");
            }
        }
        if (lmN > 0 &&
            (lmMaybe[(nia & 0x7ff) >> 3] & (1u << (nia & 7))) != 0 &&
            r->age.gpc.cpu.elapsedTimeUs >= lmAfterUs) {
            for (int i = 0; i < lmN; i++) {
                if (nia != lmAddr[i]) continue;
                lmHits[i]++;
                /* Every arrival, not just the first, up to a bound: the
                 * COUNT is the result for a landmark like FTRMGPOV, and a
                 * first-hit-only line cannot express "reached twice". */
                if (lmHits[i] <= 20)
                    fprintf(stderr, "LANDMARK %s #%ld at %05x t=%.6f s step=%ld\n",
                            lmLabel[i], lmHits[i], (unsigned)nia,
                            r->age.gpc.cpu.elapsedTimeUs / 1e6, r->step);
                if (lmStop[i] != 0 && lmHits[i] >= lmStop[i]) {
                    if (r->opts != NULL && r->opts->dumpState != NULL) {
                        char path[512];
                        snprintf(path, sizeof path, "%s-landmark-%s.json",
                                 r->opts->dumpState, lmLabel[i]);
                        ageharness_dump_state(&r->age, path);
                        snprintf(path, sizeof path, "%s-landmark-%s.mem.bin",
                                 r->opts->dumpState, lmLabel[i]);
                        dump_main_storage(r, path);
                    }
                    snprintf(r->stopReason, sizeof r->stopReason,
                             "landmark %s hit %ld at 0x%05x (t=%.6f s)",
                             lmLabel[i], lmHits[i], (unsigned)nia,
                             r->age.gpc.cpu.elapsedTimeUs / 1e6);
                    r->hasStopReason = true;
                    return false;
                }
                break;
            }
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
    if (wantDetail) instr_to_str(hw1, hw2, disasm, sizeof disasm);
    else disasm[0] = '\0';
    /* The length is only ever printed, so it is only ever computed when
     * something is printing.  Whether the instruction decodes AT ALL is
     * answered by cpu_exec1() itself, after the fact (cpu.h decodeFailed)
     * -- decoding here as well doubled the single most expensive thing
     * the emulator does. */
    int instrLen = 1;
    if (wantDetail) {
        DInstr v;
        const InstrDesc *d = instr_decode(hw1, hw2, &v);
        if (d) instrLen = d->pb.origLen;
    }

    bool traceWanted = r->traceEnabled || (r->debugMode && debugger_wants_htrace(r->dbg));

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

    {
        bool paceStats = r->realTime && pace_trace_enabled();
        double execT0 = paceStats ? yagpc_monotonic_seconds() : 0.0;
        ap101_exec1(&r->age.gpc);
        if (paceStats)
            rtpacer_note_exec(&r->rtPacer, yagpc_monotonic_seconds() - execT0);
    }

    /* An instruction that did not decode executed as a no-op, so the NIA
     * has not moved and the machine would spin here forever.  Report it
     * exactly as the pre-decode check used to. */
    if (r->age.gpc.cpu.decodeFailed) {
        if (traceWanted) {
            char line[400];
            batchrunner_format_trace_line(r, r->step, nia, hw1, hw2, "??? (invalid)", 1, NULL, 0, line, sizeof line);
            batchrunner_write(r, line);
        }
        char hexv[16], niaHex[16];
        as_hex(hexv, sizeof hexv, (long long)hw1, 4);
        as_hex(niaHex, sizeof niaHex, (long long)nia, 4);
        cpu_dump_nia_ring(&r->age.gpc.cpu, "the invalid instruction",
                          psw_get_nia(&r->age.gpc.cpu.psw));
        snprintf(r->stopReason, sizeof r->stopReason,
                 "invalid instruction 0x%s at 0x%s", hexv, niaHex);
        r->hasStopReason = true;
        return false;
    }

    /* Drain the discrete bus periodically as well as on the reads
     * themselves.  The reads are what freshness actually depends on --
     * iop.c polls there, which is exactly when the value has to be
     * current -- but an image that seldom reads discretes would let
     * datagrams pile up in the socket buffer between reads, and would
     * show nothing at all under YAGPC_DISCRETETRACE while somebody was
     * flipping switches on a panel.  Every 1024 steps, so this is a
     * non-blocking syscall roughly a thousand times less often than an
     * instruction. */
    if (discretes_enabled(r->discretes) && (r->step & 0x3ff) == 0) {
        discretes_poll(r->discretes);
        /* And drive what this process's own devices put ON the bus.  The
         * mass memory's READY is a real line in the vehicle; publishing it
         * is what lets a crew panel show the tape working, and doubles as
         * the only outward sign that this emulator is running at all. */
        for (int u = 0; u < 2; u++)
            if (r->mmuModel[u]) mmumodel_publish_ready(r->mmuModel[u]);
    }

    /* The shared devices pace against the vehicle's clock, not this
     * machine's -- see vehicle.h.  Carry it forward here, once per
     * instruction, so a tape keeps turning for a computer that is IPLing
     * from it while another sits in reset. */
    if (r->vehicle != NULL) {
        vehicle_note_time(r->vehicle, r->age.gpc.cpu.elapsedTimeUs);
        /* And keep this machine within reach of the others in SIMULATED
         * time, which is the time the sync timeouts are measured in --
         * see the barrier note in vehicle.h. */
        vehicle_barrier_wait(r->vehicle, r->gpcId, r->age.gpc.cpu.elapsedTimeUs);
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
    /* SERVICE THE BUS SOCKETS ON SIMULATED TIME, NOT PER INSTRUCTION.
     * Draining and flushing every instruction meant 11 million passes over
     * the sockets in a 220 s run -- a rate set by how fast the CPU model
     * issues instructions, which has nothing to do with how fast the bus
     * moves.  A bus word takes about 20 us (YAGPC_BUS_WORD_US) and a BCE
     * samples its MIA buffer at most once every 16.5 us (BCE PoO 3.4.1),
     * so servicing every BUS_SERVICE_US of simulated time is still far
     * finer than anything on the bus can observe.  YAGPC_BUS_SERVICE_US=0
     * restores the per-instruction behaviour. */
    if (r->bceFramer) {
        double nowUs = r->age.gpc.cpu.elapsedTimeUs;
        if (nowUs - r->busServiceUs >= bus_service_us() || nowUs < r->busServiceUs) {
            r->busServiceUs = nowUs;
            bool busStats = r->realTime && pace_trace_enabled();
            double busT0 = busStats ? yagpc_monotonic_seconds() : 0.0;
            bcenet_framer_flush_tick(r->bceFramer);
            if (busStats)
                rtpacer_note_bus_service(&r->rtPacer, yagpc_monotonic_seconds() - busT0);
        }
    }

    RegChange filtered[REG_SNAPSHOT_MAX_CHANGES];
    int filteredCount = 0;
    if (wantDetail) {
        ageharness_snapshot_regs(&r->age, &after);
        range_trace(r, nia, hw1, hw2, disasm, &after);
        RegChange changes[REG_SNAPSHOT_MAX_CHANGES];
        int changeCount = ageharness_diff_regs(&before, &after, changes);
        for (int i = 0; i < changeCount; i++) {
            if (strcmp(changes[i].name, "NIA") != 0) filtered[filteredCount++] = changes[i];
        }
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
            double idleLoopW0 = yagpc_monotonic_seconds();
            double idleLoopS0 = r->age.gpc.cpu.elapsedTimeUs;
            RTPaceResult why;
            for (;;) {
                why = rtpacer_advance_idle(&r->rtPacer);
                /* The bus keeps running while the CPU waits, and its
                 * transmissions are paced against the wall clock, so they
                 * have to be released from here too -- the per-instruction
                 * flush below is never reached during a wait, which is
                 * where this machine spends most of its time. */
                if (r->bceFramer) bcenet_framer_flush_tick(r->bceFramer);
                /* THE BARRIER HAS TO BE SERVICED IN HERE TOO, and not only
                 * because this machine might get ahead: a wait state is
                 * where it spends most of its time, and a clock that stops
                 * being published for the length of one looks to the others
                 * like the slowest machine in the vehicle, frozen.  They
                 * would all stop to wait for it. */
                vehicle_barrier_wait(r->vehicle, r->gpcId,
                                     r->age.gpc.cpu.elapsedTimeUs);
                if (why != RTPACE_WAITING) break;
                /* Behind the wall clock?  Then do not sleep -- go round
                 * again and keep fast-forwarding until simulated time has
                 * caught up with real time.  Sleeping here is what made a
                 * wait state unable to repay a deficit. */
                if (rtpacer_ahead_ms(&r->rtPacer) < -RTPACE_CATCHUP_MS) continue;
                /* Ctrl-C has to be honoured here too: a paced wait can
                 * legitimately last seconds of wall time, and a loop that
                 * only checked between instructions would swallow it.
                 *
                 * STOP THE MACHINE, DO NOT EXIT THE PROCESS.  This used to
                 * call interactive_report_and_exit(), whose exit() is fatal
                 * to a vehicle: with several computers running, whichever
                 * thread happened to be in a wait state took the signal and
                 * ended the process from under the others, so the remaining
                 * machines were cut off mid-instruction and vehicle_free
                 * never ran -- no mass memory, timing unit or display
                 * reports at all, and no way to see what the run did.  A
                 * stop reason instead lands in the same reporting path as a
                 * fault, which is what the comment on the SIGINT handler
                 * says it is for. */
                if (g_sigint_received) {
                    snprintf(r->stopReason, sizeof r->stopReason,
                             "interrupted (SIGINT) after %ld steps in a wait state",
                             r->step);
                    r->hasStopReason = true;
                    rtpacer_note_idle_loop(&r->rtPacer,
                                           yagpc_monotonic_seconds() - idleLoopW0,
                                           (r->age.gpc.cpu.elapsedTimeUs - idleLoopS0) / 1e6);
                    return false;
                }
                yagpc_sleep_seconds(RTPACE_IDLE_POLL_SECONDS);
            }
            /* The wait carried the clock forward and serviced the IOP as
             * it went; without this the next instruction replays every
             * pass of it (see ap101_iop_resync). */
            ap101_iop_resync(&r->age.gpc);
            rtpacer_note_idle_loop(&r->rtPacer,
                                   yagpc_monotonic_seconds() - idleLoopW0,
                                   (r->age.gpc.cpu.elapsedTimeUs - idleLoopS0) / 1e6);
            if (why != RTPACE_RESUMED) {
                snprintf(r->stopReason, sizeof r->stopReason,
                         "wait state (%s)", rtpacer_result_name(why));
                r->hasStopReason = true;
                /* A wait-state stop reports WHERE the machine parked and
                 * nothing about how it got there, which is the one thing
                 * that matters: "masked" means a PSW was loaded with every
                 * system interrupt off, so the question is always which
                 * code did that.  The ring is already kept; dumping it
                 * here costs nothing and turns a dead end into a trail. */
                cpu_dump_nia_ring(&r->age.gpc.cpu, "the wait state",
                                  psw_get_nia(&r->age.gpc.cpu.psw));
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
            cpu_dump_nia_ring(&r->age.gpc.cpu, "the wait state",
                              psw_get_nia(&r->age.gpc.cpu.psw));
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
    if (r->opts != NULL && r->opts->dumpState != NULL)
        ageharness_dump_state(&r->age, r->opts->dumpState);
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

    /* OUT OF THE BARRIER THE MOMENT THIS MACHINE STOPS RUNNING, not later in
     * batchrunner_free: its clock has stopped, and a stopped clock is the
     * slowest in the vehicle.  Leaving it until the cleanup, which does not
     * happen until every thread has been joined, is a deadlock -- the other
     * machines wait for a computer that has finished. */
    vehicle_barrier_leave(r->vehicle, r->gpcId);

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
    if (r->opts != NULL && r->opts->dumpState != NULL)
        ageharness_dump_state(&r->age, r->opts->dumpState);
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
