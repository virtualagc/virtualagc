#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ap101.h"

void ap101_init(AP101 *gpc) {
    cpu_init(&gpc->cpu);
    iop_init(&gpc->iop, &gpc->cpu);
    gpc->cpu.iop = &gpc->iop;
    gpc->ram = membus_create(&gpc->cpu.mainStorage);
    gpc->cpu.ram = &gpc->ram;
}

void ap101_free(AP101 *gpc) {
    cpu_free(&gpc->cpu);
    iop_free(&gpc->iop);
}

/* YAGPC_UNPROTECT=lo-hi with YAGPC_UNPROTECT_AT=<us> clears store
 * protection over a halfword range ONCE, when simulated time first reaches
 * that point.  It has to be timed: clearing at startup is undone by
 * GPCIPL's memory test, which walks all of store doing
 * unprotect/write/PROTECT, and refusing the protect outright makes that
 * test fail (it verifies protection actually works).  The moment that
 * matters is after the test and before the load -- exactly when FCMUPROT
 * would have cleared it, had the phase's RESERVED storage had a load block.
 * Diagnostic: the real repair belongs in the tape build. */
#define UNPROT_MAX 8
static void ap101_timed_unprotect(AP101 *gpc) {
    static int inited = 0, done = 0, nRanges = 0;
    static long lo[UNPROT_MAX], hi[UNPROT_MAX];
    static double atUs = 0.0;
    if (!inited) {
        const char *w = getenv("YAGPC_UNPROTECT");
        const char *t = getenv("YAGPC_UNPROTECT_AT");
        if (w != NULL && t != NULL) {
            const char *p = w;
            while (*p != '\0' && nRanges < UNPROT_MAX) {
                char *end = NULL;
                long a = strtol(p, &end, 16);
                long b = a;
                if (end != NULL && *end == '-') b = strtol(end + 1, &end, 16);
                lo[nRanges] = a; hi[nRanges] = b; nRanges++;
                if (end == NULL || *end != ',') break;
                p = end + 1;
            }
            atUs = atof(t);
        }
        inited = 1;
    }
    if (done || nRanges == 0 || gpc->cpu.elapsedTimeUs < atUs) return;
    done = 1;
    for (int i = 0; i < nRanges; i++) {
        for (long a = lo[i]; a <= hi[i]; a++)
            membus_set_store_protect(gpc->cpu.ram, (uint32_t)a, false);
        fprintf(stderr, "unprotect: %ld halfword(s) %05lx..%05lx at t=%.1f\n",
                hi[i] - lo[i] + 1, lo[i], hi[i], gpc->cpu.elapsedTimeUs);
    }
}

/* ---------------------------------------------------------------------
 * IOP pacing
 *
 * The IOP used to take exactly one slice per CPU instruction.  That is
 * right on average -- a CPU instruction and an IOP slice happen to run at
 * comparable rates -- but it is wrong for any instruction that takes much
 * longer than one, and MVH is the one that matters: FCMINSSL's FCMMOVE
 * moves 7,654 halfwords in a single instruction, charging about 6.7 ms of
 * POO time, during which the IOP got ONE slice.
 *
 * That cost the SSL a halfword.  It positions BCE 18 mid-gap on purpose --
 * FCMSSLBS computes its delay as 639 - partial, i.e. (511 - partial) plus
 * 128, "ONE HALF THE MMU BLOCK GAP IN HALF WORDS" -- so that the one-word
 * "CLEAR THE MIA BUFFER" #RDLI which follows executes inside the 256-word
 * inter-block gap, with nothing on the bus, and takes the stale word left
 * in the MIA buffer.  Frozen through the move, the BCE resumed 6.7 ms late,
 * the gap had passed, and the clear-read took the next block's first real
 * word instead.  The load block then landed one halfword out of phase and
 * failed its checksum.
 *
 * So the IOP is paced by SIMULATED TIME.  The rate is not invented:
 * iopls_next_slice() cycles 33 slices, giving each BCE one slice per
 * cycle, and the AP-101S manual's Part III (BCE POO) section 3.4.1 says
 * of a BCE sampling its MIA buffer that "the sampling process occurs at
 * most once every 16.5 usec".  16.5 / 33 = 0.5 us exactly, and 16.5 us is
 * already MTO_TICK_US.  A 2 MHz slice rate giving a 16.5 us per-BCE
 * sampling period is self-consistent, so that is the number used.
 *
 * Catching up in slice COUNT alone would not have fixed anything: what the
 * bus cares about is WHEN.  So each slice is taken with the clock set to
 * the time that slice actually falls at, and the CPU's own value restored
 * afterwards -- the IOP sees time advance THROUGH a long instruction
 * rather than jump to its end.
 *
 * Escape hatches, both off by default:
 *   YAGPC_IOP_PER_INSTR=1   restore the old one-slice-per-instruction model
 *   YAGPC_IOP_PASS_US=<f>   override the 0.5 us slice interval
 * ------------------------------------------------------------------- */
