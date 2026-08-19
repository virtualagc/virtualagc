#include "ap101.h"

void ap101_init(AP101 *gpc) {
    cpu_init(&gpc->cpu);
    iop_init(&gpc->iop, &gpc->cpu);
    gpc->cpu.iop = &gpc->iop;
    gpc->ram = membus_create(&gpc->cpu.mainStorage, &gpc->iop.mainStorage);
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
    /* CPU-side clock/interrupt advance only -- deliberately does NOT also
     * call iop_exec() the way ap101_exec1() does. ap101_exec1() steps the
     * IOP once per CPU *instruction*, an emulator-level 1:1 pairing this
     * codebase has always relied on; batchrunner_step()'s WAIT-tick loop
     * (see run.c) can call this many times with no CPU instruction ever
     * executing in between, so pairing it with iop_exec() here would let
     * the IOP's own independent MSC/BCE instruction stream run far ahead
     * of anything that pairing was ever validated for -- confirmed to
     * actually happen and corrupt unrelated CPU memory (BILDNEW5/GPCIPL's
     * PCHINTH/PCHERLST program-check dispatch table, INTHNDLR.asm) the
     * first time this was tried with iop_exec() included. */
    cpu_tick(&gpc->cpu);
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
