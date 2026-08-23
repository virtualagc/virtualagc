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
        for (int i = 0; i <= 3; i++) {
            registerfile_set_dse(&gpc->cpu.regFiles[bank], i, 0);
        }
    }
    register_set32(&gpc->cpu.psw.psw1, 0);
    register_set32(&gpc->cpu.psw.psw2, 0);
}