#define IOP_PASS_US_DEFAULT 0.5
/* A backstop, not a policy: 0.1 s of simulated time in one instruction. */
#define IOP_MAX_PASSES_PER_INSTR 200000

static double iop_pass_us(void) {
    static int inited = 0;
    static double us = IOP_PASS_US_DEFAULT;
    if (!inited) {
        const char *e = getenv("YAGPC_IOP_PASS_US");
        if (e != NULL) {
            double v = atof(e);
            if (v > 0.0) us = v;
        }
        inited = 1;
    }
    return us;
}

static int iop_per_instruction(void) {
    static int inited = 0, per = 0;
    if (!inited) { per = getenv("YAGPC_IOP_PER_INSTR") != NULL; inited = 1; }
    return per;
}

void ap101_iop_resync(AP101 *gpc) {
    if (gpc != NULL) gpc->iopNextPassUs = gpc->cpu.elapsedTimeUs;
}

static void ap101_step_iop(AP101 *gpc, double startUs) {
    if (iop_per_instruction()) { iop_exec(&gpc->iop); return; }
    double now = gpc->cpu.elapsedTimeUs;
    double passUs = iop_pass_us();
    if (gpc->iopNextPassUs <= 0.0) gpc->iopNextPassUs = startUs;
    int n = 0;
    while (gpc->iopNextPassUs <= now && n < IOP_MAX_PASSES_PER_INSTR) {
        gpc->cpu.elapsedTimeUs = gpc->iopNextPassUs;   /* the IOP's view */
        iop_exec(&gpc->iop);
        gpc->iopNextPassUs += passUs;
        n++;
    }
    gpc->cpu.elapsedTimeUs = now;
    if (n >= IOP_MAX_PASSES_PER_INSTR) gpc->iopNextPassUs = now;
}

/* YAGPC_PATCH applies halfword writes at a given simulated time, e.g.
 *   YAGPC_PATCH="5000000:7c03=006f,7c04=0009;18700000:009c=47e0"
 * Groups are separated by ';', each is "<timeUs>:<addr>=<val>,...", all
 * hex except the time.  Writes bypass store protection, because the point
 * is to stand in for something the ground Mass Memory Build would have
 * written into the image before the machine ever ran.  Diagnostic only. */
/* YAGPC_POISON fills halfword RANGES with a known value at a given
 * simulated time, e.g.
 *   YAGPC_POISON="386:04020-0421f=dead,0a000-0a1ff=dead"
 * Groups are separated by ';', each is "<timeSec>:<lo>-<hi>=<val>,...",
 * addresses and value hex, time in seconds.  Writes bypass store
 * protection, like YAGPC_PATCH, and for the same reason.
 *
 * WHY A RANGE FILL AND NOT YAGPC_PATCH.  The question it exists for is
 * "did the loader WRITE here, or did memory merely already hold the right
 * value" -- and for blocks that are zeros or a repeating fill pattern, no
 * amount of comparing content can answer it, because the answer looks the
 * same either way.  Poisoning the destination first turns that into a
 * direct measurement: if the poison is gone the loader wrote, if it
 * survives the loader did not, and if it is replaced by something that is
 * neither the poison nor the tape's bytes then the loader wrote something
 * TRANSFORMED.  That last case is invisible to a content search, which is
 * why 24 phase-8 blocks came back "not found anywhere" with no way to tell
 * absence from transformation.  A patch list of 64 halfwords cannot do it;
 * one block alone is 512. */
