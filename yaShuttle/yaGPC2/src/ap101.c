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

void ap101_exec1(AP101 *gpc) {
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
                fprintf(stderr, " NEXTS=%04x CURRS=%04x\n",
                        mcm_get16(&gpc->cpu.mainStorage, 0x7347),
                        mcm_get16(&gpc->cpu.mainStorage, 0x7348));
            }
        }
    }
    cpu_exec1(&gpc->cpu);
    iop_exec(&gpc->iop);
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
