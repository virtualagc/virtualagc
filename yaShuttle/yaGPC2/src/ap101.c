#include <stdlib.h>
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

void ap101_exec1(AP101 *gpc) {
    ap101_timed_unprotect(gpc);
    ap101_timed_patch(gpc);
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
                fprintf(stderr, "NIAPROBE nia=%05x", nia);
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