#define POISON_MAX_GROUPS 4
#define POISON_MAX_RANGES 64
static void ap101_timed_poison(AP101 *gpc) {
    static int inited = 0, nGroups = 0;
    static double atUs[POISON_MAX_GROUPS];
    static int done[POISON_MAX_GROUPS];
    static int nR[POISON_MAX_GROUPS];
    static uint32_t lo[POISON_MAX_GROUPS][POISON_MAX_RANGES];
    static uint32_t hi[POISON_MAX_GROUPS][POISON_MAX_RANGES];
    static uint32_t val[POISON_MAX_GROUPS][POISON_MAX_RANGES];
    if (!inited) {
        inited = 1;
        const char *e = getenv("YAGPC_POISON");
        while (e != NULL && *e != '\0' && nGroups < POISON_MAX_GROUPS) {
            char *end = NULL;
            atUs[nGroups] = strtod(e, &end) * 1e6;
            if (end == NULL || *end != ':') break;
            const char *p2 = end + 1;
            nR[nGroups] = 0;
            while (*p2 != '\0' && *p2 != ';' && nR[nGroups] < POISON_MAX_RANGES) {
                uint32_t a = (uint32_t)strtoul(p2, &end, 16);
                if (end == p2 || *end != '-') break;
                p2 = end + 1;
                uint32_t b = (uint32_t)strtoul(p2, &end, 16);
                if (end == p2 || *end != '=') break;
                p2 = end + 1;
                uint32_t v = (uint32_t)strtoul(p2, &end, 16);
                if (end == p2) break;
                lo[nGroups][nR[nGroups]] = a;
                hi[nGroups][nR[nGroups]] = b;
                val[nGroups][nR[nGroups]] = v;
                nR[nGroups]++;
                p2 = end;
                if (*p2 == ',') p2++;
            }
            done[nGroups] = 0;
            nGroups++;
            const char *semi = strchr(e, ';');
            if (semi == NULL) break;
            e = semi + 1;
        }
        if (nGroups > 0)
            fprintf(stderr, "poison: %d group(s) armed\n", nGroups);
    }
    for (int g = 0; g < nGroups; g++) {
        if (done[g] || gpc->cpu.elapsedTimeUs < atUs[g]) continue;
        done[g] = 1;
        long n = 0;
        for (int i = 0; i < nR[g]; i++) {
            for (uint32_t a = lo[g][i]; a <= hi[g][i]; a++) {
                mcm_set16(&gpc->cpu.mainStorage, a, val[g][i], false);
                n++;
            }
        }
        fprintf(stderr, "poison: group %d wrote %ld halfword(s) in %d range(s) "
                        "at t=%.6f s\n", g, n, nR[g],
                gpc->cpu.elapsedTimeUs / 1e6);
    }
}

