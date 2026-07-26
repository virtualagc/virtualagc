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