#define PATCH_MAX_GROUPS 8
#define PATCH_MAX_WRITES 64
static void ap101_timed_patch(AP101 *gpc) {
    static int inited = 0, nGroups = 0;
    static double atUs[PATCH_MAX_GROUPS];
    static int done[PATCH_MAX_GROUPS];
    static int nW[PATCH_MAX_GROUPS];
    static uint32_t addr[PATCH_MAX_GROUPS][PATCH_MAX_WRITES];
    static uint32_t val[PATCH_MAX_GROUPS][PATCH_MAX_WRITES];
    if (!inited) {
        inited = 1;
        const char *e = getenv("YAGPC_PATCH");
        while (e != NULL && *e != '\0' && nGroups < PATCH_MAX_GROUPS) {
            char *end = NULL;
            atUs[nGroups] = strtod(e, &end);
            if (end == NULL || *end != ':') break;
            const char *p2 = end + 1;
            nW[nGroups] = 0;
            while (*p2 != '\0' && *p2 != ';' && nW[nGroups] < PATCH_MAX_WRITES) {
                uint32_t a = (uint32_t)strtoul(p2, &end, 16);
                if (end == NULL || *end != '=') break;
                uint32_t v = (uint32_t)strtoul(end + 1, &end, 16);
                addr[nGroups][nW[nGroups]] = a;
                val[nGroups][nW[nGroups]] = v;
                nW[nGroups]++;
                if (end == NULL || *end != ',') { p2 = end; break; }
                p2 = end + 1;
            }
            done[nGroups] = 0;
            nGroups++;
            if (p2 == NULL || *p2 != ';') break;
            e = p2 + 1;
        }
    }
    for (int g = 0; g < nGroups; g++) {
        if (done[g] || gpc->cpu.elapsedTimeUs < atUs[g]) continue;
        done[g] = 1;
        for (int i = 0; i < nW[g]; i++) {
            mcm_set16(&gpc->cpu.mainStorage, addr[g][i], val[g][i], false);
            fprintf(stderr, "patch: %05x <- %04x at t=%.1f\n",
                    (unsigned)addr[g][i], (unsigned)val[g][i],
                    gpc->cpu.elapsedTimeUs);
        }
    }
}

/* YAGPC_LOADBIN="<timeUs>:<hexAddr>:<path>[;<timeUs>:<hexAddr>:<path>...]"
 * loads raw big-endian halfword images into main storage at those simulated
 * times, bypassing store protection.  Each stands in for something the tape
 * build should have written and did not.
 *
 * It began as one image -- PHASE02's FCMPSA, which mmbstamp drops as Z1 pool
 * area -- and one was not enough: the ground Mass Memory Build stamps the
 * phase tables as a SET (#PFCMGPT, #PCDCPHA, FCMG3DAT), and standing in for
 * part of a set only moves the failure.  Diagnostic only. */
#define LOADBIN_MAX 8
static void ap101_timed_loadbin(AP101 *gpc) {
    static int inited = 0;
    static int count = 0;
    static double atUs[LOADBIN_MAX];
    static uint32_t base[LOADBIN_MAX];
    static uint8_t *buf[LOADBIN_MAX];
    static long len[LOADBIN_MAX];
    static int done[LOADBIN_MAX];
    if (!inited) {
        inited = 1;
        const char *e = getenv("YAGPC_LOADBIN");
        while (e != NULL && *e != '\0' && count < LOADBIN_MAX) {
            char path[512];
            double t; unsigned a;
            /* %511[^;] so a path is not cut short at the separator. */
            if (sscanf(e, "%lf:%x:%511[^;]", &t, &a, path) == 3) {
                FILE *f = fopen(path, "rb");
                if (f != NULL) {
                    fseek(f, 0, SEEK_END); len[count] = ftell(f);
                    fseek(f, 0, SEEK_SET);
                    buf[count] = malloc((size_t)len[count]);
                    if (buf[count] == NULL ||
                        fread(buf[count], 1, (size_t)len[count], f)
                            != (size_t)len[count]) len[count] = 0;
                    fclose(f);
                    atUs[count] = t; base[count] = a; done[count] = 0;
                    count++;
                } else {
                    fprintf(stderr, "loadbin: cannot open %s\n", path);
                }
            }
            const char *semi = strchr(e, ';');
            e = (semi != NULL) ? semi + 1 : NULL;
        }
    }
    for (int i = 0; i < count; i++) {
        if (done[i] || buf[i] == NULL || len[i] == 0) continue;
        if (gpc->cpu.elapsedTimeUs < atUs[i]) continue;
        done[i] = 1;
        for (long k = 0; k + 1 < len[i]; k += 2)
            mcm_set16(&gpc->cpu.mainStorage, base[i] + (uint32_t)(k / 2),
                      ((uint32_t)buf[i][k] << 8) | buf[i][k + 1], false);
        fprintf(stderr, "loadbin: %ld halfwords at %05x, t=%.1f\n",
                len[i] / 2, (unsigned)base[i], gpc->cpu.elapsedTimeUs);
    }
}


/* YAGPC_SNAPSHOT=<t1>[,<t2>...]:<prefix> writes the whole of main storage,
 * big-endian halfwords, to <prefix>-<t>.bin the first time simulated time
 * passes each t (in SECONDS).  A raw image is what lets the FCOS control
 * blocks -- PCTs, TQEs, the CVT, the compools -- be read offline with a
 * script instead of guessed at from a trace, which is how the PCT table
 * was finally located.  Times must be given in increasing order. */
static void ap101_timed_snapshot(AP101 *gpc) {
    static int inited = 0;
    static double times[16];
    static int nTimes = 0, next = 0;
    static char prefix[400];
    if (!inited) {
        inited = 1;
        const char *e = getenv("YAGPC_SNAPSHOT");
        if (e != NULL) {
            const char *colon = strrchr(e, ':');
            if (colon != NULL) {
                snprintf(prefix, sizeof(prefix), "%s", colon + 1);
                const char *p = e;
                while (p < colon && nTimes < 16) {
                    times[nTimes++] = atof(p);
                    const char *comma = strchr(p, ',');
                    if (comma == NULL || comma > colon) break;
                    p = comma + 1;
                }
            }
        }
    }
    if (next >= nTimes) return;
    if (gpc->cpu.elapsedTimeUs < times[next] * 1e6) return;
    char path[512];
    snprintf(path, sizeof(path), "%s-%g.bin", prefix, times[next]);
    FILE *f = fopen(path, "wb");
    if (f != NULL) {
        int hw = gpc->cpu.mainStorage.wordCount * 2;
        for (int a = 0; a < hw; a++) {
            uint32_t v = mcm_get16(&gpc->cpu.mainStorage, (uint32_t)a);
            fputc((int)((v >> 8) & 0xff), f);
            fputc((int)(v & 0xff), f);
        }
        fclose(f);
        fprintf(stderr, "snapshot: %s at t=%.3f s (%d halfwords)\n",
                path, gpc->cpu.elapsedTimeUs / 1e6, hw);
        iop_dump_procs(&gpc->iop);
    } else {
        fprintf(stderr, "snapshot: cannot write %s\n", path);
    }
    next++;
}

/* YAGPC_TRACEWIN=<from>-<to>:<path> writes one line per instruction
 * executed between those two simulated SECONDS.  A window is the only
 * usable form for this machine: an unconditional trace is millions of
 * lines a second, while the questions that need it -- "what did the CPU
 * do in the 38 ms between enabling the BCEs and never starting them" --
 * are always about a known, short interval. */
static void ap101_timed_trace(AP101 *gpc) {
    static int inited = 0;
    static double from = -1, to = -1;
    static FILE *f = NULL;
    if (!inited) {
        inited = 1;
        const char *e = getenv("YAGPC_TRACEWIN");
        if (e != NULL) {
            char path[400];
            if (sscanf(e, "%lf-%lf:%399s", &from, &to, path) == 3)
                f = fopen(path, "w");
        }
    }
    if (f == NULL) return;
    double t = gpc->cpu.elapsedTimeUs / 1e6;
    if (t < from) return;
    if (t > to) { fclose(f); f = NULL; return; }
    fprintf(f, "%.6f %05x\n", t, (unsigned)psw_get_nia(&gpc->cpu.psw));
}

/* YAGPC_TRACETRIG=<hexaddr>:<hexfullword>:<count>:<path> starts the same
 * per-instruction trace the moment that fullword first holds that value,
 * and runs it for <count> instructions.  A time window cannot catch an
 * event whose timing moves between runs -- TCVTBCEB going to 0x0f00
 * lands anywhere across a third of a second -- so the trigger is the
 * state itself. */
static void ap101_trig_trace(AP101 *gpc) {
    static int inited = 0, armed = 0;
    static uint32_t addr = 0, want = 0;
    static long count = 0;
    static FILE *f = NULL;
    if (!inited) {
        inited = 1;
        const char *e = getenv("YAGPC_TRACETRIG");
        if (e != NULL) {
            char path[400];
            unsigned a, v; long n;
            if (sscanf(e, "%x:%x:%ld:%399s", &a, &v, &n, path) == 4) {
                addr = a; want = v; count = n; f = fopen(path, "w");
            }
        }
    }
    if (f == NULL) return;
    if (!armed) {
        if (mcm_get32(&gpc->cpu.mainStorage, addr) != want) return;
        armed = 1;
        fprintf(f, "* trigger %05x=%08x at t=%.6f\n", (unsigned)addr,
                (unsigned)want, gpc->cpu.elapsedTimeUs / 1e6);
    }
    if (count-- <= 0) { fclose(f); f = NULL; return; }
    fprintf(f, "%.6f %05x %08x", gpc->cpu.elapsedTimeUs / 1e6,
            (unsigned)psw_get_nia(&gpc->cpu.psw),
            (unsigned)mcm_get32(&gpc->cpu.mainStorage, addr));
    for (int i = 0; i < 8; i++)
        fprintf(f, " %08x", (unsigned)register_get32(cpu_r(&gpc->cpu, i)));
    fprintf(f, "\n");
}

/* YAGPC_PCCOUNT=<hexaddr>[,<hexaddr>...] counts how many times each of those
 * halfword addresses is about to execute, with the simulated time of the first
 * and last visit, and prints the table when the run ends.
 *
 * This exists because the questions that matter about a stalled overlay are
 * counting questions -- was FCMMGPOV entered twice or three times, was
 * FIOMGCMP entered at all -- and the only tools for them were a window trace
 * (60 MB for five seconds, and it has to be aimed at a time that moves between
 * runs) and YAGPC_SVCTRACE (which printed so much it dropped the emulator to a
 * third of real time and the run was killed before it reached the event).  A
 * sorted array of at most 32 addresses costs a binary search per instruction
 * and answers those questions in an otherwise ordinary run. */
#define PCCOUNT_MAX 32
#define PCCOUNT_BINS 32          /* one-second bins, YAGPC_PCCOUNT_BINS=lo-hi */
typedef struct { uint32_t addr; long hits; double first, last; long bin[PCCOUNT_BINS]; } PcCount;
static PcCount g_pcCount[PCCOUNT_MAX];
static int g_binLo = -1, g_binHi = -1;
static int g_nPcCount = -1;

void ap101_pccount_report(void) {
    if (g_nPcCount <= 0) return;
    fprintf(stderr, "PCCOUNT:\n");
    for (int i = 0; i < g_nPcCount; i++)
        fprintf(stderr, "  %05x  hits=%-9ld first=%-10.3f last=%.3f\n",
                (unsigned)g_pcCount[i].addr, g_pcCount[i].hits,
                g_pcCount[i].first, g_pcCount[i].last);
    /* first/last alone cannot tell "ran steadily to the end" from "ran hard
     * early and twice more later", and that ambiguity cost a wrong reading of
     * whether FIOSTMSC keeps waking the MSC through an overlay.  The bins say
     * which. */
    if (g_binLo < 0) return;
    fprintf(stderr, "PCCOUNT per second, t=%d..%d:\n", g_binLo, g_binHi);
    fprintf(stderr, "   addr ");
    for (int t = g_binLo; t <= g_binHi; t++) fprintf(stderr, "%6d", t);
    fprintf(stderr, "\n");
    for (int i = 0; i < g_nPcCount; i++) {
        fprintf(stderr, "  %05x", (unsigned)g_pcCount[i].addr);
        for (int t = g_binLo; t <= g_binHi; t++)
            fprintf(stderr, "%6ld", g_pcCount[i].bin[t - g_binLo]);
        fprintf(stderr, "\n");
    }
}

static void ap101_pc_count(AP101 *gpc) {
    if (g_nPcCount < 0) {
        g_nPcCount = 0;
        const char *e = getenv("YAGPC_PCCOUNT");
        for (const char *p = e; p != NULL && *p && g_nPcCount < PCCOUNT_MAX; ) {
            char *end = NULL;
            unsigned long a = strtoul(p, &end, 16);
            if (end == p) break;
            g_pcCount[g_nPcCount].addr = (uint32_t)a;
            g_pcCount[g_nPcCount].hits = 0;
            g_nPcCount++;
            p = (*end == ',') ? end + 1 : end;
        }
        /* Sorted so the per-instruction test is a binary search.  Insertion
         * sort: the list is at most 32 entries and is built once. */
        for (int i = 1; i < g_nPcCount; i++) {
            for (int j = i; j > 0 && g_pcCount[j - 1].addr > g_pcCount[j].addr; j--) {
                PcCount t = g_pcCount[j];
                g_pcCount[j] = g_pcCount[j - 1];
                g_pcCount[j - 1] = t;
            }
        }
        const char *bw = getenv("YAGPC_PCCOUNT_BINS");
        if (bw != NULL) {
            int a = 0, b = 0;
            if (sscanf(bw, "%d-%d", &a, &b) == 2 && b >= a &&
                b - a < PCCOUNT_BINS) { g_binLo = a; g_binHi = b; }
        }
        if (g_nPcCount > 0) atexit(ap101_pccount_report);
    }
    if (g_nPcCount == 0) return;
    uint32_t nia = (uint32_t)psw_get_nia(&gpc->cpu.psw);
    int lo = 0, hi = g_nPcCount - 1;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (g_pcCount[mid].addr == nia) {
            double t = gpc->cpu.elapsedTimeUs / 1e6;
            if (g_pcCount[mid].hits == 0) g_pcCount[mid].first = t;
            g_pcCount[mid].last = t;
            g_pcCount[mid].hits++;
            if (g_binLo >= 0 && t >= g_binLo && t <= g_binHi)
                g_pcCount[mid].bin[(int)t - g_binLo]++;
            return;
        }
        if (g_pcCount[mid].addr < nia) lo = mid + 1; else hi = mid - 1;
    }
}

void ap101_exec1(AP101 *gpc) {
    ap101_timed_unprotect(gpc);
    ap101_timed_snapshot(gpc);
    ap101_pc_count(gpc);
    ap101_timed_trace(gpc);
    ap101_trig_trace(gpc);
    ap101_timed_patch(gpc);
    ap101_timed_poison(gpc);
    ap101_timed_loadbin(gpc);
    /* YAGPC_NIAPROBE=<hexaddr> dumps R0-R7 and the SSL's two context-struct
     * indices every time that address is about to execute.  Unlike --break
     * it does not stop, so it yields one line per VISIT, which is what
     * distinguishes "reached once" from "reached per load block" -- the
     * question that located the FCMMOVE odd-struct defect.  The env lookup
     * is cached because this is the per-instruction hot path. */
    static int probeInit = 0;
    static long probeAddr = -1;
    if (!probeInit) {
        const char *probe = getenv("YAGPC_NIAPROBE");
        probeAddr = probe ? (long)strtoul(probe, NULL, 16) : -1;
        probeInit = 1;
    }
    if (probeAddr >= 0) {
        {
            unsigned nia = (unsigned)psw_get_nia(&gpc->cpu.psw);
            if ((long)nia == probeAddr) {
                fprintf(stderr, "NIAPROBE nia=%05x bsr=%u dsr=%u", nia,
                        (unsigned)psw_get_bsr(&gpc->cpu.psw),
                        (unsigned)psw_get_dsr(&gpc->cpu.psw));
                for (int i = 0; i < 8; i++)
                    fprintf(stderr, " R%d=%08x", i,
                            (unsigned)register_get32(cpu_r(&gpc->cpu, i)));
                if (getenv("YAGPC_SSLDUMP")) {
                    static const struct { const char *n; unsigned a, len; } B[] = {
                        {"FCMIBLK1", 0x72f2, 20}, {"FCMIBLK2", 0x7306, 20},
                        {"FCMINSST", 0x731a, 2},  {"FCMRSADD", 0x7320, 6},
                        {"FCMNEXTB", 0x7346, 3} };
                    for (unsigned b = 0; b < 5; b++) {
                        fprintf(stderr, "\n   %s @%05x:", B[b].n, B[b].a);
                        for (unsigned i = 0; i < B[b].len; i++)
                            fprintf(stderr, " %04x",
                                mcm_get16(&gpc->cpu.mainStorage, B[b].a + i));
                    }
                    fprintf(stderr, "\n  ");
                }
                fprintf(stderr, " NEXTS=%04x CURRS=%04x\n",
                        mcm_get16(&gpc->cpu.mainStorage, 0x7347),
                        mcm_get16(&gpc->cpu.mainStorage, 0x7348));
            }
        }
    }
    double startUs = gpc->cpu.elapsedTimeUs;
    cpu_exec1(&gpc->cpu);
    ap101_step_iop(gpc, startUs);
}

void ap101_tick(AP101 *gpc) {
    /* The IOP RUNS DURING WAIT, and it has to.  Instruction fetch is what
     * the wait state suspends; the I/O processor is a separate machine
     * that keeps executing its own MSC/BCE streams underneath, and a
     * peripheral answering on a bus is one of the things that ENDS the
     * wait -- GPCIPL parks here and expects the mass memory to wake it.
     *
     * This used to advance only the CPU-side clock, on the grounds that
     * letting the IOP run untethered from CPU instructions had been seen
     * to corrupt CPU memory (GPCIPL's own program-check dispatch table).
     * That corruption was real but it was not the pairing: #SSC and #SST
     * were computing an absolute address from a raw displacement and
     * storing BCE status straight through the PSA -- see iop_bce_instr.c.
     * With that fixed the IOP is safe to step here, and not stepping it
     * is what leaves a WAIT unwakeable: with the IOP frozen no bus
     * traffic can happen, so nothing can ever raise the interrupt the
     * software is waiting for, and the run stops declaring "wait state"
     * when the machine was simply waiting for I/O it was never given. */
    cpu_tick(&gpc->cpu);
    iop_exec(&gpc->iop);
}

void ap101_set_servicer(AP101 *gpc, GpcServicerFn fn, void *servicerCtx) {
    iop_set_servicer(&gpc->iop, fn, servicerCtx);
}

/* POO 2.5.3's system reset sequence, CPU and I/O channels together -- what
 * an IPL does first, whatever the machine was doing.  Unlike ap101_reset,
 * which zeroes registers and the PSW for a harness restart, this is the
 * hardware function and touches only what the manual says it resets. */
void ap101_system_reset(AP101 *gpc) {
    cpu_system_reset(&gpc->cpu);
    iop_system_reset(&gpc->iop);
}

void ap101_reset(AP101 *gpc) {
    for (int bank = 0; bank <= 2; bank++) {
        for (int i = 0; i <= 7; i++) {
            register_set32(registerfile_r(&gpc->cpu.regFiles[bank], i), 0);
        }
    }
    for (int bank = 0; bank <= 1; bank++) {
        for (int i = 0; i <= 7; i++) {
            registerfile_set_dse(&gpc->cpu.regFiles[bank], i, 0);
        }
    }
    register_set32(&gpc->cpu.psw.psw1, 0);
    register_set32(&gpc->cpu.psw.psw2, 0);
}
